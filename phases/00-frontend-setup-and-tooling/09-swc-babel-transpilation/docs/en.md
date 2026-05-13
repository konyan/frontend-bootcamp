# SWC, Babel & Transpilation

> Transpilers convert modern syntax to what browsers can run — SWC does it 20x faster than Babel.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** Lesson 05 — Node.js Runtimes & Version Management
**Time:** ~75 minutes

## The Problem

A developer writes modern TypeScript with optional chaining and async/await. They ship to production and get errors from users on older browsers: `Unexpected token '?.'`. The browser does not understand the syntax. Back in the office, the developer realizes their "build pipeline" was just copying files — it was never actually transpiling anything.

A second scenario: a team's Webpack + Babel config takes 45 seconds to compile on every save. Half the day is spent watching a progress bar. A colleague swaps to SWC and the compile time drops to two seconds. But source maps stop working — stack traces in the browser now point to wrong line numbers, making debugging harder than before.

Transpilation is a required step for production frontend code. Understanding what it does, where it fits in the pipeline, and how to configure it correctly removes a category of invisible bugs.

## The Concept

**The compilation pipeline:**
```
TypeScript source (.ts)
        ↓
   Transpiler          ← strips types, transforms syntax
   (SWC or Babel)
        ↓
   JavaScript (.js)    ← ES2017 or ES5 depending on target
        ↓
    Bundler             ← resolves imports, splits chunks
   (Vite / Rollup)
        ↓
   Bundle (.js)         ← what the browser downloads
```

**Transpiling vs bundling:** they are separate jobs. A transpiler transforms syntax in a single file. A bundler resolves the dependency graph across all files and combines them. Vite uses esbuild for transpilation in dev and SWC (via a plugin) for production builds.

**SWC vs Babel:**

| | SWC | Babel |
|---|-----|-------|
| Written in | Rust | JavaScript |
| Speed | ~20x faster than Babel | Baseline |
| Plugin ecosystem | Limited | Extensive |
| Used by | Next.js, Vite (plugin), Deno | Legacy projects, custom transforms |
| Type checking | No (strips types only) | No (strips types only) |

Neither SWC nor Babel type-checks your code — that is `tsc`'s job. Both only transform syntax.

**Source maps:** a `.map` file that records the mapping from compiled line/column back to source line/column. Without it, a browser stack trace shows a line number in the minified bundle — useless for debugging.

## Build It

### Step 1: Install SWC

```bash
pnpm add -D @swc/core @swc/cli
```

### Step 2: Create the source file

Copy `code/input.ts` — it uses several modern TypeScript features: arrow functions, destructuring, spread, async/await, and template literals.

### Step 3: Create `.swcrc`

Copy `code/.swcrc` to the project root. Key settings:

```json
{
  "jsc": {
    "parser": { "syntax": "typescript" },
    "target": "es2017"
  },
  "sourceMaps": true
}
```

`target: "es2017"` means async/await is kept (it is ES2017 syntax). Change to `"es5"` to see Babel-style polyfill output.

### Step 4: Compile and inspect the output

```bash
pnpm swc input.ts -o output.js
```

Open `output.js` — TypeScript type annotations are gone, but the syntax is otherwise unchanged (targeting ES2017). Open `output.js.map` — this is the source map.

### Step 5: Compare with Babel

Install Babel:
```bash
pnpm add -D @babel/core @babel/cli @babel/preset-env @babel/preset-typescript
```

Copy `code/babel.config.json`. Run:
```bash
pnpm babel input.ts --out-file output-babel.js
```

Compare `output.js` (SWC) and `output-babel.js` (Babel). Babel's output is larger because it generates helper functions and polyfills for the browser targets in the config.

## Use It

Next.js uses SWC by default since v12. The configuration lives in `next.config.js`:

```js
const nextConfig = {
  swcMinify: true,
};
```

Vite uses esbuild in dev mode for speed and Rollup (with optional SWC via `@vitejs/plugin-react-swc`) for production. The transpiler is one layer below the bundler in both frameworks — you rarely configure it directly unless you need custom transforms.

## Ship It

The `.swcrc` and `package.json` from `code/` — use these when you need a standalone transpilation step outside of a framework (e.g., compiling a library). For app development inside Next.js or Vite, the framework handles transpilation and you only need to understand the concept.

The `outputs/prompt-transpile-debugger.md` is a reusable prompt for diagnosing build tool errors.

## Exercises

1. Change `"target"` in `.swcrc` from `"es2017"` to `"es5"` and compare the compiled output — how does SWC handle async/await differently?
2. Add `"jsx": "react-jsx"` to the SWC parser config and rename `input.ts` to `input.tsx` with a simple JSX expression — explain what SWC does with it.
3. Explain in one paragraph why a TypeScript type error does NOT stop SWC from compiling (hint: SWC strips types without running the type checker — `tsc --noEmit` is a separate step).

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| Transpiler | "Compiler" | A tool that transforms source code from one syntax to another, targeting a specific JS version — does not do type checking |
| Bundler | "Webpack" | A tool that resolves the full dependency graph and combines modules into output files |
| Source map | "The .map file" | A JSON file that maps compiled byte offsets back to original source locations — used by browser DevTools |
| Target | "What browsers we support" | The ECMAScript version the transpiler should output — lower targets mean more transformation |
| Type stripping | "SWC type checking" | Removing TypeScript annotations without validating them — SWC strips types; `tsc` type-checks them |

## Further Reading

- [SWC docs](https://swc.rs/docs/configuration/swcrc) — .swcrc configuration reference
- [Babel docs](https://babeljs.io/docs/config-files) — config file formats and preset options
- [Next.js blog: Rust compiler](https://nextjs.org/blog/next-12#faster-builds-and-fast-refresh-with-rust-compiler) — why Next.js switched from Babel to SWC
