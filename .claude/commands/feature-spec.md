---
description: Generate FEATURE_SPEC.md through guided Q&A
argument-hint: [target-directory]
allowed-tools: Read, Write, AskUserQuestion
---

Generate a feature specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path

## Process

Follow the instructions in @FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md exactly:

1. Ask the user to describe the feature they want to add
2. Work through each question category (Problem, Users, Behavior, Integration, Scope)
3. Make recommendations with confidence levels
4. Generate the final FEATURE_SPEC.md document

## Output

Write the completed specification to `$1/FEATURE_SPEC.md`.

## Next Step

When complete, inform the user:
```
FEATURE_SPEC.md created at $1/FEATURE_SPEC.md

Next: Run /feature-technical-spec $1
```
