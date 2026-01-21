---
description: Generate EXECUTION_PLAN.md and AGENTS_ADDITIONS.md for a feature
argument-hint: [target-directory]
allowed-tools: Read, Write, Edit, AskUserQuestion, Glob, Grep, Bash
---

Generate the execution plan and agent additions for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/FEATURE_SPEC.md` exists. If not:
  "FEATURE_SPEC.md not found at $1. Run /feature-spec $1 first."
- Check that `$1/FEATURE_TECHNICAL_SPEC.md` exists. If not:
  "FEATURE_TECHNICAL_SPEC.md not found at $1. Run /feature-technical-spec $1 first."
- Check that `PROJECT_ROOT/AGENTS.md` exists. If not:
  "AGENTS.md not found at PROJECT_ROOT. Feature development requires an existing AGENTS.md."
  (See Project Root Detection section below for how PROJECT_ROOT is derived)

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md` from the current working directory.

- If `FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/feature-plan $1`

## Existing File Guard (Prevent Overwrite)

Before generating anything, check whether either output file already exists:
- `$1/EXECUTION_PLAN.md`
- `$1/AGENTS_ADDITIONS.md`

- If neither exists: continue normally.
- If one or both exist: **STOP** and ask the user what to do for the existing file(s):
  1. **Backup then overwrite (recommended)**: for each existing file, read it and write it to `{path}.bak.YYYYMMDD-HHMMSS`, then write the new document(s) to the original path(s)
  2. **Overwrite**: replace the existing file(s) with the new document(s)
  3. **Abort**: do not write anything; suggest they rename/move the existing file(s) first

## Project Root Detection

Derive project root from the target directory:

1. If `$1` matches pattern `*/features/*` (contains `/features/` followed by a feature name):
   - PROJECT_ROOT = parent of parent of $1 (e.g., `/project/features/foo` → `/project`)
   - FEATURE_NAME = basename of $1

2. Validate PROJECT_ROOT:
   - Check `PROJECT_ROOT/AGENTS.md` exists
   - If missing: "Could not find AGENTS.md at PROJECT_ROOT. Is this a valid project with the features/ structure?"

3. If `$1` does NOT match the `*/features/*` pattern:
   - Warn: "`$1` doesn't appear to be a feature directory (expected path like `/project/features/feature-name`)"
   - Ask if they want to continue anyway

4. Use PROJECT_ROOT for:
   - Reading AGENTS.md

5. Use $1 (feature directory) for:
   - Reading FEATURE_SPEC.md and FEATURE_TECHNICAL_SPEC.md
   - Writing EXECUTION_PLAN.md and AGENTS_ADDITIONS.md

## Process

Read FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Read `$1/FEATURE_SPEC.md` and `$1/FEATURE_TECHNICAL_SPEC.md` as inputs
2. Read existing `PROJECT_ROOT/AGENTS.md` to understand current conventions
3. Generate EXECUTION_PLAN.md with phases, steps, and tasks for the feature
4. Generate AGENTS_ADDITIONS.md with any additional workflow guidelines

## Output

Write both documents to the target directory:
- `$1/EXECUTION_PLAN.md`
- `$1/AGENTS_ADDITIONS.md`

## Setup Execution Environment

After writing the documents, ensure the execution commands and skills are available at PROJECT_ROOT so `/fresh-start`, `/phase-start`, etc. work when the user switches to the feature directory.

Check if `PROJECT_ROOT/.claude/commands/fresh-start.md` exists:
- If it exists: skip this section (project already set up)
- If it does not exist: copy the execution commands and skills

### 1. Copy Execution Commands

Copy only the execution-phase commands to `PROJECT_ROOT/.claude/commands/`:

```bash
mkdir -p "PROJECT_ROOT/.claude/commands"
cp .claude/commands/fresh-start.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/phase-prep.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/phase-start.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/phase-checkpoint.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/verify-task.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/progress.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/security-scan.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/list-todos.md "PROJECT_ROOT/.claude/commands/"
cp .claude/commands/populate-state.md "PROJECT_ROOT/.claude/commands/"
```

Optional extras (not installed by default): recovery commands are available under `extras/claude/commands/`.

### 2. Copy Skills

Copy the skills directory:

```bash
cp -r .claude/skills "PROJECT_ROOT/.claude/"
```

### 3. Create CLAUDE.md

If `PROJECT_ROOT/CLAUDE.md` does not exist, create it with:

```
@AGENTS.md
```

If it already exists, do not overwrite it.

## Verification (Automatic)

After writing EXECUTION_PLAN.md, run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from FEATURE_TECHNICAL_SPEC.md and FEATURE_SPEC.md appear as tasks or acceptance criteria
3. Run quality checks for untestable criteria, missing dependencies, vague language, regression coverage
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

## Next Step

When verification is complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS_ADDITIONS.md created and verified at $1

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW

Next steps:
1. cd $1  (the feature directory)
2. /fresh-start  (will offer to merge AGENTS_ADDITIONS.md if needed)
3. /phase-prep 1
4. /phase-start 1
```
