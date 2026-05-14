# SWC, Babel & Transpilation

> JavaScript evolves faster than browsers do. A transpiler bridges that gap.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** Lesson 05 — Node.js Runtimes & Version Management
**Time:** ~75 minutes

## Learning Objectives

- Explain why transpilation is a required step for production frontend code
- Understand the difference between a transpiler and a bundler
- Configure SWC to convert TypeScript to JavaScript with source maps
- Compare SWC and Babel output and understand why modern projects prefer SWC

## The Problem

You write modern TypeScript with optional chaining (`user?.name`), async/await, and arrow functions. It works in your browser on Chrome 120. You deploy and get an error report from a user on older Safari: `Unexpected token '?.'`. Their browser does not understand that syntax. Back in the office you realize your "build pipeline" was just copying files — it was never actually transforming anything.

A second scenario: a team's Webpack + Babel setup takes 45 seconds to compile on every file save. Half the workday is watching a progress bar. A developer swaps to SWC and compile time drops to two seconds. But source maps break — stack traces now point to wrong line numbers in the minified output, making debugging impossible.

Transpilation is a required step for modern frontend code. Understanding what it does, where it fits, and how source maps work removes an entire category of invisible bugs.

## The Concept

### JavaScript Versions and Browser Support

JavaScript has yearly specification releases. Each adds new syntax. Browsers implement these releases at different speeds, and old versions never get updates:

```
Your code (ES2024)          Old Safari 12 (~ES2015)
──────────────────          ─────────────────────────
user?.name                  Error: Unexpected token '?.'
value ?? 'default'          Error: Unexpected token '?'
await fetchUser()           Understood (added in ES2017)
```

A transpiler converts modern syntax to older equivalent syntax:

```
Input:   user?.name
Output:  user === null || user === void 0 ? void 0 : user.name
```

### The Compilation Pipeline

```
TypeScript source (.ts)
        ↓
   Transpiler          ← strips types, transforms syntax
   (SWC or Babel)
        ↓
   JavaScript (.js)    ← ES2017 or ES5 depending on target
        ↓
    Bundler             ← resolves imports, combines files
   (Vite / Rollup)
        ↓
   Bundle (.js)         ← what the browser downloads
```

Transpiling and bundling are separate jobs. A transpiler transforms one file at a time. A bundler resolves the entire import graph and combines files. Vite uses esbuild for transpilation in dev and SWC (via `@vitejs/plugin-react-swc`) in production.

### SWC vs Babel

| | SWC | Babel |
|---|-----|-------|
| Written in | Rust | JavaScript |
| Speed | ~20x faster | Baseline |
| Plugin ecosystem | Limited | Extensive |
| Used by | Next.js, Vite | Legacy projects |
| Type checking | No | No |

Neither SWC nor Babel type-checks your code — that is `tsc`'s job. Both only transform syntax. You can transpile TypeScript without checking it for errors. This distinction confuses many developers.

### Source Maps

When code is transpiled and minified, browser stack traces point to the generated output — not the source you wrote. A source map (`.js.map`) records the mapping from generated positions back to original file and line numbers. Without source maps, debugging a production error means reading minified code.

## Build It

### Step 1: Install SWC

```bash
pnpm add -D @swc/core @swc/cli
```

### Step 2: Create a TypeScript source file

Create `code/input.ts` using modern features:

```typescript
interface User {
  name: string
  email?: string
}

const greet = async (user: User): Promise<string> => {
  const name = user?.name ?? 'stranger'
  return `Hello, ${name}!`
}

export { greet }
```

### Step 3: Create `.swcrc`

```json
{
  "jsc": {
    "parser": { "syntax": "typescript" },
    "target": "es2017"
  },
  "sourceMaps": true
}
```

`target: "es2017"` keeps async/await as-is. Change to `"es5"` to see full transformation.

### Step 4: Compile and inspect output

```bash
pnpm swc code/input.ts -o code/output.js
```

Open `output.js` — type annotations are gone, syntax is otherwise unchanged (targeting ES2017). Open `output.js.map` — this is the source map JSON.

### Step 5: Change the target and compare

Edit `.swcrc` to `"target": "es5"` and recompile. Compare the output — async/await becomes a state machine using generator functions. SWC transformed the syntax to be compatible with browsers that predate ES2017.

### Step 6: Install Babel and compare outputs

```bash
pnpm add -D @babel/core @babel/cli @babel/preset-env @babel/preset-typescript
```

Create `babel.config.json`:
```json
{
  "presets": [
    ["@babel/preset-env", { "targets": "defaults" }],
    "@babel/preset-typescript"
  ]
}
```

```bash
pnpm babel code/input.ts --out-file code/output-babel.js
```

Compare `output.js` (SWC) and `output-babel.js` (Babel). Babel's output is larger — it includes helper functions for the browser targets.

## Use It

Next.js uses SWC by default since v12:

```js
const nextConfig = {
  swcMinify: true,
}
```

Vite uses esbuild in dev mode and SWC in production via `@vitejs/plugin-react-swc`. For most app development, the framework handles transpilation automatically — you configure it only when you need custom transforms like decorators or macro-style transforms.

## Ship It

The `.swcrc` from `code/` covers the standard TypeScript-to-JS transform. Use it for library builds or standalone scripts. For apps in Vite or Next.js, the framework owns this file — you only need to understand the concept.

## Exercises

1. Change `"target"` to `"es5"` and recompile `input.ts`. Find the async/await in the output. How does SWC express it in ES5?

2. Add `"jsx": "react-jsx"` to the SWC parser config, rename `input.ts` to `input.tsx`, and add a JSX expression. What does the output contain?

3. Explain in writing: why does a TypeScript type error NOT stop SWC from producing output? What is the separate command you would run to catch type errors before shipping?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Transpiler** | "A compiler" | A tool that transforms source code from one syntax to another — does not type-check |
| **Bundler** | "Same as a transpiler" | A tool that resolves the import graph across files and combines them into output chunks |
| **Source map** | "A debugging extra" | A JSON file mapping compiled positions back to source lines — essential for production debugging |
| **Target** | "The browser you want to support" | The ECMAScript version the transpiler outputs — lower targets mean more transformation |
| **Type stripping** | "Type checking" | Removing TypeScript annotations without validating them — what SWC/esbuild do; `tsc` validates |

## Further Reading

- [SWC docs](https://swc.rs/docs/configuration/swcrc) — .swcrc configuration reference
- [Babel docs](https://babeljs.io/docs/config-files) — config formats and presets
- [Next.js: Rust compiler](https://nextjs.org/blog/next-12#faster-builds-and-fast-refresh-with-rust-compiler) — why Next.js switched from Babel to SWC
- [Source Maps explainer](https://web.dev/articles/source-maps) — how source maps work and how to use them
