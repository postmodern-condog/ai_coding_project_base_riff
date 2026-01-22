# Recovery Commands

These commands help you handle failures, analyze issues, and recover from problems during execution.

## Installation

Recovery commands are not installed by default. To enable them:

```bash
cp extras/claude/commands/* .claude/commands/
```

Or selectively copy only the commands you need.

## Commands

### /phase-analyze N

Analyzes what went wrong in a phase.

```bash
/phase-analyze 2    # Analyze Phase 2 failures
```

**What it does:**
- Reviews git history for the phase branch
- Identifies failed tasks and their error patterns
- Summarizes verification failures
- Suggests possible causes and fixes

**When to use:**
- After a phase fails and you want to understand why
- Before deciding whether to retry or rollback
- When debugging recurring issues

### /phase-rollback N

Rolls back to the end of a completed phase (or to a specific task).

```bash
/phase-rollback 1           # Rollback to end of Phase 1
/phase-rollback 1.2.A       # Rollback to after task 1.2.A
```

**What it does:**
- Checks out the commit at the specified point
- Creates a new branch from that point
- Preserves the rolled-back commits in the original branch

**When to use:**
- When a phase has gone off track and needs a fresh start
- When you want to try a different approach from a known-good state
- After discovering a fundamental issue partway through execution

**Caution:** This discards work. Make sure you've analyzed the failures and understand what went wrong before rolling back.

### /task-retry X.Y.Z

Retries a failed task with fresh context.

```bash
/task-retry 2.1.B    # Retry task 2.1.B
```

**What it does:**
- Reverts changes from the failed task attempt
- Re-reads the task requirements with fresh context
- Attempts the task again, potentially with a different approach

**When to use:**
- When a task failed due to a minor issue that's now fixed
- When context was lost and a fresh attempt might succeed
- After manually fixing a blocking issue

## Recovery Workflow

Typical recovery flow when execution fails:

1. **Analyze**: Run `/phase-analyze N` to understand what went wrong
2. **Decide**: Based on the analysis:
   - Minor issue → `/task-retry X.Y.Z`
   - Fundamental problem → `/phase-rollback N`
   - External blocker → Fix manually, then continue
3. **Continue**: Resume with `/phase-start N` or `/phase-checkpoint N`

## Preventing Issues

To reduce the need for recovery:

1. **Run `/phase-prep N`** before starting each phase to catch missing prerequisites
2. **Review checkpoints carefully** before moving to the next phase
3. **Keep acceptance criteria specific** and testable
4. **Use `/configure-verification`** to set up your stack's test/lint/build commands
