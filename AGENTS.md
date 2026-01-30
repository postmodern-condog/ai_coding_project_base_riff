# AGENTS.md (Toolkit Repo)

Workflow guidelines for AI agents making changes inside `ai_coding_project_base/`.

This repository is a **toolkit** (prompts, slash commands, skills). It is not a
“target app” that you execute phases against.

## Repo Context

- **Primary artifacts:** Markdown prompt templates and Claude Code skills.
- **Main directories:**
  - `.claude/skills/` — Skills (`SKILL.md`) — these create `/slash-commands`
  - `.claude/commands/` — Legacy command format (still works, but prefer skills)
  - `FEATURE_PROMPTS/` — Feature workflow prompt templates
  - `deprecated/` — Legacy/reference-only prompt files (avoid editing unless required)
  - `docs/` — Static documentation site assets

**Note:** Skills and commands are now merged in Claude Code. A file at `.claude/skills/review/SKILL.md`
creates `/review`. The `.claude/commands/` format still works but skills are preferred for new work.

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

## Skills (`.claude/skills/*/SKILL.md` and `.claude/commands/*.md`)

Skills and commands are merged in Claude Code. Both create `/slash-commands`:
- `.claude/skills/foo/SKILL.md` → `/foo`
- `.claude/commands/foo.md` → `/foo`

**Prefer skills format** for new work (supports supporting files, better discovery).

Guidelines:
- Keep the YAML frontmatter valid (`name`, `description`, `argument-hint`, `allowed-tools`).
- Keep "Directory Guard" sections accurate; skills should fail fast when run in the
  wrong directory.
- Prefer general, reusable workflows (avoid product-specific rules).
- If a skill references additional assets, link them explicitly.
- If you add/rename a skill:
  - Update `README.md` (commands list / file structure section) accordingly.
  - Ensure the skill aligns with constraints in `.claude/settings.json`.

## Cross-Model Verification

The toolkit supports cross-model verification using OpenAI Codex CLI:

- `/codex-review` — Review current branch code diffs. Supports
  `--upstream`, `--research`, `--base`, and `--model` flags.
- `/codex-consult` — Get a second opinion on documents, specs, or plans (non-code content).
  Supports `--upstream`, `--research`, and `--model` flags.
- `/phase-checkpoint` — Automatically invokes `/codex-review` when Codex is available

When Codex CLI is installed and authenticated, phase checkpoints include a second-opinion
review. Generation commands (`/product-spec`, `/technical-spec`, etc.) use `/codex-consult`
for document review. Codex researches current documentation before reviewing, catching
issues where training data may differ between models.

**Configuration** (`.claude/settings.local.json`):
```json
{
  "codexReview": {
    "enabled": true,
    "codeModel": "gpt-5.2-codex"
  },
  "codexConsult": {
    "enabled": true,
    "researchModel": "gpt-5.2"
  }
}
```

Codex findings are advisory and don't block workflows.

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

## Post-Commit Documentation Update

When you see `DOCUMENTATION SYNC PENDING` or detect `.claude/doc-update-pending.json`:

1. Run `/update-docs` to analyze the commit and update documentation
2. The skill will:
   - Analyze what changed in the commit
   - Update README, AGENTS.md, CHANGELOG, and docs/ as appropriate
   - Create a follow-up `docs:` commit if changes are made
3. After completion, delete the marker file:
   ```bash
   rm -f .claude/doc-update-pending.json
   ```

**Note:** This applies to all projects with the doc-update hook installed, not
just the toolkit.
