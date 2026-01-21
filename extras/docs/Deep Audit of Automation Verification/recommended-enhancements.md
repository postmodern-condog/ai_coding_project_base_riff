# Recommended Enhancements

## Goals

- Make every acceptance criterion machine-verifiable or explicitly human-only.
- Allow /phase-checkpoint to run unattended when possible.
- Persist verification results with evidence for orchestration and audit.

## Recommendations

### P0 (Blockers for unattended verification)

1. Add verification metadata to EXECUTION_PLAN.md
- Require a verification type and method for each acceptance criterion.
- Introduce a small schema (type, method, evidence target, optional route).
- Explicitly tag human-only criteria with a reason.

1. Add a shared verification config file
- New file (proposal): .claude/verification-config.json
- Defines commands for test, lint, typecheck, build, coverage, dev server,
  and optional browser URLs.
- Used by /verify-task and /phase-checkpoint to avoid guessing.

1. Upgrade /verify-task to execute verification metadata
- Parse the new schema, run the declared command/tool, and record results.
- Update .claude/phase-state.json with per-criterion results and timestamps.
- Write a report to .claude/verification/task-{id}.md with evidence.

1. Add a browser-verification skill that can use Playwright MCP or fallback
- Standardize DOM, visual, network, console, and accessibility checks.
- Consume verification metadata and the shared config.
- Support fallback to Chrome DevTools MCP when Playwright MCP is unavailable.

### P1 (High leverage improvements)

1. Automate pre-phase setup verification
- Extend Pre-Phase Setup items with checks (env var names, health endpoints).
- Add a /pre-phase-verify command or extend /phase-prep.

1. Persist verification logs
- Add .claude/verification-log.jsonl to store each check result.
- Include evidence pointers (test output path, screenshots, logs).

1. Add acceptance criteria linting
- New /criteria-audit command to flag untyped or untestable criteria.
- Integrate into /generate-plan or /phase-prep as a guardrail.

1. Formalize coverage and performance baselines
- Store baseline metrics in .claude/verification-baseline.json.
- Compare and report deltas at phase checkpoint.

## Tooling Recommendation

Primary automation tool for UI verification:
- Playwright MCP as default (headless, cross-browser, modern API).

Fallback tool:
- Chrome DevTools MCP when Playwright MCP is unavailable or interactive
  debugging is needed.

## Risks and Constraints

- Some criteria will always require human judgment; the system must explicitly
  label these to avoid false automation promises.
- A shared config file introduces an extra setup step; keep defaults minimal.
- Verification commands must be stack-aware; do not hardcode stack-specific commands.
