#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Configure essential MCP servers for Codex CLI to match Claude Code capabilities.

Usage:
  ./scripts/configure-codex-mcp.sh [--force]

Options:
  --force          Overwrite existing MCP configurations.
  -h, --help       Show help.

MCPs configured:
  - Playwright (browser automation for verification)

This script adds MCP server entries to ~/.codex/config.toml.
Both Claude Code and Codex CLI support the same MCP protocol,
but use different configuration formats (JSON vs TOML).
EOF
}

FORCE="0"
CONFIG_FILE="${CODEX_HOME:-$HOME/.codex}/config.toml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE="1"
      shift
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

# Ensure config directory exists
mkdir -p "$(dirname "$CONFIG_FILE")"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  touch "$CONFIG_FILE"
fi

# Function to check if an MCP server is already configured
has_mcp_server() {
  local server_name="$1"
  grep -q "^\[mcp_servers\.$server_name\]" "$CONFIG_FILE" 2>/dev/null
}

# Function to add MCP server configuration
add_mcp_server() {
  local server_name="$1"
  local config_block="$2"

  if has_mcp_server "$server_name"; then
    if [[ "$FORCE" == "1" ]]; then
      # Remove existing config (simple approach: notify user to do it manually if complex)
      echo "Warning: MCP server '$server_name' already configured."
      echo "Remove the existing [mcp_servers.$server_name] section from $CONFIG_FILE"
      echo "and re-run this script, or manually update the configuration."
      return 1
    else
      echo "Skipped: $server_name (already configured; use --force to overwrite)"
      return 0
    fi
  fi

  # Append config block to file
  {
    echo ""
    echo "$config_block"
  } >> "$CONFIG_FILE"

  echo "Configured: $server_name"
}

echo "Configuring MCP servers for Codex CLI..."
echo "Config file: $CONFIG_FILE"
echo

configured=0
skipped=0

# Playwright MCP - essential for browser verification automation
PLAYWRIGHT_CONFIG='[mcp_servers.playwright]
command = "npx"
args = ["-y", "@playwright/mcp@latest"]'

if add_mcp_server "playwright" "$PLAYWRIGHT_CONFIG"; then
  if has_mcp_server "playwright" && [[ "$FORCE" != "1" ]]; then
    ((skipped++))
  else
    ((configured++))
  fi
fi

echo
echo "Configuration complete."
echo "  Configured: $configured"
echo "  Skipped: $skipped"
echo

if [[ $configured -gt 0 ]]; then
  echo "Restart Codex CLI to pick up new MCP servers."
  echo
  echo "To verify, run in Codex TUI: /mcp"
fi
