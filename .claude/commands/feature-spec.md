---
description: Generate FEATURE_SPEC.md through guided Q&A
argument-hint: [target-directory]
allowed-tools: Read, Write, AskUserQuestion
---

Generate a feature specification document for the project at `$1`.

## Prerequisites

- This command must be run from the ai_coding_project_base toolkit directory
- If `$1` is empty, ask the user for the target directory path

## Directory Guard (Wrong Directory Check)

Before starting, confirm you're in the toolkit directory by reading `FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md` from the current working directory.

- If `FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md` is not present, **STOP** and tell the user:
  - They're likely in their target project directory (or another repo)
  - They should `cd` into the `ai_coding_project_base` toolkit repo and re-run `/feature-spec $1`

## Existing File Guard (Prevent Overwrite)

Before asking any questions, check whether `$1/FEATURE_SPEC.md` already exists.

- If it does not exist: continue normally.
- If it exists: **STOP** and ask the user what to do:
  1. **Backup then overwrite (recommended)**: read the existing file and write it to `$1/FEATURE_SPEC.md.bak.YYYYMMDD-HHMMSS`, then write the new document to `$1/FEATURE_SPEC.md`
  2. **Overwrite**: replace `$1/FEATURE_SPEC.md` with the new document
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
   - Ask if they want to continue anyway (may indicate `/setup` was not run for Feature type)

## Process

Read FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md from this toolkit directory and follow its instructions exactly:

1. Ask the user to describe the feature they want to add
2. Work through each question category (Problem, Users, Behavior, Integration, Scope)
3. Make recommendations with confidence levels
4. Generate the final FEATURE_SPEC.md document

## Output

Write the completed specification to `$1/FEATURE_SPEC.md`.

## Deferred Requirements Extraction

After writing FEATURE_SPEC.md, scan it for deferred requirements and extract them to `PROJECT_ROOT/DEFERRED.md` (not the feature directory).

### Patterns to Detect

Search the document for these patterns (case-insensitive):
- "out of scope"
- "v2" / "version 2" / "future version"
- "deferred"
- "not in this feature" / "separate feature"
- "later" / "in the future"
- "follow-up" / "future enhancement"
- "nice to have" (when explicitly deferred)

### Extraction Format

For each match found, extract:
1. **Requirement** — The feature item being deferred
2. **Reason** — Why it was deferred
3. **Section** — Which section of the spec it appeared in
4. **Feature** — The feature name (from FEATURE_NAME)

### DEFERRED.md Update

Append to `PROJECT_ROOT/DEFERRED.md`:

```markdown

## From FEATURE_SPEC.md: {FEATURE_NAME} ({date})

| Requirement | Reason Deferred | Original Section |
|-------------|-----------------|------------------|
| {extracted requirement} | {reason phrase} | {section name} |
```

If PROJECT_ROOT/DEFERRED.md doesn't exist, create it with header first.

### Reporting

After extraction, report:
```
Deferred Requirements: {count} items extracted to PROJECT_ROOT/DEFERRED.md
```

## Next Step

When complete, inform the user:
```
FEATURE_SPEC.md created at $1/FEATURE_SPEC.md
Deferred Requirements: {count} items extracted to PROJECT_ROOT/DEFERRED.md

Next: Run /feature-technical-spec $1
```
