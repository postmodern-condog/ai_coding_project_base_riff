---
description: Retry a failed task with fresh context and optional alternative approach
argument-hint: <task-id> [--fresh|--alternative]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---

Retry a specific task that previously failed or needs rework.

## Context Detection

Determine working context:

1. If current working directory matches pattern `*/features/*`:
   - PROJECT_ROOT = parent of parent of CWD
   - MODE = "feature"

2. Otherwise:
   - PROJECT_ROOT = current working directory
   - MODE = "greenfield"

## Directory Guard

Confirm these files exist:
- `EXECUTION_PLAN.md` in current working directory
- `PROJECT_ROOT/AGENTS.md`

If missing, **STOP** and direct user to correct directory.

## Argument Parsing

- `$1` = Task ID (required, e.g., `2.1.A`)
- `--fresh` = Start with clean context, ignore previous attempts
- `--alternative` = Explicitly try a different approach than before

## Pre-Retry Analysis

### 1. Find Previous Attempt (if exists)

Check git history for previous attempts at this task:

```bash
git log --oneline --grep="task($1):" --all
```

If previous commits exist:
- Extract the commit message and diff
- Summarize what was tried before
- Note any error patterns from the commit or nearby commits

### 2. Check Task State

Read EXECUTION_PLAN.md and check if task is:
- `- [ ]` = Not started or rolled back
- `- [x]` = Marked complete (may need verification)

### 3. Identify Blocking Patterns

Search for any recorded blockers or stuck reports related to this task:
- Check recent conversation history (if available)
- Look for `BLOCKED:` or `STUCK:` markers in any log files
- Check `TODOS.md` for related items

## Retry Strategies

### Strategy: Fresh Start (--fresh or default for uncompleted tasks)

Start the task as if it's brand new:

1. **Clear any partial work:**
   ```bash
   # If there's a partial commit for this task, offer to reset
   PARTIAL=$(git log --oneline --grep="task($1):" -1)
   if [ -n "$PARTIAL" ]; then
     echo "Found partial commit: $PARTIAL"
     # Ask user whether to reset or build on it
   fi
   ```

2. **Load fresh context:**
   - Read AGENTS.md
   - Read EXECUTION_PLAN.md (just this task's section)
   - Read relevant spec documents

3. **Execute task using standard flow:**
   - Explore codebase for patterns (don't repeat mistakes)
   - Write tests first
   - Implement
   - Verify with /verify-task
   - Commit

### Strategy: Alternative Approach (--alternative)

When the standard approach repeatedly fails:

1. **Document what was tried:**
   ```
   PREVIOUS APPROACHES
   -------------------
   Attempt 1: {description} → Failed because: {reason}
   Attempt 2: {description} → Failed because: {reason}
   ```

2. **Brainstorm alternatives:**

   Ask Claude to generate 3 alternative approaches:
   ```
   Given this task and its failures, suggest 3 alternative approaches:

   Task: {task description from EXECUTION_PLAN.md}
   Acceptance Criteria: {criteria}

   What failed:
   - {approach 1}: {why it failed}
   - {approach 2}: {why it failed}

   Alternatives to consider:
   1. Different library/tool
   2. Different architecture pattern
   3. Simplify requirements (flag for spec update)
   ```

3. **Present options to user:**
   ```
   ALTERNATIVE APPROACHES
   ----------------------
   1. {Approach A}: {brief description}
      Pros: {benefits}
      Cons: {trade-offs}

   2. {Approach B}: {brief description}
      Pros: {benefits}
      Cons: {trade-offs}

   3. {Approach C}: {brief description}
      Pros: {benefits}
      Cons: {trade-offs}

   4. Modify acceptance criteria (requires spec update)

   Which approach should we try?
   ```

4. **Execute chosen approach with explicit constraints:**
   - "Do NOT use {previous failed approach}"
   - "Use {chosen alternative} instead"

## Retry Safeguards

### Prevent Infinite Loops

Track retry attempts. If this is the 3rd+ retry:

```
WARNING: This is retry attempt #{N} for task $1

Previous attempts:
1. {date}: {approach} → {outcome}
2. {date}: {approach} → {outcome}

Consider:
- Is this task's acceptance criteria achievable?
- Should we escalate to human review?
- Should we modify the spec?

Options:
1. Try again with alternative approach
2. Mark task as blocked and continue
3. Abort and request human intervention
```

### Don't Repeat Mistakes

Before implementing, explicitly list what NOT to do:

```
CONSTRAINTS (from previous failures)
------------------------------------
- Do NOT: {thing that failed before}
- Do NOT: {another thing that failed}
- Instead: {what to try}
```

## Execution

Once approach is selected:

1. **Create checkpoint:**
   ```bash
   git stash push -m "pre-retry-$1" || true
   ```

2. **Execute task following AGENTS.md workflow:**
   - Write tests first
   - Implement with constraints
   - Run verification

3. **On success:**
   - Commit with message: `task($1): {description} (retry)`
   - Update EXECUTION_PLAN.md checkbox
   - Report success with what worked

4. **On failure:**
   - Report clearly what failed
   - Suggest next steps (alternative approach, escalate, modify spec)

## Completion Report

```
TASK RETRY RESULT
=================
Task: $1
Attempt: #{N}
Approach: {what was tried}
Status: SUCCESS | FAILED

{If SUCCESS}
What worked: {brief explanation}
Commit: {hash}
Files changed: {list}

{If FAILED}
What failed: {brief explanation}
Error: {key error message}

Recommended next step:
- {/task-retry $1 --alternative | /phase-rollback | escalate to human}
```
