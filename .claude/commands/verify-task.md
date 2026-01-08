---
description: Run code-verification on a specific task
argument-hint: [task-id]
---

Verify Task $1 from @EXECUTION_PLAN.md using the code-verification skill.

## Task Context

1. Read Task $1 definition from EXECUTION_PLAN.md
2. Extract all acceptance criteria

## Verification

Use /code-verification to verify each acceptance criterion:

1. Parse each criterion into a testable item
2. For each criterion:
   - Pre-flight: Confirm it's testable
   - Verify if the criterion is met
   - If failed: Attempt fix (up to 5 times)
   - Update result
3. Generate verification report

## On Success

- Check off completed criteria in EXECUTION_PLAN.md: `- [ ]` → `- [x]`
- Report: Task $1 verified, all criteria met

## On Failure

- Report which criteria failed
- Provide fix recommendations
- Do not check off incomplete criteria
