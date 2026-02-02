# Global Skills Sync

Manage symlinks in `~/.claude/skills/` that point to the toolkit, enabling Conductor autocomplete across all workspaces.

## Configuration

```bash
GLOBAL_SKILLS_DIR="$HOME/.claude/skills"
TOOLKIT_SKILLS_DIR="$(pwd)/.claude/skills"
```

## Check Global Skills Status

```bash
# Dynamically discover all distributable skills from toolkit
TOOLKIT_SKILLS=()
for skill_dir in "$TOOLKIT_SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  [[ "$skill_name" == .* ]] && continue
  # Skip toolkit-only skills
  if sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'; then
    continue
  fi
  TOOLKIT_SKILLS+=("$skill_name")
done

# Discover what's currently in the global directory
GLOBAL_INSTALLED=($(ls -1 "$GLOBAL_SKILLS_DIR" 2>/dev/null | grep -v "^\."))
```

## Status Classification

For each skill, determine its global status:

```bash
check_global_skill() {
  local skill_name="$1"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"
  local toolkit_path="$TOOLKIT_SKILLS_DIR/$skill_name"

  if [[ ! -e "$global_path" ]]; then
    echo "MISSING"
  elif [[ -L "$global_path" ]]; then
    local target=$(readlink "$global_path")
    if [[ "$target" == "$toolkit_path" || "$target" == *"/.claude/skills/$skill_name" ]]; then
      echo "SYMLINK_CURRENT"
    else
      echo "SYMLINK_OTHER"
    fi
  else
    # Real directory — never touch these (e.g., design-principles)
    echo "REAL_DIR"
  fi
}
```

| Status | Meaning | Action |
|--------|---------|--------|
| `MISSING` | Skill not in global dir | Create symlink |
| `SYMLINK_CURRENT` | Symlink to this toolkit | No action needed |
| `SYMLINK_OTHER` | Symlink to different source | Skip (not ours) |
| `REAL_DIR` | Real directory (not symlink) | Skip (preserve) |

## Orphan Detection

Detect global symlinks pointing to this toolkit for skills that no longer exist:

```bash
find_orphaned_global_skills() {
  local orphans=()
  for item in "${GLOBAL_INSTALLED[@]}"; do
    local global_path="$GLOBAL_SKILLS_DIR/$item"
    # Only consider symlinks pointing to this toolkit
    if [[ -L "$global_path" ]]; then
      local target=$(readlink "$global_path")
      if [[ "$target" == *"/ai_coding_project_base/.claude/skills/"* ]]; then
        # Check if skill still exists in toolkit
        if [[ ! -d "$TOOLKIT_SKILLS_DIR/$item" ]]; then
          orphans+=("$item")
        fi
      fi
    fi
  done
  echo "${orphans[@]}"
}
```

| Orphan Type | Description | Action |
|-------------|-------------|--------|
| Dangling symlink to toolkit | Skill removed from toolkit | Delete automatically |
| Symlink to other source | Not from this toolkit | Skip |
| Real directory | User-created | Skip (preserve) |

## Sync Logic

```bash
sync_global_skill() {
  local skill_name="$1"
  local status="$2"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"
  local toolkit_path="$TOOLKIT_SKILLS_DIR/$skill_name"

  case "$status" in
    MISSING)
      ln -s "$toolkit_path" "$global_path"
      echo "LINKED"
      ;;
    SYMLINK_CURRENT|REAL_DIR)
      echo "CURRENT"
      ;;
    SYMLINK_OTHER)
      echo "SKIPPED"
      ;;
  esac
}

delete_orphaned_global_skill() {
  local skill_name="$1"
  local global_path="$GLOBAL_SKILLS_DIR/$skill_name"
  rm "$global_path"
  echo "DELETED"
}
```

## Status Display

```
GLOBAL SKILLS (Conductor Autocomplete)
───────────────────────────────────────
Location: ~/.claude/skills
Status:   CURRENT (30 symlinks active)

  Skill                  Status
  ──────────────────────────────────────
  fresh-start            SYMLINK_CURRENT
  phase-start            SYMLINK_CURRENT
  new-skill              MISSING          ← needs linking
  design-principles      REAL_DIR         (preserved)
```

**If all linked:**
```
Status: CURRENT (all 30 skills symlinked)
All distributable skills are globally available for Conductor autocomplete.
```

**If orphans found:**
```
ORPHANED GLOBAL SYMLINKS
────────────────────────
The following global symlinks point to skills removed from toolkit:
  - old-removed-skill

These will be deleted during sync.
```

**If directory missing:**
```
Status: DIRECTORY NOT FOUND
Creating ~/.claude/skills/ ...
```
