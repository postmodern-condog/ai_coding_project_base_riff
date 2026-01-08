---
description: Generate FEATURE_SPEC.md through guided Q&A
allowed-tools: Read, Write, AskUserQuestion
---

Generate a feature specification document using the guided Q&A process.

## Prerequisites

Check that `FEATURE_SPEC_PROMPT.md` exists in the current directory. If not:
"FEATURE_SPEC_PROMPT.md not found. Run /setup from the ai_coding_project_base toolkit first."

## Process

Follow the instructions in @FEATURE_SPEC_PROMPT.md exactly:

1. Ask the user to describe the feature they want to add
2. Work through each question category (Problem, Users, Behavior, Integration, Scope)
3. Make recommendations with confidence levels
4. Generate the final FEATURE_SPEC.md document

## Output

Write the completed specification to `FEATURE_SPEC.md` in the current directory.

## Next Step

When complete, inform the user:
"FEATURE_SPEC.md created. Run /feature-technical-spec to define the integration approach."
