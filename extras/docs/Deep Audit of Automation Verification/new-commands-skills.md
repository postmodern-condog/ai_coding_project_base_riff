# New Commands and Skills (Proposed)

This list focuses on closing automation gaps without overhauling existing
workflows. Items are proposals, not yet implemented.

## Commands

### 1) /criteria-audit
Purpose: Validate EXECUTION_PLAN.md for verification metadata and testability.
- Input: EXECUTION_PLAN.md
- Output: Report of untyped criteria, missing verification methods, and
  MANUAL items without reasons.
- Uses: For gating /phase-prep or /generate-plan.

### 2) /verify-task-auto (or extend /verify-task)
Purpose: Execute verification metadata per criterion.
- Input: Task ID, EXECUTION_PLAN.md, verification config file.
- Behavior:
  - Run tests and commands as specified.
  - Invoke browser-verification for BROWSER criteria.
  - Update .claude/phase-state.json with per-criterion results.
  - Write evidence report to .claude/verification/task-{id}.md.

### 3) /pre-phase-verify (or extend /phase-prep)
Purpose: Automate pre-phase setup checks.
- Input: Pre-Phase Setup items with verification methods.
- Output: Ready/blocked report with failures.

### 4) /phase-checkpoint-auto (or extend /phase-checkpoint)
Purpose: Run all automated checkpoint items and record results.
- Input: EXECUTION_PLAN.md, verification config.
- Output: Checkpoint report plus updated phase-state.

### 5) /verification-report
Purpose: Aggregate verification logs and highlight gaps.
- Input: .claude/verification-log.jsonl and phase-state.
- Output: Summary of what was verified, evidence paths, and manual items.

## Skills

### 1) browser-verification
Purpose: Standardize UI verification with MCP tooling.
- Capabilities: DOM, visual, network, console, performance, accessibility.
- Inputs: route, selector, expected content, viewport, optional actions.
- Tooling: Prefer Playwright MCP; fallback to Chrome DevTools MCP if needed.

### 2) criteria-audit
Purpose: Parse EXECUTION_PLAN.md and validate verification metadata.
- Capabilities: Enforce verification type and method, flag manual items.
- Integration: Used by /criteria-audit command.

### 3) verification-logger
Purpose: Persist verification outcomes with evidence pointers.
- Output: .claude/verification-log.jsonl
- Integration: Called by /verify-task-auto and /phase-checkpoint-auto.

## Supporting Artifact (Proposed)

Introduce a verification config file (example):

```
.claude/verification-config.json
{
  "commands": {
    "test": "{project test command}",
    "lint": "{project lint command}",
    "typecheck": "{project typecheck command}",
    "build": "{project build command}",
    "coverage": "{project coverage command}"
  },
  "devServer": {
    "command": "{project dev server command}",
    "url": "{dev server url}",
    "startupSeconds": 10
  }
}
```

This avoids guessing commands and allows deterministic automation.
