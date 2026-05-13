# Advanced Git Workflow

> Knowing how to commit is entry-level. Knowing how to rewrite, recover, and navigate history is what separates juniors from seniors.

**Type:** Learn
**Languages:** —
**Prerequisites:** Lesson 01
**Time:** ~75 minutes

## The Problem

A developer pushes a 200-line feature branch that touched six files. A reviewer asks them to split the unrelated refactor into a separate PR. The developer does not know how to do that without losing work. Meanwhile, the main branch moved forward and their branch now has 12 conflicts. They type `git pull` and create a merge commit. The reviewer can no longer follow the history. They panic and force-push, overwriting a teammate's commit.

This is not a rare situation. It happens on every team that treats Git as a file-upload tool rather than a history-management tool. The developer in this scenario is not careless — they simply never learned the tools that exist past `commit`, `push`, and `pull`.

The good news: five commands fix most of these situations. Rebase, cherry-pick, stash, reflog, and interactive rebase cover 95% of the messy-history problems you will encounter in production workflows.

## The Concept

### The Git Object Model

Every commit in Git is a snapshot, not a diff. Git stores three object types:

- **blob** — a file's contents at a point in time
- **tree** — a directory listing that points to blobs and other trees
- **commit** — metadata (author, timestamp, message) plus a pointer to a tree and a parent commit

A branch is just a named pointer to a commit. `HEAD` is a pointer to the currently checked-out branch (or commit in detached-HEAD mode).

```
main ────► commit C3 ──► commit C2 ──► commit C1
                            ▲
feature ────────────────────┘
```

When you create a branch, Git creates a new pointer. No files are copied.

### Merge vs Rebase

**Merge** preserves the complete history. It creates a new "merge commit" with two parents.

```
Before:
  main:    A ── B ── C
  feature:      D ── E

After git merge:
  main:    A ── B ── C ── M
                 \       /
  feature:        D ── E
```

**Rebase** replays your commits on top of another branch. The commits are rewritten (new SHAs) but the line of work appears linear.

```
Before:
  main:    A ── B ── C
  feature:      D ── E

After git rebase main (on feature branch):
  main:    A ── B ── C
  feature:           D' ── E'
```

| Approach | History shape | Safe to reuse on shared branches? |
|----------|--------------|----------------------------------|
| Merge    | Branchy, preserves all context | Yes |
| Rebase   | Linear, easier to read | Only on private branches |

The rule: **never rebase commits that have been pushed to a shared branch.** Rebase rewrites commit SHAs, so anyone who has the old commits will have a diverged history.

### HEAD and Refs

`HEAD` is stored in `.git/HEAD`. When on a branch it contains a symbolic ref like `ref: refs/heads/main`. In detached-HEAD mode it contains a raw commit SHA.

`git reflog` is a local log of every time HEAD moved — even across resets and deletions. It is your safety net.

## Build It

### Step 1: Create a Test Repo and Practice Branch Workflow

Run `code/git-workflow.sh` to set up a temporary practice repo, create branches, merge, cherry-pick, and clean up:

```bash
bash code/git-workflow.sh
```

The script initialises a repo, creates a feature branch with two commits, merges it back with `--no-ff` to preserve the branch topology, then cherry-picks a hotfix commit. Read through the script line by line before running it.

### Step 2: Practice Rebase

Create a feature branch that diverges from main, then rebase it:

```bash
git checkout -b feature/my-work
git commit --allow-empty -m "feat: add sidebar"
git commit --allow-empty -m "feat: add footer"

git checkout main
git commit --allow-empty -m "chore: update deps"

git checkout feature/my-work
git rebase main
```

If a conflict occurs during rebase, Git pauses. Resolve the conflict in the file, then:

```bash
git add <conflicted-file>
git rebase --continue
```

To abort and return to the pre-rebase state:

```bash
git rebase --abort
```

### Step 3: Cherry-Pick

Cherry-pick moves a single commit from one branch to another. Only the diff introduced by that commit is applied — not the entire branch history.

```bash
git log --oneline feature/my-work
git cherry-pick <commit-hash>
```

If the cherry-picked commit conflicts with the target branch, resolve it the same way as a rebase conflict, then `git cherry-pick --continue`.

### Step 4: Stash

Stash saves your working directory changes without committing them, so you can switch branches cleanly.

```bash
git stash push -m "wip: header styles"
git checkout main
git checkout feature/my-work
git stash pop
```

List all stashes: `git stash list`
Apply a specific stash without dropping it: `git stash apply stash@{2}`
Drop a stash manually: `git stash drop stash@{0}`

### Step 5: Reflog Rescue

`git reflog` shows every position HEAD has been at, even after resets. If you lose a commit with `git reset --hard`, it is still in the reflog for 90 days (the default expiry).

```bash
git reflog
```

Output looks like:

```
abc1234 HEAD@{0}: reset: moving to HEAD~1
def5678 HEAD@{1}: commit: feat: add footer
...
```

To recover the lost commit:

```bash
git checkout HEAD@{1}
```

Or create a new branch pointing to it:

```bash
git branch recover-work HEAD@{1}
```

## Use It

**GitHub's "Squash and merge" button** does an interactive squash rebase on your behalf. When you click it, GitHub takes all commits on your PR branch, squashes them into a single commit, and applies that to main. This is exactly what `git rebase -i HEAD~N` with `squash` does on the command line.

**`git bisect`** uses binary search to find the commit that introduced a bug. You mark one commit as "good" and one as "bad", and Git checks out the midpoint. You test, mark good or bad, and repeat. Git finds the culprit in O(log N) steps:

```bash
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
```

## Ship It

Set this global config once so every `git pull` becomes a rebase instead of a merge commit:

```bash
git config --global pull.rebase true
```

This single setting prevents the most common source of noisy merge commits in team histories. If a conflict occurs during the rebase-pull, resolve it the same way as any other rebase conflict. Store the command in your new-machine setup script.

## Exercises

1. Create a two-commit feature branch, then use `git rebase -i HEAD~2` to squash them into one commit with a clean message.
2. Simulate a lost commit by running `git reset --hard HEAD~1` on a branch with a commit you care about. Recover it using `git reflog`.
3. Explain in one paragraph why force-pushing to a shared branch is dangerous, and what command you would use instead if you need to update a shared branch after a rebase.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| rebase | "rebase onto main" | Replay your commits on top of another branch, rewriting their SHAs |
| cherry-pick | "cherry-pick that fix" | Apply the diff from a single commit onto the current branch |
| stash | "stash your changes" | Save uncommitted work to a temporary stack without creating a commit |
| reflog | "check the reflog" | A local log of every position HEAD has been, including after resets |
| HEAD | "detached HEAD" | A pointer to the currently checked-out commit or branch |
| interactive rebase | "rebase -i" | A rebase that opens an editor so you can reorder, squash, edit, or drop commits |

## Further Reading

- [Pro Git Book](https://git-scm.com/book/en/v2) — the definitive free reference, especially chapters 3 (branching) and 7 (tools)
- [git-rebase docs](https://git-scm.com/docs/git-rebase) — official reference for all rebase options
- [GitHub: About merge methods](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/about-merge-methods-on-github) — how squash, merge, and rebase differ on the platform
