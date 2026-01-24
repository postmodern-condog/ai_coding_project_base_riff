# AGENTS.md (Toolkit Repo)

Workflow guidelines for AI agents making changes inside `ai_coding_project_base/`.

This repository is a **toolkit** (prompts, slash commands, skills). It is not a
“target app” that you execute phases against.

## Repo Context

- **Primary artifacts:** Markdown prompt templates and Claude Code slash commands.
- **Main directories:**
  - `.claude/commands/` — Slash command definitions (frontmatter + instructions)
  - `.claude/skills/` — Skills (`SKILL.md`)
  - `FEATURE_PROMPTS/` — Feature workflow prompt templates
  - `deprecated/` — Legacy/reference-only prompt files (avoid editing unless required)
  - `docs/` — Static documentation site assets

## Operating Principles

- **Be conservative:** Prefer small, targeted edits over rewrites.
- **Keep behavior compatible:** Existing command names and core workflows should not
  break without a strong reason and explicit documentation.
- **Docs are code:** Treat prompt/command changes like API changes—update related
  docs when behavior or outputs change.
- **Avoid speculation:** If requirements are unclear, ask the user rather than
  encoding assumptions into prompts.

## Editing Rules (Markdown / Prompts)

- Preserve existing structure, headings, and code fences unless intentionally changing
  behavior.
- When adding examples, keep them minimal and copy-pastable.
- Avoid introducing new long, duplicated sections—prefer referencing an existing
  command/skill or consolidating.

## Slash Commands (`.claude/commands/*.md`)

- Keep the YAML frontmatter valid (description, argument-hint, allowed-tools).
- Keep “Directory Guard” sections accurate; commands should fail fast when run in the
  wrong directory.
- If you add/rename a command:
  - Update `README.md` (commands list / file structure section) accordingly.
  - Ensure the command aligns with constraints in `.claude/settings.json`.

## Skills (`.claude/skills/*/SKILL.md`)

- Prefer general, reusable workflows (avoid product-specific rules).
- If a skill references additional assets, link them explicitly (don’t require bulk
  reading to understand the workflow).

## Validation

- Run `npm run lint` before finishing changes that touch Markdown files.
- Do not add new tooling/formatters unless requested.

## Git Hygiene (If Asked to Use Git)

- Do not rewrite history (`reset --hard`, force push) unless explicitly requested.
- Avoid broad formatting churn; keep diffs reviewable.

## Post-Commit Sync Prompt

When you see `TOOLKIT SYNC PENDING` in git commit output, it means skills were
modified and target projects may need syncing. You MUST:

1. Use `AskUserQuestion` to prompt:
   - Question: "Skills were modified. Sync target projects now?"
   - Options: "Yes, sync now" / "No, skip for now"

2. If user says yes, run `/update-target-projects`

3. After sync (or skip), delete the marker file:
   ```bash
   rm -f .claude/sync-pending.json
   ```

This replaces the previous background sync approach which couldn't access other
project directories due to sandboxing.
