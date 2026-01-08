---
description: Generate TECHNICAL_SPEC.md through guided Q&A
allowed-tools: Read, Write, AskUserQuestion
---

Generate a technical specification document using the guided Q&A process.

## Prerequisites

1. Check that `TECHNICAL_SPEC_PROMPT.md` exists. If not:
   "TECHNICAL_SPEC_PROMPT.md not found. Run /setup from the ai_coding_project_base toolkit first."

2. Check that `PRODUCT_SPEC.md` exists. If not:
   "PRODUCT_SPEC.md not found. Run /product-spec first to define what you're building."

## Process

Follow the instructions in @TECHNICAL_SPEC_PROMPT.md exactly:

1. Read and reference @PRODUCT_SPEC.md as input
2. Work through each question category (Architecture, Stack, Data, APIs, Implementation)
3. Make recommendations with confidence levels
4. Generate the final TECHNICAL_SPEC.md document

## Output

Write the completed specification to `TECHNICAL_SPEC.md` in the current directory.

## Next Step

When complete, inform the user:
"TECHNICAL_SPEC.md created. Run /generate-plan to create EXECUTION_PLAN.md and AGENTS.md."
