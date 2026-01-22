---
description: Install git hooks for this project
allowed-tools: Bash, Read, Write, AskUserQuestion
---

Install git hooks to enhance the development workflow.

## Available Hooks

| Hook | Purpose | When It Runs |
|------|---------|--------------|
| `pre-push-doc-check` | Warns if docs may need updating | Before `git push` |

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
   Purpose: Warns when commands/skills/prompts change without documentation updates
   Checks: .claude/commands/, .claude/skills/, *PROMPT*.md
   Against: README.md, docs/*.md, AGENTS.md

Select hooks to install: [1] [All] [None]
```

### 3. Install Selected Hooks

For each selected hook, create a symlink from `.git/hooks/` to `.claude/hooks/`:

```bash
# For pre-push hook
ln -sf ../../.claude/hooks/pre-push-doc-check.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

**Note:** If a hook already exists at the destination:
- Check if it's a symlink to our hook (already installed)
- If it's a different file, warn and ask to backup/overwrite

### 4. Report Installation

```
HOOKS INSTALLED
===============

✓ pre-push → .claude/hooks/pre-push-doc-check.sh

Hooks are now active. They will run automatically during git operations.

To uninstall: rm .git/hooks/pre-push
To bypass temporarily: git push --no-verify
```

## Hook Details

### pre-push-doc-check

**What it checks:**

| Files Changed | Documentation Expected |
|---------------|----------------------|
| `.claude/commands/*.md` | README.md should be updated |
| `.claude/skills/*.md` | README.md or docs/*.md |
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

  - Commands changed but README.md not updated:
      .claude/commands/new-command.md
      .claude/commands/phase-start.md

Consider updating:
  - README.md (command list, file structure)
  - docs/*.md (detailed documentation)
  - AGENTS.md (if behavior changes affect agent instructions)

Continue with push anyway? [y/N]:
```

## Uninstalling Hooks

To remove installed hooks:

```bash
rm .git/hooks/pre-push  # Remove pre-push hook
```

To bypass hooks temporarily:

```bash
git push --no-verify  # Skip pre-push hooks for this push only
```
