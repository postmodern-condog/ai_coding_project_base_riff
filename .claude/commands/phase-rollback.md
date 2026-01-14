---
description: Rollback to end of a previous phase or specific task
argument-hint: [phase-number|task-id]
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
---

Rollback the current phase branch to a clean state.

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

- If not, **STOP** and tell the user to `cd` into their project/feature directory and re-run.

## Argument Parsing

Parse `$1` to determine rollback target:

| Input | Target |
|-------|--------|
| Number (e.g., `2`) | End of Phase 2 (last task commit of that phase) |
| Task ID (e.g., `2.1.A`) | Just after that specific task's commit |
| `--last` or empty | Undo the most recent task commit |

## Pre-Rollback Safety

Before any rollback:

1. **Check for uncommitted changes:**
   ```bash
   git status --porcelain
   ```
   - If dirty, ask: "You have uncommitted changes. Stash them before rollback?"
   - If yes: `git stash push -m "pre-rollback-stash"`
   - If no: **STOP** — refuse to rollback with dirty working directory

2. **Check current branch:**
   ```bash
   git branch --show-current
   ```
   - If not on a `phase-*` or `feature/*` branch, warn: "You're on `{branch}`. Rollback is designed for phase/feature branches."

3. **Verify target exists:**
   - For phase rollback: Check commits exist with `task({phase}.` pattern
   - For task rollback: Check commit with `task({task-id}):` exists

## Rollback Strategies

### Strategy 1: Rollback to End of Phase N

```bash
# Find the last commit of Phase N
LAST_COMMIT=$(git log --oneline --grep="task($1\." | head -1 | cut -d' ' -f1)

if [ -z "$LAST_COMMIT" ]; then
  echo "No commits found for Phase $1"
  exit 1
fi

# Show what will be undone
git log --oneline $LAST_COMMIT..HEAD
```

Ask: "This will undo the commits above. Proceed?"

If yes:
```bash
git reset --hard $LAST_COMMIT
```

### Strategy 2: Rollback to After Task X.Y.Z

```bash
# Find the commit for this task
TASK_COMMIT=$(git log --oneline --grep="task($1):" | head -1 | cut -d' ' -f1)

if [ -z "$TASK_COMMIT" ]; then
  echo "No commit found for task $1"
  exit 1
fi

# Show what will be undone
git log --oneline $TASK_COMMIT..HEAD
```

Ask: "This will undo all commits after task $1. Proceed?"

If yes:
```bash
git reset --hard $TASK_COMMIT
```

### Strategy 3: Undo Last Task (--last or empty)

```bash
# Get the most recent task commit
LAST_TASK=$(git log --oneline --grep="^task(" -1 | cut -d' ' -f1)
TASK_NAME=$(git log --oneline --grep="^task(" -1 | sed 's/^[^ ]* //')

# Show what will be undone
echo "Will undo: $TASK_NAME"
```

Ask: "Undo the last task commit? This removes: {TASK_NAME}"

If yes:
```bash
git reset --hard HEAD~1
```

## Post-Rollback Actions

1. **Update EXECUTION_PLAN.md checkboxes:**
   - Find tasks that were rolled back
   - Change `- [x]` back to `- [ ]` for those tasks
   - Report which tasks are now unchecked

2. **Restore stashed changes (if any):**
   ```bash
   git stash list | grep "pre-rollback-stash" && git stash pop
   ```

3. **Report rollback summary:**
   ```
   ROLLBACK COMPLETE
   =================
   Target: {phase N | task X.Y.Z | last task}
   Commits removed: {N}
   Current HEAD: {commit hash} - {message}

   Tasks now pending:
   - [ ] Task X.Y.A: {description}
   - [ ] Task X.Y.B: {description}

   Next step: /phase-start {N} or /task-retry {X.Y.Z}
   ```

## Recovery Options

If rollback was a mistake:

```bash
# Git reflog shows all recent HEAD positions
git reflog

# Recover to a specific point
git reset --hard HEAD@{N}
```

Report: "If this rollback was a mistake, use `git reflog` to find and restore the previous state."
