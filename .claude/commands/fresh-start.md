---
description: Orient to project structure and load context
argument-hint: [project-directory]
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
---

Orient to a project directory and load context for execution.

## Project Directory

Use the current working directory by default.

If `$1` is provided, treat `$1` as the project directory and read files under `$1` instead.

## Directory Guard (Wrong Directory Check)

Confirm the project directory contains `AGENTS.md` and `EXECUTION_PLAN.md`.

- If either is missing:
  - Tell the user this project is not ready for execution yet
  - If they are in the toolkit repo (e.g., `GENERATOR_PROMPT.md` exists), instruct them to:
    1. Run `/generate-plan <project-path>` from the toolkit repo (or feature equivalents)
    2. `cd` into the project directory
    3. Re-run `/fresh-start`
  - Otherwise, ask the user for the correct project directory path and re-run `/fresh-start <project-path>`

## Git Initialization (First Run)

In the project directory:

1. Check whether this is already a git repo (`.git/` exists).
2. If not a git repo:
   - Ask: "Initialize git in this project now?" (recommended)
   - If yes:
     ```bash
     git init
     git branch -M main
     ```
3. If it is a git repo but has no commits yet:
   - Ask: "Create an initial commit of the current project state now?" (recommended)
   - If yes:
     ```bash
     git add -A
     git commit -m "chore: initial commit"
     ```

## Required Context

Read these files first:
- **AGENTS.md** — Workflow guidelines
- **EXECUTION_PLAN.md** — Tasks and acceptance criteria

## Specification Documents

Check which of these exist and read them:
- **PRODUCT_SPEC.md** — What we're building (greenfield)
- **TECHNICAL_SPEC.md** — How it's built (greenfield)
- **FEATURE_SPEC.md** — Feature requirements (feature work)
- **FEATURE_TECHNICAL_SPEC.md** — Feature technical approach (feature work)

## Your Task

1. Read all available documents above
2. Summarize your understanding:
   - What is being built
   - Current phase and progress
   - Tech stack and key patterns
3. Confirm you're ready to begin execution
