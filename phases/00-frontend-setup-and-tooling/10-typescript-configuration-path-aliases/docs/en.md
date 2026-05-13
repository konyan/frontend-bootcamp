# TypeScript Configuration & Path Aliases

> A tsconfig is not boilerplate — it is the contract your compiler enforces on every line of code.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** Lesson 09
**Time:** ~75 minutes

## The Problem

A developer writes `import { Button } from '../../../components/ui/Button'` in every file. When they refactor the folder structure, 40 import paths break simultaneously. TypeScript catches some of the breakage, but the errors are cryptic because `strict` mode is off — `null` values pass through as non-null types, causing runtime crashes that the compiler should have caught at the source.

A new developer joins the team and cannot tell which compiler options are active or why. The tsconfig has `"strict": false` because someone turned it off a year ago to silence a compile error rather than fix it. The safety net was quietly removed, and nobody noticed until a production incident surfaced a null dereference that TypeScript would have flagged.

The root cause is treating `tsconfig.json` as a file you copy once and never revisit. A well-configured tsconfig is the single place where the team agrees on what TypeScript will and will not tolerate — and path aliases make that config pay dividends every time someone writes an import.

## The Concept

**The TypeScript compiler pipeline:**

```
Source files (.ts, .tsx)
        |
        v
   Type Checker   <-- tsconfig.json controls this stage
        |
        v
     Emitter      <-- produces .js (or noEmit skips this)
        |
        v
  Bundler (Vite)  <-- picks up the output
```

The type checker and the emitter are separate. `noEmit: true` tells TypeScript to check types but produce no output — the bundler handles that. This separation is why you run `tsc --noEmit` in CI and `vite build` for the actual artifact.

**`strict` is a shorthand flag.** Enabling `"strict": true` turns on a collection of individual flags at once:

| Flag | What it catches |
|------|----------------|
| `noImplicitAny` | Variables inferred as `any` without an explicit annotation |
| `strictNullChecks` | Using a value that could be `null` or `undefined` without narrowing |
| `strictFunctionTypes` | Unsafe function parameter covariance |
| `strictBindCallApply` | Wrong argument types in `.bind`, `.call`, `.apply` |

`noUncheckedIndexedAccess` is not part of `strict` but is worth adding: it makes array indexing return `T | undefined` instead of `T`, which matches reality.

**`moduleResolution: bundler`** is the modern default for Vite and Next.js projects. It understands that a bundler handles module resolution at build time rather than following Node.js file-system rules. The alternative, `node16`, is correct for projects that run directly in Node without a bundler.

**Path alias resolution** requires agreement between two tools:

```
tsconfig.json                vite.config.ts
─────────────                ──────────────
"baseUrl": "."               resolve: {
"paths": {                     alias: {
  "@/*": ["./src/*"]             "@": path.resolve(__dirname, "./src")
}                            }
                             }

     At type-check time           At bundle time
     TypeScript resolves          Vite resolves
     @/Button → ./src/Button      @/Button → ./src/Button
```

If only one side is configured, imports work in the editor or in the build — but not both. Both must agree on the mapping.

## Build It

### Step 1: Create `tsconfig.json`

Copy `code/tsconfig.json` to the root of your project. Walk through each group of options:

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
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
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

`target` and `lib` describe the runtime environment. `module: ESNext` keeps import/export syntax for the bundler. `isolatedModules: true` prevents patterns that break Vite's file-by-file transpilation.

### Step 2: Add path aliases

The `baseUrl` and `paths` block at the bottom of `compilerOptions` is what TypeScript uses at type-check time. `baseUrl: "."` means all paths resolve from the project root. The `@/*` alias maps to `./src/*`.

Verify it: create `src/lib/utils.ts` with any export, then import it as `@lib/utils` in another file. Run `tsc --noEmit` — it should pass.

### Step 3: Mirror the aliases in Vite

Open `vite.config.ts` and add the `resolve.alias` block so Vite knows the same mapping at bundle time:

```ts
import path from "path";

export default defineConfig({
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

A single `@` alias covering `./src` is usually sufficient. If you added granular aliases (`@components`, `@lib`) in tsconfig, add matching entries here.

### Step 4: Write an aliased import and type-check it

Create or update a file that uses `@/` imports, like `code/example.ts`:

```ts
import type { User } from "@lib/types";
import { formatDate } from "@lib/utils";
import { useUser } from "@hooks/useUser";

const displayUser = (user: User): string => {
  return `${user.name} joined on ${formatDate(user.createdAt)}`;
};

export { displayUser };
```

Run:

```bash
pnpm tsc --noEmit
```

No output means no errors. Any error here means either the path alias is misconfigured or the imported module has a type mismatch.

### Step 5: Enable `strict: true` and fix the first two errors

If you are adding this tsconfig to an existing project, `strict: true` will likely surface errors immediately. The two most common are:

1. `Object is possibly 'null'` — add a null check or use the optional chaining operator.
2. `Parameter 'x' implicitly has an 'any' type` — add an explicit type annotation.

Fix these one at a time rather than suppressing them with `// @ts-ignore`. Each one removed is a genuine bug prevented.

## Use It

`create-next-app --typescript` already generates a `tsconfig.json` with `@/*` path aliases wired. The generated file uses `"moduleResolution": "bundler"` and sets `"strict": true` — the same choices made here. The difference is that Next.js also handles the bundler side of alias resolution automatically via its Webpack config, so you only configure `tsconfig.json`.

The `ts-reset` library extends TypeScript's built-in lib types with safer defaults: `JSON.parse` returns `unknown` instead of `any`, `Array.filter(Boolean)` narrows correctly, and `fetch` response types are tighter. Add it with `import "@total-typescript/ts-reset"` in a global `.d.ts` file.

## Ship It

The `tsconfig.json` and `tsconfig.node.json` in `code/` are ready to drop into any new Vite + React + TypeScript project. Copy them to the project root and update the `paths` block to match your folder structure. Run `tsc --noEmit` to confirm there are no immediate errors before the first commit.

## Exercises

1. Add `"noUncheckedIndexedAccess": true` to your tsconfig and run `tsc --noEmit`. Find every place where array access needs a guard (`if (item !== undefined)`) and add it.
2. Create a `tsconfig.base.json` with the shared `compilerOptions`, then have `tsconfig.json` extend it with `"extends": "./tsconfig.base.json"`. Add only the project-specific options (`paths`, `include`) in the leaf config.
3. Explain in writing why both `tsconfig.json` and `vite.config.ts` need path aliases configured, and what breaks if only one of them has the mapping.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| strict mode | "turn on strict" | A single flag that enables ~8 individual safety checks in one |
| path alias | "@/ imports" | A string prefix mapped to a filesystem path in both the type checker and bundler |
| moduleResolution | "bundler mode" | Which algorithm TypeScript uses to locate imported files |
| type checking | "running tsc" | The phase where TypeScript validates types without producing output |
| tsconfig | "the config file" | The JSON file that controls the TypeScript compiler for an entire project |
| composite projects | "project references" | A tsconfig feature that lets one tsconfig depend on another for incremental builds |

## Further Reading

- [TypeScript tsconfig reference](https://www.typescriptlang.org/tsconfig) — authoritative docs for every compiler option
- [TypeScript strict mode](https://www.typescriptlang.org/docs/handbook/2/basic-types.html#strictness) — explains what each flag in the strict family does
- [ts-reset](https://github.com/total-typescript/ts-reset) — library that patches unsafe defaults in TypeScript's built-in types
