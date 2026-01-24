#!/bin/bash
#
# Post-commit hook for toolkit sync notification
#
# When skills are modified, writes a marker file and displays a message.
# Claude (in the current session) will see this and prompt the user to sync.
#
# Installation:
#   ln -sf ../../.claude/hooks/post-commit-sync-check.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
#
# Or use the /install-hooks command to set up automatically.

# Colors for output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Get the toolkit directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Marker file to signal sync is needed
SYNC_MARKER="$TOOLKIT_DIR/.claude/sync-pending.json"

# Get files changed in the last commit
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)

# Check for skill changes (only .claude/skills/ files trigger sync)
SKILL_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/skills/" || true)

# If skill files changed, write marker and notify
if [ -n "$SKILL_CHANGES" ]; then
    # Get commit info
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_SHORT=$(git rev-parse --short HEAD)
    COMMIT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Count skills changed
    SKILL_COUNT=$(echo "$SKILL_CHANGES" | wc -l | tr -d ' ')

    # Write marker file with sync details
    cat > "$SYNC_MARKER" << EOF
{
  "timestamp": "$COMMIT_TIME",
  "commit": "$COMMIT_HASH",
  "commit_short": "$COMMIT_SHORT",
  "skills_changed": [
$(echo "$SKILL_CHANGES" | sed 's/^/    "/; s/$/"/' | paste -sd ',' - | sed 's/,/,\n/g')
  ],
  "skill_count": $SKILL_COUNT
}
EOF

    echo ""
    echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}              ${YELLOW}TOOLKIT SYNC PENDING${NC}                          ${CYAN}│${NC}"
    echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${YELLOW}Skills modified in commit ${COMMIT_SHORT}:${NC}"
    echo "$SKILL_CHANGES" | sed 's/^/  /'
    echo ""
    echo -e "${GREEN}Target projects may need syncing.${NC}"
    echo -e "${DIM}Claude will prompt you to sync.${NC}"
    echo ""
fi

# Always exit 0 - this hook should never block commits
exit 0
