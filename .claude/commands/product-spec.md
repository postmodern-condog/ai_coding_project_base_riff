---
description: Generate PRODUCT_SPEC.md through guided Q&A
allowed-tools: Read, Write, AskUserQuestion
---

Generate a product specification document using the guided Q&A process.

## Prerequisites

Check that `PRODUCT_SPEC_PROMPT.md` exists in the current directory. If not, inform the user:
"PRODUCT_SPEC_PROMPT.md not found. Run /setup from the ai_coding_project_base toolkit first."

## Process

Follow the instructions in @PRODUCT_SPEC_PROMPT.md exactly:

1. Ask the user to describe their idea
2. Work through each question category (Problem, Users, Experience, Features, Data)
3. Make recommendations with confidence levels
4. Generate the final PRODUCT_SPEC.md document

## Output

Write the completed specification to `PRODUCT_SPEC.md` in the current directory.

## Next Step

When complete, inform the user:
"PRODUCT_SPEC.md created. Run /technical-spec to define the technical approach."
