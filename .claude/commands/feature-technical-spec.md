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
- Check that `PROJECT_ROOT/AGENTS.md` exists (indicates an existing project). If not, warn:
  "AGENTS.md not found at PROJECT_ROOT. Feature development assumes an existing project. Did you mean to run /product-spec for a new project?"
  (See Project Root Detection section below for how PROJECT_ROOT is derived)

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md` from the current working directory.

- If `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/feature-technical-spec $1`

## Existing File Guard (Prevent Overwrite)

Before asking any questions, check whether `$1/FEATURE_TECHNICAL_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Backup then overwrite (recommended)**: read the existing file and write it to `$1/FEATURE_TECHNICAL_SPEC.md.bak.YYYYMMDD-HHMMSS`, then write the new document to `$1/FEATURE_TECHNICAL_SPEC.md`
  2. **Overwrite**: replace `$1/FEATURE_TECHNICAL_SPEC.md` with the new document
  3. **Abort**: do not write anything; suggest they rename/move the existing file first

## Project Root Detection

Derive project root from the target directory:

1. If `$1` matches pattern `*/features/*` (contains `/features/` followed by a feature name):
   - PROJECT_ROOT = parent of parent of $1 (e.g., `/project/features/foo` → `/project`)
   - FEATURE_NAME = basename of $1

2. Validate PROJECT_ROOT:
   - Check `PROJECT_ROOT/AGENTS.md` exists
   - If missing: "Could not find AGENTS.md at PROJECT_ROOT. Is this a valid project with the features/ structure?"

3. If `$1` does NOT match the `*/features/*` pattern:
   - Warn: "`$1` doesn't appear to be a feature directory (expected path like `/project/features/feature-name`)"
   - Ask if they want to continue anyway

4. Use PROJECT_ROOT for:
   - Reading AGENTS.md
   - Codebase analysis and pattern detection (steps 2-3 below)
   - Existing code searches

5. Use $1 (feature directory) for:
   - Reading FEATURE_SPEC.md
   - Writing FEATURE_TECHNICAL_SPEC.md

## Process

Read FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Read `$1/FEATURE_SPEC.md` as input

2. **Perform Existing Code Analysis** (REQUIRED before any design):

   **Note:** All code analysis should be performed on PROJECT_ROOT, not the feature directory.

   a. **Similar Functionality Audit**
      - Search PROJECT_ROOT for existing code that does something similar to what the feature needs
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

## Deferred Requirements Extraction

After verification, scan FEATURE_TECHNICAL_SPEC.md for deferred requirements and extract them to `PROJECT_ROOT/DEFERRED.md`.

### Patterns to Detect

Search the document for these patterns (case-insensitive):
- "out of scope"
- "v2" / "version 2" / "future version"
- "deferred"
- "not in this feature" / "separate feature"
- "later" / "in the future"
- "premature optimization"
- "technical debt" (when explicitly deferred)
- "follow-up" / "future enhancement"

### Extraction Format

For each match found, extract:
1. **Requirement** — The technical item being deferred
2. **Reason** — Why it was deferred
3. **Section** — Which section of the spec it appeared in
4. **Feature** — The feature name (from FEATURE_NAME)

### DEFERRED.md Update

Append to `PROJECT_ROOT/DEFERRED.md`:

```markdown

## From FEATURE_TECHNICAL_SPEC.md: {FEATURE_NAME} ({date})

| Requirement | Reason Deferred | Original Section |
|-------------|-----------------|------------------|
| {extracted requirement} | {reason phrase} | {section name} |
```

## Next Step

When verification is complete, inform the user:
```
FEATURE_TECHNICAL_SPEC.md created and verified at $1/FEATURE_TECHNICAL_SPEC.md

Verification: PASSED | PASSED WITH NOTES | NEEDS REVIEW
Deferred Requirements: {count} items extracted to PROJECT_ROOT/DEFERRED.md

Next: Run /feature-plan $1
```
