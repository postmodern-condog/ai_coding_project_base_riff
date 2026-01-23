---
name: phase-checkpoint
description: Emulates the AI Coding Toolkit's Claude Code command /phase-checkpoint <N> (run checkpoint criteria: tests, typecheck, lint, security scan, coverage; list manual verification steps; update .claude/phase-state.json). Triggers on "/phase-checkpoint" or "phase-checkpoint".
---

# /phase-checkpoint (Codex)

Run checkpoint criteria after completing Phase `<N>`.

## Inputs

- Required: phase number (example: `/phase-checkpoint 1`)

If the phase number is missing, ask the user for it and stop.

## Context Detection

- If current working directory path contains `/features/<feature-name>`:
  - `PROJECT_ROOT` = parent of parent of CWD
  - `MODE` = `feature`
- Else:
  - `PROJECT_ROOT` = CWD
  - `MODE` = `greenfield`

## Directory Guard

Confirm `EXECUTION_PLAN.md` exists in the current working directory. If not, stop and instruct the user to `cd` into the directory containing `EXECUTION_PLAN.md` and rerun `/phase-checkpoint <N>`.

## Tool Availability Check (Optional)

Check browser tools in fallback order:
- ExecuteAutomation Playwright MCP:
  - Check for `mcp__playwright__*` or `mcp__executeautomation__*` tools
  - Recommended primary if available
- Browser MCP:
  - Check for `mcp__browsermcp__*` tools
  - Uses existing browser sessions
- Microsoft Playwright MCP:
  - Check for `mcp__playwright__*` tools
- Chrome DevTools MCP:
  - Attempt: `mcp__chrome-devtools__list_pages`
  - Basic fallback, often pre-installed

**If phase has BROWSER:* criteria but NO browser tools available (SOFT BLOCK):**
- Display warning listing the browser criteria that cannot be verified
- Prompt user to choose:
  - "Continue with manual verification" → Add browser checks to Manual Verification section
  - "Stop to configure tools" → Halt checkpoint and provide setup instructions

Other tools:
- Trigger.dev MCP:
  - Attempt: `mcp__trigger__list_projects`
  - If unavailable: skip Trigger.dev checks.

## Automated Checks

Run and report results:

1. **Tests**
   - Use the repo's configured test command (from `AGENTS.md` or `package.json`).

2. **Type Checking**
   - Run the configured typecheck command (if applicable).

3. **Linting**
   - Run the configured lint command (if applicable).

4. **Security Scan**
   - Run the `/security-scan` workflow (dependency audit, secrets detection, static analysis).
   - CRITICAL or HIGH findings block checkpoint until resolved (or explicitly accepted by the user).

5. **Coverage (if available)**
   - Run the configured coverage command (if applicable).
   - Target: 80% (if meaningful for the repo).

## Manual Verification

From the "Phase N Checkpoint" section in `EXECUTION_PLAN.md`:
- List each manual verification item with its reason
- For each item, provide numbered step-by-step instructions:
  1. What to do (specific actions)
  2. What to look for (expected outcomes)
  3. How to confirm success

## Approach Review (Human)

Ask the human to sanity-check:
- Appropriate abstractions (not over/under-engineered)
- Follows existing patterns/conventions
- No unnecessary dependencies
- Consistent error handling

## State Update

If checkpoint passes, update `.claude/phase-state.json`:
- Set phase status to `CHECKPOINTED`
- Add `completed_at` timestamp
- Record checkpoint results (tests/typecheck/lint/security/coverage/manual verification)

If checkpoint fails:
- Keep phase status as `IN_PROGRESS`
- Add checkpoint failure details

## Report Format

```text
Phase <N> Checkpoint Results
===========================

Tool Availability:
- ExecuteAutomation Playwright: ✓ | ✗ (primary)
- Browser MCP Extension: ✓ | ✗
- Microsoft Playwright MCP: ✓ | ✗
- Chrome DevTools MCP: ✓ | ✗
- Trigger.dev MCP: ✓ | ✗ | N/A

Automated Checks:
- Tests: PASSED | FAILED
- Type Check: PASSED | FAILED | SKIPPED
- Linting: PASSED | FAILED | SKIPPED
- Security: PASSED | FAILED | X critical, Y high
- Coverage: <X>% (target: 80%) | SKIPPED

Manual Verification:
- [ ] <item description>
  - Reason: <why human review is needed>
  - Steps:
    1. <First action to take>
    2. <What to verify/look for>
    3. <How to confirm success>

Approach Review: No issues noted | <issues>

Overall: Ready to proceed | Issues to address
```
