---
name: progress
description: Emulates the AI Coding Toolkit's Claude Code command /progress (show progress through EXECUTION_PLAN.md by phase: completed vs remaining acceptance criteria, last completed task, next task). Triggers on "/progress" or "progress".
---

# /progress (Codex)

Show current execution status by parsing `EXECUTION_PLAN.md`.

## Directory Guard

Confirm `EXECUTION_PLAN.md` exists in the current working directory. If not, stop and instruct the user to `cd` into the directory containing `EXECUTION_PLAN.md` and rerun `/progress`.

## Report Requirements

1. Overview:
   - Total phases, steps, tasks (from the plan header and task headings)
   - Current phase in progress (first phase with incomplete items)

1. Per-phase completion:
   - Count acceptance criteria checkboxes `- [x]` vs `- [ ]`
   - Compute % complete per phase

1. Current position:
   - Last completed task (most recent task whose criteria are all checked)
   - Next task to execute (next task with any unchecked criteria)
   - Any blocked tasks (if plan contains explicit `**Status:** BLOCKED` markers)

1. Summary table:

```text
| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: <name> | Complete | 12/12 (100%) |
| Phase 2: <name> | In Progress | 5/8 (62%) |
| Phase 3: <name> | Not Started | 0/10 (0%) |
```

1. Next action recommendation:
   - `/phase-prep <N>` or `/phase-start <N>`, or `/phase-checkpoint <N>`
