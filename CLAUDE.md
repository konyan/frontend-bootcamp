# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Scaffold a new lesson
./scripts/scaffold-lesson.sh <phase-dir> <lesson-dir> ["Lesson Title"]
# Example: ./scripts/scaffold-lesson.sh 05-javascript-fundamentals 03-closures "Closures in Depth"

# Regenerate the website data after editing README.md, ROADMAP.md, or glossary/terms.md
node site/build.js
# Verify structural safety: git diff site/data.js should show only a timestamp change

# Run a lesson's code
python phases/<phase>/<lesson>/code/main.py
python3 -m pip install -r requirements.txt   # if dependencies needed
```

## Architecture

**Curriculum structure:** 20 phases, ~300 hours of frontend engineering instruction. Each lesson lives at:

```
phases/<NN>-<phase-name>/<NN>-<lesson-name>/
├── code/          Runnable implementation (primarily TypeScript/JavaScript; Python where applicable)
├── docs/
│   └── en.md      Lesson narrative (required)
├── notebook/      Optional Jupyter notebook
└── outputs/       Prompts, skills, or agents this lesson produces
```

**Site pipeline:** `site/build.js` parses three source files to generate `site/data.js` for the static website:
- `README.md` — phase/lesson catalog (parsed for titles, types, languages, links)
- `ROADMAP.md` — lesson status tracker (parsed for ✅/🚧/⬚ glyphs)
- `glossary/terms.md` — term definitions

**README/ROADMAP format is strictly parsed** — the build script keys on exact patterns:
- Phase headers: `### Phase N: Name \`X lessons\`` or `<details><summary><b>Phase N — Name</b>...<code>X lessons</code>...<em>Description</em></summary>`
- Lesson tables: columns must be `| # | Lesson | Type | Lang |` (or `| # | Project | Combines | Lang |` for capstones)
- Status glyphs: `✅` `🚧` `⬚` — never replace with text

**Lesson doc format** (`docs/en.md`) follows six sections in order: Problem → Concept → Build It → Use It → Ship It → Exercises. The Build It/Use It split is intentional: learners implement from scratch first, then see the library equivalent.

**Output artifacts** go in `outputs/` and use frontmatter:
- Prompts: `name`, `description`, `phase`, `lesson` fields
- Skills: adds `version` and `tags` fields

**Lesson slug format:** `NN-kebab-case` (e.g. `03-closures`). The scaffold script enforces this pattern.

## Conventions

- Code files must run without errors and contain no comments.
- Lesson slug numbering is zero-padded two digits (`01`, `02`, ...).
- After adding a lesson, add a row to ROADMAP.md under the correct phase. Commit lesson folder and ROADMAP.md atomically: `git add phases/<phase>/<lesson> ROADMAP.md`.
- Commit message format: `feat(phase-N/NN): Lesson Title`
- Claude Code skills live in `.claude/skills/` — `/find-your-level` and `/check-understanding <phase>` are the built-in curriculum skills.
