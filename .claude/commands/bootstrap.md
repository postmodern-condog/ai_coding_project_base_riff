---
description: Generate execution plan from existing context or description
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# Bootstrap

Quickly generate an execution plan from an existing feature description, spec fragment, or conversation context. Use this when you have a clear idea of what to build and want to skip the full specification workflow.

## When to Use

- You've discussed a feature elsewhere and have a solid description
- You have a simple/well-defined tweak or enhancement
- You want to start executing without full product/technical specs
- You ran `/adopt` from the orchestrator and saved context

## Instructions

### Step 1: Gather Input

Check for existing context first:
```bash
cat .claude/bootstrap-context.md 2>/dev/null
```

**If bootstrap-context.md exists:**
- Read the content
- Show a summary to the user: "I found saved context from your previous session:"
- Ask: "Should I use this context, or would you like to provide something different?"

**If no saved context, or user wants something different:**

Ask the user:
```
What would you like to build? You can:

1. Paste a description (feature spec, requirements, conversation summary)
2. Point me to a file that has the details
3. Describe it now and I'll ask clarifying questions

Which approach?
```

### Step 2: Analyze the Input

Review the provided input and identify:

**What's clear:**
- Core functionality / what it does
- Key requirements or constraints
- Success criteria (if stated)

**What's missing (common gaps):**
- Scope boundaries (what's NOT included)
- Edge cases / error handling approach
- Testing requirements
- Dependencies on existing code
- Acceptance criteria for "done"

### Step 3: Ask Clarifying Questions

If there are important gaps, ask targeted questions. Keep it minimal — only ask what's necessary to create an actionable plan.

Example questions:
- "Should this handle [edge case], or is that out of scope?"
- "Is there existing code this needs to integrate with?"
- "What's the testing expectation — unit tests, integration tests, both?"
- "Any specific error handling requirements?"

**Do NOT ask about:**
- Things that are clearly implied
- Implementation details you can decide
- Nice-to-haves that can be added later

If the input is already comprehensive, acknowledge that and proceed.

### Step 4: Determine Project Type

Check current directory for existing project markers:

```bash
ls PRODUCT_SPEC.md FEATURE_SPEC.md EXECUTION_PLAN.md AGENTS.md 2>/dev/null
```

**If EXECUTION_PLAN.md already exists:**
- Stop and inform user: "This project already has an EXECUTION_PLAN.md. Did you mean to run /fresh-start instead?"
- Offer options: view existing plan, backup and replace, or cancel

**If AGENTS.md exists but no EXECUTION_PLAN.md:**
- This is likely a feature being added to an existing project
- Will create EXECUTION_PLAN.md only

**If neither exists:**
- Fresh project setup
- Will create both EXECUTION_PLAN.md and AGENTS.md

### Step 5: Generate Execution Plan

Create a focused EXECUTION_PLAN.md based on the input. Keep it lean:

**Structure:**
```markdown
# Execution Plan: [Feature/Project Name]

## Overview

[2-3 sentence summary of what this accomplishes]

## Phase 1: [Phase Name]

### Setup
- [ ] [Any prerequisite setup needed]

### Step 1.1: [Logical grouping]

#### Task 1.1.A: [Specific task]

**Acceptance Criteria:**
- [ ] [Testable criterion]
- [ ] [Testable criterion]

#### Task 1.1.B: [Next task]
...

## Phase 2: [If needed]
...

## Out of Scope

- [Things explicitly not included]
```

**Guidelines:**
- Use 1-3 phases for simple features, more for complex ones
- Each task should be completable in one focused session
- Acceptance criteria must be testable/verifiable
- Include an "Out of Scope" section to prevent creep
- Don't over-engineer — this is meant to be lean

### Step 6: Generate AGENTS.md (if needed)

If no AGENTS.md exists, create a minimal one:

```markdown
# Agent Guidelines

## Workflow

- Follow TDD: write tests before implementation
- One commit per task with message format: `task(X.Y.Z): description`
- Run tests after each change
- Ask for clarification rather than assuming

## Code Style

- Match existing patterns in the codebase
- Keep functions small and focused
- Add comments only where logic isn't self-evident

## Testing

- Unit tests for business logic
- Integration tests for API endpoints (if applicable)
- Test edge cases identified in acceptance criteria

## When Stuck

- If blocked for more than 2 attempts, stop and explain the issue
- Don't modify code outside the current task's scope without asking
```

### Step 7: Update CLAUDE.md

If CLAUDE.md exists but doesn't reference AGENTS.md, add the reference:

```bash
grep -q "AGENTS.md" CLAUDE.md
```

If not found, append `@AGENTS.md` to CLAUDE.md.

If CLAUDE.md doesn't exist, create it with just:
```markdown
@AGENTS.md
```

### Step 8: Clean Up and Report

If `.claude/bootstrap-context.md` was used, offer to delete it:
```
The bootstrap context file is no longer needed. Delete it?
1. Yes (recommended)
2. No, keep it for reference
```

Report success:
```
✓ Execution plan created

Files created:
- EXECUTION_PLAN.md — [N] phases, [M] tasks
{if created}
- AGENTS.md — Workflow guidelines for AI agents
{endif}

Next steps:
1. Review the execution plan: cat EXECUTION_PLAN.md
2. Start execution:
   /fresh-start
   /phase-start 1

To track this project in the orchestrator, run /scan there.
```

## Example

**Input:** "Add a dark mode toggle to the settings page. It should persist the preference to localStorage and apply a dark class to the body element."

**Output:** A 1-2 phase plan with tasks for:
1. Add toggle component to settings
2. Implement localStorage persistence
3. Apply dark mode styles
4. Add tests

With clear acceptance criteria like:
- [ ] Toggle appears in settings page
- [ ] Clicking toggle switches between light/dark
- [ ] Preference persists across page reloads
- [ ] Dark mode applies appropriate CSS class to body
