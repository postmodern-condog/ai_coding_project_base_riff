#!/bin/bash
#
# Post-commit hook for automatic toolkit sync
#
# When skills are modified, automatically syncs target projects in background.
# This hook is non-blocking - sync runs asynchronously after commit completes.
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

# Log file for background sync
SYNC_LOG="$TOOLKIT_DIR/.claude/sync-log.txt"

# Get files changed in the last commit
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)

# Check for skill changes (only .claude/skills/ files trigger sync)
SKILL_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/skills/" || true)

# If skill files changed, run sync in background
if [ -n "$SKILL_CHANGES" ]; then
    echo ""
    echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}              ${YELLOW}TOOLKIT AUTO-SYNC${NC}                             ${CYAN}│${NC}"
    echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"
    echo ""

    echo -e "${YELLOW}Skills modified:${NC}"
    echo "$SKILL_CHANGES" | sed 's/^/  /'
    echo ""

    # Check if claude CLI is available
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}Starting background sync of target projects...${NC}"
        echo -e "${DIM}Log: $SYNC_LOG${NC}"
        echo ""

        # Run sync in background, redirecting output to log file
        # Use nohup to ensure it continues even if terminal closes
        (
            echo "=== Sync started: $(date) ===" >> "$SYNC_LOG"
            echo "Skills changed:" >> "$SYNC_LOG"
            echo "$SKILL_CHANGES" >> "$SYNC_LOG"
            echo "" >> "$SYNC_LOG"

            # Run claude with the update-target-projects command
            # --print flag runs non-interactively
            cd "$TOOLKIT_DIR" && claude -p "/update-target-projects" >> "$SYNC_LOG" 2>&1

            echo "" >> "$SYNC_LOG"
            echo "=== Sync completed: $(date) ===" >> "$SYNC_LOG"
            echo "" >> "$SYNC_LOG"
        ) &

        # Disown the background process so it's not tied to the terminal
        disown

        echo -e "${DIM}Sync running in background. Check $SYNC_LOG for results.${NC}"
    else
        echo -e "${YELLOW}Claude CLI not found. Manual sync required:${NC}"
        echo -e "  ${GREEN}/update-target-projects${NC}"
    fi
    echo ""
fi

# Always exit 0 - this hook should never block commits
exit 0
