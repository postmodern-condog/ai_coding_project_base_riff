---
description: Run checkpoint criteria after completing a phase
argument-hint: [phase-number]
allowed-tools: Bash, Read, Edit, Glob, Grep, AskUserQuestion
---

Phase $1 is complete. Read EXECUTION_PLAN.md and run the checkpoint criteria.

## Context Detection

Determine working context:

1. If current working directory matches pattern `*/features/*`:
   - PROJECT_ROOT = parent of parent of CWD (e.g., `/project/features/foo` → `/project`)
   - MODE = "feature"

2. Otherwise:
   - PROJECT_ROOT = current working directory
   - MODE = "greenfield"

## Directory Guard (Wrong Directory Check)

Before starting, confirm `EXECUTION_PLAN.md` exists in the current working directory.

- If it does not exist, **STOP** and tell the user to `cd` into their project/feature directory (the one containing `EXECUTION_PLAN.md`) and re-run `/phase-checkpoint $1`.

## Tool Availability Check

Before running checks, detect which optional tools are available by attempting a harmless call:

| Tool | Check Method | Fallback |
|------|--------------|----------|
| Playwright MCP | Attempt a harmless Playwright MCP call (e.g., list pages) | Manual browser verification |
| code-simplifier | Check if agent type available | Skip code simplification |
| Trigger.dev MCP | `mcp__trigger__list_projects` | Skip Trigger.dev checks |

Read `.claude/verification-config.json` from PROJECT_ROOT. Use it to determine
commands for tests, lint, typecheck, build, coverage, and dev server.

If the config is missing or required commands are empty:
- Run `/configure-verification`
- Do not proceed with automated checks until commands are configured

## Automated Checks

Run these commands and report results:

1. **Tests**
   ```
   {commands.test from verification-config}
   ```
   (if empty, block and ask to configure)

2. **Type Checking**
   ```
   {commands.typecheck from verification-config}
   ```
   (if empty, mark as not applicable or configure)

3. **Linting**
   ```
   {commands.lint from verification-config}
   ```
   (if empty, mark as not applicable or configure)

4. **Security Scan**

   Run security checks:
   - Use the project’s configured security tooling (if documented)
   - Run secrets detection (pattern-based)
   - Run static analysis via documented tools or ask for a command

   For CRITICAL or HIGH issues:
   - Present each issue with resolution options
   - Apply fixes based on user choices
   - Re-scan to confirm resolution

   Security scan blocks checkpoint if CRITICAL or HIGH issues remain unresolved.

5. **Code Quality Metrics**

   Collect and report these metrics for the phase:

   ```
   CODE QUALITY METRICS
   --------------------
   Test Coverage: {X}% (target: 80%)
   Files changed in phase: {N}
   Lines added: {N}
   Lines removed: {N}
   New dependencies added: {list or "None"}
   ```

   To get coverage:
   - Use `commands.coverage` from verification-config if present
   - If empty, mark coverage as not applicable or ask to configure

   Flag if coverage dropped compared to before the phase (if a baseline exists).

## Optional Enhanced Checks

These checks run only if the required tools are available (detected above).

6. **Code Simplification** (requires: code-simplifier plugin)

   If available, run code-simplifier on files changed in this phase:
   ```bash
   git diff --name-only HEAD~{commits-in-phase}
   ```

   Focus: reduce complexity, improve naming, eliminate redundancy. Preserve all functionality.

7. **Browser Verification** (requires: Playwright MCP)

   If Playwright MCP is available and phase includes UI work:
   - Parse Phase $1 tasks for acceptance criteria marked `BROWSER:*`
   - Use the browser-verification skill with each criterion's `Verify:` metadata
   - Take snapshots for verification

   If unavailable:
   - Add browser checks to Human Required section instead

8. **Technical Debt Check** (optional)

   If `.claude/skills/tech-debt-check/SKILL.md` exists:
   - Run duplication analysis
   - Run complexity analysis
   - Check file sizes
   - Detect AI code smells

   Report findings with severity levels. Informational only (does not block).

## Human Required

From the "Phase $1 Checkpoint" section in EXECUTION_PLAN.md:
- List each human-required item and its reason
- For each item, provide step-by-step instructions explaining how to verify it
- Indicate what I need to verify before proceeding

## Approach Review (Human)

Ask the human to review the phase's implementation approach against these criteria:

- Solutions use appropriate abstractions (not over/under-engineered)
- New code follows existing codebase patterns and conventions
- No unnecessary dependencies were added
- Error handling is consistent with rest of codebase
- Any "almost correct" AI solutions that need refinement?

**Reporting format:**
- Only list items that have issues or need attention
- If all criteria pass, report: "Approach Review: No issues noted"
- If issues exist, report each one briefly with context

This is a quick sanity check to catch "works but wrong approach" issues before they compound.

## Regression Check (if feature work)

- Confirm existing tests still pass
- Note any changes to existing functionality

## State Update

After checkpoint passes, update `.claude/phase-state.json`:

1. Set phase status to `CHECKPOINTED`
2. Add `completed_at` timestamp
3. Record checkpoint results

```json
{
  "phases": [
    {
      "number": 1,
      "status": "CHECKPOINTED",
      "completed_at": "{ISO timestamp}",
      "checkpoint": {
        "tests_passed": true,
        "type_check_passed": true,
        "lint_passed": true,
        "security_passed": true,
        "coverage_percent": 85,
        "manual_verified": true
      }
    }
  ]
}
```

If checkpoint fails, keep status as `IN_PROGRESS` and add `checkpoint_failed` with details.

## Verification Evidence and Logs

After running checks:
- Write a checkpoint report to `.claude/verification/phase-$1.md`
- Append results to `.claude/verification-log.jsonl`
  - Include check type, status, timestamp, and evidence path
 - Ensure `.claude/verification/` exists before writing evidence files

Example log entry:
```json
{
  "timestamp": "{ISO timestamp}",
  "scope": "phase-checkpoint",
  "phase": "$1",
  "check": "tests",
  "status": "PASS",
  "evidence": ".claude/verification/phase-$1.md"
}
```

---

## Report

```
Phase $1 Checkpoint Results
===========================

Tool Availability:
- Playwright MCP: ✓ | ✗
- code-simplifier: ✓ | ✗
- Trigger.dev MCP: ✓ | ✗ | N/A

Automated Checks:
- Tests: PASSED | FAILED
- Type Check: PASSED | FAILED | SKIPPED
- Linting: PASSED | FAILED | SKIPPED
- Security: PASSED | FAILED | X critical, Y high
- Coverage: {X}% (target: 80%)

Optional Checks:
- Code Simplification: APPLIED | SKIPPED
- Browser Verification: PASSED | SKIPPED
- Tech Debt: PASSED | NOTES | SKIPPED

Human Required:
- [ ] {items from EXECUTION_PLAN.md checkpoint section}

Approach Review: No issues noted | {list specific issues}

Overall: Ready to proceed | Issues to address
```
