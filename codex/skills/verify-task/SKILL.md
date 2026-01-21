---
name: verify-task
description: Emulates the AI Coding Toolkit's Claude Code command /verify-task <task-id> (verify a specific task from EXECUTION_PLAN.md against acceptance criteria, enforce TDD expectations, fix failures with a limited retry loop). Triggers on "/verify-task" or "verify-task".
---

# /verify-task (Codex)

Verify Task `<task-id>` from `EXECUTION_PLAN.md` against its acceptance criteria.

## Inputs

- Required: task id (example: `/verify-task 1.2.A`)

If the task id is missing, ask the user for it and stop.

## Directory Guard

Confirm `EXECUTION_PLAN.md` exists in the current working directory. If not, stop and instruct the user to `cd` into the directory containing `EXECUTION_PLAN.md` and rerun `/verify-task <task-id>`.

## Workflow

### Step 1: Load Task + Criteria

1. Read the Task `<task-id>` section from `EXECUTION_PLAN.md`.
2. Extract all acceptance criteria (checkbox items under that task).

### Step 2: Parse Criteria into Verification Items

For each criterion, create a verification item:

| Field | Value |
|------:|-------|
| ID | `V-001`, `V-002`, ... |
| Criterion | criterion text |
| Type | `CODE`, `TEST`, `LINT`, `TYPE`, `BUILD`, `BROWSER` |
| Files | files to inspect / commands to run |

### Step 3: TDD Compliance Check

For each criterion:
- Locate corresponding test(s). If missing, fail fast and write tests before proceeding.
- If git history exists, check whether tests were committed before/with implementation:
  ```bash
  git log --oneline --follow -- "path/to/test/file"
  git log --oneline --follow -- "path/to/impl/file"
  ```
Record PASS/WARNING/SKIP.

### Step 4: Verify Each Criterion (Fix-and-Verify Loop)

For each criterion:
1. Verify it is met.
2. If FAIL, apply the smallest fix and re-verify.
3. Retry up to 5 attempts per criterion; avoid repeating the same fix.

Use this per-criterion record:

```text
VERIFICATION: [V-001]
---------------------
Status: PASS | FAIL | BLOCKED
Location: <file:line or N/A>
Finding: <what was found>
Expected: <what was expected>
Suggested Fix: <if FAIL>
```

### Step 5: On Success

- Check off completed criteria in `EXECUTION_PLAN.md` (`- [ ]` → `- [x]`) if and only if they are truly met.
- Update `.claude/phase-state.json` task entry if that file is in use.

### Step 6: Report

```text
TASK VERIFICATION: <task-id>
===========================

TDD Compliance:
- Tests Found: X/Y criteria covered
- Test-First: PASS | WARNING | UNABLE TO VERIFY

Criteria Verification:
- Total: N
- Passed: X
- Failed: Y
- Skipped: Z
```
