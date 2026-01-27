#!/bin/bash
#
# Post-commit hook for automatic documentation updates
#
# Creates a marker file that signals Claude to run /update-docs.
# This keeps documentation in sync with code changes automatically.
#
# Installation:
#   ln -sf ../../.claude/hooks/post-commit-doc-update.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
#
# Or use the /install-hooks command to set up automatically.
#
# To combine with other post-commit hooks, create a dispatcher script.
#
# Note: This hook always exits 0 to never block commits. Errors are silently ignored.

# Skip if [skip-docs] is in the commit message
COMMIT_MSG=$(git log -1 --pretty=%B)
if echo "$COMMIT_MSG" | grep -q '\[skip-docs\]'; then
    exit 0
fi

# Skip if SKIP_DOC_SYNC environment variable is set
if [ -n "$SKIP_DOC_SYNC" ]; then
    exit 0
fi

# Skip if this is already a docs commit (prevent loops)
# Matches: docs:, docs(scope):, Docs:, DOCS:, etc. (case-insensitive, with optional scope)
if echo "$COMMIT_MSG" | grep -qiE '^docs(\([^)]*\))?:'; then
    exit 0
fi

# Colors for output (using printf for POSIX compatibility)
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    exit 0
fi

# Create marker directory if needed
mkdir -p "$REPO_ROOT/.claude"

# Marker file to signal doc update needed
MARKER="$REPO_ROOT/.claude/doc-update-pending.json"

# Get commit info
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_SHORT=$(git rev-parse --short HEAD)
COMMIT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get changed files (-m flag handles merge commits properly)
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r -m HEAD 2>/dev/null || true)

# Categorize changes for the marker
SKILL_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/skills/" || true)
CONFIG_CHANGES=$(echo "$CHANGED_FILES" | grep -E "(package\.json|\.claude/.*\.json|pyproject\.toml|Cargo\.toml)" || true)
STRUCTURE_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^(src|lib|app|components|pages|api)/" || true)

# Count significant changes (using wc -l, trimming whitespace)
count_lines() {
    echo "$1" | grep -c . 2>/dev/null | tr -d '[:space:]' || echo "0"
}

SKILL_COUNT=$(count_lines "$SKILL_CHANGES")
CONFIG_COUNT=$(count_lines "$CONFIG_CHANGES")
STRUCTURE_COUNT=$(count_lines "$STRUCTURE_CHANGES")

# Ensure counts are valid integers (default to 0)
SKILL_COUNT=${SKILL_COUNT:-0}
CONFIG_COUNT=${CONFIG_COUNT:-0}
STRUCTURE_COUNT=${STRUCTURE_COUNT:-0}

# Only create marker if there are potentially doc-worthy changes
TOTAL_SIGNIFICANT=$((SKILL_COUNT + CONFIG_COUNT + STRUCTURE_COUNT))
if [ "$TOTAL_SIGNIFICANT" -eq 0 ]; then
    # Check for any meaningful changes (not just docs)
    NON_DOC_CHANGES=$(echo "$CHANGED_FILES" | grep -vE "\.(md|txt)$" | grep -c . 2>/dev/null | tr -d '[:space:]' || echo "0")
    NON_DOC_CHANGES=${NON_DOC_CHANGES:-0}
    if [ "$NON_DOC_CHANGES" -eq 0 ]; then
        exit 0
    fi
fi

# Function to escape a string for JSON
# Handles: backslashes, quotes, newlines, tabs, carriage returns, and control chars
json_escape() {
    local str="$1"
    # Use printf and sed for POSIX compatibility
    # Order matters: escape backslashes first, then other chars
    printf '%s' "$str" | sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e 's/	/\\t/g' \
        -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' \
        -e 's/\r/\\r/g'
}

# Get first line of commit message and escape for JSON
COMMIT_MSG_LINE=$(echo "$COMMIT_MSG" | head -1)
COMMIT_MSG_ESCAPED=$(json_escape "$COMMIT_MSG_LINE")

# Write marker file with context
cat > "$MARKER" << EOF
{
  "timestamp": "$COMMIT_TIME",
  "commit": "$COMMIT_HASH",
  "commit_short": "$COMMIT_SHORT",
  "message": "$COMMIT_MSG_ESCAPED",
  "trigger": "post-commit",
  "changes": {
    "skills": $SKILL_COUNT,
    "config": $CONFIG_COUNT,
    "structure": $STRUCTURE_COUNT,
    "total_files": $(count_lines "$CHANGED_FILES")
  }
}
EOF

# Display notification (using printf for POSIX compatibility)
printf '\n'
printf '%b╭─────────────────────────────────────────────────────────────╮%b\n' "$CYAN" "$NC"
printf '%b│%b            %bDOCUMENTATION SYNC PENDING%b                       %b│%b\n' "$CYAN" "$NC" "$YELLOW" "$NC" "$CYAN" "$NC"
printf '%b╰─────────────────────────────────────────────────────────────╯%b\n' "$CYAN" "$NC"
printf '\n'
printf '%bCommit %s%b may require documentation updates.\n' "$GREEN" "$COMMIT_SHORT" "$NC"
printf '\n'
if [ "${SKILL_COUNT:-0}" -gt 0 ]; then
    printf '  %bSkills changed:%b %s\n' "$DIM" "$NC" "$SKILL_COUNT"
fi
if [ "${CONFIG_COUNT:-0}" -gt 0 ]; then
    printf '  %bConfig changed:%b %s\n' "$DIM" "$NC" "$CONFIG_COUNT"
fi
if [ "${STRUCTURE_COUNT:-0}" -gt 0 ]; then
    printf '  %bStructure changed:%b %s\n' "$DIM" "$NC" "$STRUCTURE_COUNT"
fi
printf '\n'
printf '%bClaude will run /update-docs automatically.%b\n' "$DIM" "$NC"
printf '%bTo skip: add [skip-docs] to commit message%b\n' "$DIM" "$NC"
printf '\n'

# Always exit 0 - this hook should never block commits
exit 0
