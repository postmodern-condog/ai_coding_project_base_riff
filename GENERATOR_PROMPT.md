# Execution Toolkit Generator

Generate an execution toolkit from a technical specification. This prompt produces two documents with distinct purposes:

- **EXECUTION_PLAN.md** — What to build (tasks, acceptance criteria, dependencies)
- **AGENTS.md** — How to work (workflow rules, guardrails, verification protocol)

---

## The Prompt

```
I need you to generate an execution toolkit from the attached technical specification.

Generate two documents:
1. EXECUTION_PLAN.md — Task breakdown with acceptance criteria
2. AGENTS.md — Workflow guidelines for AI agents

══════════════════════════════════════════════════════════════════════════════
PART 1: CORE CONCEPTS
══════════════════════════════════════════════════════════════════════════════

EXECUTION HIERARCHY

┌─────────┬────────────────────────────────────────────────────────────────┐
│ Level   │ Definition                                                     │
├─────────┼────────────────────────────────────────────────────────────────┤
│ PHASE   │ Major milestone ending with human checkpoint                   │
│         │ - Represents demonstrable functionality                        │
│         │ - Requires manual testing and approval before proceeding       │
│         │ - Includes pre-phase setup (env vars, external services)       │
├─────────┼────────────────────────────────────────────────────────────────┤
│ STEP    │ Ordered group of related tasks                                 │
│         │ - All tasks in a step complete before next step begins         │
│         │ - Tasks within a step may run in parallel                      │
├─────────┼────────────────────────────────────────────────────────────────┤
│ TASK    │ Atomic unit of work for a single agent session                 │
│         │ - Has specific, testable acceptance criteria                   │
│         │ - Creates or modifies a focused set of files                   │
│         │ - Independent from parallel tasks in same step                 │
└─────────┴────────────────────────────────────────────────────────────────┘

DOCUMENT RESPONSIBILITIES

EXECUTION_PLAN.md owns:
- Task definitions and acceptance criteria
- File create/modify lists
- Dependencies between tasks
- Spec references
- Pre-phase setup requirements
- Phase checkpoint criteria

AGENTS.md owns:
- Workflow mechanics (how agents pick up and complete tasks)
- TDD policy and testing requirements
- Context management between tasks
- Guardrails and "when to stop" triggers
- Verification protocol
- Git conventions
- Minimal project context (tech stack, dev server only)

AGENTS.md does NOT include:
- Error handling patterns (agents discover from codebase)
- Mocking strategies (agents infer from test framework)
- Naming conventions (agents follow existing code)
- Detailed file structures (agents explore the repo)

══════════════════════════════════════════════════════════════════════════════
PART 2: EXECUTION_PLAN.md FORMAT
══════════════════════════════════════════════════════════════════════════════

# Execution Plan: {Project Name}

## Overview

| Metric | Value |
|--------|-------|
| Phases | {N} |
| Steps  | {N} |
| Tasks  | {N} |

## Phase Flow

```
Phase 1: {Name}
    ↓
Phase 2: {Name}
    ↓
...
```

---

## Phase 1: {Phase Name}

**Goal:** {What this phase accomplishes}

### Pre-Phase Setup

Human must complete before agents begin:

- [ ] {Environment variable or secret}
- [ ] {External service setup}
- [ ] {Other prerequisite}

---

### Step 1.1: {Step Name}

#### Task 1.1.A: {Task Name}

**What:** {1-2 sentence description}

**Acceptance Criteria:**
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}
- [ ] {Specific, testable criterion}

**Files:**
- Create: `{path}` — {purpose}
- Modify: `{path}` — {what change}

**Depends On:** {Prior task IDs, or "None"}

**Spec Reference:** {Section name from technical spec}

---

#### Task 1.1.B: {Task Name}
{Same structure}

---

### Step 1.2: {Step Name}
{Continue pattern}

---

### Phase 1 Checkpoint

**Automated:**
- [ ] All tests pass
- [ ] Type checking passes
- [ ] Linting passes

**Manual Verification:**
- [ ] {What human should verify}
- [ ] {Another manual check}

---

## Phase 2: {Phase Name}
{Continue pattern}

══════════════════════════════════════════════════════════════════════════════
PART 3: AGENTS.md FORMAT
══════════════════════════════════════════════════════════════════════════════

# AGENTS.md

Workflow guidelines for AI agents executing tasks from EXECUTION_PLAN.md.

---

## Project Context

**Tech Stack:** {language, runtime, framework, test runner, package manager}

**Dev Server:** `{command}` → `{url}` (wait {N}s for startup)

---

## Workflow

```
HUMAN (Orchestrator)
├── Completes pre-phase setup
├── Assigns tasks from EXECUTION_PLAN.md
├── Reviews and approves at phase checkpoints

AGENT (Executor)
├── Executes one task at a time
├── Works in git branch
├── Follows TDD: tests first, then implementation
├── Runs verification against acceptance criteria
└── Reports completion or blockers
```

---

## Task Execution

1. **Load context** — Read AGENTS.md, your spec documents, and your task from EXECUTION_PLAN.md
2. **Check CLAUDE.md** — Read project root CLAUDE.md if it exists
3. **Create branch** — If first task in step, create branch: `git checkout -b step-{phase}.{step}`
4. **Verify dependencies** — Confirm prior tasks are complete
5. **Write tests first** — One test per acceptance criterion
6. **Implement** — Minimum code to pass tests
7. **Verify** — Use code-verification skill (see Verification section below)
8. **Update progress** — Check off completed criteria in EXECUTION_PLAN.md (see checkbox format below)
9. **Commit** — Format: `task(1.1.A): brief description`

### Checkbox Format

When updating EXECUTION_PLAN.md, change unchecked boxes to checked:

```markdown
# Before
- [ ] User can log in with email and password

# After
- [x] User can log in with email and password
```

---

## Context Management

**Start fresh for each task.** Do not carry conversation history between tasks.

Before starting any task, load:
1. AGENTS.md (this file)
2. Specification documents:
   - Greenfield projects: PRODUCT_SPEC.md and TECHNICAL_SPEC.md
   - Feature work: FEATURE_SPEC.md and FEATURE_TECHNICAL_SPEC.md
3. Your task definition from EXECUTION_PLAN.md

**Preserve context while debugging.** If tests fail within a task, continue in the same conversation until resolved.

```
Task N starts (fresh)
    → Write tests
    → Implement
    → Tests fail → Debug (keep context) → Fix
    → Tests pass
    → Verify (code-verification skill or manual checklist)
    → Update checkboxes in EXECUTION_PLAN.md
    → Task complete
Task N+1 starts (fresh)
```

### Context Hygiene

Context pollution degrades response quality. Follow these rules:

1. **Use `/compact` between phases** — After completing a step, run `/compact` to summarize and free context
2. **Never exceed 60% context capacity** — If responses become repetitive or confused, context is polluted
3. **Separate concerns by phase:**
   - Research (read-only exploration)
   - Plan (design approach)
   - Implement (write code)
   - Validate (verify acceptance criteria)
4. **When in doubt, start fresh** — A clean context with reloaded documents beats a polluted one

---

## Testing Policy

- Tests must exist for every acceptance criterion
- All tests must pass before reporting complete
- Never skip or disable tests to make them pass
- Never claim "working" when functionality is broken
- Read full error output before attempting fixes

---

## Verification

After implementing each task, verify all acceptance criteria are met.

### Primary: Code Verification Skill (Claude Code)

If using Claude Code with the code-verification skill available:

```
Use /code-verification to verify this task against its acceptance criteria
```

The skill will:
- Parse each acceptance criterion
- Spawn sub-agents to verify each one
- Attempt fixes (up to 5 times) for failures
- Generate a verification report

### Fallback: Manual Verification Checklist

If the code-verification skill is not available, manually verify:

1. **Run tests** — `npm test` (or equivalent)
2. **Type check** — `npm run typecheck` (or equivalent)
3. **Lint** — `npm run lint` (or equivalent)
4. **Manual check** — For each acceptance criterion:
   - Read the criterion
   - Verify it is met (inspect code, run app, check output)
   - If not met, fix and re-verify
5. **Document** — Note verification status in completion report

---

## When to Stop and Ask

Stop and ask the human if:
- A dependency is missing (file, function, service doesn't exist)
- You need environment variables or secrets
- Acceptance criteria are ambiguous
- A test fails and you cannot determine why after reading full error output
- You need to modify files outside your task scope

**Blocker format:**
```
BLOCKED: Task {id}
Issue: {what's wrong}
Tried: {what you attempted}
Need: {what would unblock}
```

---

## Completion Report

When done:
- What was built (1-2 sentences)
- Files created/modified
- Test status
- Commit hash

---

## Git Conventions

### Branch Strategy

Create one branch per **step** (not per task):

```
git checkout -b step-{phase}.{step}
# Example: git checkout -b step-1.2
```

**Branch lifecycle:**
1. Create branch from main/develop before starting first task in step
2. Commit after each task completion
3. Push branch when step is complete
4. Create PR for review at phase checkpoints
5. Merge after checkpoint approval

### Commit Format

```
task({id}): {description}
# Example: task(1.2.A): Add user authentication endpoint
```

### Branch Naming

| Item | Format | Example |
|------|--------|---------|
| Step branch | `step-{phase}.{step}` | `step-1.2` |
| Commit | `task({id}): {description}` | `task(1.2.A): Add login form` |

---

## Guardrails

- Make the smallest change that satisfies acceptance criteria
- Do not duplicate files to work around issues — fix the original
- Do not guess — if you can't access something, say so
- Do not introduce new APIs without flagging for spec updates
- Read error output fully before attempting fixes

---

## Follow-Up Items (TODOS.md)

During development, you will discover items that need attention but are outside the current task scope: refactoring opportunities, edge cases to handle later, documentation needs, technical debt, etc.

**When you identify a follow-up item:**

1. **Prompt the human to start TODOS.md** if it doesn't exist:
   ```
   I've identified a follow-up item: {description}

   Should I create TODOS.md to track this and future items?
   ```

2. **Add items to TODOS.md** with context:
   ```markdown
   ## TODO: {Brief title}
   - **Source:** Task {id} or {file:line}
   - **Description:** {What needs to be done}
   - **Priority:** {Suggested: High/Medium/Low}
   - **Added:** {Date}
   ```

3. **Prompt for prioritization** when the list grows or at phase checkpoints:
   ```
   TODOS.md now has {N} items. Would you like to:
   - Review and prioritize them?
   - Add any to the current phase?
   - Defer to a future phase?
   ```

**Do not** silently ignore discovered issues. **Do not** scope-creep by fixing them without approval. Track them in TODOS.md and let the human decide when to address them.

══════════════════════════════════════════════════════════════════════════════
PART 4: GENERATION INSTRUCTIONS
══════════════════════════════════════════════════════════════════════════════

Before generating:

1. **Identify phases** — Major functional areas from the spec become phases
2. **Map dependencies** — What must exist before each component can be built
3. **Group into steps** — Related tasks that should complete together
4. **Break into tasks** — Atomic units with 3-6 testable acceptance criteria each
5. **Identify setup** — External services, env vars, manual prerequisites per phase
6. **Define checkpoints** — What demonstrates each phase is complete

Task quality checks:
✓ 3-6 specific, testable acceptance criteria
✓ Concrete files to create/modify (not vague)
✓ Dependencies explicitly listed
✓ References spec section
✓ Independent from parallel tasks in same step

Red flags to fix:
✗ Vague criteria like "works correctly"
✗ Too many files (>7) in one task
✗ Dependencies on parallel tasks
✗ Missing spec reference

══════════════════════════════════════════════════════════════════════════════
SPECIFICATION
══════════════════════════════════════════════════════════════════════════════

{Paste or attach TECHNICAL_SPEC.md here}

══════════════════════════════════════════════════════════════════════════════

Generate:
1. EXECUTION_PLAN.md
2. AGENTS.md
```


---

## Post-Generation Checklist

**EXECUTION_PLAN.md**
- [ ] All phases have pre-phase setup sections
- [ ] All tasks have 3-6 testable acceptance criteria
- [ ] All tasks specify files to create/modify
- [ ] All tasks have dependencies listed
- [ ] All phases have checkpoint criteria
- [ ] No task depends on a parallel task in the same step

**AGENTS.md**
- [ ] Project context filled in (tech stack, dev server)
- [ ] Workflow section present
- [ ] Context management section present
- [ ] Testing policy present
- [ ] "When to stop" triggers present
- [ ] Git conventions present
- [ ] Guardrails present
