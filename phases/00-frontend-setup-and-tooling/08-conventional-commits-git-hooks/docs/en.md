# Conventional Commits & Git Hooks

> A commit message a machine can read is a commit message a human can trust.

**Type:** Build
**Languages:** Git
**Prerequisites:** Lesson 07 — Advanced Git Workflow
**Time:** ~75 minutes

## The Problem

A team's git log looks like this:
```
fix stuff
asdf
WIP
fix again
FINAL
FINAL FINAL v2
```

Nobody can automatically generate a changelog from this history. Nobody can run `git log --grep="fix" --oneline` and find relevant changes. The idea of auto-bumping the npm version based on commit type — `feat` bumps minor, `fix` bumps patch — is impossible because the commits carry no semantic signal.

A second problem: a developer commits code with a linting error because `git commit` runs nothing. The CI pipeline catches it two minutes later. Multiply this by 50 commits per day across a team and CI is constantly red for trivial reasons. A pre-commit hook would have caught it in two seconds on the developer's machine before the code ever left.

Conventional Commits gives the first problem a standard format. Git hooks solve the second by automating checks at the right moment in the workflow.

## The Concept

**The Conventional Commits format:**
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types and their meaning:**

| Type | Semver bump | When to use |
|------|------------|------------|
| `feat` | minor | New user-visible feature |
| `fix` | patch | Bug fix |
| `perf` | patch | Performance improvement |
| `refactor` | none | Internal restructure, no behavior change |
| `docs` | none | Documentation only |
| `test` | none | Adding or fixing tests |
| `chore` | none | Build scripts, CI, dependencies |
| `ci` | none | CI configuration changes |

A `BREAKING CHANGE:` footer (or `!` after the type, e.g. `feat!:`) triggers a major bump.

**Git hooks fire at specific lifecycle points:**
```
git commit
    ↓
pre-commit hook    ← runs lint-staged (format + lint changed files)
    ↓
commit-msg hook    ← runs commitlint (validates message format)
    ↓
commit created
    ↓
pre-push hook      ← (optional) runs tests before push
```

Husky manages these hooks. lint-staged runs tools only on the files that are staged, not the entire codebase — keeping pre-commit fast even in large repos.

## Build It

### Step 1: Install Husky

```bash
pnpm add -D husky
pnpm exec husky init
```

This creates a `.husky/` directory and a `prepare` script that installs hooks when anyone runs `pnpm install`.

### Step 2: Install commitlint

```bash
pnpm add -D @commitlint/cli @commitlint/config-conventional
```

Create `commitlint.config.js` from `code/commitlint.config.js`:

```js
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'ci', 'perf', 'revert']],
    'subject-case': [2, 'always', 'lower-case'],
    'header-max-length': [2, 'always', 100],
  },
};
```

### Step 3: Create the commit-msg hook

Create `.husky/commit-msg` from `code/.husky/commit-msg`:

```sh
#!/usr/bin/env sh
npx --no -- commitlint --edit "$1"
```

### Step 4: Install lint-staged and create pre-commit hook

```bash
pnpm add -D lint-staged
```

Add `lint-staged` config to `package.json`:

```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{css,md,json}": ["prettier --write"]
  }
}
```

Create `.husky/pre-commit` from `code/.husky/pre-commit`:

```sh
#!/usr/bin/env sh
pnpm lint-staged
```

### Step 5: Test the setup

Try committing with a bad message — it should fail:
```bash
git add .
git commit -m "stuff"
# FAIL: subject may not be empty / type must be one of [feat, fix, ...]
```

Try a correct message:
```bash
git commit -m "feat(ui): add navigation header component"
# OK: hooks pass, commit created
```

## Use It

`semantic-release` reads Conventional Commits from the entire git log and decides whether to publish a new npm version, what the new version number should be, and what goes in `CHANGELOG.md` — fully automated from commit messages alone.

GitHub Actions can run commitlint on PR titles when the merge strategy is "Squash and merge" — since only the PR title becomes the commit message, validating it in CI is equivalent to validating every commit that lands on main.

## Ship It

The `commitlint.config.js`, `.husky/pre-commit`, `.husky/commit-msg`, and the `lint-staged` block in `package.json` from `code/` form a portable hook setup. Apply these to every project at the start, before the first hundred commits make backfilling impossible.

## Exercises

1. Make three commits using the convention: one `feat(ui):`, one `fix(auth):`, one `chore(deps):`.
2. Add a `.husky/pre-push` hook that runs `pnpm build` — verify it blocks a push when the build fails.
3. Research what a `BREAKING CHANGE:` footer in a commit message means for a library that uses `semantic-release` to publish to npm.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| Conventional Commits | "The commit format" | A specification for structured commit messages that tools can parse — `<type>(<scope>): <subject>` |
| Git hook | "Pre-commit" | A shell script in `.git/hooks/` that Git runs at a specific lifecycle point — Husky manages them in version control |
| lint-staged | "Only lint changed files" | A tool that runs configured commands only on the files currently staged for commit |
| commitlint | "Commit message linter" | A tool that parses a commit message against rules and exits non-zero if it does not conform |
| Semantic versioning | "semver" | A versioning scheme where `major.minor.patch` bumps have defined meanings tied to the nature of the change |

## Further Reading

- [conventionalcommits.org](https://www.conventionalcommits.org/) — the full specification
- [Husky docs](https://typicode.github.io/husky/) — hook setup and lifecycle reference
- [semantic-release docs](https://semantic-release.gitbook.io/semantic-release/) — automated versioning and changelog generation
