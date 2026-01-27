---
name: update-docs
description: Update documentation after commits. Syncs README, AGENTS.md, CHANGELOG, and docs/ with code changes. Use after commits or to analyze working tree changes.
argument-hint: [commit-range|--working-tree]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Update Documentation

Automatically update documentation to reflect code changes. Works in any repository with convention-based discovery.

## Trigger Modes

1. **Post-commit (automatic)**: Triggered by git hook after commits
2. **Manual with commit range**: `/update-docs HEAD~3..HEAD` to analyze specific commits
3. **Manual with working tree**: `/update-docs --working-tree` to analyze uncommitted changes

## Arguments

- No arguments: Analyze the most recent commit (HEAD)
- `HEAD~N..HEAD`: Analyze the last N commits
- `COMMIT1..COMMIT2`: Analyze a specific commit range
- `--working-tree` or `-w`: Analyze uncommitted changes in working tree

## Marker File Detection

When triggered by post-commit hook, check for `.claude/doc-update-pending.json`:

```bash
if [ -f .claude/doc-update-pending.json ]; then
  # Read marker to get commit info
  COMMIT=$(jq -r '.commit_short' .claude/doc-update-pending.json)
  # Process that specific commit
fi
```

**After processing, always clean up the marker:**

```bash
rm -f .claude/doc-update-pending.json
```

This prevents re-processing the same commit on subsequent runs.

## Workflow

Copy this checklist and track progress:

```
Update Docs Progress:
- [ ] Phase 1: Discover documentation files
- [ ] Phase 2: Detect changes (git diff or working tree)
- [ ] Phase 3: Analyze documentation implications
- [ ] Phase 4: Update documentation files
- [ ] Phase 5: Update CHANGELOG (if exists)
- [ ] Phase 6: Create docs commit (if changes made)
```

---

## Phase 1: Discover Documentation Files

Scan the repository for documentation using conventions:

### Primary Documentation
- `README.md` (root) — Project overview, features, usage
- `AGENTS.md` (root) — AI agent workflow guidelines
- `CHANGELOG.md` (root) — Version history and changes
- `CONTRIBUTING.md` (root) — Contribution guidelines

### Secondary Documentation
- `docs/*.md` — Detailed documentation files
- `docs/**/*.md` — Nested documentation

### Config Documentation
- `package.json` — `description`, `keywords`, `scripts` descriptions
- `pyproject.toml` — Project description
- `Cargo.toml` — Package description

**Output:** List discovered files with their modification times.

---

## Phase 2: Detect Changes

### For Commit Analysis (default or commit range)

```bash
# Get changed files
git diff --name-only <range>

# Get detailed diff for understanding changes
git diff --stat <range>
git diff <range> -- <relevant-files>
```

### For Working Tree Analysis (`--working-tree`)

```bash
# Get staged and unstaged changes
git status --porcelain

# Get detailed diff
git diff          # unstaged
git diff --cached # staged
```

**Categorize changes:**
- **Structural**: New/deleted/renamed files or directories
- **Skill/Command**: Changes to `.claude/skills/` or `.claude/commands/`
- **Configuration**: Changes to config files (package.json, settings, etc.)
- **Feature**: New functionality or modified behavior
- **Fix**: Bug fixes or corrections
- **Refactor**: Code restructuring without behavior change

---

## Phase 3: Analyze Documentation Implications

For each category of change, determine documentation impact:

### Structural Changes
| Change | Documentation Impact |
|--------|---------------------|
| New directory | Update file structure in README |
| New major file | Consider mentioning in README/docs |
| Deleted component | Remove references in all docs |
| Renamed paths | Update all path references |

### Skill/Command Changes
| Change | Documentation Impact |
|--------|---------------------|
| New skill | Add to commands table in README |
| Modified skill | Update description if behavior changed |
| Deleted skill | Remove from commands table |
| New workflow pattern | Consider updating AGENTS.md |

### Configuration Changes
| Change | Documentation Impact |
|--------|---------------------|
| New config option | Document in relevant section |
| Changed defaults | Update examples |
| New integration | Add setup instructions |

### Feature Changes
| Change | Documentation Impact |
|--------|---------------------|
| New feature | Add to features list, update README |
| Modified behavior | Update usage examples |
| New API | Update API documentation |

**Decision Rule:** If unsure whether a change warrants doc updates, skip silently. Err on the side of not making unnecessary changes.

---

## Phase 4: Update Documentation Files

For each file that needs updates:

### README.md Updates

**Commands/Features Table:**
If the repo has a commands table (like toolkit projects), keep it in sync:
1. Scan for actual skills/commands in `.claude/skills/` and `.claude/commands/`
2. Compare against documented commands
3. Add missing entries, remove deleted ones
4. Update descriptions if skill descriptions changed

**File Structure Section:**
If README has a file structure tree:
1. Compare against actual directory structure
2. Update tree to reflect new/deleted directories
3. Keep annotations accurate

**Feature Lists:**
1. Check if new features are documented
2. Remove references to deleted features

### AGENTS.md Updates

AGENTS.md requires careful handling—only update when:
- New workflow patterns are introduced (new skill categories)
- Integration points change (hooks, verification, cross-model)
- Operating principles need clarification based on new tooling

**Do NOT auto-update:**
- Nuanced guidance sections
- Project-specific conventions
- Editorial content

### docs/*.md Updates

For each documentation file:
1. Check for broken internal links
2. Update feature/command references
3. Keep examples current with actual file paths

### Config Documentation

**package.json:**
- Update `description` if project scope changed
- Sync `scripts` descriptions with actual behavior

---

## Phase 5: Update CHANGELOG

If `CHANGELOG.md` exists, append an entry for the changes.

### CHANGELOG Format Detection

Read existing CHANGELOG to detect format:
- **Keep a Changelog** format (most common)
- **Conventional Changelog** format
- **Simple list** format

### Entry Generation

Based on categorized changes from Phase 2:

```markdown
## [Unreleased]

### Added
- New `/update-docs` skill for automatic documentation sync

### Changed
- Updated README commands table

### Fixed
- Fixed broken link in docs/setup.md
```

**Rules:**
- Only add entries for user-facing changes
- Use past tense ("Added", "Fixed", "Changed")
- Keep entries concise (one line each)
- Group by type (Added, Changed, Deprecated, Removed, Fixed, Security)

---

## Phase 6: Create Documentation Commit

If any documentation files were modified:

### Verify Changes

```bash
git status --porcelain
git diff --stat
```

### Review Before Commit

Display a summary:
```
Documentation Updates
=====================

Modified files:
  - README.md (updated commands table)
  - CHANGELOG.md (added entry)
  - docs/setup.md (fixed broken link)

Changes: +15 -3
```

### Create Commit

```bash
git add <modified-doc-files>
git commit -m "docs: sync documentation with recent changes

- Updated commands table in README
- Added CHANGELOG entry
- Fixed broken link in docs/setup.md

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Commit message format:**
- Prefix with `docs:`
- Summary line under 72 characters
- Body lists specific updates
- Include Co-Authored-By

---

## Edge Cases

### No Documentation Files Found
- Report: "No documentation files found in this repository"
- Suggest: "Consider adding a README.md"
- Exit without error

### No Changes Detected
- Report: "No changes require documentation updates"
- Exit without creating commit

### Working Tree Has Uncommitted Changes (non-working-tree mode)
- Warn: "Working tree has uncommitted changes. Documentation commit will only include doc files."
- Proceed with doc-only commit

### CHANGELOG Doesn't Exist
- Skip CHANGELOG updates
- Do not create CHANGELOG (too opinionated)

### Conflict with Existing Changes
- If doc files have uncommitted changes, warn user
- Ask whether to include existing changes or skip file

### Stale Marker File (Session Ended Before Processing)

If `.claude/doc-update-pending.json` exists but references an old commit:

1. **Check if marker is stale:**
   ```bash
   MARKER_COMMIT=$(jq -r '.commit_short' .claude/doc-update-pending.json 2>/dev/null)
   CURRENT_HEAD=$(git rev-parse --short HEAD)
   ```

2. **If marker commit != HEAD:**
   - The Claude session likely ended before processing
   - Ask user: "Stale marker found for commit {marker_commit}. Current HEAD is {current_head}. Process anyway or delete marker?"
   - Options:
     - **Process original commit**: Analyze the commit referenced in marker
     - **Process HEAD instead**: Analyze current HEAD
     - **Delete and skip**: Remove marker without processing

3. **If marker is very old (>24 hours):**
   - Recommend deleting: "Marker is over 24 hours old. The commit may have been pushed/merged already."
   - Still offer to process if user insists

4. **After handling, always clean up:**
   ```bash
   rm -f .claude/doc-update-pending.json
   ```

### Marker File Has Invalid JSON
- If `.claude/doc-update-pending.json` exists but can't be parsed:
- Warn: "Marker file is corrupted. Deleting and skipping."
- Delete the marker and exit without error

---

## Configuration (Optional)

Projects can customize behavior via `.claude/doc-sync-config.json`:

```json
{
  "enabled": true,
  "files": {
    "readme": "README.md",
    "agents": "AGENTS.md",
    "changelog": "CHANGELOG.md",
    "docs": ["docs/**/*.md"]
  },
  "changelog": {
    "enabled": true,
    "format": "keepachangelog"
  },
  "skipPatterns": [
    "docs/api/**"
  ],
  "autoCommit": true
}
```

If no config exists, use conventions described above.

---

## Integration with Post-Commit Hook

This skill can be triggered automatically via git hook. See `POST_COMMIT_HOOK.md` for installation instructions.

When triggered by hook:
- Analyze only the most recent commit
- Run in non-interactive mode
- Create follow-up commit automatically
- Log activity to `.claude/doc-sync.log`

---

## Final Cleanup

**Always run at the end of the skill, regardless of outcome:**

```bash
# Remove marker file to prevent re-triggering
rm -f .claude/doc-update-pending.json
```

This ensures the hook doesn't re-trigger on the next commit.
