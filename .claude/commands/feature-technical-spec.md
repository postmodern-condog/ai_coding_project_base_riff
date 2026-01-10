---
description: Generate FEATURE_TECHNICAL_SPEC.md through guided Q&A
argument-hint: [target-directory]
allowed-tools: Read, Write, Edit, AskUserQuestion, Glob, Grep
---

Generate a feature technical specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path
- Check that `$1/FEATURE_SPEC.md` exists. If not:
  "FEATURE_SPEC.md not found at $1. Run /feature-spec $1 first."
- Check that `$1/AGENTS.md` exists (indicates an existing project). If not, warn:
  "AGENTS.md not found at $1. Feature development assumes an existing project. Did you mean to run /product-spec for a new project?"

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md` from the current working directory.

- If `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/feature-technical-spec $1`

## Process

Read FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Read `$1/FEATURE_SPEC.md` as input

2. **Perform Existing Code Analysis** (REQUIRED before any design):

   a. **Similar Functionality Audit**
      - Search for existing code that does something similar to what the feature needs
      - List any utilities, helpers, or patterns that could be reused
      - Flag if creating new code when existing code could be extended
      - Output:
        ```
        SIMILAR FUNCTIONALITY FOUND
        ---------------------------
        - {file}: {description of similar functionality}
        - {file}: {reusable utility/helper}

        Recommendation: {extend existing | create new | hybrid approach}
        ```

   b. **Pattern Compliance Check**
      - Identify how similar features are implemented in the codebase
      - Note naming conventions, file organization, error handling patterns
      - Document the "house style" for this type of feature
      - Output:
        ```
        EXISTING PATTERNS
        -----------------
        File organization: {pattern}
        Naming convention: {pattern}
        Error handling: {pattern}
        Testing approach: {pattern}
        ```

   c. **Integration Point Mapping**
      - List every existing file/module the feature will touch
      - For each, assess: complexity, test coverage, documentation quality
      - Flag high-risk integration points
      - Output:
        ```
        INTEGRATION POINTS
        ------------------
        | File | Risk | Coverage | Notes |
        |------|------|----------|-------|
        | {file} | High/Med/Low | X% | {concerns} |
        ```

3. **Assess codebase maturity** — Is this a legacy/brownfield codebase?
   - Look for: outdated dependencies, missing tests, undocumented code, deprecated patterns
   - If legacy indicators found, explicitly address technical debt, undocumented behavior, and human decision points

4. Work through integration analysis, regression risks, and migration strategy

5. Generate the final FEATURE_TECHNICAL_SPEC.md document, incorporating findings from step 2

## Output

Write the completed specification to `$1/FEATURE_TECHNICAL_SPEC.md`.

## Verification (Automatic)

After writing FEATURE_TECHNICAL_SPEC.md, run the spec-verification workflow:

1. Read `.claude/skills/spec-verification/SKILL.md` for the verification process
2. Verify context preservation: Check that all key items from FEATURE_SPEC.md appear in FEATURE_TECHNICAL_SPEC.md
3. Run quality checks for vague language, missing rationale, undefined contracts, integration gaps
4. Present any CRITICAL issues to the user with resolution options
5. Apply fixes based on user choices
6. Re-verify until clean or max iterations reached

**IMPORTANT**: Do not proceed to "Next Step" until verification passes or user explicitly chooses to proceed with noted issues.

## Next Step

When verification is complete, inform the user:
```
FEATURE_TECHNICAL_SPEC.md created and verified at $1/FEATURE_TECHNICAL_SPEC.md

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW

Next: Run /feature-plan $1
```
