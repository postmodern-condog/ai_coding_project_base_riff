---
description: Generate FEATURE_TECHNICAL_SPEC.md through guided Q&A
allowed-tools: Read, Write, AskUserQuestion, Glob, Grep
---

Generate a feature technical specification document using the guided Q&A process.

## Prerequisites

1. Check that `FEATURE_TECHNICAL_SPEC_PROMPT.md` exists. If not:
   "FEATURE_TECHNICAL_SPEC_PROMPT.md not found. Run /setup from the ai_coding_project_base toolkit first."

2. Check that `FEATURE_SPEC.md` exists. If not:
   "FEATURE_SPEC.md not found. Run /feature-spec first to define the feature."

3. Check that `AGENTS.md` exists (indicates an existing project). If not, warn:
   "AGENTS.md not found. Feature development assumes an existing project. Did you mean to run /product-spec for a new project?"

## Process

Follow the instructions in @FEATURE_TECHNICAL_SPEC_PROMPT.md exactly:

1. Read @FEATURE_SPEC.md as input
2. Explore the existing codebase to understand patterns and architecture
3. Work through integration analysis, regression risks, and migration strategy
4. Generate the final FEATURE_TECHNICAL_SPEC.md document

## Output

Write the completed specification to `FEATURE_TECHNICAL_SPEC.md` in the current directory.

## Next Step

When complete, inform the user:
"FEATURE_TECHNICAL_SPEC.md created. Run /feature-plan to create EXECUTION_PLAN.md and AGENTS_ADDITIONS.md."
