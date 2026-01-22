# Verification Deep Dive

The toolkit enforces quality through multiple verification mechanisms that run automatically during execution.

## Code Verification

Every task has testable acceptance criteria. After completing a task, the `code-verification` skill checks:

- All acceptance criteria are met
- Tests pass
- No regressions introduced

The verification uses a multi-agent approach: a sub-agent independently verifies the work against criteria, preventing the implementing agent from marking incomplete work as done.

## TDD Enforcement

The `/verify-task` command includes TDD compliance checking.

### What It Verifies

| Check | Description |
|-------|-------------|
| **Test existence** | Every acceptance criterion has a corresponding test |
| **Test-first** | Tests were committed before or with implementation (via git history) |
| **Test effectiveness** | Tests have meaningful assertions and descriptive names |

### TDD Compliance Report

When running `/verify-task`, you'll see:

```
TDD COMPLIANCE: Task 1.2.A
-----------------------
Tests Found: 3/3 criteria covered
Test-First: PASS
Issues: None
```

If tests are missing or were written after implementation:

```
TDD COMPLIANCE: Task 1.2.A
-----------------------
Tests Found: 2/3 criteria covered
Test-First: WARNING
Issues:
- [Criterion 3] Missing test
- [Criterion 1] Test added after implementation
```

### Test Quality Standards

The generated `AGENTS.md` includes test quality standards:

- **AAA Pattern** — Tests use Arrange-Act-Assert structure
- **Naming** — Tests use `should {behavior} when {condition}` format
- **Coverage** — Happy path, edge cases, error cases, state changes
- **Independence** — No shared mutable state between tests

### Mocking Policy

`AGENTS.md` also includes mocking guidelines:

- **What to mock** — External APIs, databases, file system, time, random values
- **What not to mock** — Code under test, pure functions
- **Mock hygiene** — Reset between tests, prefer dependency injection

## Automatic Spec Verification

After generating `TECHNICAL_SPEC.md`, `EXECUTION_PLAN.md`, or their feature equivalents, the toolkit automatically runs verification.

### Context Preservation

Ensures nothing important is lost as requirements flow through the document chain:

```
PRODUCT_SPEC.md → TECHNICAL_SPEC.md → EXECUTION_PLAN.md
```

For each upstream document, verification extracts key items (features, constraints, edge cases) and confirms they appear in the downstream document—either directly, consolidated into broader items, or explicitly deferred.

### Quality Checks

Scans for common specification anti-patterns:

| Issue Type | Example | Why It Matters |
|------------|---------|----------------|
| Vague language | "API should be fast" | Can't write tests for unmeasurable requirements |
| Missing rationale | "Use Redis" | Without "why", future decisions lack context |
| Undefined contracts | "POST /users" without request shape | Implementation will guess or stall |
| Untestable criteria | "Should feel intuitive" | Acceptance criteria must be verifiable |
| Scope creep | Feature in tech spec not in product spec | Requirements should flow downstream, not appear spontaneously |

### Interactive Repair

When issues are found, verification presents each one with resolution options:

```
ISSUE 1 of 2: Vague Language
Location: TECHNICAL_SPEC.md, Section "Performance"
Problem: "API responses should be fast" is unmeasurable

How would you like to resolve this?
○ Use suggested: "API responses return within 200ms p95" (Recommended)
○ Specify custom target
○ Remove requirement
```

Fixes are applied automatically based on your choices, then re-verified.

### Manual Verification

Run verification manually anytime:

```bash
/verify-spec technical-spec      # Verify TECHNICAL_SPEC.md
/verify-spec execution-plan      # Verify EXECUTION_PLAN.md
/verify-spec feature-technical   # Verify FEATURE_TECHNICAL_SPEC.md
/verify-spec feature-plan        # Verify feature EXECUTION_PLAN.md
```

## Browser Verification

For acceptance criteria that require browser interaction (UI rendering, user flows, visual checks), the toolkit supports automated browser verification with authentication.

### Supported Tools

| Tool | Type | Best For |
|------|------|----------|
| **Chrome DevTools MCP** | MCP server | Real-time interaction, debugging, already integrated |
| **Playwright MCP** | MCP server | Cross-browser automated verification, headless |

The toolkit auto-detects available tools and uses the best option. Configure via `/configure-verification`.

### Authentication

Many apps require login before browser verification can access protected pages. The toolkit supports authenticated browser sessions:

1. **Run `/configure-verification`** — Answer questions about login route and credentials
2. **Create `.env.verification`** — Copy from `.env.verification.example` and fill in test credentials
3. **Verification auto-authenticates** — Browser skills log in before checking protected pages

```
# .env.verification (never commit this file)
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=your-test-password
```

The auth state is cached in `.claude/verification/auth-state.json` to avoid repeated logins.

### Fallback Chain

When browser verification runs:

1. Try primary tool (auto-selected or configured)
2. If unavailable, try fallback tool
3. If no tools available, mark as MANUAL verification needed

### No Browser Tools?

If no browser MCP is configured, browser-based criteria require manual verification. To enable automation:

```json
// .claude/settings.json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-playwright"]
    }
  }
}
```

## Security Scanning

The toolkit includes integrated security scanning that runs automatically during `/phase-checkpoint` and can be invoked manually via `/security-scan`.

### What It Checks

| Category | Examples | Severity |
|----------|----------|----------|
| **Dependency vulnerabilities** | Known CVEs in project dependencies | CRITICAL-LOW |
| **Hardcoded secrets** | AWS keys, GitHub tokens, API keys, private keys | CRITICAL-HIGH |
| **Insecure code patterns** | `eval()`, SQL concatenation, disabled SSL verification | HIGH-MEDIUM |

### How It Works

1. **Discovers security tooling** from project docs and configuration
2. **Runs documented tools** (or prompts for commands if missing)
3. **Presents findings** with severity levels and fix suggestions
4. **Offers resolution options** for each CRITICAL/HIGH issue
5. **Blocks checkpoint** if unresolved CRITICAL/HIGH issues remain

### Manual Scanning

```bash
/security-scan              # Full scan (deps + secrets + code)
/security-scan --deps       # Dependency vulnerabilities only
/security-scan --secrets    # Secrets detection only
/security-scan --code       # Static analysis only
/security-scan --fix        # Auto-fix where possible
```

## Stuck Detection

Agents can get stuck in loops, repeatedly failing on the same issue. The toolkit detects this and escalates to human intervention.

### Escalation Triggers

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Consecutive task failures | 3 tasks | Pause phase |
| Same error pattern | 2 occurrences | Pause and report |
| Verification loop | 5 attempts on same criterion | Mark task blocked |
| Test flakiness | Same test passes then fails | Flag for review |

### What Happens

When stuck, the agent stops and presents:
- Pattern description (what keeps failing)
- Last 3 errors
- Possible causes
- Options: skip task, modify criteria, try different approach, abort phase

This prevents agents from burning tokens on unfixable issues and ensures human judgment is applied where needed.
