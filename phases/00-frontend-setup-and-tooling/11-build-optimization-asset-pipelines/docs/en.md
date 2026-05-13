# Build Optimization & Asset Pipelines

> Shipping less JavaScript is always faster than optimizing the JavaScript you ship.

**Type:** Build
**Languages:** JavaScript
**Prerequisites:** Lessons 09 and 10
**Time:** ~75 minutes

## The Problem

A developer ships a React app and the initial JavaScript bundle is 2.1 MB. Users on mobile connections wait 8 seconds before the page becomes interactive. The developer imported `lodash` for a single `_.debounce` call, and the entire 70 KB library landed in the bundle — a 150-byte inline function would have done the same job.

A charting library used only on the admin dashboard still loads for every logged-out visitor on the landing page. The library is 400 KB on its own. The developer knows about lazy loading but assumed the bundler handled it automatically — it does not. Code splitting requires an explicit dynamic `import()` call.

Code the team deleted six months ago is still in the bundle. The module had a top-level side effect (`window.analytics = ...`) that prevented the bundler's dead code elimination from removing it. Tree-shaking is not magic: it requires ES modules and modules that declare no side effects.

## The Concept

**The four main build optimizations:**

| Optimization | What it does | Who triggers it |
|---|---|---|
| Tree-shaking | Removes exports that are never imported | Bundler, automatically, if modules are side-effect-free |
| Code splitting | Breaks the bundle into chunks loaded on demand | Developer, via dynamic `import()` |
| Minification | Removes whitespace, shortens identifiers | Bundler, automatically in production mode |
| Asset optimization | Compresses images, subsets fonts | Bundler plugins (e.g., vite-imagetools) |

**Bundler vs transpiler** — these are different tools that are often confused:

- A **bundler** (Vite, Webpack, Rollup) resolves module imports, combines files, and produces output chunks.
- A **transpiler** (SWC, Babel) converts new JavaScript syntax to older syntax a browser can run. Vite uses SWC internally via `@vitejs/plugin-react-swc`.

Vite is both: it uses Rollup as its bundler and SWC as its transpiler.

**Dynamic `import()` as the code-splitting hook:**

```
Static import (always loaded):
  import { HeavyChart } from "./HeavyChart"
  └─> HeavyChart code is in the initial bundle

Dynamic import (loaded on demand):
  const HeavyChart = lazy(() => import("./HeavyChart"))
  └─> HeavyChart code is in a separate chunk
      fetched only when the component renders
```

**Bundle anatomy after splitting:**

```
dist/
├── index.html
└── assets/
    ├── index-[hash].js      <-- initial chunk (your app shell)
    ├── vendor-[hash].js     <-- manual chunk (React, react-dom)
    └── HeavyChart-[hash].js <-- lazy chunk (loaded on demand)
```

The hash in each filename is derived from file content. When you ship a new build, only the chunks that changed get new hashes — the browser reuses cached chunks for everything else.

## Build It

### Step 1: Create `vite.config.ts`

Copy `code/vite.config.ts` to your project root:

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    target: "es2020",
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ["react", "react-dom"],
        },
      },
    },
  },
});
```

`sourcemap: true` produces `.map` files alongside the bundle so that error stack traces in production point to original source lines rather than minified identifiers.

### Step 2: Run the build and inspect output

```bash
pnpm build
ls -lh dist/assets/
```

Note the file names, sizes, and hashes. Every `.js` file is a chunk. The vendor chunk should contain React. The index chunk should contain your application code.

### Step 3: Add `manualChunks` and compare sizes

The `manualChunks` option in `rollupOptions` tells Rollup to put specific packages into named chunks. Before adding it, React ships inside the index chunk alongside your app. After adding it:

```
Before:  index-abc123.js  890 KB  (app + React)
After:   index-def456.js  120 KB  (app only)
         vendor-ghi789.js 150 KB  (React + react-dom)
```

The total size is similar, but the index chunk is now much smaller — which is what the browser downloads on first load before it can serve anything to the user.

### Step 4: Implement lazy loading

Use `code/lazy-example.tsx` as the pattern:

```tsx
import { lazy, Suspense } from "react";

const HeavyChart = lazy(() => import("./HeavyChart"));

export function Dashboard() {
  return (
    <Suspense fallback={<div>Loading chart...</div>}>
      <HeavyChart />
    </Suspense>
  );
}
```

`React.lazy` wraps a dynamic `import()`. The component is fetched over the network when it is first rendered. `Suspense` provides the loading state while the chunk is in flight. Run `pnpm build` again — the chart code appears as a separate chunk.

### Step 5: Generate a bundle treemap

Install and configure `rollup-plugin-visualizer`:

```bash
pnpm add -D rollup-plugin-visualizer
```

Add it to `vite.config.ts`:

```ts
import { visualizer } from "rollup-plugin-visualizer";

export default defineConfig({
  plugins: [
    react(),
    visualizer({ open: true, filename: "bundle-stats.html" }),
  ],
});
```

Run `pnpm build`. A treemap opens in the browser showing every module sized by its contribution to the bundle. Large rectangles are candidates for lazy loading or replacement with lighter alternatives.

## Use It

Next.js App Router does code splitting automatically per route segment. Each `page.tsx` file becomes its own chunk — no dynamic `import()` needed. For components within a page, Next.js provides `next/dynamic`, which wraps React's `lazy` with SSR awareness:

```ts
import dynamic from "next/dynamic";

const HeavyChart = dynamic(() => import("./HeavyChart"), {
  ssr: false,
  loading: () => <div>Loading chart...</div>,
});
```

`ssr: false` skips rendering the component on the server entirely, which is correct for browser-only libraries. Vite's `React.lazy` does not have this option because Vite apps are client-side by default.

The difference from manual `manualChunks`: Next.js handles vendor splitting automatically; with Vite you configure it explicitly.

## Ship It

The `vite.config.ts` in `code/` is a baseline for new Vite projects. It includes the vendor split, source maps, and the path alias from Lesson 10. Drop it into any new project before the first commit and adjust `manualChunks` as dependencies grow.

## Exercises

1. Add `rollup-plugin-visualizer` to the Vite config and run `pnpm build`. Open the treemap and identify the three largest modules. Write down what each one does and whether it could be lazy-loaded or replaced.
2. Convert a large page component to lazy-load using `React.lazy`. Run `pnpm build` before and after, and measure the change in the initial chunk size from `dist/assets/`.
3. Explain in writing what "tree-shaking" requires from a JavaScript module to work correctly. Cover two requirements: the module format (ES modules, not CommonJS) and the package declaration (`"sideEffects": false` in `package.json`).

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| tree-shaking | "dead code elimination" | Removing exported functions that are imported nowhere, possible only with ES module static analysis |
| code splitting | "lazy loading routes" | Splitting the bundle into separate chunks that load on demand via dynamic import |
| lazy loading | "loading on demand" | Deferring the download of a module until the code path that needs it is executed |
| bundler | "Webpack" or "Vite" | A tool that resolves module imports and combines source files into output chunks |
| chunk | "a bundle file" | One output file produced by the bundler, identified by a content hash in its filename |
| minification | "minifying" | Removing whitespace and shortening identifiers to reduce file size without changing behavior |
| dead code elimination | "tree-shaking" | The bundler pass that removes exports never reached by any import path |

## Further Reading

- [Vite build options](https://vitejs.dev/config/build-options) — full reference for `build.*` config, including `rollupOptions`
- [Rollup code splitting guide](https://rollupjs.org/tutorial/#code-splitting) — explains how dynamic imports produce chunks
- [web.dev: Code splitting](https://web.dev/articles/code-splitting-suspense) — patterns for route-level and component-level splitting with React Suspense
