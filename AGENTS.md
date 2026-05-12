---
description: "Agent guidance for the AI Engineering from Scratch curriculum repo"
---

# AGENTS

This repo is a curriculum with strict content structure. Keep changes minimal, link to docs, and avoid rewriting large files unless requested.

## Start Here

- Project overview and structure: [README.md](README.md)
- Contribution rules and lesson format: [CONTRIBUTING.md](CONTRIBUTING.md)
- Lesson skeleton: [LESSON_TEMPLATE.md](LESSON_TEMPLATE.md)
- Phase status tracker: [ROADMAP.md](ROADMAP.md)

## High-Value Commands

- Regenerate site data after README/ROADMAP edits: `node site/build.js`
- Verify environment setup lesson: `python phases/00-setup-and-tooling/01-dev-environment/code/verify.py`
- Scaffold a new lesson: `./scripts/scaffold-lesson.sh <phase-dir> <lesson-dir> "Lesson Title"`

## Conventions That Matter

- README/ROADMAP parsing is strict; preserve table layouts and status glyphs (✅/🚧/⬚).
- Lesson content lives in `phases/<phase>/<lesson>/` with `docs/en.md`, `code/`, and optional `outputs/`, `notebook/`, `quiz.json`.
- Prefer Python unless the lesson is language-specific.
- Use `python3 -m pip` (or `pip3`) on macOS if installation is needed.

## Where To Look

- Lesson examples: [phases/00-setup-and-tooling](phases/00-setup-and-tooling)
- Build logic: [site/build.js](site/build.js)
- Lesson scaffold script: [scripts/scaffold-lesson.sh](scripts/scaffold-lesson.sh)
