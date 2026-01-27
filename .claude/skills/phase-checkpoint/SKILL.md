---
name: phase-checkpoint
description: Run checkpoint criteria after completing a phase. Use after /phase-start completes all tasks to verify quality gates before proceeding.
argument-hint: [phase-number]
allowed-tools: Bash, Read, Edit, Glob, Grep, AskUserQuestion, WebFetch, WebSearch
---

Phase $1 is complete. Run the checkpoint criteria from EXECUTION_PLAN.md.

## Workflow

Copy this checklist and track progress:

```
Phase Checkpoint Progress:
- [ ] Step 1: Context and tool detection
- [ ] Step 2: Read verification config
- [ ] Step 3: Run automated local checks
- [ ] Step 4: Run optional checks (browser, tech debt)
- [ ] Step 5: Process manual verification items
- [ ] Step 6: Human confirmation for manual items
- [ ] Step 7: Production verification (if local passes)
- [ ] Step 8: Update state and generate report
- [ ] Step 9: Auto-advance check
```

## Step 1: Context Detection

Determine working context:

1. If CWD matches `*/features/*`:
   - PROJECT_ROOT = parent of parent of CWD
   - MODE = "feature"
2. Otherwise:
   - PROJECT_ROOT = current working directory
   - MODE = "greenfield"

**Directory Guard:** Confirm `EXECUTION_PLAN.md` exists. If not, STOP and tell user to `cd` into their project directory.

**Context Check:** If context is below 40% remaining, run `/compact` first.

## Step 2: Tool Availability & Config

Check which optional tools are available:

| Tool | Check Method | Fallback |
|------|--------------|----------|
| ExecuteAutomation Playwright | Check for `mcp__playwright__*` | Next in chain |
| Browser MCP | Check for `mcp__browsermcp__*` | Next in chain |
| Chrome DevTools MCP | `mcp__chrome-devtools__list_pages` | Manual verification |
| code-simplifier | Check if agent type available | Skip |

**Browser fallback chain:** ExecuteAutomation → Browser MCP → Microsoft Playwright → Chrome DevTools → Manual

Read `.claude/verification-config.json` from PROJECT_ROOT. If missing or incomplete, run `/configure-verification` first.

## Step 3: Local Verification (Must Pass First)

**IMPORTANT**: All local verification must pass before production verification.

See [VERIFICATION.md](VERIFICATION.md) for detailed check procedures.

### Automated Checks

Run these using commands from verification-config:
1. Tests (`commands.test`)
2. Type Checking (`commands.typecheck`)
3. Linting (`commands.lint`)
4. Build (`commands.build`)
5. Dev Server (`devServer.command`)
6. Security Scan
7. Code Quality Metrics

### Optional Checks

- Code Simplification (if code-simplifier available)
- Browser Verification (if browser tools available)
- Technical Debt Check (if skill exists)

### Manual Verification

1. Extract manual items from "Phase $1 Checkpoint" in EXECUTION_PLAN.md
2. Attempt automation using auto-verify skill
3. Generate detailed verification guide for remaining items
4. Ask human for batch confirmation
5. Update checkboxes in EXECUTION_PLAN.md

For external integrations, follow [DOCS_PROTOCOL.md](DOCS_PROTOCOL.md) to fetch latest documentation.

## Step 4: Production Verification

**BLOCKED** until all Local Verification passes.

When local passes, verify:
- Staging/production deployment
- External integrations
- Production-only manual checks

## Step 5: State Update

After checkpoint passes, update `.claude/phase-state.json`:

```json
{
  "phases": [{
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
  }]
}
```

Write checkpoint report to `.claude/verification/phase-$1.md` and append to `.claude/verification-log.jsonl`.

## Step 6: Report

```
Phase $1 Checkpoint Results
===========================

Tool Availability:
- ExecuteAutomation Playwright: ✓ | ✗
- Browser MCP: ✓ | ✗
- Chrome DevTools MCP: ✓ | ✗
- code-simplifier: ✓ | ✗

## Local Verification

Automated Checks:
- Tests: PASSED | FAILED
- Type Check: PASSED | FAILED | SKIPPED
- Linting: PASSED | FAILED | SKIPPED
- Build: PASSED | FAILED | SKIPPED
- Security: PASSED | FAILED

Optional Checks:
- Browser Verification: PASSED | SKIPPED
  - Target: {URL}
- Tech Debt: PASSED | NOTES | SKIPPED

Manual Checks:
- Automated: {X} items
- Truly manual: {Y} items

Local Verification: ✓ PASSED | ✗ FAILED

---

## Production Verification
{items or "Blocked: Complete local verification first"}

---

Overall: Ready to proceed | Issues to address
```

## Step 7: Auto-Advance

See [AUTO_ADVANCE.md](AUTO_ADVANCE.md) for auto-advance logic.

**Summary:** If all checks pass and no manual items remain, automatically invoke `/phase-prep {N+1}`.

---

**REMINDER**: Local verification must pass before production verification. If any local check fails, stop and report — do not proceed to production checks.
