#!/bin/bash
#
# Pre-push hook for documentation sync checking
#
# This hook analyzes commits being pushed and warns if documentation
# may need updating based on code/command changes.
#
# Installation:
#   ln -sf ../../.claude/hooks/pre-push-doc-check.sh .git/hooks/pre-push
#   chmod +x .git/hooks/pre-push
#
# Or use the /install-hooks command to set up automatically.

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get the range of commits being pushed
# If this is the first push, compare against empty tree
EMPTY_TREE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"

while read local_ref local_sha remote_ref remote_sha; do
    if [ "$remote_sha" = "$EMPTY_TREE" ] || [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
        # First push or new branch - check all commits
        RANGE="$local_sha"
    else
        RANGE="$remote_sha..$local_sha"
    fi

    # Get list of changed files in this push
    CHANGED_FILES=$(git diff --name-only "$RANGE" 2>/dev/null || git diff-tree --no-commit-id --name-only -r "$local_sha")

    # Categorize changes
    COMMAND_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/commands/.*\.md$" || true)
    SKILL_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^\.claude/skills/.*\.md$" || true)
    PROMPT_CHANGES=$(echo "$CHANGED_FILES" | grep -E ".*PROMPT.*\.md$|.*_SPEC_PROMPT\.md$" || true)
    DOC_CHANGES=$(echo "$CHANGED_FILES" | grep -E "^README\.md$|^docs/.*\.md$|^AGENTS\.md$" || true)

    # Check for documentation sync issues
    WARNINGS=""

    # Case 1: Commands changed but README not updated
    if [ -n "$COMMAND_CHANGES" ] && [ -z "$(echo "$DOC_CHANGES" | grep -E "^README\.md$")" ]; then
        WARNINGS+="  - Commands changed but README.md not updated:\n"
        while IFS= read -r file; do
            [ -n "$file" ] && WARNINGS+="      $file\n"
        done <<< "$COMMAND_CHANGES"
    fi

    # Case 2: Skills changed but no docs updated
    if [ -n "$SKILL_CHANGES" ] && [ -z "$DOC_CHANGES" ]; then
        WARNINGS+="  - Skills changed but no documentation updated:\n"
        while IFS= read -r file; do
            [ -n "$file" ] && WARNINGS+="      $file\n"
        done <<< "$SKILL_CHANGES"
    fi

    # Case 3: Prompt templates changed but no docs updated
    if [ -n "$PROMPT_CHANGES" ] && [ -z "$DOC_CHANGES" ]; then
        WARNINGS+="  - Prompt templates changed but no documentation updated:\n"
        while IFS= read -r file; do
            [ -n "$file" ] && WARNINGS+="      $file\n"
        done <<< "$PROMPT_CHANGES"
    fi

    # Output warnings if any
    if [ -n "$WARNINGS" ]; then
        echo -e "${YELLOW}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║           DOCUMENTATION SYNC CHECK - WARNING                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo -e "The following changes may require documentation updates:\n"
        echo -e "$WARNINGS"
        echo ""
        echo -e "${YELLOW}Consider updating:${NC}"
        echo "  - README.md (command list, file structure)"
        echo "  - docs/*.md (detailed documentation)"
        echo "  - AGENTS.md (if behavior changes affect agent instructions)"
        echo ""

        # Interactive prompt (only if terminal is available)
        if [ -t 0 ]; then
            echo -n "Continue with push anyway? [y/N]: "
            read -r response
            case "$response" in
                [yY][eE][sS]|[yY])
                    echo -e "${GREEN}Proceeding with push...${NC}"
                    ;;
                *)
                    echo -e "${RED}Push aborted. Update documentation and try again.${NC}"
                    exit 1
                    ;;
            esac
        else
            # Non-interactive mode - warn but allow
            echo -e "${YELLOW}Running in non-interactive mode. Push will proceed.${NC}"
            echo "Run 'git push' interactively to be prompted for confirmation."
        fi
    fi
done

exit 0
