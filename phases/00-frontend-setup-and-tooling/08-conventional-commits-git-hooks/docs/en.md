# Conventional Commits & Git Hooks

> Consistent commit history and lightweight automation reduce review friction and catch mistakes earlier.

**Type:** Build
**Languages:** Git
**Prerequisites:** None
**Time:** ~75 minutes

## Learning Objectives

- Write commit messages that can automate changelogs
- Use Husky or similar tooling for pre-commit checks
- Understand why hooks protect code quality before it lands
- Set up basic lint or test checks on commit

## The Concept

A good commit convention plus a small hook can stop low-quality changes before they reach the repository.

## Build It

### Step 1
Draft a commit format such as feat, fix, docs, or chore.

### Step 2
Add a pre-commit hook that runs formatting or linting.

### Step 3
Make one commit that follows the convention exactly.

### Step 4
Try a failing hook locally and read the output carefully.

## Use It

Apply the workflow to your current frontend project instead of waiting until later.

## Exercises

1. Write three commit messages using a consistent format.
1. Add a hook that runs a lint command before commit.
1. Explain how hooks help protect main branches from accidental breakage.
