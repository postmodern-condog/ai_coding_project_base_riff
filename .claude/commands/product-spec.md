---
description: Generate PRODUCT_SPEC.md through guided Q&A
argument-hint: [target-directory]
allowed-tools: Read, Write, AskUserQuestion
---

Generate a product specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path

## Process

Follow the instructions in @PRODUCT_SPEC_PROMPT.md exactly:

1. Ask the user to describe their idea
2. Work through each question category (Problem, Users, Experience, Features, Data)
3. Make recommendations with confidence levels
4. Generate the final PRODUCT_SPEC.md document

## Output

Write the completed specification to `$1/PRODUCT_SPEC.md`.

## Next Step

When complete, inform the user:
```
PRODUCT_SPEC.md created at $1/PRODUCT_SPEC.md

Next: Run /technical-spec $1
```
