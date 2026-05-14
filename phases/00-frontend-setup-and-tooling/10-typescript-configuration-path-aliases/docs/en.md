# TypeScript Configuration & Path Aliases

> TypeScript is JavaScript with rules. The rules catch bugs before they reach users.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** Lesson 09 — SWC, Babel & Transpilation
**Time:** ~75 minutes

## Learning Objectives

- Understand what TypeScript adds to JavaScript and why strict mode matters
- Read and configure `tsconfig.json` without guessing at options
- Set up path aliases so imports use `@/` instead of `../../..`
- Wire path aliases in both tsconfig and Vite so they work in the editor and in the build

## The Problem

A developer writes a function that reads `user.name`. A teammate calls it and passes `null` by mistake. The app crashes at runtime with "Cannot read properties of null". TypeScript would have caught this at the moment the mistake was made — but only if `strict` mode is on. On this project it is off, turned off a year ago to silence an error someone did not want to fix. The safety net was quietly removed.

A second problem: as the project folder structure deepens, imports look like this:

```ts
import { Button } from '../../../components/ui/Button'
import { formatDate } from '../../../../lib/utils'
```

Every `../../..` chain breaks when a file moves. Updating 40 import paths in a refactor is the kind of work that makes people avoid refactoring. A path alias (`@/components/ui/Button`) is stable regardless of where the importing file lives.

## The Concept

### What TypeScript Adds

TypeScript is a superset of JavaScript. Every JS file is valid TypeScript. TypeScript adds type annotations that the compiler checks before running:

```ts
function greet(name) {           // JavaScript — no type info
  return 'Hello ' + name
}

function greet(name: string) {   // TypeScript — type checked
  return 'Hello ' + name
}

greet(42)  // TypeScript catches: Argument of type 'number' is not assignable to 'string'
```

### The Two-Stage Pipeline

```
Source files (.ts, .tsx)
        |
        v
   Type Checker   ← tsconfig.json controls this
        |
        v
     Emitter      ← produces .js (or skips with noEmit)
        |
        v
  Bundler (Vite)  ← picks up the output
```

`noEmit: true` tells TypeScript to type-check without producing output files — the bundler handles that. Run `tsc --noEmit` in CI to catch type errors; run `vite build` to produce the artifact.

### `strict` Mode

`"strict": true` enables a collection of safety checks at once. The two most important:

**`strictNullChecks`** — without this, `null` passes anywhere without error:
```ts
function getLength(str: string | null): number {
  return str.length          // Error: str could be null
}

function getLength(str: string | null): number {
  return str?.length ?? 0   // Fixed: check before access
}
```

**`noImplicitAny`** — prevents variables from silently becoming `any`:
```ts
function process(data) { }       // Error: implicit any
function process(data: unknown) { }  // Required: be explicit
```

### Path Aliases — Two Tools, One Mapping

Path aliases require configuration in both TypeScript (for the editor) and Vite (for the build):

```
tsconfig.json                  vite.config.ts
──────────────                 ──────────────
"baseUrl": "."                 resolve: { alias: {
"paths": {                       "@": "./src"
  "@/*": ["./src/*"]           }}
}
     At type-check time             At bundle time
     TypeScript resolves            Vite resolves
     @/Button → ./src/Button        @/Button → ./src/Button
```

If only one side is configured, the alias works in the editor or the build — but not both.

## Build It

### Step 1: Create `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@lib/*": ["./src/lib/*"],
      "@hooks/*": ["./src/hooks/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### Step 2: Add path aliases to Vite

```ts
import path from 'path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

### Step 3: Write and verify an aliased import

Create `src/lib/utils.ts`:
```ts
export const formatDate = (date: Date): string =>
  date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
```

Import it with an alias in another file:
```ts
import { formatDate } from '@lib/utils'
```

Run type-check:
```bash
pnpm tsc --noEmit
```

No output means no errors.

### Step 4: Enable strict and fix the first errors

If adding this tsconfig to an existing project, `strict: true` surfaces errors. The two most common:

```
Object is possibly 'null'.         → add optional chaining or a null check
Parameter 'x' implicitly has 'any' type. → add a type annotation
```

Fix one at a time. Each is a real bug prevented.

### Step 5: Run tsc in CI

Add a script to `package.json`:
```json
{
  "scripts": {
    "typecheck": "tsc --noEmit"
  }
}
```

`pnpm typecheck` fails with exit code 1 on any type error. Add it to your CI pipeline alongside `lint` and `build`.

## Use It

`create-next-app --typescript` generates a tsconfig with `@/*` path aliases pre-wired. It uses `"moduleResolution": "bundler"` and `"strict": true` — the same choices made here. Next.js handles the Webpack side of alias resolution automatically, so you only configure `tsconfig.json`.

`ts-reset` patches unsafe TypeScript defaults: `JSON.parse` returns `unknown` instead of `any`, array `.filter(Boolean)` narrows correctly. Add it with `import "@total-typescript/ts-reset"` in a global `.d.ts` file.

## Ship It

The `tsconfig.json` from `code/` is ready to drop into any Vite + React + TypeScript project. Copy it to the project root, update `paths` to match your folder structure, and run `pnpm typecheck` before the first commit.

## Exercises

1. Add `"noUncheckedIndexedAccess": true` and run `tsc --noEmit`. Find every array access that needs a guard and add one.

2. Create a `tsconfig.base.json` with shared `compilerOptions` and extend it from `tsconfig.json` with `"extends": "./tsconfig.base.json"`. Put only project-specific options (`paths`, `include`) in the leaf config.

3. Explain in writing: why do both `tsconfig.json` and `vite.config.ts` need path aliases? What breaks if only one has the mapping?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Type annotation** | "Optional documentation" | An explicit declaration that the compiler enforces — not a comment |
| **strict mode** | "Makes TypeScript harder" | A single flag enabling ~8 safety checks that catch null errors, implicit any, and more |
| **noEmit** | "TypeScript not doing anything" | Run type-check only, no output files produced — the bundler handles building |
| **Path alias** | "A nice-to-have shortcut" | A stable import prefix configured in both tsconfig and the bundler — breaks relative-path fragility |
| **moduleResolution: bundler** | "Advanced setting for bundlers" | Tells TypeScript to resolve imports the same way Vite/webpack do — required for path aliases to work |

## Further Reading

- [TypeScript tsconfig reference](https://www.typescriptlang.org/tsconfig) — every compiler option documented
- [TypeScript strict mode](https://www.typescriptlang.org/docs/handbook/2/basic-types.html#strictness) — what each flag in the strict family does
- [Total TypeScript: ts-reset](https://github.com/total-typescript/ts-reset) — patches unsafe TypeScript defaults
- [Vite path aliases](https://vitejs.dev/config/shared-options.html#resolve-alias) — official Vite alias documentation
