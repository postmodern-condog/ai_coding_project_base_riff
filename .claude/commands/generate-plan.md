---
description: Generate EXECUTION_PLAN.md and AGENTS.md
allowed-tools: Read, Write
---

Generate the execution plan and agent guidelines for a greenfield project.

## Prerequisites

1. Check that `GENERATOR_PROMPT.md` exists. If not:
   "GENERATOR_PROMPT.md not found. Run /setup from the ai_coding_project_base toolkit first."

2. Check that `PRODUCT_SPEC.md` exists. If not:
   "PRODUCT_SPEC.md not found. Run /product-spec first."

3. Check that `TECHNICAL_SPEC.md` exists. If not:
   "TECHNICAL_SPEC.md not found. Run /technical-spec first."

## Process

Follow the instructions in @GENERATOR_PROMPT.md exactly:

1. Read @PRODUCT_SPEC.md and @TECHNICAL_SPEC.md as inputs
2. Generate EXECUTION_PLAN.md with phases, steps, and tasks
3. Generate AGENTS.md with workflow guidelines

## Output

Write both documents to the current directory:
- `EXECUTION_PLAN.md`
- `AGENTS.md`

## Next Step

When complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS.md created.

Your project is ready for execution. Next steps:
1. Review the generated documents
2. Run /fresh-start to orient and load context
3. Run /phase-prep 1 to check prerequisites for Phase 1
4. Run /phase-start 1 to begin execution
```
