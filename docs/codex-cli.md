# Codex CLI Setup

This toolkit includes a Codex CLI skill pack that mirrors the execution slash commands.

## Installation

### Auto-Detection (Recommended)

When running `/setup` to initialize a new project, the toolkit automatically detects if Codex CLI is installed. If found, it offers to install the skill pack via symlinks—keeping commands in sync as the toolkit updates.

### Manual Installation

From the toolkit repo root:

```bash
./scripts/install-codex-skill-pack.sh
```

Then restart Codex CLI.

### Symlinks vs Copy

The recommended installation uses symlinks. This means:
- Commands stay in sync when you update the toolkit
- No need to reinstall after toolkit updates
- Single source of truth for command definitions

## Usage

In any target project directory, you can use the same commands:

```bash
/fresh-start
/phase-prep 1
/phase-start 1
/phase-checkpoint 1
```

## Available Commands

The Codex skill pack includes:

| Command | Description |
|---------|-------------|
| `/fresh-start` | Orient to project, load context |
| `/phase-prep N` | Check prerequisites for phase N |
| `/phase-start N` | Execute phase N |
| `/phase-checkpoint N` | Run tests, security scan, verify completion |
| `/verify-task X.Y.Z` | Verify specific task |
| `/security-scan` | Run security checks |
| `/progress` | Show execution progress |

## Differences from Claude Code

The Codex skill pack provides equivalent functionality, but:

- MCP tool detection may behave differently
- Some skills may have reduced capability without Claude Code's native integrations
- File paths and working directory handling follow Codex conventions

## Troubleshooting

If commands aren't recognized after installation:

1. Ensure the install script completed successfully
2. Restart Codex CLI completely
3. Verify the skills are in the expected Codex skills directory
