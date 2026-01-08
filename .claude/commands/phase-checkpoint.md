---
description: Run checkpoint criteria after completing a phase
argument-hint: [phase-number]
allowed-tools: Bash, Read, Glob, Grep
---

Phase $1 is complete. Run the checkpoint criteria from @EXECUTION_PLAN.md.

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

## Manual Verification

From the "Phase $1 Checkpoint" section in EXECUTION_PLAN.md:
- List each manual verification item
- Indicate what I need to verify before proceeding

## Regression Check (if feature work)

- Confirm existing tests still pass
- Note any changes to existing functionality

## Report

Provide:
- Pass/fail status for each automated check
- List of manual items for me to verify
- Overall: Ready to proceed to Phase {next} or issues to address
