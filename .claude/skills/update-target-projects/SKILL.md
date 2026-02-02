---
name: update-target-projects
description: Discover and sync all toolkit-using projects with the latest skills. Use when skills are modified, after the post-commit hook reminds you, or to batch-sync multiple projects.
toolkit-only: true
---

# Update Target Projects

Discover and sync all toolkit-using projects, the Codex CLI skill pack, and global Conductor skill symlinks with the latest skills.

## Trigger

Use this skill when:
- The post-commit hook reminds you to sync after skill changes
- You want to batch-sync multiple projects at once
- You need to check which projects are out of date
- You want to update the Codex CLI skill pack
- You want to verify global skill symlinks for Conductor autocomplete

## Configuration

**Codex skill pack location:**
1. `$CODEX_HOME/skills` if `CODEX_HOME` is set
2. `~/.codex/skills` (default)

**Project search paths:**
1. `$TOOLKIT_SEARCH_PATH` environment variable (colon-separated paths)
2. `~/Projects` (default)

**Search depth:** 4 levels (finds `~/Projects/*/`, `~/Projects/*/*/`, and `~/Projects/*/*/*/`)

**Global skills location:** `~/.claude/skills/` (symlinks for Conductor autocomplete)

## Workflow

Copy this checklist and track progress:

```
Update Target Projects Progress:
- [ ] Phase 1: Discover projects with toolkit-version.json
- [ ] Phase 1b: Check Codex CLI skill pack status
- [ ] Phase 1c: Check global skill symlinks (Conductor autocomplete)
- [ ] Phase 1d: Detect orphaned skills (removed from toolkit)
- [ ] Phase 2: Detect activity status for each project
- [ ] Phase 3: Check sync status (OUTDATED vs CURRENT)
- [ ] Phase 4: Display status report (including orphans and global status)
- [ ] Phase 5: User selection (what to sync)
- [ ] Phase 6a: Sync Codex skill pack (if selected) — includes deletions
- [ ] Phase 6b: Sync global skill symlinks (if selected)
- [ ] Phase 6c: Sync target projects (if selected) — includes deletions
- [ ] Phase 7: Generate summary report
```

### Phase 1: Discover Projects

See [PROJECT_SYNC.md](PROJECT_SYNC.md) for detailed discovery and sync logic.

1. Find all `toolkit-version.json` files in search paths
2. Read each file and verify `toolkit_location` matches
3. Extract `toolkit_commit` and `last_sync` timestamps

### Phase 1b: Check Codex CLI Skill Pack

See [CODEX_SYNC.md](CODEX_SYNC.md) for detailed Codex sync logic.

1. Discover skills dynamically from toolkit
2. Classify each skill: MISSING, SYMLINK_CURRENT, COPY_OUTDATED, etc.
3. Determine overall Codex status

### Phase 1c: Check Global Skill Symlinks

See [GLOBAL_SYNC.md](GLOBAL_SYNC.md) for detailed global sync logic.

1. Scan `~/.claude/skills/` for existing entries
2. Classify each: SYMLINK_CURRENT, MISSING, SYMLINK_OTHER, REAL_DIR
3. Detect orphaned symlinks (pointing to deleted toolkit skills)
4. Determine overall global status

### Phase 1d: Detect Orphaned Skills

Identify skills that exist in targets but have been removed from toolkit:

1. Compare installed skills against current toolkit skills
2. Mark as ORPHANED if skill directory no longer exists in toolkit
3. Check if orphaned skills have local modifications

See [CODEX_SYNC.md](CODEX_SYNC.md) and [PROJECT_SYNC.md](PROJECT_SYNC.md) for orphan detection logic.

### Phase 2-3: Activity and Sync Status

For each project:
- Classify activity: ACTIVE (uncommitted), RECENT (modified <24h), DORMANT
- Check if sync needed by comparing commits

### Phase 4: Display Status Report

```
TOOLKIT SYNC STATUS
===================
Toolkit: /path/to/toolkit
Current: abc1234 (2026-01-23)

GLOBAL SKILLS (Conductor Autocomplete)
───────────────────────────────────────
Location: ~/.claude/skills
Status:   CURRENT (30 symlinks active)

CODEX CLI SKILL PACK
────────────────────
Location: ~/.codex/skills
Status:   {status summary}

TARGET PROJECTS
───────────────
  #  Project          Sync Status   Last Sync     Activity
  ─────────────────────────────────────────────────────────
  1  ~/Projects/app   OUTDATED      3 days ago    DORMANT
```

### Phase 5: User Selection

Prompt with options:
1. Sync everything (Recommended)
2. Global skill symlinks only
3. Codex skill pack only
4. Target projects only
5. Select specific items
6. Include ACTIVE projects too
7. Skip for now

### Phase 6: Execute Sync

**6a: Codex Sync** — See [CODEX_SYNC.md](CODEX_SYNC.md)
**6b: Global Skills Sync** — See [GLOBAL_SYNC.md](GLOBAL_SYNC.md)
**6c: Project Sync** — See [PROJECT_SYNC.md](PROJECT_SYNC.md)

### Phase 7: Summary Report

```
SYNC COMPLETE
=============

Global Skills (Conductor Autocomplete):
  Symlinks created: 2
  Symlinks removed: 1 (orphaned)
  Already current:  28

Codex CLI Skill Pack:
  Skills updated:  3
  Skills deleted:  1 (orphaned)
  Already current: 12

Target Projects:
  Projects processed: 4
    Synced:  2
    Skipped: 1 (active)
    Current: 1
  Skills deleted: 1 (orphaned)

Deleted Skills (removed from toolkit):
  - multi-model-verify

All synced items are now at toolkit commit abc1234
```

## Edge Cases

See [EDGE_CASES.md](EDGE_CASES.md) for handling:
- Codex directory doesn't exist
- No projects found
- Project uses different toolkit
- Git not available
- Sync conflicts

---

**REMINDER**: Always copy skills to target projects, not just update toolkit-version.json. The version file tracks state, but skills must actually be copied for changes to take effect.
