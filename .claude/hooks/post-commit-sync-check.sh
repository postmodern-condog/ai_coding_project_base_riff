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

# Get files changed in the last commit
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)

# Check for skill changes (only .claude/skills/ files trigger sync)
SKILL_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/skills/" || true)

# If skill files changed, run sync in background
if [ -n "$SKILL_CHANGES" ]; then
    echo ""
    echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}              ${YELLOW}TOOLKIT SYNC REMINDER${NC}                         ${CYAN}│${NC}"
    echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"
    echo ""

    echo -e "${YELLOW}Skills modified:${NC}"
    echo "$SKILL_CHANGES" | sed 's/^/  /'
    echo ""

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
