---
name: populate-state
description: Emulates the AI Coding Toolkit's Claude Code command /populate-state (generate .claude/phase-state.json from EXECUTION_PLAN.md + git history to track phase/task status). Triggers on "/populate-state" or "populate-state".
---

# /populate-state (Codex)

Generate `.claude/phase-state.json` from `EXECUTION_PLAN.md` and git history.

Use when:
- starting execution on an existing project
- `.claude/phase-state.json` is missing/corrupt
- state has drifted from actual progress

## Directory Guard

Confirm `EXECUTION_PLAN.md` exists in the current working directory. If not, stop and instruct the user to `cd` into the directory containing `EXECUTION_PLAN.md` and rerun `/populate-state`.

## Workflow

1. Ensure `.claude/` exists:
   ```bash
   mkdir -p .claude
   ```

1. Parse `EXECUTION_PLAN.md` to extract:
   - phases (count `## Phase N:` headers)
   - tasks per phase (count `#### Task X.Y.Z:` headers)
   - completion status per task from acceptance criteria checkboxes
   - task is COMPLETE if all its acceptance criteria are `[x]`

1. Parse git history to extract:
   - task completion timestamps from commits matching `task(X.Y.Z):`
   - phase branches from branches matching `phase-N`

1. Determine task status:
   - `COMPLETE`: all criteria `[x]` AND git commit exists for task (if available)
   - `IN_PROGRESS`: some criteria `[x]` OR commit exists but not all criteria done
   - `BLOCKED`: explicit `**Status:** BLOCKED` marker OR stale (7+ days, incomplete, no activity)
   - `NOT_STARTED`: no criteria checked and no commit

1. Determine phase status:
   - `COMPLETE`: all tasks COMPLETE
   - `IN_PROGRESS`: at least one task COMPLETE/IN_PROGRESS but not all COMPLETE
   - `BLOCKED`: current task BLOCKED
   - `NOT_STARTED`: no tasks have progress

1. Write `.claude/phase-state.json` with this structure (create if missing, overwrite if present):

```json
{
  "schema_version": "1.0",
  "project_name": "<directory name>",
  "last_updated": "<ISO timestamp>",
  "generated_by": "populate-state",
  "main": {
    "current_phase": 1,
    "total_phases": 1,
    "status": "IN_PROGRESS",
    "phases": []
  }
}
```

1. Print a short summary (phases, task counts, blockers found).
