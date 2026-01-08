---
description: Execute all tasks in a phase autonomously
argument-hint: [phase-number]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

Execute all steps and tasks in Phase $1 from @EXECUTION_PLAN.md.

## Context

- @AGENTS.md — Follow all workflow conventions
- @EXECUTION_PLAN.md — Task definitions and acceptance criteria

## Execution Rules

1. **Git Workflow**
   - Create branch `step-$1.{step}` before starting each step
   - Commit after each task: `task({id}): {description}`
   - Push branch when step is complete

2. **Task Execution** (for each task)
   - Read the task definition and acceptance criteria
   - Write tests first (one per acceptance criterion)
   - Implement minimum code to pass tests
   - Run verification using /verify-task
   - Update checkboxes in EXECUTION_PLAN.md: `- [ ]` → `- [x]`
   - Commit changes

3. **Blocking Issues**
   - If blocked, report using the format in AGENTS.md
   - Do not continue past a blocker without resolution

4. **Context Hygiene**
   - Run `/compact` between steps if context grows large

## Completion

Do not check back until Phase $1 is complete, unless blocked.

When done, provide:
- Summary of what was built
- Files created/modified
- Any issues encountered
- Ready for /phase-checkpoint $1
