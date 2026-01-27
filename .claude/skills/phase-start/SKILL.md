---
name: phase-start
description: Execute all tasks in a phase autonomously. Use after /phase-prep confirms prerequisites are met.
argument-hint: "<phase-number> [--codex] [--pause]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebFetch, WebSearch
---

Execute all steps and tasks in Phase $1 from EXECUTION_PLAN.md.

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `$1` | Yes | Phase number to execute |
| `--codex` | No | Execute tasks via Codex CLI instead of directly |
| `--pause` | No | Stop after phase completes (skip auto-advance to checkpoint) |

## Execution Modes

**Default mode:** Claude Code executes tasks directly using its tools.

**Codex mode (`--codex`):** Claude Code orchestrates while Codex CLI executes each task:
- Claude Code maintains context, verification, auto-advance logic
- Codex executes individual tasks with documentation research
- Results return to Claude Code for verification and next-task decisions

Use `--codex` when:
- Tasks involve external APIs where current documentation matters
- You want cross-model execution for different perspectives
- Codex's web search during implementation adds value

## External Tool Documentation Protocol

**CRITICAL:** Before implementing code that integrates with external services, you MUST read the latest official documentation first.

### When to Fetch Docs

Fetch documentation when ANY of these apply:
- Task involves integrating with a third-party API (Supabase, Stripe, Firebase, etc.)
- You're writing code that calls external service endpoints
- Task references SDK usage for an external service
- You need to implement webhooks, authentication, or data sync with external services

### How to Fetch Docs

1. **Identify external services** from task description and acceptance criteria
2. **Fetch relevant docs** using WebFetch or WebSearch:
   - SDK/library installation and setup
   - API reference for specific endpoints being used
   - Code examples for the integration pattern
3. **Cache per session** — Don't re-fetch docs already fetched in this session
4. **Handle failures gracefully:**
   - Retry with exponential backoff (2-3 attempts)
   - If all retries fail: warn user and proceed with best available info

### Documentation URLs by Service

| Service | SDK/API Documentation |
|---------|----------------------|
| Supabase | https://supabase.com/docs/reference/javascript |
| Firebase | https://firebase.google.com/docs/reference/js |
| Stripe | https://stripe.com/docs/api |
| Auth0 | https://auth0.com/docs/api |
| Clerk | https://clerk.com/docs/references/javascript |
| Resend | https://resend.com/docs/api-reference |
| OpenAI | https://platform.openai.com/docs/api-reference |
| Anthropic | https://docs.anthropic.com/en/api |
| Trigger.dev | https://trigger.dev/docs |

For services not listed, use WebSearch: `{service name} {language} SDK documentation`

### Integration with Task Execution

When implementing external service integrations:
1. Fetch docs FIRST before writing integration code
2. Use the official SDK patterns (not outdated examples)
3. Follow current authentication methods from docs
4. Reference error handling patterns from official documentation
5. Check for breaking changes if using a newer SDK version

## Context Detection

Determine working context:

1. If current working directory matches pattern `*/features/*`:
   - PROJECT_ROOT = parent of parent of CWD (e.g., `/project/features/foo` → `/project`)
   - MODE = "feature"

2. Otherwise:
   - PROJECT_ROOT = current working directory
   - MODE = "greenfield"

## Context

Before starting, read these files:
- **PROJECT_ROOT/AGENTS.md** — Follow all workflow conventions
- **EXECUTION_PLAN.md** — Task definitions and acceptance criteria (from CWD)

## Directory Guard (Wrong Directory Check)

Before starting, confirm the required files exist:
- `EXECUTION_PLAN.md` exists in the current working directory
- `PROJECT_ROOT/AGENTS.md` exists

- If either is missing, **STOP** and tell the user to `cd` into their project/feature directory (the one containing `EXECUTION_PLAN.md`) and re-run `/phase-start $1`.

## Context Check

**Before starting:** If context is below 40% remaining, run `/compact` first. This ensures the full command instructions remain in context throughout execution. Compaction mid-command loses procedural instructions.

## Codex Mode Prerequisites (if `--codex` flag provided)

Skip this section if `--codex` was not provided.

### Check Codex CLI

```bash
# Verify Codex is installed
codex --version

# Verify authentication
codex login status
```

**If Codex CLI not available:**
```
ERROR: --codex flag requires Codex CLI
=======================================
Codex CLI is not installed or not authenticated.

Install: npm install -g @openai/codex
Auth:    codex login

Falling back to default execution mode.
```

Fall back to default mode (Claude Code executes directly). Do NOT block the phase.

### Read Codex Configuration

Read `.claude/settings.local.json` for Codex settings:

```json
{
  "multiModelVerify": {
    "codexModel": "o3",
    "taskTimeoutMinutes": 60
  }
}
```

Extract configuration values:

```bash
# Extract model (default: omit flag to use Codex default)
CODEX_MODEL=$(jq -r '.multiModelVerify.codexModel // empty' .claude/settings.local.json 2>/dev/null)

# Extract timeout in minutes (default: 60 = 1 hour)
TIMEOUT_MINS=$(jq -r '.multiModelVerify.taskTimeoutMinutes // 60' .claude/settings.local.json 2>/dev/null || echo "60")
TIMEOUT_SECS=$((TIMEOUT_MINS * 60))
```

Use defaults if not configured: model=Codex default, timeout=60 minutes.

## Execution Rules

1. **Git Workflow (Auto-Commit)**

   **One branch per phase, one commit per task:**
   ```
   main
     └── phase-$1 (branch)
           ├── task(1.1.A): Add user model       ← step 1.1
           ├── task(1.1.B): Add user routes
           ├── task(1.1.C): Add user tests
           ├── task(1.2.A): Add auth middleware   ← step 1.2 continues
           ├── task(1.2.B): Add login endpoint
           └── task(1.3.A): Add session handling  ← step 1.3 continues
   ```

   Before starting the phase (once, at the beginning):
   ```bash
   # Commit any dirty files first (preserves user work)
   git add -A && git diff --cached --quiet || git commit -m "wip: uncommitted changes before phase-$1"
   ```

   **Check for unpushed commits before branching:**
   ```bash
   # Get current branch and check if ahead of remote
   CURRENT_BRANCH=$(git branch --show-current)
   UNPUSHED=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "no-upstream")
   ```

   - If `UNPUSHED` is a number > 0:
     - Ask: "You have {UNPUSHED} unpushed commit(s) on `{CURRENT_BRANCH}`. Push before creating phase branch? (recommended)"
     - If yes: `git push`
     - If no: Continue (user accepts branching from unpushed state)
   - If `UNPUSHED` is "no-upstream" or 0: Continue without prompting

   ```bash
   # Create phase branch from current HEAD
   git checkout -b phase-$1
   ```

   After each task completion (sequential commits on same branch):
   ```bash
   git add -A
   git commit -m "task({id}): {description} [REQ-XXX]"
   ```

   **Requirement traceability:** Check the task's `Requirement:` field in EXECUTION_PLAN.md.
   - If a REQ-ID exists (e.g., `REQ-002`), include it: `task(1.2.A): Add auth [REQ-002]`
   - If no REQ-ID or "None", omit brackets: `task(1.1.A): Set up scaffolding`

   **Do NOT push.** Leave pushing to the human after manual verification at checkpoint.

   **Commit discipline:**
   - Every task gets its own commit immediately after verification passes
   - All commits are sequential on the phase branch—each builds on the previous
   - Steps are logical groupings, not separate branches
   - Never batch multiple tasks into one commit
   - Include task ID in commit message for traceability
   - Use conventional commit format: `task({id}): {imperative description}`

2. **Task Execution** (for each task)

   {If `--codex` flag provided}

   **Codex Execution Mode:**

   a. **Build task prompt** — Write to a temp file:

      ```bash
      # Create prompt file path
      TASK_PROMPT="/tmp/codex-task-${task_id}.md"
      TASK_OUTPUT="/tmp/codex-task-${task_id}-output.txt"
      ```

      Write the following content to `$TASK_PROMPT`:

      ```markdown
      # Task Execution Request

      ## Project Context

      Read these files first:
      - AGENTS.md (workflow conventions)
      - EXECUTION_PLAN.md (full plan context)
      - {relevant source files for this task}

      ## Task to Execute

      **Task ID:** {task_id}
      **Description:** {task description}

      ## Acceptance Criteria

      {list acceptance criteria from EXECUTION_PLAN.md}

      ## Instructions

      1. **Explore first:** Search for similar existing functionality, identify patterns
      2. **Write tests first:** One test per acceptance criterion
      3. **Implement:** Minimum code to pass tests, following codebase patterns
      4. **Verify:** Run tests, ensure all pass
      5. **Report results** in this exact format at the end of your response:

      TASK EXECUTION RESULT
      =====================
      Task: {task_id}
      Status: COMPLETE | FAILED | BLOCKED

      Files Created:
      - {path}

      Files Modified:
      - {path}

      Tests:
      - {test status summary}

      {If FAILED or BLOCKED}
      Issue: {description}
      {/If}

      ## Constraints

      - Follow patterns in AGENTS.md
      - Use project's existing conventions (naming, structure, error handling)
      - Do NOT commit (orchestrator handles commits)
      - Do NOT modify EXECUTION_PLAN.md (orchestrator handles checkboxes)
      ```

   b. **Execute via Codex:**

      Build the command with optional model flag:

      ```bash
      # Build model flag if configured
      MODEL_FLAG=""
      if [ -n "$CODEX_MODEL" ]; then
        MODEL_FLAG="--model $CODEX_MODEL"
      fi

      # Execute with timeout (default: 1 hour)
      timeout ${TIMEOUT_SECS:-3600} bash -c "cat $TASK_PROMPT | codex exec \
        --sandbox danger-full-access \
        -c 'approval_policy=\"never\"' \
        -c 'features.search=true' \
        $MODEL_FLAG \
        -o $TASK_OUTPUT \
        -"
      EXIT_CODE=$?
      ```

      **Flags explained:**
      - `--sandbox danger-full-access`: Full file and network access for task execution
      - `-c 'approval_policy="never"'`: Non-interactive, no approval prompts
      - `-c 'features.search=true'`: Enable web search for documentation research
      - `--model`: Optional, uses configured model or Codex default
      - `-o $TASK_OUTPUT`: Write final response to file for parsing
      - `-`: Read prompt from stdin
      - `timeout`: Hard limit per task (default 1 hour)

   c. **Process results:**

      Handle exit codes and parse output:

      ```bash
      # Check exit status
      if [ $EXIT_CODE -eq 124 ]; then
        # Timeout
        STATUS="FAILED"
        ISSUE="Task timed out after ${TIMEOUT_MINS:-60} minutes"
      elif [ $EXIT_CODE -ne 0 ]; then
        # Codex error
        STATUS="FAILED"
        ISSUE="Codex exited with code $EXIT_CODE"
      elif [ ! -f "$TASK_OUTPUT" ]; then
        # No output file
        STATUS="FAILED"
        ISSUE="Codex produced no output"
      else
        # Parse the output file for TASK EXECUTION RESULT block
        # Extract Status line (format: "Status: COMPLETE | FAILED | BLOCKED")
        STATUS=$(grep "^Status:" "$TASK_OUTPUT" | head -1 | awk '{print $2}')
        if [ -z "$STATUS" ]; then
          # Fallback: try without anchor in case of indentation
          STATUS=$(grep "Status:" "$TASK_OUTPUT" | head -1 | awk '{print $2}')
        fi
        if [ -z "$STATUS" ]; then
          STATUS="FAILED"
          ISSUE="Could not parse task result from Codex output"
        fi
      fi
      ```

      Based on status:
      - If `COMPLETE`: proceed to verification
      - If `FAILED` or `BLOCKED`: apply stuck detection logic (see section 3)
      - Log the issue and increment failure counter

   d. **Verify and commit:**
      - Run `/verify-task {task_id}` (Claude Code verifies Codex's work)
      - Update checkboxes in EXECUTION_PLAN.md
      - Commit (see Git Workflow above)
      - Clean up temp files: `rm -f $TASK_PROMPT $TASK_OUTPUT`

   {Else}

   **Default Execution Mode:**

   - Read the task definition and acceptance criteria
   - **Explore before implementing:**
     - Search for similar existing functionality (don't duplicate)
     - Identify patterns used elsewhere in codebase
     - List reusable utilities/components to leverage
     - Note conventions (naming, error handling, structure)
   - Write tests first (one per acceptance criterion)
   - Implement minimum code to pass tests, following discovered patterns
   - Run verification using /verify-task
   - Update checkboxes in EXECUTION_PLAN.md: `- [ ]` → `- [x]`
   - **Commit immediately** (see Git Workflow above)

   {/If}

3. **Stuck Detection and Recovery**

   Track consecutive failures. If ANY of these occur, **STOP and escalate to human**:

   | Trigger | Threshold | Action |
   |---------|-----------|--------|
   | Consecutive task failures | 3 tasks | Pause phase |
   | Same error pattern | 2 occurrences | Pause and report pattern |
   | Verification loop | 5 attempts on same criterion | Mark task blocked |
   | Test flakiness | Same test passes then fails | Flag for review |

   **When stuck, report:**
   ```
   STUCK: Phase $1, Task {id}
   ─────────────────────────────
   Pattern: {describe what keeps failing}
   Attempts: {N}

   Last 3 errors:
   1. {error summary}
   2. {error summary}
   3. {error summary}

   Possible causes:
   - {hypothesis 1}
   - {hypothesis 2}

   Options:
   1. Skip this task and continue
   2. Modify acceptance criteria
   3. Take a different approach: {suggestion}
   4. Abort phase for manual intervention
   ```

   **Do not:**
   - Keep retrying the same approach
   - Silently skip failing tasks
   - Reduce test coverage to make things pass

4. **Blocking Issues**
   - If blocked, report using the format in AGENTS.md
   - Do not continue past a blocker without resolution

5. **Context Hygiene**
   - Summarize progress between steps if context grows large

## State Tracking

Maintain `.claude/phase-state.json` throughout execution:

1. **At phase start**, update state:
   ```bash
   mkdir -p .claude
   ```

   Set phase status to `IN_PROGRESS` with `started_at` timestamp and `execution_mode`:
   ```json
   {
     "status": "IN_PROGRESS",
     "started_at": "{ISO timestamp}",
     "execution_mode": "default | codex"
   }
   ```

2. **After each task completion**, update the task entry:
   ```json
   {
     "tasks": {
       "{task_id}": {
         "status": "COMPLETE",
         "completed_at": "{ISO timestamp}"
       }
     }
   }
   ```

3. **If task is blocked**, record the blocker:
   ```json
   {
     "tasks": {
       "{task_id}": {
         "status": "BLOCKED",
         "blocker": "{description}",
         "blocker_type": "user-action|dependency|external-service|unclear-requirements",
         "since": "{ISO timestamp}"
       }
     }
   }
   ```

4. **State file format** (create if missing):
   ```json
   {
     "schema_version": "1.0",
     "project_name": "{directory name}",
     "last_updated": "{ISO timestamp}",
     "main": {
       "current_phase": 1,
       "total_phases": 6,
       "status": "IN_PROGRESS",
       "phases": [
         {
           "number": 1,
           "name": "{Phase Name}",
           "status": "IN_PROGRESS",
           "started_at": "{ISO timestamp}",
           "tasks": {}
         }
       ]
     }
   }
   ```

If `.claude/phase-state.json` doesn't exist, run `/populate-state` first to initialize it.

---

## Completion

Do not check back until Phase $1 is complete, unless blocked or stuck.

When done, provide:
- Execution mode used (default or Codex)
- Summary of what was built
- Files created/modified
- Git branch and commits created
- Any issues encountered
- Ready for /phase-checkpoint $1

**Note:** Branches are not pushed automatically. After `/phase-checkpoint` passes, the human will review and push.

---

## Auto-Advance (After Phase Completes)

Check if auto-advance is enabled and this phase completes with no manual items.

### Configuration Check

Read `.claude/settings.local.json` for auto-advance configuration:

```json
{
  "autoAdvance": {
    "enabled": true      // default: true
  }
}
```

If `autoAdvance` is not configured, use defaults (`enabled: true`).

### Pre-Check: Attempt Automation on Manual Items

Before evaluating auto-advance conditions, attempt automation on checkpoint manual items:

1. Extract manual verification items from "Phase $1 Checkpoint" section in EXECUTION_PLAN.md
2. For each manual item, invoke auto-verify skill with item text and available tools
3. Categorize results:
   - **Automated**: Item can be verified automatically (PASS/FAIL)
   - **Truly Manual**: No automation possible (subjective criteria like "feels intuitive")

### Auto-Advance Conditions

Auto-advance to `/phase-checkpoint $1` ONLY if ALL of these are true:

1. ✓ All tasks in Phase $1 are complete
2. ✓ No "truly manual" checkpoint items remain (automated items are OK)
3. ✓ No tasks were marked as blocked or skipped
4. ✓ `--pause` flag was NOT passed to this command
5. ✓ `autoAdvance.enabled` is true (or not configured, defaulting to true)

**Rationale:** Auto-verify attempts automation before blocking. Only items that genuinely require human judgment (UX, visual aesthetics, brand tone) block auto-advance. Items that can be verified with curl, file checks, or browser automation don't require human presence.

### If Auto-Advance Conditions Met

1. **Show brief notification:**
   ```
   AUTO-ADVANCE
   ============
   All Phase $1 tasks complete. No truly manual verification items.
   {N} checkpoint items can be auto-verified.
   Proceeding to checkpoint...
   ```

2. **Execute immediately:**
   - Track this command in auto-advance session log
   - Invoke `/phase-checkpoint $1` using the Skill tool
   - Checkpoint will continue the chain if it passes

### If Auto-Advance Conditions NOT Met

Stop and report why:

```
PHASE $1 COMPLETE
=================
All tasks finished.

Cannot auto-advance because:
- {reason: e.g., "Phase has truly manual verification items"}

Checkpoint Verification Preview:
--------------------------------
Automatable ({N} items):
- [auto] "{item}" — can verify with {method}

Truly Manual ({N} items requiring human judgment):
- [ ] "{item}"
  - Reason: {why automation not possible, e.g., "subjective UX assessment"}

Next: Run /phase-checkpoint $1 when ready to verify
```
