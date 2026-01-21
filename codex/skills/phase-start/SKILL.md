---
name: phase-start
description: Emulates the AI Coding Toolkit's Claude Code command /phase-start <N> (execute all tasks in a phase autonomously: one branch per phase, one commit per task, TDD, verification after each task, update EXECUTION_PLAN.md checkboxes, maintain .claude/phase-state.json). Triggers on "/phase-start" or "phase-start".
---

# /phase-start (Codex)

Execute all steps and tasks in Phase `<N>` from `EXECUTION_PLAN.md`.

## Inputs

- Required: phase number (example: `/phase-start 1`)

If the phase number is missing, ask the user for it and stop.

## Context (must load before starting)

- Read `PROJECT_ROOT/AGENTS.md` and follow its workflow conventions.
- Read `EXECUTION_PLAN.md` from the current working directory.

## Context Detection

- If current working directory path contains `/features/<feature-name>`:
  - `PROJECT_ROOT` = parent of parent of CWD
  - `MODE` = `feature`
- Else:
  - `PROJECT_ROOT` = CWD
  - `MODE` = `greenfield`

## Directory Guard (Wrong Directory Check)

Before starting, confirm:
- `EXECUTION_PLAN.md` exists in the current working directory
- `PROJECT_ROOT/AGENTS.md` exists

If either is missing, stop and tell the user to `cd` into the directory containing `EXECUTION_PLAN.md` and rerun `/phase-start <N>`.

## Execution Rules

### 1) Git Workflow (Auto-Commit)

One branch per phase, one commit per task.

Before branching (once, at phase start):

```bash
git add -A && git diff --cached --quiet || git commit -m "wip: uncommitted changes before phase-<N>"
```

Create and switch to the phase branch (from current HEAD):

```bash
git checkout -b phase-<N>
```

After each task completion:

```bash
git add -A
git commit -m "task(<task-id>): <imperative description>"
```

Do not push. Leave pushing to the human after checkpoint review.

### 2) State Tracking (`.claude/phase-state.json`)

Maintain `.claude/phase-state.json` throughout execution.

If the file does not exist, initialize it (or run `/populate-state` first).

At phase start:
- Mark phase `<N>` as `IN_PROGRESS` with `started_at` timestamp.

After each task:
- Record task as `COMPLETE` with `completed_at`.

If a task is blocked:
- Record `BLOCKED` with `blocker`, `blocker_type`, and `since`.

### 3) Task Execution Loop (for each task in Phase N)

For each task:

1. Read task definition + acceptance criteria from `EXECUTION_PLAN.md`.
2. Explore before implementing:
   - Search for existing similar functionality; do not duplicate.
   - Identify reusable utilities/components and code conventions.
3. Write tests first:
   - One test per acceptance criterion.
   - Use AAA pattern.
   - Test names: `should {expected behavior} when {condition}`.
4. Implement minimum code to pass tests.
5. Verify:
   - Run tests/typecheck/lint as appropriate.
   - Run the `/verify-task <task-id>` workflow and fix any failures.
6. Update `EXECUTION_PLAN.md`:
   - Check off completed criteria: `- [ ]` → `- [x]`.
7. Commit immediately (see Git Workflow above).

### 4) Stuck Detection (Escalate Instead of Spinning)

Stop and ask the human if any occurs:
- 3 consecutive task failures
- same error pattern repeats twice
- 5 verification attempts on same criterion
- test flakiness (same test passes then fails)

Use this format:

```text
STUCK: Phase <N>, Task <task-id>
─────────────────────────────
Pattern: <what keeps failing>
Attempts: <N>

Last 3 errors:
1. <error summary>
2. <error summary>
3. <error summary>

Possible causes:
- <hypothesis 1>
- <hypothesis 2>

Options:
1. Skip this task and continue
2. Modify acceptance criteria
3. Take a different approach: <suggestion>
4. Abort phase for manual intervention
```

### 5) Blocking Issues

If blocked, report using the blocker format from `AGENTS.md` and do not continue past the blocker without resolution.

## Completion

When Phase `<N>` is complete, provide:
- Summary of what was built
- Files created/modified
- Git branch and commits created
- Any issues encountered
- Ready for `/phase-checkpoint <N>`
