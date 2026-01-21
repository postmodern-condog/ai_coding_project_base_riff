# Deep Audit of Automation Verification - Gap Analysis

## Scope

This audit reviews verification automation coverage across the toolkit prompts,
commands, and skills. It focuses on what can be verified without human
intervention and what must still be manual.

Files reviewed (non-exhaustive):
- GENERATOR_PROMPT.md
- FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md
- START_PROMPTS.md
- .claude/commands/phase-prep.md
- .claude/commands/phase-start.md
- .claude/commands/verify-task.md
- .claude/commands/phase-checkpoint.md
- .claude/commands/security-scan.md
- .claude/commands/populate-state.md
- .claude/skills/code-verification/SKILL.md
- .claude/skills/security-scan/SKILL.md
- .claude/skills/spec-verification/SKILL.md

Assumptions:
- Commands and skills are executed by an AI agent, so automation means the
  agent can complete verification without human input.
- Playwright MCP may or may not be available at runtime.

## Summary of Current Capabilities

- Automated checks exist for tests, lint, typecheck, and security scanning at
  phase checkpoints.
- Task-level verification is driven by /verify-task and the code-verification
  skill with optional browser checks.
- Phase state is tracked in .claude/phase-state.json, with a populate-state
  command to rebuild it.
- Spec verification enforces testability and reduces vague acceptance criteria
  in EXECUTION_PLAN.md.

## Gaps by Audit Area

### 1) Acceptance Criteria Auditability

Current state:
- GENERATOR_PROMPT.md asks for 3-6 "specific, testable" criteria per task.
- spec-verification flags untestable criteria (Q-EP-001).
- /verify-task labels criteria as CODE, TEST, LINT, TYPE, BUILD, or BROWSER.

Gap:
- No requirement to declare how each criterion is verified (command, tool,
  file/selector, or data). No explicit tagging for human-only criteria.
- The agent must infer verification approach, which is inconsistent and often
  manual.

Impact:
- /verify-task and /phase-checkpoint cannot deterministically auto-verify many
  criteria, which blocks unattended verification.

Evidence:
- GENERATOR_PROMPT.md (Task format)
- .claude/commands/verify-task.md (Type assignment and manual checks)
- .claude/skills/spec-verification/SKILL.md (Q-EP-001)

### 2) Verification Tool Coverage

Current state:
- Tests, lint, typecheck, and security scan are defined.
- Browser checks are optional if Playwright MCP is available.
- Tech debt check is optional and informational.

Gap:
- No reliable automation for accessibility, performance, visual regression,
  data migrations, or API contract validation beyond tests.
- Optional tools are not defined via a shared config (commands differ by repo).

Impact:
- Many criteria types have no automated path and fall back to manual review.

Evidence:
- .claude/commands/phase-checkpoint.md
- .claude/skills/code-verification/SKILL.md

### 3) State Persistence Completeness

Current state:
- .claude/phase-state.json is updated by instructions in /phase-start,
  /verify-task, and /phase-checkpoint.
- /populate-state can rebuild state from EXECUTION_PLAN.md and git history.

Gap:
- No standardized schema for per-criterion verification results, tool outputs,
  or evidence (logs, screenshots). Updates rely on the agent following
  instructions, not enforced by tooling.
- No persistent verification log or audit trail beyond free-form updates.

Impact:
- An orchestrator cannot reliably reconstruct what was verified, when, and with
  what evidence.

Evidence:
- .claude/commands/phase-start.md
- .claude/commands/verify-task.md
- .claude/commands/phase-checkpoint.md
- .claude/commands/populate-state.md

### 4) Pre-Phase Setup Verification

Current state:
- /phase-prep lists pre-phase setup items and flags missing prerequisites.

Gap:
- No machine-checkable format for pre-phase setup items. Environment variables,
  services, and credentials are listed but not validated.

Impact:
- Agents can start work without required env vars or services, leading to
  failures mid-task and more manual intervention.

Evidence:
- .claude/commands/phase-prep.md
- GENERATOR_PROMPT.md (Pre-Phase Setup section)

### 5) Checkpoint Automation

Current state:
- /phase-checkpoint runs tests, lint, typecheck, security scan, and optional
  Playwright checks.
- Manual verification is listed and delegated to the human.

Gap:
- Manual checkpoint items are not auto-verifiable or tied back to tasks or
  acceptance criteria.
- Coverage comparison requires a baseline that is not stored anywhere.

Impact:
- /phase-checkpoint cannot run fully unattended, even when checks could be
  automated.

Evidence:
- .claude/commands/phase-checkpoint.md

### 6) Browser and UI Verification

Current state:
- code-verification skill supports Playwright MCP and multiple UI check types.
- /phase-checkpoint optionally runs browser verification if Playwright MCP is
  available.

Gap:
- No standard format for UI criteria (route, selector, action, expected state).
- Dev server command and URL are defined in AGENTS.md, but not consumed by
  verification commands.
- No fallback to other browser tools (e.g., Chrome DevTools MCP) when Playwright
  is unavailable.

Impact:
- UI criteria are frequently unverifiable without human input.

Evidence:
- .claude/skills/code-verification/SKILL.md
- .claude/commands/phase-checkpoint.md
- GENERATOR_PROMPT.md (AGENTS.md format)

### 7) Test Quality Verification

Current state:
- /verify-task includes a TDD compliance check (test existence, test-first,
  meaningful assertions).
- code-verification skill mentions TDD but does not implement checks.

Gap:
- No deterministic mapping between criteria and tests.
- Test-first verification depends on git history and manual interpretation.

Impact:
- TDD compliance is inconsistent and not enforceable at scale.

Evidence:
- .claude/commands/verify-task.md

### 8) Blocker Detection and Resolution

Current state:
- /phase-start defines stuck detection thresholds and a reporting format.
- /verify-task instructs updates for blocked tasks.

Gap:
- No automated detection across sessions, no aggregation of repeated failures,
  and no human review queue for blockers.

Impact:
- Stuck detection relies on manual reporting and can be missed.

Evidence:
- .claude/commands/phase-start.md
- .claude/commands/verify-task.md

## Additional Cross-Cutting Gaps

- Tool detection is described as a "harmless call" but no standard call is
  defined for Playwright MCP or a shared tool registry.
- There is no shared verification config file to define test, lint, typecheck,
  build, coverage, or dev server commands per project.
- Criteria types are not normalized across skills and commands, leading to
  mismatched expectations (CODE/TEST/etc vs browser subtypes).
