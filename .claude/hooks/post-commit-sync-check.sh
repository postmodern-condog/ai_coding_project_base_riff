#!/bin/bash
#
# Post-commit hook for toolkit sync reminders
#
# When skills or commands are modified, reminds user to sync target projects.
# This hook is non-blocking and only displays a reminder message.
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

# Get files changed in the last commit
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)

# Check for skill/command changes
SKILL_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/skills/.*\.md$" || true)
COMMAND_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/commands/.*\.md$" || true)

# Filter out non-syncable commands (these are toolkit-only, not synced to projects)
# Syncable items are skills only - commands stay in the toolkit
SYNCABLE_SKILL_CHANGES="$SKILL_CHANGES"

# If relevant files changed, show reminder
if [ -n "$SYNCABLE_SKILL_CHANGES" ]; then
    echo ""
    echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}              ${YELLOW}TOOLKIT SYNC REMINDER${NC}                         ${CYAN}│${NC}"
    echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"
    echo ""

    if [ -n "$SYNCABLE_SKILL_CHANGES" ]; then
        echo -e "${YELLOW}Skills modified:${NC}"
        echo "$SYNCABLE_SKILL_CHANGES" | sed 's/^/  /'
        echo ""
    fi

    echo -e "Projects using this toolkit may need syncing."
    echo ""
    echo -e "To discover and sync target projects, run:"
    echo -e "  ${GREEN}/update-target-projects${NC}"
    echo ""
    echo -e "${DIM}Or sync a specific project:${NC}"
    echo -e "  ${DIM}/sync /path/to/project${NC}"
    echo ""
fi

# Always exit 0 - this hook should never block commits
exit 0
