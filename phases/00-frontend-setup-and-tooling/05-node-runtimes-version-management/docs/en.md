# Node.js Runtimes & Version Management

> When different projects expect different Node versions, even a simple install can fail in confusing ways.

**Type:** Build
**Languages:** JavaScript
**Prerequisites:** None
**Time:** ~60 minutes

## Learning Objectives

- Compare Node.js, Bun, and version managers such as fnm or nvm
- Pin runtime versions per project
- Understand why runtime drift causes frontend bugs
- Check versions from the command line before starting work

## The Concept

Pick one runtime strategy, pin it per project, and verify it early.

## Build It

### Step 1
Install or select a version manager and pin a Node version.

### Step 2
Compare node, npm, and bun version output if available.

### Step 3
Document the project runtime in package.json or an env note.

### Step 4
Verify the runtime before running installs or builds.

## Use It

Apply the workflow to your current frontend project instead of waiting until later.

## Exercises

1. Install a second Node version and switch between them.
1. Create a project note that documents the expected runtime version.
1. Check how your version manager behaves in a fresh terminal session.
