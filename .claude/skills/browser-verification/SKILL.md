---
name: browser-verification
description: Verify browser-based acceptance criteria using Playwright MCP with Chrome DevTools MCP fallback.
---

# Browser Verification Skill

Verify UI-related acceptance criteria using MCP browser tooling with evidence
(snapshots, logs, or screenshots).

## Inputs

For each criterion, use metadata from `Verify:`:
- route (e.g., `/login`)
- selector (e.g., `[data-testid="login-form"]`)
- expected state (visible, text, attribute, etc.)
- optional actions (click, type, hover)
- optional viewport

## Workflow Overview

```
1. Load dev server config
2. Launch browser tool (Playwright MCP preferred)
3. Navigate and validate
4. Capture evidence
5. Report results
```

## Step 1: Load Dev Server Config

Read `.claude/verification-config.json` and use `devServer`:
- `command`
- `url`
- `startupSeconds`

If missing or empty, ask the human to run `/configure-verification`.
If AGENTS.md includes dev server info, use it as a temporary fallback and
record the fallback in the report.

## Step 2: Tool Selection

Preferred: Playwright MCP
Fallback: Chrome DevTools MCP (if Playwright MCP is unavailable)

## Step 3: Navigate and Validate

For each browser criterion:
- Start from the base URL and navigate to the route
- Wait for content to load (use wait-for-text or wait-for-selector)
- Perform optional actions in order
- Validate the expected state (visibility, text, attribute, layout)
- Capture console errors and network failures when relevant

## Step 4: Evidence Capture

Capture evidence appropriate to the criterion type:
- DOM: accessibility snapshot and selector details
- VISUAL: screenshot
- CONSOLE: console log excerpt
- NETWORK: request/response summary
- PERFORMANCE: timing metrics (if supported)
- ACCESSIBILITY: ARIA/semantic checks and notes

Save evidence under `.claude/verification/` with a stable name:
- `browser-{task-id}-{criterion-id}.png`
- `browser-{task-id}-{criterion-id}.json`

## Step 5: Output Format

Return a structured result:

```
BROWSER VERIFICATION RESULT
---------------------------
Instruction ID: [ID]
Status: PASS | FAIL | BLOCKED
Type: DOM | VISUAL | CONSOLE | NETWORK | PERFORMANCE | ACCESSIBILITY
URL: [URL] | Viewport: [width]x[height]

Finding: [What was observed]
Expected: [What was expected]

Evidence:
- {path}

Suggested Fix: [If FAIL]
```

## Failure Handling

- If dev server is unreachable, mark BLOCKED and report the failing command.
- If selector is missing, mark FAIL and capture a screenshot.
- If Playwright MCP is unavailable, try Chrome DevTools MCP; if both fail, mark
  BLOCKED and note manual verification required.
