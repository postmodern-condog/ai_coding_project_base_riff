---
description: Generate EXECUTION_PLAN.md and AGENTS.md
argument-hint: [target-directory]
allowed-tools: Read, Write, Edit, AskUserQuestion, Grep, Glob
---

Generate the execution plan and agent guidelines for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/PRODUCT_SPEC.md` exists. If not:
  "PRODUCT_SPEC.md not found at $1. Run /product-spec $1 first."
- Check that `$1/TECHNICAL_SPEC.md` exists. If not:
  "TECHNICAL_SPEC.md not found at $1. Run /technical-spec $1 first."

## Process

Follow the instructions in @GENERATOR_PROMPT.md exactly:

1. Read `$1/PRODUCT_SPEC.md` and `$1/TECHNICAL_SPEC.md` as inputs
2. Generate EXECUTION_PLAN.md with phases, steps, and tasks
3. Generate AGENTS.md with workflow guidelines

## Output

Write both documents to the target directory:
- `$1/EXECUTION_PLAN.md`
- `$1/AGENTS.md`

## Verification (Automatic)

After writing EXECUTION_PLAN.md and AGENTS.md:

### 1. AGENTS.md Size Check

Count the lines in the generated AGENTS.md:
```bash
wc -l $1/AGENTS.md
```

**Thresholds:**
- **≤150 lines**: PASS — Optimal for LLM instruction-following
- **151-200 lines**: WARN — "AGENTS.md is {N} lines. Research shows LLMs follow ~150 instructions consistently. Consider splitting project-specific rules into subdirectory CLAUDE.md files."
- **>200 lines**: FAIL — "AGENTS.md exceeds 200 lines ({N} lines). This will degrade agent performance. Split into:
  - AGENTS.md (core workflow, ≤100 lines)
  - `.claude/CLAUDE.md` files in subdirectories for context-specific rules"

If WARN or FAIL, offer to help split the file before proceeding.

### 2. Spec Verification

Run the spec-verification skill:

1. Follow `.claude/skills/spec-verification/SKILL.md`
2. Verify context preservation: Check that all key items from TECHNICAL_SPEC.md and PRODUCT_SPEC.md appear as tasks or acceptance criteria
3. Run quality checks for untestable criteria, missing dependencies, vague language
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

## Next Step

When verification is complete, inform the user:
```
EXECUTION_PLAN.md and AGENTS.md created and verified at $1

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW

Your project is ready for execution:
1. cd $1
2. /fresh-start
3. /phase-prep 1
4. /phase-start 1
```
