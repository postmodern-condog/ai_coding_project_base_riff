
Verify a specification document for context preservation (nothing important lost from upstream) and quality issues.

## Arguments

`$1` = Document type to verify. One of:
- `technical-spec` - Verify TECHNICAL_SPEC.md against PRODUCT_SPEC.md
- `execution-plan` - Verify EXECUTION_PLAN.md against TECHNICAL_SPEC.md
- `feature-technical` - Verify FEATURE_TECHNICAL_SPEC.md against FEATURE_SPEC.md
- `feature-plan` - Verify feature EXECUTION_PLAN.md against FEATURE_TECHNICAL_SPEC.md
- `product-spec` - Quality check only (no upstream document)
- `feature-spec` - Quality check only (no upstream document)

If `$1` is empty, ask the user which document to verify.

## Prerequisites

- The target document must exist in the current directory
- For context preservation checks, the upstream document must also exist

## Process

Follow the instructions in `.claude/skills/spec-verification/SKILL.md` exactly.

1. **Identify documents** - Based on `$1`, determine target and upstream documents
2. **Context preservation check** - If upstream exists, extract key items and verify presence
3. **Quality check** - Scan for anti-patterns (vague language, missing rationale, etc.)
4. **Present issues** - Show CRITICAL issues inline with resolution options
5. **Collect resolutions** - Use AskUserQuestion for each CRITICAL issue
6. **Apply fixes** - Edit document(s) based on user choices
7. **Re-verify** - Run checks again (max 2 iterations)
8. **Report** - Show final status

## Output

Inline report showing:
- Context preservation results
- Quality check results
- Issues found and resolved
- Final status (PASSED / PASSED WITH NOTES / NEEDS REVIEW)

## Important

- Be **conservative** - only flag obvious, clear problems
- Maximum 5 CRITICAL issues per run (show most severe first)
- CRITICAL issues block; MAJOR issues are noted but don't block
- Upstream document edits require explicit confirmation
