---
description: Generate EXECUTION_PLAN.md and AGENTS_ADDITIONS.md for a feature
allowed-tools: Read, Write, Glob, Grep
---

Generate the execution plan and agent additions for a feature in an existing project.

## Prerequisites

1. Check that `FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md` exists. If not:
   "FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md not found. Run /setup from the ai_coding_project_base toolkit first."

2. Check that `FEATURE_SPEC.md` exists. If not:
   "FEATURE_SPEC.md not found. Run /feature-spec first."

3. Check that `FEATURE_TECHNICAL_SPEC.md` exists. If not:
   "FEATURE_TECHNICAL_SPEC.md not found. Run /feature-technical-spec first."

4. Check that `AGENTS.md` exists. If not:
   "AGENTS.md not found. Feature development requires an existing AGENTS.md. Did you mean to run /generate-plan for a new project?"

## Process

Follow the instructions in @FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md exactly:

1. Read @FEATURE_SPEC.md and @FEATURE_TECHNICAL_SPEC.md as inputs
2. Read existing @AGENTS.md to understand current conventions
3. Generate EXECUTION_PLAN.md with phases, steps, and tasks for the feature
4. Generate AGENTS_ADDITIONS.md with any additional workflow guidelines

## Output

Write both documents to the current directory:
- `EXECUTION_PLAN.md`
- `AGENTS_ADDITIONS.md`

## Next Step

When complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS_ADDITIONS.md created.

Next steps:
1. Review the generated documents
2. Merge AGENTS_ADDITIONS.md into your existing AGENTS.md
3. Run /fresh-start to orient and load context
4. Run /phase-prep 1 to check prerequisites for Phase 1
5. Run /phase-start 1 to begin execution
```
