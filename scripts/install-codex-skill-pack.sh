#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install the AI Coding Toolkit Codex skill pack into ~/.codex/skills (or CODEX_HOME).

Usage:
  ./scripts/install-codex-skill-pack.sh [--force] [--method copy|symlink] [--dest <path>]

Options:
  --force          Overwrite existing skill directories.
  --method <m>     "copy" or "symlink" (default: symlink).
  --dest <path>    Destination skills directory (default: $CODEX_HOME/skills or ~/.codex/skills).
  -h, --help       Show help.

Skills: All skills from .claude/skills/ are discovered and installed automatically.
EOF
}

# Default to symlink for auto-updates
METHOD="symlink"
FORCE="0"
DEST="${CODEX_HOME:-$HOME/.codex}/skills"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE="1"
      shift
      ;;
    --method)
      METHOD="${2:-}"
      shift 2
      ;;
    --dest)
      DEST="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$METHOD" != "copy" && "$METHOD" != "symlink" ]]; then
  echo "Invalid --method: $METHOD (expected: copy|symlink)" >&2
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/.claude/skills"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source skills directory not found: $SRC_DIR" >&2
  exit 1
fi

# Dynamically discover all skills from the toolkit
# This ensures new skills are automatically included without manual updates
# Skills with toolkit-only: true in frontmatter are excluded from distribution
SKILLS=()
while IFS= read -r -d '' skill_dir; do
  skill_name="$(basename "$skill_dir")"
  # Skip hidden directories
  [[ "$skill_name" == .* ]] && continue
  # Skip toolkit-only skills (parse YAML frontmatter between --- markers)
  if sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -q '^toolkit-only: true'; then
    continue
  fi
  SKILLS+=("$skill_name")
done < <(find "$SRC_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ ${#SKILLS[@]} -eq 0 ]]; then
  echo "No skills found in $SRC_DIR" >&2
  exit 1
fi

echo "Discovered ${#SKILLS[@]} skills to install."

mkdir -p "$DEST"

installed=()
skipped=()
missing=()

for skill_name in "${SKILLS[@]}"; do
  skill_path="$SRC_DIR/$skill_name"
  dest_path="$DEST/$skill_name"

  if [[ ! -d "$skill_path" ]]; then
    missing+=("$skill_name")
    continue
  fi

  if [[ -e "$dest_path" ]]; then
    if [[ "$FORCE" == "1" ]]; then
      rm -rf "$dest_path"
    else
      skipped+=("$skill_name")
      continue
    fi
  fi

  if [[ "$METHOD" == "symlink" ]]; then
    ln -s "$skill_path" "$dest_path"
  else
    cp -R "$skill_path" "$dest_path"
  fi

  installed+=("$skill_name")
done

echo "Codex skill pack install complete."
echo "Destination: $DEST"
echo "Method: $METHOD"
echo

if [[ ${#installed[@]} -gt 0 ]]; then
  echo "Installed:"
  printf '  - %s\n' "${installed[@]}"
  echo
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
  echo "Skipped (already exists; re-run with --force to overwrite):"
  printf '  - %s\n' "${skipped[@]}"
  echo
fi

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Warning - skills not found in toolkit:"
  printf '  - %s\n' "${missing[@]}"
  echo
fi

if [[ "$METHOD" == "symlink" ]]; then
  echo "Using symlinks: Skills will auto-update when toolkit is updated."
else
  echo "Using copies: Re-run with --force to get toolkit updates."
fi
echo
echo "Restart Codex CLI to pick up new skills."
