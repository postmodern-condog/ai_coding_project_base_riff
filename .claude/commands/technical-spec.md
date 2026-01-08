---
description: Generate TECHNICAL_SPEC.md through guided Q&A
argument-hint: [target-directory]
allowed-tools: Read, Write, AskUserQuestion
---

Generate a technical specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/PRODUCT_SPEC.md` exists. If not:
  "PRODUCT_SPEC.md not found at $1. Run /product-spec $1 first."

## Process

Follow the instructions in @TECHNICAL_SPEC_PROMPT.md exactly:

1. Read `$1/PRODUCT_SPEC.md` as input
2. Work through each question category (Architecture, Stack, Data, APIs, Implementation)
3. Make recommendations with confidence levels
4. Generate the final TECHNICAL_SPEC.md document

## Output

Write the completed specification to `$1/TECHNICAL_SPEC.md`.

## Next Step

When complete, inform the user:
```
TECHNICAL_SPEC.md created at $1/TECHNICAL_SPEC.md

Next: Run /generate-plan $1
```
