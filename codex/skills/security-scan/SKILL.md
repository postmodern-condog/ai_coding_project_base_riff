---
name: security-scan
description: Emulates the AI Coding Toolkit's Claude Code command /security-scan (scan for dependency vulnerabilities, secrets, and insecure code patterns; optionally offer fixes; blocks phase checkpoints on critical/high issues). Triggers on "/security-scan" or "security-scan".
---

# /security-scan (Codex)

Scan the codebase for security vulnerabilities:

1. Dependency vulnerabilities (known CVEs)
2. Secrets in code
3. Static analysis for insecure patterns

## Inputs

Optional scope flag:
- `--deps` (dependencies only)
- `--secrets` (secrets only)
- `--code` (static analysis only)
- `--fix` (apply safe fixes where possible)

If no argument, run all checks.

## Workflow

### 1) Detect Tech Stack

Detect which tools to use based on repo files:

- Node.js: `package.json`, lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)
- Python: `requirements.txt`, `pyproject.toml`
- Rust: `Cargo.toml`
- Go: `go.mod`
- Ruby: `Gemfile.lock`

### 2) Dependency Audit

If Node.js is detected and `--secrets`/`--code` are not forcing scope:

```bash
npm audit --json 2>/dev/null
```

Summarize by severity and indicate whether `npm audit fix` can resolve.

### 3) Secrets Detection

Search for common secret patterns. Skip:
- `node_modules/`, `.git/`, `dist/`, `build/`, `vendor/`, `venv/`, `.venv/`

Examples (non-exhaustive):
- AWS keys: `AKIA[0-9A-Z]{16}`
- GitHub tokens: `ghp_[a-zA-Z0-9]{36}`, `github_pat_...`
- Private keys: `-----BEGIN .* PRIVATE KEY-----`
- Generic `api_key|secret|password` assignments

Report findings with file + line number and severity.

### 4) Static Analysis (Code Patterns)

For JS/TS (examples):
- `eval(` (HIGH)
- `.innerHTML =` (MEDIUM)
- `document.write(` (MEDIUM)
- disabled TLS verification (HIGH)

Use grep/rg to locate patterns and report file + line.

### 5) Present Findings

Aggregate and dedupe. Use this format:

```text
SECURITY SCAN RESULTS
=====================
Tech Stack: <detected>
Checks Run: <list>

CRITICAL (N)
------------
<issue summaries>

HIGH (N)
--------
<issue summaries>

Summary: X critical, Y high, Z medium, W low
Status: PASSED | FAILED | PASSED WITH NOTES
```

### 6) Fixes (Optional)

For CRITICAL/HIGH issues:
- Present options to fix, ignore (with documented acceptance), or defer.
- If `--fix` is set, apply safe fixes automatically where possible (e.g., `npm audit fix` without `--force`).

Re-scan after fixes to confirm resolution.
