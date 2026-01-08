---
description: Generate EXECUTION_PLAN.md and AGENTS_ADDITIONS.md for a feature
argument-hint: [target-directory]
allowed-tools: Read, Write, Glob, Grep
---

Generate the execution plan and agent additions for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/FEATURE_SPEC.md` exists. If not:
  "FEATURE_SPEC.md not found at $1. Run /feature-spec $1 first."
- Check that `$1/FEATURE_TECHNICAL_SPEC.md` exists. If not:
  "FEATURE_TECHNICAL_SPEC.md not found at $1. Run /feature-technical-spec $1 first."
- Check that `$1/AGENTS.md` exists. If not:
  "AGENTS.md not found at $1. Feature development requires an existing AGENTS.md."

## Process

Follow the instructions in @FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md exactly:

1. Read `$1/FEATURE_SPEC.md` and `$1/FEATURE_TECHNICAL_SPEC.md` as inputs
2. Read existing `$1/AGENTS.md` to understand current conventions
3. Generate EXECUTION_PLAN.md with phases, steps, and tasks for the feature
4. Generate AGENTS_ADDITIONS.md with any additional workflow guidelines

## Output

Write both documents to the target directory:
- `$1/EXECUTION_PLAN.md`
- `$1/AGENTS_ADDITIONS.md`

## Next Step

When complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS_ADDITIONS.md created at $1

Next steps:
1. cd $1
2. Merge AGENTS_ADDITIONS.md into AGENTS.md
3. /fresh-start
4. /phase-prep 1
5. /phase-start 1
```
