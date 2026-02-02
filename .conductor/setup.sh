#!/usr/bin/env zsh
# Conductor workspace setup script
# Runs inside each newly-created workspace directory.
# $CONDUCTOR_ROOT_PATH = the main repo root.

# Symlink settings.local.json (gitignored, so never in worktrees)
if [ -d ".claude" ] && [ -f "$CONDUCTOR_ROOT_PATH/.claude/settings.local.json" ]; then
  [ -f ".claude/settings.local.json" ] || \
    ln -s "$CONDUCTOR_ROOT_PATH/.claude/settings.local.json" ".claude/settings.local.json"
  echo "✓ Linked settings.local.json"
fi

# Install dependencies if a lockfile exists
if [ -f "pnpm-lock.yaml" ]; then
  pnpm install
elif [ -f "package-lock.json" ]; then
  npm install
elif [ -f "yarn.lock" ]; then
  yarn install
fi
