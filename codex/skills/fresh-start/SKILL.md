---
name: fresh-start
description: Emulates the AI Coding Toolkit's Claude Code command /fresh-start (orient to project structure, validate directory, load AGENTS.md + specs + EXECUTION_PLAN.md, optionally set up git/feature branches). Triggers on "/fresh-start" or "fresh-start".
---

# /fresh-start (Codex)

This skill mirrors the AI Coding Toolkit's Claude Code slash command `/fresh-start`.

## Inputs

- Optional: project directory path after the command (example: `/fresh-start ~/Projects/my-app`).

## Workflow

### 1) Context Detection

1. Set `WORKING_DIR`:
   - If the user provided a path argument, use it.
   - Otherwise, use the current working directory.

2. Detect mode:
   - If `WORKING_DIR` contains `/features/<feature-name>` in its path:
     - `PROJECT_ROOT` = parent of parent of `WORKING_DIR`
     - `FEATURE_DIR` = `WORKING_DIR`
     - `MODE` = `feature`
   - Else:
     - `PROJECT_ROOT` = `WORKING_DIR`
     - `FEATURE_DIR` = none
     - `MODE` = `greenfield`

### 2) Directory Guard (Wrong Directory Check)

Confirm required files exist:

- `PROJECT_ROOT/AGENTS.md` must exist
- `EXECUTION_PLAN.md` must exist in:
  - `FEATURE_DIR` (feature mode), or
  - `PROJECT_ROOT` (greenfield mode)

If either is missing:
- Stop and tell the user this directory is not ready for execution.
- If this appears to be the toolkit repo (e.g., `GENERATOR_PROMPT.md` exists), instruct them to generate/copy plan docs into a target project directory and rerun `/fresh-start` there.
- Otherwise, ask the user for the correct project directory path and rerun `/fresh-start <project-path>`.

### 3) Git Initialization (First Run)

Run these checks in `PROJECT_ROOT`:

1. Check whether this is already a git repo:
   ```bash
   git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree 2>/dev/null
   ```

2. If not a git repo:
   - Ask: "Initialize git in this project now? (recommended)"
   - If yes:
     ```bash
     git -C "$PROJECT_ROOT" init
     git -C "$PROJECT_ROOT" branch -M main
     ```

3. If it is a git repo but has no commits yet:
   - Ask: "Create an initial commit of the current project state now? (recommended)"
   - If yes:
     ```bash
     git -C "$PROJECT_ROOT" add -A
     git -C "$PROJECT_ROOT" commit -m "chore: initial commit"
     ```

### 4) Feature Branch Setup (Feature Mode Only)

If `MODE=feature`:

1. Derive `FEATURE_NAME` = basename of `FEATURE_DIR`
2. Check current branch:
   ```bash
   git -C "$PROJECT_ROOT" branch --show-current
   ```
3. If not already on `feature/$FEATURE_NAME`:
   - Preserve user work:
     ```bash
     git -C "$PROJECT_ROOT" add -A
     git -C "$PROJECT_ROOT" diff --cached --quiet || git -C "$PROJECT_ROOT" commit -m "wip: uncommitted changes before feature/$FEATURE_NAME"
     ```
   - Create and switch:
     ```bash
     git -C "$PROJECT_ROOT" checkout -b "feature/$FEATURE_NAME"
     ```
4. Report created/active branch.

### 5) AGENTS_ADDITIONS Merge (Feature Mode Only)

If `MODE=feature` and `FEATURE_DIR/AGENTS_ADDITIONS.md` exists:

1. Read and summarize the proposed additions.
2. Ask: "Apply these workflow additions to `PROJECT_ROOT/AGENTS.md` now? (recommended)"
3. If approved:
   - Apply additions (insert at requested locations if clear; else append).
   - Add marker `<!-- Added for FEATURE_NAME -->` where content was added.
   - Prepend to `AGENTS_ADDITIONS.md`:
     ```md
     <!-- MERGED into PROJECT_ROOT/AGENTS.md on YYYY-MM-DD -->
     ```

### 6) Load Required Context

Always read:
- `PROJECT_ROOT/AGENTS.md`
- `EXECUTION_PLAN.md` (from `FEATURE_DIR` if feature mode; else `PROJECT_ROOT`)

If present, also read:
- `PROJECT_ROOT/PRODUCT_SPEC.md`
- `PROJECT_ROOT/TECHNICAL_SPEC.md`

If feature mode, also read (if present):
- `FEATURE_DIR/FEATURE_SPEC.md`
- `FEATURE_DIR/FEATURE_TECHNICAL_SPEC.md`

### 7) Summarize and Confirm Ready

Provide:
- What is being built
- Current phase/progress (based on `EXECUTION_PLAN.md` checkboxes)
- Tech stack / key patterns
- Next recommended command (usually `/phase-prep <N>` or `/progress`)
