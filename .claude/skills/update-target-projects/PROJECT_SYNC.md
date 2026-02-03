# Target Project Sync

## Discover Projects

```bash
SEARCH_PATH="${TOOLKIT_SEARCH_PATH:-$HOME/Projects}"
TOOLKIT_PATH="$(pwd)"
CURRENT_COMMIT=$(git rev-parse HEAD)

# Find all projects with toolkit-version.json
find "$SEARCH_PATH" -maxdepth 4 -name "toolkit-version.json" -path "*/.claude/*" 2>/dev/null
```

For each discovered project:
1. Read `.claude/toolkit-version.json`
2. Verify `toolkit_location` matches current toolkit (skip if different)
3. Extract `toolkit_commit` and `last_sync` timestamps

## Activity Detection

```bash
detect_activity() {
  local project_path="$1"

  # ACTIVE: Has uncommitted changes
  if [ -n "$(git -C "$project_path" status --porcelain 2>/dev/null)" ]; then
    echo "ACTIVE"
    return
  fi

  # RECENT: Files modified in last 24 hours
  if find "$project_path" -maxdepth 3 -type f -mtime -1 \
       -not -path '*/node_modules/*' \
       -not -path '*/.git/*' \
       -not -name '*.log' 2>/dev/null | head -1 | grep -q .; then
    echo "RECENT"
    return
  fi

  echo "DORMANT"
}
```

| Status | Meaning | Default Action |
|--------|---------|----------------|
| `ACTIVE` | Uncommitted git changes | Skip (ask first) |
| `RECENT` | Modified in last 24h | Include with note |
| `DORMANT` | No recent activity | Safe to sync |

## Sync Status Check

```bash
LAST_COMMIT="<from toolkit-version.json>"
CURRENT_COMMIT=$(git rev-parse HEAD)

if [ "$LAST_COMMIT" != "$CURRENT_COMMIT" ]; then
  SKILL_CHANGES=$(git diff --name-only "$LAST_COMMIT".."$CURRENT_COMMIT" -- .claude/skills 2>/dev/null | wc -l)
  WORKSTREAM_CHANGES=$(git diff --name-only "$LAST_COMMIT".."$CURRENT_COMMIT" -- .workstream 2>/dev/null | wc -l)
  if [ "$SKILL_CHANGES" -gt 0 ] || [ "$WORKSTREAM_CHANGES" -gt 0 ]; then
    echo "OUTDATED"
  else
    echo "CURRENT"
  fi
else
  echo "CURRENT"
fi
```

## Sync Execution

For each selected project:

```
[1/3] ~/Projects/my-app
      Checking files...
      Copying skills...
      Removing orphaned skills...
      Updating toolkit-version.json...
      Done (5 files updated, 1 deleted)
```

**Sync Logic (for each project):**

1. Change working context to target project
2. **Detect orphaned skills** — skills in target that no longer exist in toolkit
3. For each skill in the sync list, compare hashes:
   - If toolkit hash = target hash: skip (current)
   - If target missing: copy from toolkit (new)
   - If target = last-synced hash: copy from toolkit (clean update)
   - If target differs from last-synced: report conflict (ask user)
4. **Delete orphaned skills** (with user confirmation if locally modified)
5. Update `toolkit-version.json` with new commit, hashes, and removed skills

**Skills to sync:** All skills from `.claude/skills/` are synced dynamically, **excluding toolkit-only skills** (those with `toolkit-only: true` in SKILL.md frontmatter).

**Toolkit-only filtering:**
```bash
# Check if a skill is toolkit-only
is_toolkit_only() {
  local skill_dir="$1"
  sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'
}
```

**Cleanup of toolkit-only skills in targets:** During sync, if a toolkit-only skill is found in a target project, treat it as an orphan:
- If unmodified (hash matches last sync): delete automatically
- If locally modified: prompt user (delete/keep/backup)

## Orphan Detection

Detect skills in target project that no longer exist in toolkit:

```bash
find_orphaned_project_skills() {
  local project_path="$1"
  local target_skills_dir="$project_path/.claude/skills"
  local orphans=()

  # List skills in target project
  for skill in $(ls -1 "$target_skills_dir" 2>/dev/null | grep -v "^\\."); do
    # Check if skill exists in toolkit
    if [[ ! -d "$TOOLKIT_SKILLS_DIR/$skill" ]]; then
      orphans+=("$skill")
    fi
  done
  echo "${orphans[@]}"
}
```

**Orphan handling:**

| Scenario | Action |
|----------|--------|
| Orphaned, no local changes | Delete automatically |
| Orphaned, has local changes | Prompt: delete / keep / backup |
| Not from this toolkit | Skip (may be project-specific) |

```bash
delete_orphaned_project_skill() {
  local project_path="$1"
  local skill_name="$2"
  local skill_path="$project_path/.claude/skills/$skill_name"

  # Check for local modifications (compare against last-synced hash)
  local last_synced_hash=$(jq -r ".skills[\"$skill_name\"].hash // empty" \
    "$project_path/.claude/toolkit-version.json" 2>/dev/null)

  if [[ -z "$last_synced_hash" ]]; then
    # Not tracked — might be project-specific, skip
    echo "SKIPPED"
    return
  fi

  local current_hash=$(find "$skill_path" -type f -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)

  if [[ "$current_hash" == "$last_synced_hash" ]]; then
    # No local changes, safe to delete
    rm -rf "$skill_path"
    echo "DELETED"
  else
    # Has local changes — prompt user
    echo "MODIFIED"
  fi
}
```

## Active Project Handling

For ACTIVE projects, show confirmation:

```
Project: ~/Projects/api-service
Status: ACTIVE (uncommitted changes)

This project has uncommitted git changes:
  M src/api/handlers.ts
  ?? src/api/new-file.ts

Syncing will update skill files but won't affect your uncommitted changes.

Options:
1. Sync anyway
2. Skip this project
3. Show full git status
```

## Workstream Scripts Sync

In addition to skills, sync the `.workstream/` scripts to each target project.

**Files synced (from toolkit `.workstream/`):**

| File | Target location | Notes |
|------|----------------|-------|
| `lib.sh` | `.workstream/lib.sh` | Shared utility library |
| `setup.sh` | `.workstream/setup.sh` | Worktree initializer |
| `dev.sh` | `.workstream/dev.sh` | Dev server launcher |
| `verify.sh` | `.workstream/verify.sh` | Quality gate runner |
| `README.md` | `.workstream/README.md` | Documentation |
| `workstream.json.example` | `.workstream/workstream.json.example` | Schema reference |

**NOT synced:**

- `workstream.json` — Project-owned config (each project has different ports/commands)

**Sync logic:**

```bash
sync_workstream_scripts() {
  local project_path="$1"
  local toolkit_ws="$TOOLKIT_PATH/.workstream"
  local target_ws="$project_path/.workstream"

  mkdir -p "$target_ws"

  for file in lib.sh setup.sh dev.sh verify.sh README.md workstream.json.example; do
    local src="$toolkit_ws/$file"
    local dest="$target_ws/$file"

    if [ ! -f "$src" ]; then continue; fi

    local src_hash=$(shasum -a 256 "$src" | cut -d' ' -f1)
    local dest_hash=""
    if [ -f "$dest" ]; then
      dest_hash=$(shasum -a 256 "$dest" | cut -d' ' -f1)
    fi

    if [ "$src_hash" = "$dest_hash" ]; then
      echo "  $file — current"
    else
      cp "$src" "$dest"
      echo "  $file — updated"
    fi
  done

  # Ensure scripts are executable
  chmod +x "$target_ws"/*.sh 2>/dev/null || true
}
```

**Tracking in toolkit-version.json:**

Workstream script hashes are stored under a `"workstream"` key:

```json
{
  "schema_version": "1.0",
  "toolkit_commit": "abc1234",
  "files": { ... },
  "workstream": {
    ".workstream/lib.sh": {
      "hash": "{sha256}",
      "synced_at": "{ISO timestamp}"
    },
    ".workstream/setup.sh": { ... },
    ".workstream/dev.sh": { ... },
    ".workstream/verify.sh": { ... },
    ".workstream/README.md": { ... }
  }
}
```
