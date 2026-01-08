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

3. **Copy files based on project type**

   **Always copy:**
   - `.claude/` directory (commands and skills)
   - `.codex/` directory (skills for Codex CLI)

   **For Greenfield projects, also copy:**
   - `PRODUCT_SPEC_PROMPT.md`
   - `TECHNICAL_SPEC_PROMPT.md`
   - `GENERATOR_PROMPT.md`
   - `START_PROMPTS.md`

   **For Feature projects, also copy:**
   - `FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md` → target root as `FEATURE_SPEC_PROMPT.md`
   - `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md` → target root as `FEATURE_TECHNICAL_SPEC_PROMPT.md`
   - `FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md` → target root as `FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md`
   - `START_PROMPTS.md`

4. **Create CLAUDE.md if it doesn't exist**

   Create a minimal CLAUDE.md that references AGENTS.md:
   ```
   @AGENTS.md
   ```

5. **Report success and next steps**

   For Greenfield:
   ```
   Toolkit initialized at $1

   Next steps:
   1. cd $1
   2. Run /product-spec to define what you're building
   3. Run /technical-spec to define how it's built
   4. Run /generate-plan to create EXECUTION_PLAN.md and AGENTS.md
   5. Run /fresh-start to orient and load context
   6. Run /phase-prep 1 to check prerequisites
   7. Run /phase-start 1 to begin execution
   ```

   For Feature:
   ```
   Toolkit initialized at $1

   Next steps:
   1. cd $1
   2. Run /feature-spec to define the feature
   3. Run /feature-technical-spec to define integration approach
   4. Run /feature-plan to create EXECUTION_PLAN.md and AGENTS_ADDITIONS.md
   5. Merge AGENTS_ADDITIONS.md into your existing AGENTS.md
   6. Run /fresh-start to orient and load context
   7. Run /phase-prep 1 to check prerequisites
   8. Run /phase-start 1 to begin execution
   ```

## Important

- This command should be run from the ai_coding_project_base toolkit directory
- Use `cp -r` for directory copies to preserve structure
- Do not overwrite existing files without asking
