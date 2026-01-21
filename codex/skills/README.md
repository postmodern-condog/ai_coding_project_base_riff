# Codex CLI Skill Pack (AI Coding Toolkit)

This folder contains **Codex CLI skills** that mirror the AI Coding Toolkit's Claude Code execution slash commands.

After installing, you can type commands like `/fresh-start` and `/phase-start 1` in Codex CLI and get the same workflow behavior as Claude Code's `.claude/commands/*`.

## Install

From the toolkit repo root:

```bash
./scripts/install-codex-skill-pack.sh
```

To update an existing install:

```bash
./scripts/install-codex-skill-pack.sh --force
```

Then restart Codex CLI so it picks up the new skills.

## Usage

In your target project directory (the one containing `EXECUTION_PLAN.md`):

```bash
codex
```

Then run:

- `/fresh-start`
- `/phase-prep 1`
- `/phase-start 1`
- `/phase-checkpoint 1`
- `/verify-task 1.2.A`
- `/progress`
- `/security-scan`

If Codex doesn't auto-trigger the right skill from a slash command, use the explicit form:

- `$fresh-start`
- `$phase-start 1`

## Included Skills

- `fresh-start`
- `phase-prep`
- `phase-start`
- `phase-checkpoint`
- `verify-task`
- `progress`
- `security-scan`
- `populate-state`
- `list-todos`

## Notes / Differences vs Claude Code

- Browser checks use **Chrome DevTools MCP** if available (instead of Playwright MCP).
- This pack follows the toolkit convention of storing state in `.claude/phase-state.json` (same as Claude Code workflows).
