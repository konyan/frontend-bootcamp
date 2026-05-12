# SWC, Babel & Transpilation

> Modern frontend syntax is not always supported directly by the browser or the runtime you are targeting.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** None
**Time:** ~75 minutes

## Learning Objectives

- Explain why frontend code often needs transpilation
- Compare SWC and Babel at a high level
- Understand JSX and TypeScript compilation flow
- Recognize source maps as a debugging aid

## The Concept

Transpilers transform modern code into widely supported output while preserving a good developer experience.

## Build It

### Step 1
Inspect a tiny TypeScript or JSX file before and after transpilation.

### Step 2
Look at the generated source map or output bundle.

### Step 3
Compare a fast compiler like SWC with the older Babel workflow.

### Step 4
Confirm which parts of your stack are compiling vs bundling.

## Use It

Apply the workflow to your current frontend project instead of waiting until later.

## Exercises

1. Explain the difference between transpiling and bundling.
1. List one reason source maps matter during debugging.
1. Describe where SWC fits in a Next.js build pipeline.
