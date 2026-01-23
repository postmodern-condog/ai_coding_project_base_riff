#!/bin/bash
#
# Session End Logger for Automation Opportunity Discovery
#
# This hook captures session data after each Claude Code session ends.
# Used to identify manual patterns that could be automated with new skills.
#
# Data is stored in .claude/logs/sessions.jsonl (append-only JSONL format).
# Analysis is triggered automatically after every 5 sessions.
#
# Installation (via settings.json hooks section):
#   "hooks": {
#     "SessionEnd": [{
#       "type": "command",
#       "command": "bash .claude/hooks/session-end-logger.sh"
#     }]
#   }

set -e

# Read session data from stdin (JSON with session_id, transcript_path, cwd, etc.)
SESSION_DATA=$(cat)

# Parse session info
SESSION_ID=$(echo "$SESSION_DATA" | jq -r '.session_id // empty')
TRANSCRIPT_PATH=$(echo "$SESSION_DATA" | jq -r '.transcript_path // empty')
CWD=$(echo "$SESSION_DATA" | jq -r '.cwd // empty')

# Exit early if no session ID (shouldn't happen, but be safe)
if [ -z "$SESSION_ID" ]; then
    exit 0
fi

# Determine log directory (centralized in toolkit)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_DIR="$TOOLKIT_ROOT/.claude/logs"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log file path
LOG_FILE="$LOG_DIR/sessions.jsonl"
ANALYSIS_FILE="$LOG_DIR/ANALYSIS_REPORT.md"

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Extract project name from CWD
PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

# Build log entry
# Note: transcript_path may be empty or inaccessible - we log what we can
LOG_ENTRY=$(jq -n \
    --arg session_id "$SESSION_ID" \
    --arg timestamp "$TIMESTAMP" \
    --arg project "$PROJECT_NAME" \
    --arg cwd "$CWD" \
    --arg transcript_path "$TRANSCRIPT_PATH" \
    '{
        session_id: $session_id,
        timestamp: $timestamp,
        project: $project,
        cwd: $cwd,
        transcript_path: $transcript_path
    }'
)

# Append to log file
echo "$LOG_ENTRY" >> "$LOG_FILE"

# Count sessions since last analysis
SESSION_COUNT=$(wc -l < "$LOG_FILE" | tr -d ' ')
LAST_ANALYSIS_COUNT=0

# Check if analysis marker exists
ANALYSIS_MARKER="$LOG_DIR/.last-analysis-count"
if [ -f "$ANALYSIS_MARKER" ]; then
    LAST_ANALYSIS_COUNT=$(cat "$ANALYSIS_MARKER")
fi

SESSIONS_SINCE_ANALYSIS=$((SESSION_COUNT - LAST_ANALYSIS_COUNT))

# Trigger analysis after every 5 sessions
if [ "$SESSIONS_SINCE_ANALYSIS" -ge 5 ]; then
    # Update marker before analysis (prevents duplicate triggers)
    echo "$SESSION_COUNT" > "$ANALYSIS_MARKER"

    # Output reminder to user (will be shown in terminal)
    echo ""
    echo "---"
    echo "Session logged. You have $SESSION_COUNT sessions recorded."
    echo "Run /analyze-sessions to discover automation opportunities."
    echo "---"
fi

exit 0
