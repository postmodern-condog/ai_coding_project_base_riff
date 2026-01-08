# Feature Technical Specification Prompt

Use this prompt to create a technical specification for a feature in an existing project.

## Required Inputs

Provide these alongside your FEATURE_SPEC.md:
- **FEATURE_SPEC.md** — The feature specification from the previous step
- **AGENTS.md** — Your existing project's workflow guidelines
- **Project context** — One of the following:
  - Project tree output (`tree -L 3` or similar)
  - Key file listing with descriptions
  - Relevant existing code files the feature will interact with

---

## The Prompt

```
You are an expert software architect and technical specification writer. You will receive:
1. A feature specification document (FEATURE_SPEC.md)
2. The existing project's AGENTS.md
3. Project context (structure, key files, or documentation)

Parse all inputs thoroughly before asking clarifying questions. Your role is to help create a comprehensive, developer-ready technical specification that integrates cleanly with the existing codebase.

If the feature spec contains ambiguities or contradictions, flag them explicitly and propose a resolution before proceeding.

Before you begin asking questions, plan your questions out to meet the following guidelines:
* Review the existing project context to understand current patterns, tech stack, and architecture.
* If you can infer the answer from the feature spec or project context, no need to ask a question about it.
* Each set of questions builds on the questions before it.
* If you can ask multiple questions at once, do so, and prompt the user to answer all of the questions at once. To do this, you need to ensure there are no dependencies between questions asked in a single set.
* For each question, provide your recommendation and a brief explanation of why you made this recommendation. Also provide 'recommendation strength' of weak, medium, or strong based on your level of confidence in your recommendation.
* Focus questions on integration concerns: how this feature fits with existing code, what patterns to follow, what might break.

We are building an MVP of this feature - bias your choices towards simplicity, ease of implementation, and speed. Prefer extending existing patterns over introducing new ones. When off-the-shelf or open source solutions exist, consider suggesting them as options.

We will ultimately pass this document on to the next stage of the workflow, which is converting this document into tasks that an AI coding agent will execute on autonomously. This document needs to contain enough detail that the AI coding agent will successfully be able to implement the feature while maintaining consistency with the existing codebase.

Once we have enough to generate a strong technical specification document, tell the user you're ready. Generate `FEATURE_TECHNICAL_SPEC.md` with the following structure:
```

---

## Output Structure

```markdown
# Feature Technical Specification: {Feature Name}

## Existing Tech Stack
{Reference the tech stack from AGENTS.md or project context - do not propose changes unless necessary}

## Integration Analysis

### Files to Modify
| File | Change Type | Description |
|------|-------------|-------------|
| {path} | {extend/modify/refactor} | {what changes and why} |

### Files to Create
| File | Purpose | Pattern Reference |
|------|---------|-------------------|
| {path} | {what it does} | {existing file to use as template} |

### Existing Patterns to Follow
{List existing code patterns this feature should follow for consistency}
- {Pattern 1}: Found in `{file}` — {description}
- {Pattern 2}: Found in `{file}` — {description}

## Data Model Changes

### New Entities
{For each new entity: schema definition with fields, types, relationships}

#### {Entity Name}
| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| ... | ... | ... | ... |

### Modified Entities
| Entity | Change | Migration Required |
|--------|--------|-------------------|
| {existing entity} | {what changes} | {yes/no} |

## API Changes

### New Endpoints
| Method | Path | Description | Request | Response |
|--------|------|-------------|---------|----------|
| ... | ... | ... | ... | ... |

### Modified Endpoints
| Method | Path | Change | Backwards Compatible |
|--------|------|--------|---------------------|
| ... | ... | ... | {yes/no} |

## State Management
{How this feature's state integrates with existing state management}

## New Dependencies
| Package | Version | Purpose | Alternatives Considered |
|---------|---------|---------|------------------------|
| ... | ... | ... | ... |

## Regression Risk Assessment
{What existing functionality could break and how to mitigate}

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {what could break} | {low/medium/high} | {description} | {how to prevent/detect} |

## Migration Strategy
{If data model changes require migration}
- Migration approach: {description}
- Rollback plan: {how to undo if needed}
- Data preservation: {how existing data is handled}

## Edge Cases & Boundary Conditions
{Feature-specific edge cases and how they should be handled}

## Implementation Sequence
{Ordered list of what to build first, considering dependencies on existing code}

1. {First thing to build} — {why first, what it depends on}
2. {Second thing} — {why second}
...
```
