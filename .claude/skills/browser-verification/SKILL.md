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
1. Load config (dev server + auth + browser)
2. Select browser tool (with fallback chain)
3. Authenticate (if required)
4. Navigate and validate
5. Capture evidence
6. Handle errors and recover
7. Report results
```

## Step 1: Load Configuration

Read `.claude/verification-config.json` for:

**Dev Server:**
- `devServer.command`
- `devServer.url`
- `devServer.startupSeconds`

**Authentication:**
- `auth.strategy` — `none`, `env`, or `storage-state`
- `auth.loginRoute` — URL path for login form
- `auth.credentials.usernameVar` — Env var name for username
- `auth.credentials.passwordVar` — Env var name for password
- `auth.storageState` — Path to save/load session state

**Browser:**
- `browser.tool` — `auto`, `executeautomation`, `playwright`, `browsermcp`
- `browser.headless` — Run headless (default: true)
- `browser.timeout` — Default timeout in ms (default: 30000)
- `browser.navigationTimeout` — Navigation timeout in ms (default: 60000)

If config is missing or incomplete, ask the human to run `/configure-verification`.

## Step 2: Tool Selection (Automatic with Fallback)

Automatically detect and use the best available browser tool. Try tools in
order until one responds:

```
1. Chrome DevTools MCP (if available)
   - Test: Call mcp__chrome-devtools__list_pages
   - Preferred because it's commonly pre-installed

2. Playwright MCP (ExecuteAutomation or Microsoft)
   - Test: Attempt harmless call (list pages / navigate)
   - Check for mcp__playwright__* tools

3. Manual Verification (last resort)
   - If all tools fail
   - Mark criteria as BLOCKED (not FAIL)
   - Report which tools were tried and why they failed
```

**Log tool selection:**
```
Browser Tool: Chrome DevTools MCP (auto-detected)
Fallback: Manual verification if tool fails mid-session
```

## Step 3: Authentication

**Skip if `auth.strategy` is `none`.**

### Strategy: `storage-state`

1. Check if `auth.storageState` file exists and is recent (< 24h)
2. If exists, load session state into browser
3. Navigate to a protected route to verify session validity
4. If session invalid, proceed to login flow

### Strategy: `env` (or storage-state with invalid session)

1. Read credential env var names from config (NOT the values)
2. Navigate to `auth.loginRoute`
3. Identify login form fields (username/email, password)
4. Fill credentials using browser tool's form fill
   - Pass env var names to the tool, which reads values from environment
   - Agent NEVER sees plaintext credentials
5. Submit the form
6. Wait for successful login indicator (redirect, logged-in element)
7. Save session to `auth.storageState` for reuse

### Auth Failure Handling

If login fails after 2 attempts:
- Mark criteria as BLOCKED (not FAIL)
- Report: "Authentication failed. Check credentials in .env.verification"
- Do NOT expose credential values in error messages

## Step 4: Navigate and Validate

For each browser criterion:

1. Start from base URL (`devServer.url`)
2. Navigate to the criterion's route
3. Wait for content to load:
   - Use wait-for-text or wait-for-selector
   - Respect `browser.navigationTimeout`
4. Perform optional actions in order (click, type, hover)
5. Validate expected state:
   - visibility
   - text content
   - attribute values
   - layout position
6. Capture console errors and network failures when relevant

## Step 5: Evidence Capture

Capture evidence appropriate to the criterion type:

| Type | Evidence |
|------|----------|
| DOM | Accessibility snapshot, selector details |
| VISUAL | Screenshot |
| CONSOLE | Console log excerpt |
| NETWORK | Request/response summary |
| PERFORMANCE | Timing metrics (if supported) |
| ACCESSIBILITY | ARIA/semantic checks and notes |

Save evidence under `.claude/verification/` with stable names:
- `browser-{task-id}-{criterion-id}.png`
- `browser-{task-id}-{criterion-id}.json`

## Step 6: Error Recovery

**Detect failures:**
- Tool returns "undefined" or "Error calling tool"
- Connection timeout
- Server not responding

**Recovery procedure:**

```
1. Log the error with context:
   "Tool {name} returned: {error}"

2. If transient error (timeout, connection):
   - Wait 2 seconds
   - Retry current operation (max 2 retries)

3. If persistent error or tool unavailable:
   - Attempt tool restart (kill and re-init MCP)
   - If restart succeeds, retry current criterion

4. If restart fails:
   - Try next tool in fallback chain
   - Log: "Switching from {current} to {fallback}"

5. If all tools exhausted:
   - Mark remaining criteria as BLOCKED
   - Report: "Browser tools unavailable after trying:
     - ExecuteAutomation Playwright: {error}
     - Chrome DevTools: {error}
     Manual verification required."
```

**Session degradation detection:**

Some tools work initially then fail after extended use. Monitor for:
- Increasing response times
- Intermittent "undefined" errors
- Loss of page state

If detected, proactively switch to fallback before complete failure.

## Step 7: Output Format

Return a structured result for each criterion:

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

## Failure Handling Summary

| Condition | Action | Status |
|-----------|--------|--------|
| Dev server unreachable | Report failing command | BLOCKED |
| Selector missing | Capture screenshot | FAIL |
| Auth fails | Check credentials | BLOCKED |
| Tool unavailable | Try fallback chain | Continue or BLOCKED |
| Tool returns undefined | Retry then switch | Continue or BLOCKED |
| All tools fail | Require manual verification | BLOCKED |

## Tool-Specific Notes

### Chrome DevTools MCP
- Often pre-installed with Claude Code
- Good for debugging and basic automation
- Use `mcp__chrome-devtools__*` tools

### Playwright MCP
- More powerful automation capabilities
- Better for complex multi-step workflows
- Install: Add to `.claude/settings.json` mcpServers
- Prefer `@anthropic-ai/mcp-server-playwright` or pinned versions
- Avoid `@playwright/mcp@latest` (known stability issues with beta releases)
