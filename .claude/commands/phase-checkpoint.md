---
description: Run checkpoint criteria after completing a phase
argument-hint: [phase-number]
allowed-tools: Bash, Read, Edit, Glob, Grep, AskUserQuestion
---

Phase $1 is complete. Read EXECUTION_PLAN.md and run the checkpoint criteria.

## Automated Checks

Run these commands and report results:

1. **Tests**
   ```
   npm test
   ```
   (or equivalent test command from AGENTS.md)

2. **Type Checking**
   ```
   npm run typecheck
   ```
   (or equivalent, if applicable)

3. **Linting**
   ```
   npm run lint
   ```
   (or equivalent, if applicable)

4. **Security Scan**

   Run security checks:
   - Run dependency audit (npm audit, pip-audit, etc.)
   - Run secrets detection (grep for API keys, tokens, passwords)
   - Run static analysis for insecure patterns

   For CRITICAL or HIGH issues:
   - Present each issue with resolution options
   - Apply fixes based on user choices
   - Re-scan to confirm resolution

   Security scan blocks checkpoint if CRITICAL or HIGH issues remain unresolved.

5. **Technical Debt Check**

   Follow the instructions in `.claude/skills/tech-debt-check/SKILL.md`:
   - Run duplication analysis
   - Run complexity analysis
   - Check file sizes
   - Detect AI code smells

   Report findings with severity levels. Tech debt check is informational (does not block) unless CRITICAL thresholds are exceeded.

6. **Code Quality Metrics**

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
   - JS/TS: `npm test -- --coverage` or `npx vitest --coverage`
   - Python: `pytest --cov`

   Flag if coverage dropped compared to before the phase.

## Manual Verification

From the "Phase $1 Checkpoint" section in EXECUTION_PLAN.md:
- List each manual verification item
- For each item, provide step-by-step instructions explaining how to verify it
- Indicate what I need to verify before proceeding

## Approach Review (Human)

Present this checklist for human review of the phase's implementation approach:

```
APPROACH REVIEW
---------------
For each task completed in Phase $1, briefly consider:

- [ ] Solutions use appropriate abstractions (not over/under-engineered)
- [ ] New code follows existing codebase patterns and conventions
- [ ] No unnecessary dependencies were added
- [ ] Error handling is consistent with rest of codebase
- [ ] Any "almost correct" AI solutions that need refinement?

Notes: {space for human to add observations}
```

This is a quick sanity check to catch "works but wrong approach" issues before they compound.

## Regression Check (if feature work)

- Confirm existing tests still pass
- Note any changes to existing functionality

## Report

```
Phase $1 Checkpoint Results
===========================

Automated Checks:
- [ ] Tests: PASSED/FAILED
- [ ] Type Check: PASSED/FAILED/SKIPPED
- [ ] Linting: PASSED/FAILED/SKIPPED
- [ ] Security: PASSED/FAILED/PASSED WITH NOTES
- [ ] Tech Debt: PASSED/PASSED WITH NOTES/FAILED
- [ ] Coverage: {X}% (target: 80%)

Security Summary: X critical, Y high, Z medium (if applicable)
Tech Debt Summary: X duplicate blocks, Y complex functions, Z large files

Manual Verification Required:
- [ ] {item from EXECUTION_PLAN.md}
- [ ] {item from EXECUTION_PLAN.md}

Approach Review Required:
- [ ] Human has reviewed implementation approach (see checklist above)

Overall: Ready to proceed to Phase {next} | Issues to address
```
