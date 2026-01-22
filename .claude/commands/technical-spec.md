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

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `TECHNICAL_SPEC_PROMPT.md` from the current working directory.

- If `TECHNICAL_SPEC_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/technical-spec $1`

## Existing File Guard (Prevent Overwrite)

Before asking any questions, check whether `$1/TECHNICAL_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Backup then overwrite (recommended)**: read the existing file and write it to `$1/TECHNICAL_SPEC.md.bak.YYYYMMDD-HHMMSS`, then write the new document to `$1/TECHNICAL_SPEC.md`
  2. **Overwrite**: replace `$1/TECHNICAL_SPEC.md` with the new document
  3. **Abort**: do not write anything; suggest they rename/move the existing file first

## Process

Read TECHNICAL_SPEC_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Read `$1/PRODUCT_SPEC.md` as input
2. Work through each question category (Architecture, Stack, Data, APIs, Implementation)
3. Make recommendations with confidence levels
4. Generate the final TECHNICAL_SPEC.md document

## Output

Write the completed specification to `$1/TECHNICAL_SPEC.md`.

## Verification (Automatic)

After writing TECHNICAL_SPEC.md, run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from PRODUCT_SPEC.md appear in TECHNICAL_SPEC.md
3. Run quality checks for vague language, missing rationale, undefined contracts
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

## Deferred Requirements Extraction

After verification, scan TECHNICAL_SPEC.md for deferred requirements and extract them to `$1/DEFERRED.md`.

### Patterns to Detect

Search the document for these patterns (case-insensitive):
- "out of scope"
- "v2" / "version 2" / "future version"
- "deferred"
- "not in MVP" / "post-MVP"
- "later" / "in the future"
- "phase 2" / "next phase"
- "premature optimization"
- "over-engineering" / "overkill for MVP"
- "won't implement" / "will not implement"

### Extraction Format

For each match found, extract:
1. **Requirement** — The technical item being deferred
2. **Reason** — Why it was deferred
3. **Section** — Which section of the spec it appeared in

### DEFERRED.md Update

If `$1/DEFERRED.md` already exists (from product-spec), append:

```markdown

## From TECHNICAL_SPEC.md ({date})

| Requirement | Reason Deferred | Original Section |
|-------------|-----------------|------------------|
| {extracted requirement} | {reason phrase} | {section name} |
```

If it doesn't exist, create it with header and this section.

### Reporting

After extraction, report:
```
Deferred Requirements: {count} items extracted to DEFERRED.md
```

## Next Step

When verification is complete, inform the user:
```
TECHNICAL_SPEC.md created and verified at $1/TECHNICAL_SPEC.md

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW
Deferred Requirements: {count} items extracted to DEFERRED.md

Next: Run /generate-plan $1
```
