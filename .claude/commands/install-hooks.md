---
description: Install git hooks for this project
allowed-tools: Bash, Read, Write, AskUserQuestion
---

Install git hooks to enhance the development workflow.

## Available Hooks

| Hook | Purpose | When It Runs |
|------|---------|--------------|
| `pre-push-doc-check` | Warns if docs may need updating | Before `git push` |
| `post-commit-sync-check` | Reminds to sync target projects | After `git commit` |

## Steps

### 1. Verify Git Repository

```bash
git rev-parse --git-dir
```

If not a git repository, **STOP** and report: "Not a git repository. Run /gh-init first."

### 2. List Available Hooks

Show the user which hooks are available:

```
AVAILABLE HOOKS
===============

1. pre-push-doc-check
   Purpose: Warns when skills/prompts change without documentation updates
   Checks: .claude/skills/, .claude/commands/, *PROMPT*.md
   Against: README.md, docs/*.md, AGENTS.md

2. post-commit-sync-check
   Purpose: Reminds to sync target projects when skills are modified
   Checks: .claude/skills/*.md changes in commits
   Action: Displays reminder to run /update-target-projects

Select hooks to install: [1] [2] [All] [None]
```

### 3. Install Selected Hooks

For each selected hook, create a symlink from `.git/hooks/` to `.claude/hooks/`:

```bash
# For pre-push hook
ln -sf ../../.claude/hooks/pre-push-doc-check.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push

# For post-commit hook
ln -sf ../../.claude/hooks/post-commit-sync-check.sh .git/hooks/post-commit
chmod +x .git/hooks/post-commit
```

**Note:** If a hook already exists at the destination:
- Check if it's a symlink to our hook (already installed)
- If it's a different file, warn and ask to backup/overwrite

### 4. Report Installation

```
HOOKS INSTALLED
===============

✓ pre-push → .claude/hooks/pre-push-doc-check.sh
✓ post-commit → .claude/hooks/post-commit-sync-check.sh

Hooks are now active. They will run automatically during git operations.

To uninstall: rm .git/hooks/<hook-name>
To bypass temporarily: git commit --no-verify  OR  git push --no-verify
```

## Hook Details

### pre-push-doc-check

**What it checks:**

| Files Changed | Documentation Expected |
|---------------|----------------------|
| `.claude/skills/*.md` | README.md or docs/*.md should be updated |
| `.claude/commands/*.md` | README.md or docs/*.md (legacy format) |
| `*PROMPT*.md` | README.md or docs/*.md |

**Behavior:**
- Analyzes commits in the push range
- If documentation may be stale, shows warning
- Prompts to continue or abort (interactive mode)
- In non-interactive mode, warns but allows push

**Example output:**
```
╔════════════════════════════════════════════════════════════════╗
║           DOCUMENTATION SYNC CHECK - WARNING                   ║
╚════════════════════════════════════════════════════════════════╝

The following changes may require documentation updates:

  - Skills changed but README.md not updated:
      .claude/skills/new-skill/SKILL.md
      .claude/skills/phase-start/SKILL.md

Consider updating:
  - README.md (command list, file structure)
  - docs/*.md (detailed documentation)
  - AGENTS.md (if behavior changes affect agent instructions)

Continue with push anyway? [y/N]:
```

### post-commit-sync-check

**What it checks:**

| Files Changed | Action |
|---------------|--------|
| `.claude/skills/*.md` | Displays sync reminder |

**Behavior:**
- Analyzes the just-committed files
- If skills were modified, shows a reminder box
- Suggests running `/update-target-projects`
- Non-blocking (never prevents commits)

**Example output:**
```
╭─────────────────────────────────────────────────────────────╮
│              TOOLKIT SYNC REMINDER                          │
╰─────────────────────────────────────────────────────────────╯

Skills modified:
  .claude/skills/phase-start/SKILL.md
  .claude/skills/progress/SKILL.md

Projects using this toolkit may need syncing.

To discover and sync target projects, run:
  /update-target-projects

Or sync a specific project:
  /sync /path/to/project
```

## Uninstalling Hooks

To remove installed hooks:

```bash
rm .git/hooks/pre-push      # Remove pre-push hook
rm .git/hooks/post-commit   # Remove post-commit hook
```

To bypass hooks temporarily:

```bash
git commit --no-verify  # Skip post-commit hooks for this commit only
git push --no-verify    # Skip pre-push hooks for this push only
```
