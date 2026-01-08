# Feature Specification Prompt

Use this prompt to develop a feature specification for an existing project.

## Required Inputs

Provide these alongside your feature idea:
- **AGENTS.md** — Your existing project's workflow guidelines
- **Project context** — One of the following:
  - Project tree output (`tree -L 3` or similar)
  - Key file listing with descriptions
  - README.md or project documentation

---

## The Prompt

```
Ask me questions so that we can develop a feature specification document for this idea.

The resulting document should answer at least (but not limited to) this set of questions:

**Core Feature Definition**
* What problem does the feature solve?
* Who benefits from this feature?
* Describe the core user experience, step-by-step.
* What data will the feature need to persist?

**Integration with Existing Project**
* How does this feature integrate with existing functionality?
* Which existing components will this feature modify or extend?
* Are there backwards compatibility concerns?
* Could this feature break existing user workflows?

**Scope Boundaries**
* What is explicitly OUT of scope for this feature?
* Are there related features that should be deferred to later?

Before you begin asking questions, plan your questions out to meet the following guidelines:
* Review the provided project context to understand existing patterns and architecture.
* If you can infer the answer from the feature idea or project context, no need to ask a question about it.
* Each set of questions builds on the questions before it.
* If you can ask multiple questions at once, do so, and prompt the user to answer all of the questions at once. To do this, you need to ensure there are no dependencies between questions asked in a single set.
* For each question, provide your recommendation and a brief explanation of why you made this recommendation. Also provide 'recommendation strength' of weak, medium, or strong based on your level of confidence in your recommendation.

We are building an MVP of this feature - bias your choices towards simplicity, ease of implementation, and speed. When off-the-shelf or open source solutions exist, consider suggesting them as options.

If the user wants to add capabilities beyond the feature scope during our discussion, acknowledge the idea and note it as a "future enhancement" rather than expanding scope. Keep the feature focused.

We will ultimately pass this document on to the next stage of the workflow, a technical specification designed by a software engineer. This document needs to contain sufficient product context that the engineer can make reasonable technical decisions without product clarification.

Once we have enough to generate a strong feature specification, tell the user that you can generate it when they're ready. Generate `FEATURE_SPEC.md` with the following structure:
```

---

## Output Structure

```markdown
# Feature Specification: {Feature Name}

## Problem Statement
{What problem does this feature solve and why does it matter}

## Target Users
{Who benefits from this feature}

## Core User Experience
{Step-by-step user journey through the feature's main flow}

## Feature Requirements
{Bulleted list of must-have capabilities for this feature}

## Data Requirements
{What new data needs to be stored/persisted}

## Integration Points
{How this feature connects with existing functionality}

| Existing Component | Integration Type | Notes |
|--------------------|------------------|-------|
| {component} | {uses/extends/modifies} | {details} |

## Backwards Compatibility
{Any concerns about breaking existing functionality}

## Out of Scope
{What is explicitly NOT part of this feature}

## Future Enhancements
{Ideas discussed but deferred from this feature's scope}
```
