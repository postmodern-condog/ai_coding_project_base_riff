---
description: Initialize a new project with the AI Coding Toolkit
argument-hint: [target-directory]
allowed-tools: Bash, Read, Write, AskUserQuestion
---

Initialize a new project at `$1` with the AI Coding Toolkit.

## Steps

1. **Validate target directory**
   - If `$1` is empty, ask the user for the target directory path
   - Check if the directory exists; if not, offer to create it

2. **Ask project type**
   - Greenfield: Starting a new project from scratch
   - Feature: Adding a feature to an existing project

3. **Copy execution commands and skills**

   Copy only the execution-phase commands to the target's `.claude/commands/`:
   - `fresh-start.md`
   - `phase-prep.md`
   - `phase-start.md`
   - `phase-checkpoint.md`
   - `verify-task.md`
   - `progress.md`
   - `security-scan.md`
   - `list-todos.md`

   Copy skills directory:
   - `.claude/skills/` → target's `.claude/skills/`

   **Do NOT copy:**
   - Generation commands (setup.md, product-spec.md, etc.) — these run from the toolkit
   - Prompt files — these stay in the toolkit

4. **Create CLAUDE.md if it doesn't exist**

   Create a minimal CLAUDE.md that references AGENTS.md:
   ```
   @AGENTS.md
   ```

5. **Report success and next steps**

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
   6. /phase-prep 1
   7. /phase-start 1
   ```

   For Feature:
   ```
   Toolkit initialized at $1

   Next steps (run from THIS toolkit directory):
   1. /feature-spec $1
   2. /feature-technical-spec $1
   3. /feature-plan $1

   Then switch to your project:
   4. cd $1
   5. Merge AGENTS_ADDITIONS.md into AGENTS.md
   6. /fresh-start
   7. /phase-prep 1
   8. /phase-start 1
   ```

## Important

- This command must be run from the ai_coding_project_base toolkit directory
- Generation commands run from toolkit, execution commands run from target
- Use `cp -r` for directory copies to preserve structure
- Do not overwrite existing files without asking
