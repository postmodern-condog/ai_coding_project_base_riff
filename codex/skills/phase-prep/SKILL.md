---
name: phase-prep
description: Emulates the AI Coding Toolkit's Claude Code command /phase-prep <N> (checks prerequisites before starting a phase: pre-phase setup, prior phase completion, git status, tool availability). Triggers on "/phase-prep" or "phase-prep".
---

# /phase-prep (Codex)

Check prerequisites before starting a phase from `EXECUTION_PLAN.md`.

## Inputs

- Required: phase number (example: `/phase-prep 2`)

If the phase number is missing, ask the user for it and stop.

## Workflow

### 1) Context Detection

Determine working context:

- If current working directory path contains `/features/<feature-name>`:
  - `PROJECT_ROOT` = parent of parent of CWD
  - `MODE` = `feature`
- Else:
  - `PROJECT_ROOT` = CWD
  - `MODE` = `greenfield`

### 2) Directory Guard (Wrong Directory Check)

Before starting, confirm:
- `EXECUTION_PLAN.md` exists in the current working directory
- `PROJECT_ROOT/AGENTS.md` exists

If either is missing, stop and instruct the user to `cd` into the directory containing `EXECUTION_PLAN.md` and rerun `/phase-prep <N>`.

### 3) Pre-Flight Checks

1. **Pre-Phase Setup**
   - Read Phase `<N>`'s "Pre-Phase Setup" section.
   - List unmet prerequisites (env vars, services, external setup).

2. **Dependencies**
   - Verify all prior phases are complete by checking that their task acceptance criteria are checked off.
   - Flag any incomplete dependencies.

3. **Git Status**
   - Run `git status` and record:
     - current branch
     - clean vs dirty working tree

4. **Tool Availability (Optional)**
   - Chrome DevTools MCP (browser verification fallback):
     - Attempt a harmless call: `mcp__chrome-devtools__list_pages`
     - If unavailable: note "Browser verification will be manual"
   - Trigger.dev MCP (optional):
     - Attempt: `mcp__trigger__list_projects`
     - If unavailable: note "Trigger.dev checks skipped"

5. **Permissions / Execution Notes**
   - Review Phase `<N>` tasks and note any:
     - required env vars / secrets
     - required external services
     - browser/manual verification needs

### 4) Report

Output:

```text
PHASE <N> PREREQUISITES
======================

Documents:
- EXECUTION_PLAN.md: ✓ | ✗
- AGENTS.md (at PROJECT_ROOT): ✓ | ✗
- Prior phases: Complete | Incomplete | N/A

Git: <branch>, <clean|dirty>

Pre-Phase Setup:
- <items or "None required">

Environment:
- <env vars or "None required">

Tools:
- Chrome DevTools MCP: ✓ | ✗
- Trigger.dev MCP: ✓ | ✗ | N/A

Status: READY | BLOCKED | READY WITH NOTES
<Details if not READY>
```
