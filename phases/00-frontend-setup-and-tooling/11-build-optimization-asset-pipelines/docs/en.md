# Build Optimization & Asset Pipelines

> Your app is only as fast as what the browser has to download.

**Type:** Build
**Languages:** TypeScript, JavaScript
**Prerequisites:** Lessons 09 and 10
**Time:** ~75 minutes

## Learning Objectives

- Explain what happens between `pnpm build` and a user seeing your page
- Apply tree-shaking, code splitting, and lazy loading to reduce initial bundle size
- Configure Vite's `manualChunks` to separate vendor dependencies from application code
- Use the bundle visualizer to identify what is largest in the output

## The Problem

You build a React app and deploy it. On your laptop it loads in under a second. You test it on a phone with mobile data and the page is blank for 8 seconds. Lighthouse reports the JavaScript bundle is 2.1 MB.

Three specific mistakes caused this:

1. You imported `lodash` for a single `_.debounce` call. The entire 70 KB library ended up in the bundle — a 150-byte inline function would have done the same job.
2. A charting library used only on the admin dashboard loads for every visitor on the landing page. It is 400 KB and is never needed until an admin logs in.
3. Code the team deleted six months ago is still in the bundle because a top-level side effect (`window.analytics = ...`) prevented the bundler's dead code removal from running.

These are not unusual problems. They are the default outcome when the bundler is never configured. Each fix is specific and takes under an hour to apply.

## The Concept

### What the Browser Downloads

```
User opens your URL
        ↓
Browser requests index.html      ← ~5 KB, arrives fast
        ↓
Browser sees <script src="index-abc.js">
        ↓
Browser downloads index-abc.js   ← 2.1 MB — this is the wait
        ↓
JavaScript parses and executes
        ↓
Page becomes interactive
```

Every kilobyte removed from `index-abc.js` directly reduces how long the user waits. On a 10 Mbps mobile connection, 2 MB takes 1.6 seconds to transfer — before parsing begins.

### The Four Optimizations

| Optimization | What it does | Who triggers it |
|---|---|---|
| Tree-shaking | Removes unexported code | Bundler, if module has no side effects |
| Code splitting | Breaks bundle into on-demand chunks | Developer, via dynamic `import()` |
| Minification | Removes whitespace, shortens names | Bundler, automatically in production |
| Content hashing | Fingerprints filenames for caching | Bundler, automatically |

**Tree-shaking requires ES modules.** If `lodash` uses CommonJS (`require()`), the bundler cannot determine which exports are used and includes everything. Use `lodash-es` (the ES module build) so tree-shaking works.

**Code splitting via dynamic import:**

```ts
import { AdminChart } from './AdminChart'        // always in the initial bundle
const AdminChart = lazy(() => import('./AdminChart'))  // separate chunk, loaded on demand
```

**Bundle anatomy after splitting:**

```
dist/assets/
├── index-a1b2c3.js     ← initial chunk (app shell)
├── vendor-d4e5f6.js    ← React + react-dom (changes rarely, cached aggressively)
└── AdminChart-g7h8.js  ← lazy chunk (downloaded only when needed)
```

Content hashes in filenames mean browsers cache chunks indefinitely. Only chunks with changed content get new hashes — users re-download only what actually changed.

## Build It

### Step 1: Create `vite.config.ts`

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    target: 'es2020',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
        },
      },
    },
  },
})
```

`sourcemap: true` produces `.map` files so production error traces point to your source — not minified output.

### Step 2: Build and inspect the output

```bash
pnpm build
ls -lh dist/assets/
```

Note file names, sizes, and hashes. Verify a `vendor-*.js` chunk exists containing React.

### Step 3: Measure the impact of manualChunks

Remove `manualChunks` temporarily and build again. Compare the index chunk size:

```
Without manualChunks:  index-abc.js  890 KB  (app + React)
With manualChunks:     index-def.js  120 KB  (app only)
                       vendor-ghi.js 150 KB  (React + react-dom)
```

Total size is similar, but the index chunk users download on every new deploy is much smaller. The vendor chunk is cached by the browser across deploys.

### Step 4: Add lazy loading

```tsx
import { lazy, Suspense } from 'react'

const HeavyChart = lazy(() => import('./HeavyChart'))

export function Dashboard() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyChart />
    </Suspense>
  )
}
```

Run `pnpm build` again. The chart code now appears as a separate chunk downloaded only when the Dashboard renders.

### Step 5: Generate a bundle visualizer

```bash
pnpm add -D rollup-plugin-visualizer
```

Add to `vite.config.ts`:

```ts
import { visualizer } from 'rollup-plugin-visualizer'

plugins: [react(), visualizer({ open: true, filename: 'bundle-stats.html' })]
```

Run `pnpm build`. A treemap opens in the browser. Large rectangles are candidates for lazy loading or replacement with lighter alternatives.

## Use It

Next.js App Router splits automatically per route segment — each `page.tsx` becomes its own chunk with no dynamic `import()` needed. For components within a page, use `next/dynamic`:

```ts
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('./HeavyChart'), {
  ssr: false,
  loading: () => <div>Loading...</div>,
})
```

`ssr: false` skips server-side rendering — correct for browser-only libraries. Vite's `React.lazy` does not have this option because Vite apps are client-side by default.

## Ship It

The `vite.config.ts` from `code/` — vendor split, source maps, and path alias from Lesson 10 — is the baseline for new Vite projects. Drop it in before the first commit and adjust `manualChunks` as the dependency list grows.

## Exercises

1. Add `rollup-plugin-visualizer` and run `pnpm build`. Open the treemap. Identify the three largest modules and write one sentence each: what they do and whether they could be lazy-loaded.

2. Convert a page-level component to lazy-load with `React.lazy`. Run `pnpm build` before and after. Measure the initial chunk size difference from `ls -lh dist/assets/`.

3. Explain in writing what tree-shaking requires: the module format (ES modules, not CommonJS) and the `"sideEffects": false` declaration in `package.json`. Why does a top-level `window.x = ...` prevent tree-shaking?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Tree-shaking** | "The bundler removes unused files" | Removes unexported functions within a module — requires ES modules and no side effects |
| **Code splitting** | "Automatic in Vite" | Splitting the bundle into on-demand chunks — requires explicit dynamic `import()` in Vite |
| **Lazy loading** | "Just wrapping in React.lazy" | Deferring a module's download until the code path that needs it actually runs |
| **Content hash** | "A random string in the filename" | A fingerprint derived from the file's content — changes only when the content changes, enabling safe long-term caching |
| **manualChunks** | "An optimization for large apps only" | A Rollup/Vite option that places specific packages into named chunks — useful from the start |

## Further Reading

- [Vite build options](https://vitejs.dev/config/build-options.html) — full reference for `build.*` config
- [Rollup code splitting](https://rollupjs.org/tutorial/#code-splitting) — how dynamic imports produce chunks
- [web.dev: Code splitting](https://web.dev/articles/code-splitting-suspense) — React Suspense patterns for lazy loading
- [Bundle Phobia](https://bundlephobia.com/) — check the size cost of any npm package before adding it
