---
description: Initialize a new project with the AI Coding Toolkit
argument-hint: [target-directory]
allowed-tools: Bash, Read, Write, AskUserQuestion
---

Initialize a new project at `$1` with the AI Coding Toolkit.

## Steps

0. **Directory guard (must run from toolkit repo)**
   - Confirm `START_PROMPTS.md` and `GENERATOR_PROMPT.md` exist in the current working directory
   - If either is missing, **STOP** and tell the user to `cd` into the `ai_coding_project_base` toolkit repo and re-run `/setup $1`

1. **Validate target directory**
   - If `$1` is empty, ask the user for the target directory path
   - Check if the directory exists; if not, offer to create it

2. **Ask project type**
   - Greenfield: Starting a new project from scratch
   - Feature: Adding a feature to an existing project

2a. **For Feature type: Ask feature name and create directory**
    - Prompt: "What should this feature be called? (used as folder name, e.g., 'analytics-dashboard')"
    - Validate: lowercase, hyphens and underscores allowed, no spaces or special characters
    - Create `$1/features/` directory if it doesn't exist
    - Create `$1/features/<feature-name>/` directory
    - Store the feature path as `FEATURE_PATH` = `$1/features/<feature-name>`

3. **Copy execution commands and skills**

   Copy only the execution-phase commands to the target's `.claude/commands/`:
   - `fresh-start.md`
   - `phase-prep.md`
   - `phase-start.md`
   - `phase-checkpoint.md`
   - `verify-task.md`
   - `criteria-audit.md`
   - `configure-verification.md`
   - `progress.md`
   - `security-scan.md`
   - `list-todos.md`

   Copy skills directory:
   - `.claude/skills/` → target's `.claude/skills/`

   Copy verification config (if missing):
   - `.claude/verification-config.json` → target's `.claude/verification-config.json`

4. **Create toolkit-version.json**

   After copying files, create `.claude/toolkit-version.json` in the target to enable future syncs:

   ```json
   {
     "schema_version": "1.0",
     "toolkit_location": "{absolute path to this toolkit}",
     "toolkit_commit": "{current git HEAD commit hash}",
     "toolkit_commit_date": "{commit date in ISO format}",
     "last_sync": "{current ISO timestamp}",
     "files": {
       ".claude/commands/fresh-start.md": {
         "hash": "{sha256 hash of copied file}",
         "synced_at": "{ISO timestamp}"
       }
       // ... entry for each copied command and skill
     }
   }
   ```

   Get toolkit info:
   ```bash
   TOOLKIT_PATH=$(pwd)
   COMMIT_HASH=$(git rev-parse HEAD)
   COMMIT_DATE=$(git log -1 --format=%cI HEAD)
   ```

   Calculate file hashes:
   ```bash
   shasum -a 256 "$file" | cut -d' ' -f1
   ```

   Include entries for:
   - All copied commands (`.claude/commands/*.md`)
   - All copied skills (`.claude/skills/*/SKILL.md`)

   **Do NOT copy:**
   - Generation commands (setup.md, product-spec.md, etc.) — these run from the toolkit
   - Prompt files — these stay in the toolkit

5. **Create CLAUDE.md if it doesn't exist**

   Create a minimal CLAUDE.md that references AGENTS.md:
   ```
   @AGENTS.md
   ```

6. **Codex CLI Detection (Optional)**

   Check if OpenAI Codex CLI is installed:
   ```bash
   command -v codex >/dev/null 2>&1
   ```

   If Codex is detected:
   - Use AskUserQuestion to prompt:
     ```
     Question: "Codex CLI detected. Install toolkit skills for Codex?"
     Options:
       - "Yes, install" — Install skills via symlink (auto-updates with toolkit)
       - "No, skip" — Don't install Codex skills
     ```

   If user selects "Yes, install":
   - Run from this toolkit directory:
     ```bash
     ./scripts/install-codex-skill-pack.sh --method symlink
     ```
   - Report the installation result

   If Codex is not detected:
   - Skip silently (don't mention Codex to users who don't have it)

   **Note:** Using symlinks means Codex skills auto-update when user runs `git pull` on the toolkit.

6a. **Codex MCP Configuration (if Codex detected and skills installed)**

   After installing Codex skills, offer to configure essential MCPs:
   - Use AskUserQuestion to prompt:
     ```
     Question: "Configure essential MCP servers for Codex? (Playwright for browser verification)"
     Options:
       - "Yes, configure" — Add Playwright MCP to ~/.codex/config.toml
       - "No, skip" — Skip MCP configuration
     ```

   If user selects "Yes, configure":
   - Run from this toolkit directory:
     ```bash
     ./scripts/configure-codex-mcp.sh
     ```
   - Report the configuration result

   **Why this matters:** Both Claude Code and Codex CLI support the same MCP protocol.
   This ensures Codex has access to browser automation for verification workflows,
   matching Claude Code's capabilities when using the Playwright MCP.

7. **Report success and next steps**

   For Greenfield:
   ```
   Toolkit initialized at $1

   Next steps (run from THIS toolkit directory):
   1. /product-spec $1
   2. /technical-spec $1
   3. /generate-plan $1

   Then switch to your project:
   4. cd $1
   5. /fresh-start
   6. /configure-verification
   7. /phase-prep 1
   8. /phase-start 1
   ```

   For Feature:
   ```
   Toolkit initialized at $1
   Feature directory created at FEATURE_PATH

   Next steps (run from THIS toolkit directory):
   1. /feature-spec FEATURE_PATH
   2. /feature-technical-spec FEATURE_PATH
   3. /feature-plan FEATURE_PATH

   Then switch to your feature directory:
   4. cd FEATURE_PATH
   5. /fresh-start
   6. /configure-verification
   7. /phase-prep 1
   8. /phase-start 1

   After phase completion, merge AGENTS_ADDITIONS.md into $1/AGENTS.md
   ```

## Important

- This command must be run from the ai_coding_project_base toolkit directory
- Generation commands run from toolkit, execution commands run from target
- Use `cp -r` for directory copies to preserve structure
- Do not overwrite existing files without asking
