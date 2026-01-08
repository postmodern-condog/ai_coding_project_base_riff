---
description: Generate EXECUTION_PLAN.md and AGENTS.md
argument-hint: [target-directory]
allowed-tools: Read, Write
---

Generate the execution plan and agent guidelines for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/PRODUCT_SPEC.md` exists. If not:
  "PRODUCT_SPEC.md not found at $1. Run /product-spec $1 first."
- Check that `$1/TECHNICAL_SPEC.md` exists. If not:
  "TECHNICAL_SPEC.md not found at $1. Run /technical-spec $1 first."

## Process

Follow the instructions in @GENERATOR_PROMPT.md exactly:

1. Read `$1/PRODUCT_SPEC.md` and `$1/TECHNICAL_SPEC.md` as inputs
2. Generate EXECUTION_PLAN.md with phases, steps, and tasks
3. Generate AGENTS.md with workflow guidelines

## Output

Write both documents to the target directory:
- `$1/EXECUTION_PLAN.md`
- `$1/AGENTS.md`

## Next Step

When complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS.md created at $1

Your project is ready for execution:
1. cd $1
2. /fresh-start
3. /phase-prep 1
4. /phase-start 1
```
