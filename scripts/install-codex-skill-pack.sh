#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install the AI Coding Toolkit Codex skill pack into ~/.codex/skills (or CODEX_HOME).

Usage:
  ./scripts/install-codex-skill-pack.sh [--force] [--method copy|symlink] [--dest <path>]

Options:
  --force          Overwrite existing skill directories.
  --method <m>     "copy" (default) or "symlink".
  --dest <path>    Destination skills directory (default: $CODEX_HOME/skills or ~/.codex/skills).
  -h, --help       Show help.
EOF
}

METHOD="copy"
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
SRC_DIR="$ROOT_DIR/codex/skills"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source skills directory not found: $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$DEST"

installed=()
skipped=()

for skill_path in "$SRC_DIR"/*; do
  [[ -d "$skill_path" ]] || continue

  skill_name="$(basename "$skill_path")"
  dest_path="$DEST/$skill_name"

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

echo "Restart Codex CLI to pick up new skills."
