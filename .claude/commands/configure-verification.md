---
description: Configure verification commands for this project
argument-hint: [project-directory]
allowed-tools: Read, Edit, Grep, Glob, AskUserQuestion
---

Configure `.claude/verification-config.json` with the project’s actual commands
for tests, lint, typecheck, build, coverage, and dev server.

## Project Directory

Use the current working directory by default.

If `$1` is provided, treat `$1` as the working directory and read files under
`$1` instead.

## Context Detection

Determine working context:

1. If the working directory matches `*/features/*`:
   - PROJECT_ROOT = parent of parent of working directory
2. Otherwise:
   - PROJECT_ROOT = working directory

## Directory Guard

Confirm `PROJECT_ROOT` exists and is writable. If not, stop and ask for a valid
project directory.

## Discovery (Read-Only)

Scan project documentation for commands and hints:
- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `Makefile`
- `Taskfile.yml`
- `justfile`
- Any `docs/` or `scripts/` usage notes

Look for sections mentioning: tests, linting, type checking, build, coverage,
local dev server, and security checks.

Summarize any candidate commands you find.

## Configure Commands

If `.claude/verification-config.json` does not exist, create it with empty
fields. Then ask the human to confirm or provide commands for:

- Test command
- Lint command
- Typecheck command (if applicable)
- Build command (if applicable)
- Coverage command (if applicable)
- Dev server command + URL + startup wait

If a command is not applicable, set it to an empty string and note it as
"not applicable" in the summary.

## Write Config

Update `.claude/verification-config.json` with the confirmed values.

## Report

```
VERIFICATION CONFIGURED
=======================
Project Root: {path}

Commands:
- test: {value or ""}
- lint: {value or ""}
- typecheck: {value or ""}
- build: {value or ""}
- coverage: {value or ""}

Dev Server:
- command: {value or ""}
- url: {value or ""}
- startupSeconds: {value}

Status: READY | READY WITH NOTES
Notes: {missing or not-applicable commands}
```
