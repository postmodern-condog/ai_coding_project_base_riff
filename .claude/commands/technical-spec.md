---
description: Generate TECHNICAL_SPEC.md through guided Q&A
argument-hint: [target-directory]
allowed-tools: Read, Write, Edit, AskUserQuestion, Grep, Glob
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

## Verification (Automatic)

After writing TECHNICAL_SPEC.md, run the spec-verification skill:

1. Follow `.claude/skills/spec-verification/SKILL.md`
2. Verify context preservation: Check that all key items from PRODUCT_SPEC.md appear in TECHNICAL_SPEC.md
3. Run quality checks for vague language, missing rationale, undefined contracts
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

## Next Step

When verification is complete, inform the user:
```
TECHNICAL_SPEC.md created and verified at $1/TECHNICAL_SPEC.md

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW

Next: Run /generate-plan $1
```
