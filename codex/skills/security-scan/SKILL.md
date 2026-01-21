---
name: security-scan
description: Scan for security vulnerabilities in dependencies, code patterns, and secrets. Uses project-documented tooling where available.
---

# Security Scan Skill (Codex)

Run a security scan using project-documented commands. Avoid hardcoded
stack-specific tooling unless the project explicitly documents it.

## Workflow

1) Discover commands in `README.md`, `CONTRIBUTING.md`, `SECURITY.md`,
   `Makefile`, `Taskfile.yml`, `justfile`, or `scripts/`
2) Run dependency audit if a command is documented
3) Run secrets detection (pattern-based) unless a project tool is documented
4) Run static analysis if a command is documented
5) Summarize results and severity

## Secrets Detection (Default)

Search for common secret patterns (tokens, private keys, API keys) and report
file + line number. Skip `node_modules/`, `.git/`, `dist/`, `build/`, `vendor/`,
`venv/`.

## Reporting

Report findings with severity (CRITICAL/HIGH/MEDIUM/LOW). For critical/high,
present options and prefer project-documented fix commands.

If a required command is missing, ask the user to provide it or mark the check
as SKIPPED with a reason.
