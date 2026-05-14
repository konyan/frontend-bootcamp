# Git Workflow

> Git is not a backup system — it is a time machine with a collaboration protocol built in.

**Type:** Learn
**Languages:** Shell
**Prerequisites:** Lesson 01 — Modern Development Environment
**Time:** ~75 minutes

## Learning Objectives

- Understand what a branch is and why it enables parallel work without conflicts
- Use merge and rebase correctly for the right situation
- Recover from common mistakes using stash and reflog
- Clean up commit history before a pull request using interactive rebase

## The Problem

You have been using git like a save button: `git add .`, `git commit -m "stuff"`, `git push`. That works in isolation — until it does not.

A reviewer asks you to split two unrelated changes into separate PRs. A teammate pushed to main and now your branch has conflicts. You accidentally reset past a commit you needed. You have eight tiny commits that should be one clean commit before merging.

These situations happen to every developer within the first few weeks on a real project. Git has specific tools for each of them. You do not need to understand Git's internal storage model to use these tools — but knowing the fundamentals makes the commands click rather than feel like magic.

## The Concept

### Branches Are Just Pointers

A branch is a named pointer to a commit. Creating a branch is free — no files are copied.

```
main:    A ── B ── C
feature:      D ── E
```

`feature` started at commit B and added two commits. `main` moved to C. These histories are independent until you merge or rebase.

`HEAD` is a pointer to where you currently are. When you are on a branch, HEAD points to the branch, which points to the latest commit.

### Merge vs Rebase

**Merge** joins two histories. It creates a new merge commit with two parents:

```
main:    A ── B ── C ── M
                  \   /
feature:           D ── E
```

**Rebase** replays your commits on top of another branch. The history appears linear:

```
main:    A ── B ── C
feature:           D' ── E'
```

| When to use | Approach |
|-------------|----------|
| Merging a PR into main | Merge (or squash merge) |
| Updating your branch with latest main | Rebase |
| Cleaning up commits before review | Interactive rebase |

**The rule:** never rebase commits already pushed to a branch that others are using. Rebase rewrites commit IDs — anyone who has the old commits will have a diverged history.

### The Five Commands That Fix Most Problems

| Command | Solves |
|---------|--------|
| `git stash` | Uncommitted work blocking a branch switch |
| `git rebase main` | Branch is behind main |
| `git rebase -i HEAD~N` | Messy commits to clean before a PR |
| `git cherry-pick <hash>` | One commit needed from another branch |
| `git reflog` | A commit was lost |

## Build It

### Step 1: Create and switch branches

```bash
git checkout -b feature/my-feature
git branch        # lists all branches, current marked with *
git switch main   # modern equivalent of git checkout main
```

### Step 2: Stash — save work without committing

Stash saves your changes temporarily so you can switch branches cleanly:

```bash
git stash push -m "wip: header styles"
git switch main                   # switch freely
git switch feature/my-feature     # come back
git stash pop                     # restore changes
```

List stashes: `git stash list`
Apply without dropping: `git stash apply stash@{0}`
Drop manually: `git stash drop stash@{0}`

### Step 3: Rebase — update your branch

When main has moved ahead:

```bash
git switch feature/my-feature
git rebase main
```

When a conflict occurs, Git pauses. Resolve the file, then:

```bash
git add <resolved-file>
git rebase --continue
```

To cancel and return to the state before the rebase:

```bash
git rebase --abort
```

### Step 4: Interactive rebase — clean up commits

`git rebase -i HEAD~N` opens an editor with your last N commits:

```bash
git rebase -i HEAD~3
```

The editor shows:
```
pick abc123 feat: add sidebar
pick def456 fix typo
pick ghi789 fix another typo
```

Change `pick` to `squash` (or `s`) on commits to combine them:
```
pick abc123 feat: add sidebar
squash def456 fix typo
squash ghi789 fix another typo
```

Save and close. Git prompts for a single combined commit message.

### Step 5: Cherry-pick — apply one commit

Cherry-pick applies the changes from a specific commit onto your current branch:

```bash
git log --oneline other-branch
git cherry-pick <commit-hash>
```

Resolve any conflicts the same way as a rebase conflict.

### Step 6: Reflog — recover lost commits

`git reflog` shows every position HEAD has been at — even after resets. If you lose a commit with `git reset --hard`, it lives in the reflog for 90 days:

```bash
git reflog
# abc1234 HEAD@{0}: reset: moving to HEAD~1
# def5678 HEAD@{1}: commit: feat: add footer

git branch recover-work HEAD@{1}
```

## Use It

**GitHub's "Squash and merge" button** does an interactive squash rebase on your behalf — all commits on the PR become one commit on main. This is exactly what `git rebase -i` with `squash` does. Use the button until you are comfortable doing it manually.

Set this global config so `git pull` always rebases instead of creating a merge commit:

```bash
git config --global pull.rebase true
```

## Ship It

The `code/git-workflow.sh` script sets up a practice repository with branches, creates conflict scenarios, and walks through resolving them. Run it in a temporary directory to practice safely before applying these commands to real work.

## Exercises

1. Create a two-commit feature branch. Use `git rebase -i HEAD~2` to squash them into one commit with a clean message.

2. Simulate a lost commit: run `git reset --hard HEAD~1` on a branch with a commit you care about. Use `git reflog` to recover it into a new branch.

3. Explain in one paragraph why force-pushing to a shared branch is dangerous. What would you do instead if you need to update a shared branch after a rebase?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Branch** | "A copy of the code" | A named pointer to a commit — creating one copies nothing |
| **Merge** | "The only way to combine branches" | Joins two histories by creating a merge commit with two parents |
| **Rebase** | "Dangerous and complicated" | Replays your commits on top of another branch — safe on private branches, dangerous on shared ones |
| **Stash** | "A temporary save" | A stack of uncommitted changes you can push and pop — not a commit |
| **Reflog** | "Git's internal log" | A local log of every HEAD position — your recovery tool when commits appear lost |
| **Interactive rebase** | "Rewriting history (bad)" | Squashing, reordering, or editing commits before they are shared — standard practice for clean PRs |

## Further Reading

- [Pro Git Book — Branching](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell) — definitive free reference
- [Pro Git Book — Git Tools](https://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging) — stash, cherry-pick, rebase, reflog
- [GitHub merge methods](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/about-merge-methods-on-github) — squash, merge, rebase on the platform
