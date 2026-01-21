---
description: Analyze what went wrong in a phase and recommend fixes
argument-hint: [phase-number]
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
---

Analyze a phase that had problems and provide actionable recommendations.

## Context Detection

Determine working context:

1. If current working directory matches pattern `*/features/*`:
   - PROJECT_ROOT = parent of parent of CWD
   - MODE = "feature"

2. Otherwise:
   - PROJECT_ROOT = current working directory
   - MODE = "greenfield"

## Directory Guard

Confirm `EXECUTION_PLAN.md` exists in the current working directory.

If missing, **STOP** and direct user to correct directory.

## Analysis Scope

If `$1` is provided, analyze Phase $1 specifically.
If `$1` is omitted, analyze the current/most recent phase (detect from git branch or EXECUTION_PLAN.md progress).

## Data Collection

### 1. Git History Analysis

```bash
# Get all commits for this phase
git log --oneline --grep="task($1\." --reverse

# Get commits with their stats
git log --stat --grep="task($1\." --reverse

# Find any reverted or amended commits
git log --oneline --grep="revert\|Revert" --since="1 week ago"
```

Extract:
- Number of commits
- Number of task commits vs other commits (WIP, fixes, etc.)
- Any reverts or amendments
- Time span of the phase

### 2. Task Completion Status

Read EXECUTION_PLAN.md and count:
- Total tasks in phase
- Completed tasks (`- [x]`)
- Incomplete tasks (`- [ ]`)
- Tasks with partial checkboxes (some criteria met)

### 3. Error Pattern Detection

Search for common failure patterns:

```bash
# Recent test failures in git log
git log --oneline --grep="fail\|error\|broken" --since="1 week ago"

# Files that were modified multiple times (churn)
git log --name-only --grep="task($1\." | sort | uniq -c | sort -rn | head -10
```

### 4. Spec Alignment Check

Compare implementation against specs:

- Read relevant sections of TECHNICAL_SPEC.md (or FEATURE_TECHNICAL_SPEC.md)
- For each incomplete task, check if:
  - Acceptance criteria are clear and testable
  - Required files/dependencies exist
  - Spec assumptions match reality

## Analysis Report

Generate a comprehensive analysis:

```
PHASE $1 ANALYSIS
=================

## Summary

| Metric | Value |
|--------|-------|
| Tasks in phase | {N} |
| Completed | {N} ({%}) |
| Incomplete | {N} |
| Commits | {N} (expected: {tasks}, actual: {commits}) |
| Files churned (3+ edits) | {N} |
| Duration | {time span} |

## Completion Status

### Completed Tasks
- [x] Task $1.1.A: {name}
- [x] Task $1.1.B: {name}

### Incomplete Tasks
- [ ] Task $1.2.A: {name}
  - Status: {not started | partial | blocked}
  - Criteria met: {N}/{total}

- [ ] Task $1.2.B: {name}
  - Status: {not started | partial | blocked}
  - Criteria met: {N}/{total}

## Failure Patterns Detected

### Pattern 1: {Name}
- **Where:** {tasks or files affected}
- **Symptom:** {what went wrong}
- **Likely cause:** {analysis}
- **Evidence:** {git commits, error messages}

### Pattern 2: {Name}
...

## High-Churn Files

Files edited 3+ times (indicates rework or unclear requirements):

| File | Edits | Tasks | Concern |
|------|-------|-------|---------|
| {path} | {N} | {task IDs} | {why this is concerning} |

## Spec Issues Found

### Issue 1: {Vague or Missing Requirement}
- **Location:** TECHNICAL_SPEC.md, Section {X}
- **Problem:** {description}
- **Impact:** Caused confusion in Task {X.Y.Z}
- **Recommendation:** {how to clarify}

### Issue 2: {Unrealistic Assumption}
...

## Root Cause Analysis

Based on the above data, the primary issues were:

1. **{Root Cause 1}**
   - Contributed to: {tasks affected}
   - Fix: {recommendation}

2. **{Root Cause 2}**
   - Contributed to: {tasks affected}
   - Fix: {recommendation}

## Recommendations

### Immediate Actions (to complete this phase)

1. **{Action 1}**
   - Why: {brief justification}
   - How: {specific steps}
   - Unblocks: Task {X.Y.Z}

2. **{Action 2}**
   ...

### Spec Updates Needed

- [ ] Update TECHNICAL_SPEC.md: {specific change}
- [ ] Clarify EXECUTION_PLAN.md Task {X.Y.Z} criteria
- [ ] Add missing prerequisite to Phase {N} setup

### Process Improvements (for future phases)

1. **{Improvement 1}**
   - Problem it addresses: {pattern from above}
   - Change to make: {specific process change}

## Suggested Next Steps

Choose one:

1. **Fix and continue** — Apply immediate actions, then `/phase-start $1` to resume
2. **Rollback and retry** — `/phase-rollback {target}`, address root causes, start fresh
3. **Modify scope** — Update specs to remove/simplify problematic tasks
4. **Escalate** — These issues require human decision: {list}
```

## Interactive Mode

After presenting the analysis, ask:

```
What would you like to do?

1. Deep dive into a specific failure pattern
2. Generate fix plan for incomplete tasks
3. Update specs based on findings
4. Start fresh with /phase-rollback
5. Continue with recommended immediate actions
```

## Quick Diagnostics

For fast troubleshooting, also output a one-liner summary:

```
QUICK DIAGNOSIS: Phase $1 is {X}% complete. Main blocker: {one sentence}.
Recommended: {/task-retry X.Y.Z | /phase-rollback N | update spec section Y}
```
