# Verification Matrix

Status definitions:
- Automated: Fully runnable without human input in current toolkit.
- Partial: Runnable but requires inferred context, missing config, or manual
  interpretation.
- Manual: Requires human judgment or steps.
- Not supported: No tooling defined.

## Criteria Type Coverage

| Criterion Type | Primary Tooling | Automation Status | Notes |
| --- | --- | --- | --- |
| CODE (file exists, exports, wiring) | /verify-task + code-verification | Partial | Manual inspection by agent, no deterministic checks. |
| TEST (unit/integration) | project test command | Partial | Command is not standardized and not always defined. |
| LINT | lint command | Partial | Command varies by project. |
| TYPE | typecheck command | Partial | Command varies by project. |
| BUILD | build command | Not supported | No standard command or checkpoint step. |
| SECURITY (deps/secrets/code) | /security-scan | Partial | Depends on installed tooling; interactive fixes. |
| BROWSER:DOM | Playwright MCP | Partial | No standard UI criteria format; relies on agent inference. |
| BROWSER:VISUAL | Playwright MCP | Not supported | No baseline or diff strategy defined. |
| BROWSER:NETWORK | Playwright MCP | Partial | No criteria schema for endpoints/expectations. |
| BROWSER:CONSOLE | Playwright MCP | Partial | No criteria schema for console expectations. |
| PERFORMANCE (UI) | Playwright MCP tracing | Not supported | No thresholds or reporting pipeline. |
| ACCESSIBILITY | Playwright MCP + a11y checks | Not supported | No actual checks or thresholds specified. |
| DATA MIGRATION | none | Not supported | No tooling or verification pattern. |
| CONFIG/ENV | none | Not supported | Pre-phase setup is manual. |
| MANUAL/UX | human review | Manual | Manual by design, no explicit tagging required today. |

## Phase Checkpoint Coverage

| Checkpoint Area | Current Tooling | Automation Status | Notes |
| --- | --- | --- | --- |
| Tests | project test command | Partial | Command not defined in config. |
| Typecheck | project typecheck command | Partial | Optional and stack-dependent. |
| Lint | project lint command | Partial | Optional and stack-dependent. |
| Security | /security-scan | Partial | Depends on installed tools. |
| Coverage | project coverage command | Not supported | No baseline or storage defined. |
| Browser verification | Playwright MCP | Partial | Optional, no formal criteria. |
| Manual verification | Human | Manual | No automation path. |
| Approach review | Human | Manual | Explicitly manual. |

## State and Logging Coverage

| Artifact | Current Behavior | Automation Status | Notes |
| --- | --- | --- | --- |
| .claude/phase-state.json | Updated by instructions | Partial | Not enforced; no per-criterion evidence. |
| Verification logs | none | Not supported | No persistent audit trail. |
| Coverage baselines | none | Not supported | Cannot compare coverage across phases. |
