---
description: Generate FEATURE_TECHNICAL_SPEC.md through guided Q&A
argument-hint: [target-directory]
allowed-tools: Read, Write, AskUserQuestion, Glob, Grep
---

Generate a feature technical specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/FEATURE_SPEC.md` exists. If not:
  "FEATURE_SPEC.md not found at $1. Run /feature-spec $1 first."
- Check that `$1/AGENTS.md` exists (indicates an existing project). If not, warn:
  "AGENTS.md not found at $1. Feature development assumes an existing project. Did you mean to run /product-spec for a new project?"

## Process

Follow the instructions in @FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md exactly:

1. Read `$1/FEATURE_SPEC.md` as input
2. Explore the existing codebase at `$1` to understand patterns and architecture
3. Work through integration analysis, regression risks, and migration strategy
4. Generate the final FEATURE_TECHNICAL_SPEC.md document

## Output

Write the completed specification to `$1/FEATURE_TECHNICAL_SPEC.md`.

## Next Step

When complete, inform the user:
```
FEATURE_TECHNICAL_SPEC.md created at $1/FEATURE_TECHNICAL_SPEC.md

Next: Run /feature-plan $1
```
