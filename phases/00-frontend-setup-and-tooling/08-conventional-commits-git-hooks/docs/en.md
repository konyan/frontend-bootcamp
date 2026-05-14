# Conventional Commits & Git Hooks

> A commit message your future self can read is worth ten minutes today.

**Type:** Build
**Languages:** JavaScript, Shell
**Prerequisites:** Lesson 07 — Git Workflow
**Time:** ~75 minutes

## Learning Objectives

- Write commit messages that are human-readable and machine-parseable
- Understand what a git hook is and where it runs in the commit lifecycle
- Set up Husky to manage pre-commit and commit-msg hooks in version control
- Use lint-staged to run checks only on staged files, keeping hooks fast

## The Problem

After three months of development, the git log looks like this:

```
fix stuff
asdf
WIP
fix again
FINAL
FINAL FINAL v2
```

A new developer joins the team and tries to understand when a bug was introduced. There is no way to search this history. A teammate asks what changed last sprint — you read every diff by hand.

A second problem: a developer commits code with a linting error because nothing checks it at commit time. CI catches it two minutes later. They fix the typo and push again. This cycle repeats dozens of times per day across the team. Every round trip to CI costs two minutes that a two-second local check would have prevented.

Conventional Commits gives commit history a structured, searchable format. Git hooks run the checks locally before code ever leaves the machine.

## The Concept

### What Makes a Good Commit Message

A commit message has one job: explain why this change was made. The diff shows what changed. The message explains the reason.

**Before:**
```
fix stuff
```

**After:**
```
fix(auth): redirect to login when session expires

Previously the app showed a blank screen on 401 responses.
Now it detects the status code and navigates to /login.
```

The structured version tells you: what system was affected (`auth`), what kind of change (`fix`), and what problem it solves.

### The Conventional Commits Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

| Type | When to use |
|------|-------------|
| `feat` | New user-visible feature |
| `fix` | Bug fix |
| `refactor` | Code restructure, no behavior change |
| `docs` | Documentation only |
| `test` | Tests only |
| `chore` | Build scripts, CI, dependency updates |
| `ci` | CI configuration changes |

### What a Git Hook Is

A hook is a shell script that git runs automatically at a specific point:

```
git commit -m "message"
        ↓
pre-commit hook     ← runs lint-staged (format + lint staged files)
        ↓
commit-msg hook     ← validates the message format
        ↓
commit is created
        ↓
git push
        ↓
pre-push hook       ← (optional) runs tests
```

If any hook exits with a non-zero code, the operation stops. The commit is never created.

**Husky** manages hooks so they live in `.husky/` (tracked by git) instead of `.git/hooks/` (not tracked). Every developer who clones the repo gets the same hooks automatically.

**lint-staged** runs configured tools only on the files staged for the current commit — not the entire codebase. A pre-commit hook stays fast even in a large repo.

## Build It

### Step 1: Install Husky

```bash
pnpm add -D husky
pnpm exec husky init
```

This creates `.husky/` and adds a `prepare` script to `package.json` that installs hooks after `pnpm install`.

### Step 2: Install commitlint

```bash
pnpm add -D @commitlint/cli @commitlint/config-conventional
```

Create `commitlint.config.js`:

```js
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', ['feat', 'fix', 'docs', 'refactor', 'test', 'chore', 'ci', 'perf', 'revert']],
    'subject-case': [2, 'always', 'lower-case'],
    'header-max-length': [2, 'always', 100],
  },
}
```

### Step 3: Create the commit-msg hook

Create `.husky/commit-msg`:

```sh
#!/usr/bin/env sh
npx --no -- commitlint --edit "$1"
```

### Step 4: Install lint-staged and create the pre-commit hook

```bash
pnpm add -D lint-staged
```

Add to `package.json`:

```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{css,md,json}": ["prettier --write"]
  }
}
```

Create `.husky/pre-commit`:

```sh
#!/usr/bin/env sh
pnpm lint-staged
```

### Step 5: Test the setup

Try a bad message:
```bash
git add .
git commit -m "stuff"
# FAIL: type must be one of [feat, fix, ...]
```

Try a correct message:
```bash
git commit -m "feat(ui): add navigation header"
# pre-commit runs lint-staged, commit-msg validates format, commit created
```

### Step 6: Add an optional pre-push hook

```bash
cat > .husky/pre-push << 'EOF'
#!/usr/bin/env sh
pnpm build
EOF
```

This blocks a push if the build fails — catching broken builds before CI sees them.

## Use It

`semantic-release` reads the Conventional Commits log and automatically determines the next version number, publishes to npm, and writes `CHANGELOG.md`. The commit format you establish now enables this later with no backfilling.

GitHub Actions can validate PR titles with commitlint. When the merge strategy is "Squash and merge", the PR title becomes the commit message on main — validating the title in CI is equivalent to validating every commit that lands.

## Ship It

The four files from `code/` — `commitlint.config.js`, `.husky/pre-commit`, `.husky/commit-msg`, and the `lint-staged` block in `package.json` — form a portable hook setup. Add them to every project before the first hundred commits make backfilling impossible.

## Exercises

1. Make three commits using the convention: one `feat(ui):`, one `fix(auth):`, one `chore(deps):`. Run `git log --oneline` and read the result.

2. Try to commit with a message that violates the rules (`"Update stuff"`). Read the error from commitlint. Fix the message and commit successfully.

3. Research what a `BREAKING CHANGE:` footer in a commit message means for semantic versioning. Write a sample commit message that would trigger a major version bump.

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Conventional Commits** | "A style guide for commit messages" | A machine-readable specification — `<type>(<scope>): <subject>` — that enables automated changelog generation |
| **Git hook** | "A server-side trigger" | A local shell script in `.husky/` that git runs at a specific lifecycle point |
| **lint-staged** | "Runs the linter on all files" | Runs configured commands only on files currently staged for commit — keeps hooks fast |
| **commitlint** | "Spellcheck for commits" | A linter that validates commit message format against a ruleset and exits non-zero on failure |
| **Husky** | "A git plugin" | A tool that manages git hooks in version control so the whole team shares the same lifecycle scripts |

## Further Reading

- [conventionalcommits.org](https://www.conventionalcommits.org/) — the full specification
- [Husky docs](https://typicode.github.io/husky/) — hook setup and lifecycle reference
- [lint-staged](https://github.com/lint-staged/lint-staged) — configuration and usage guide
- [semantic-release](https://semantic-release.gitbook.io/semantic-release/) — automated versioning from commit history
