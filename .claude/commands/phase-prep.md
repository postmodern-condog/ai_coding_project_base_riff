---
description: Check prerequisites before starting a phase
argument-hint: [phase-number]
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
---

I want to execute Phase $1 from EXECUTION_PLAN.md. Before starting, read EXECUTION_PLAN.md and check:

## Pre-Flight Checks

1. **Pre-Phase Setup** — Check the "Pre-Phase Setup" section for Phase $1:
   - List any unmet prerequisites I need to complete
   - Identify environment variables or secrets needed
   - Note any external services that must be configured

2. **Dependencies** — Verify prior phases are complete:
   - Check that all tasks from previous phases have checked boxes
   - Flag any incomplete dependencies

3. **Git Status** — Check repository state:
   - Run `git status` to verify clean working tree (or understand current state)
   - Note the current branch

4. **Tool Availability** — Check optional tools that enhance this phase:

   **Required tools** (blocking if unavailable):
   - Bash, Read, Edit, Write, Glob, Grep — Core tools (always available)

   **Optional tools** (graceful degradation if unavailable):

   To check MCP availability, attempt a harmless call and check for errors:

   a. **Chrome DevTools MCP** — For browser-based verification
      - Try: `mcp__chrome-devtools__list_pages`
      - If unavailable: Browser tests will require manual verification
      - Setup: Add chrome-devtools MCP to Claude settings

   b. **code-simplifier plugin** — For automated code cleanup at checkpoints
      - Try: Check if the code-simplifier agent type is available
      - If unavailable: Code simplification step will be skipped
      - Setup: `claude plugin install code-simplifier`

   c. **Trigger.dev MCP** — For background task management (if project uses it)
      - Try: `mcp__trigger__list_projects`
      - If unavailable: Trigger.dev features will be skipped
      - Setup: Add trigger MCP to Claude settings

   Note: Only check tools relevant to this project's tech stack.

5. **Permissions** — Review the tasks in Phase $1:
   - Identify any tools or permissions needed for autonomous execution
   - Check if any tasks require browser verification

## Report

```
PHASE $1 PREREQUISITES
======================

Documents:
- [ ] EXECUTION_PLAN.md exists and readable
- [ ] AGENTS.md exists and readable
- [ ] Prior phases complete (if applicable)

Git Status:
- Branch: {current branch}
- Working tree: {clean/dirty}

Pre-Phase Setup:
- [ ] {item from EXECUTION_PLAN.md or "None required"}

Environment:
- [ ] {required env vars or "None required"}

Tool Availability:
- Core tools: ✓ Available
- Chrome DevTools MCP: {✓ Available | ✗ Not configured}
- code-simplifier: {✓ Available | ✗ Not installed}
- Trigger.dev MCP: {✓ Available | ✗ Not configured | N/A}

Status: {READY | BLOCKED | READY WITH NOTES}
{If READY WITH NOTES: explain what optional features are unavailable}
{If BLOCKED: list what must be resolved}
```
