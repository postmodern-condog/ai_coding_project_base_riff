# Start Prompts

Copy-paste prompts for executing phases from your EXECUTION_PLAN.md.

---

## Greenfield Projects

Use these prompts when working with documents generated from the greenfield workflow (PRODUCT_SPEC.md, TECHNICAL_SPEC.md, EXECUTION_PLAN.md, AGENTS.md).

### Fresh Start

Use this when beginning work on a new project or onboarding to an existing execution plan.

```
Read the following files to understand the structure and purpose of this project:
- AGENTS.md (workflow guidelines)
- PRODUCT_SPEC.md (what we're building and why)
- TECHNICAL_SPEC.md (how it's built technically)
- EXECUTION_PLAN.md (tasks and acceptance criteria)

Summarize your understanding and confirm you're ready to begin execution.
```

### Phase Prep

Use this before starting a new phase to verify prerequisites are met.

```
I want to execute Phase {N} from EXECUTION_PLAN.md. Before starting:

1. Check the Pre-Phase Setup section — are there unmet prerequisites I need to complete?
2. Verify dependencies — are all prior phases complete?
3. Review permissions — are there any permissions needed in configuration files for autonomous execution?

Report what's ready and what's blocking.
```

### Phase Start

Use this to execute all tasks in a phase autonomously.

```
I have completed all prerequisites for Phase {N}. Execute all steps and tasks in Phase {N} from EXECUTION_PLAN.md, one at a time.

Guidelines:
- Read AGENTS.md thoroughly for workflow conventions (git branches, TDD, etc.)
- Use the code-verification skill for every task
- Do not check back until the phase is complete, unless blocked
- Report blockers using the format in AGENTS.md

Begin with Step {N}.1.
```

### Phase Checkpoint

Use this after completing a phase to verify before proceeding.

```
Phase {N} is complete. Run the checkpoint criteria from EXECUTION_PLAN.md:

1. Automated checks — run tests, type checking, linting
2. Manual verification — list items for me to verify
3. Summarize what was built in this phase

Report results and confirm ready to proceed to Phase {N+1}.
```

---

## Feature Development

Use these prompts when working with documents generated from the feature workflow (FEATURE_SPEC.md, FEATURE_TECHNICAL_SPEC.md, EXECUTION_PLAN.md, AGENTS_ADDITIONS.md).

### Fresh Start

Use this when beginning work on a new feature.

```
Read the following files to understand this feature and how it integrates:
- AGENTS.md (workflow guidelines)
- FEATURE_SPEC.md (what the feature does and why)
- FEATURE_TECHNICAL_SPEC.md (how it integrates technically)
- EXECUTION_PLAN.md (tasks and acceptance criteria)

Summarize your understanding of the feature and its integration points. Confirm you're ready to begin execution.
```

### Phase Prep

Use this before starting a new phase to verify prerequisites are met.

```
I want to execute Phase {N} from EXECUTION_PLAN.md for this feature. Before starting:

1. Check the Pre-Phase Setup section — are there unmet prerequisites I need to complete?
2. Verify dependencies — are all prior phases complete?
3. Review integration points — are the existing components we're modifying in the expected state?
4. Check for any permissions needed in configuration files for autonomous execution

Report what's ready and what's blocking.
```

### Phase Start

Use this to execute all tasks in a phase autonomously.

```
I have completed all prerequisites for Phase {N}. Execute all steps and tasks in Phase {N} from EXECUTION_PLAN.md, one at a time.

Guidelines:
- Read AGENTS.md thoroughly for workflow conventions (git branches, TDD, etc.)
- Use the code-verification skill for every task
- Pay attention to "Existing Code to Reference" in each task for patterns to follow
- Run existing tests after modifications to catch regressions
- Do not check back until the phase is complete, unless blocked
- Report blockers using the format in AGENTS.md

Begin with Step {N}.1.
```

### Phase Checkpoint

Use this after completing a phase to verify before proceeding.

```
Phase {N} is complete. Run the checkpoint criteria from EXECUTION_PLAN.md:

1. Automated checks — run tests (including existing tests), type checking, linting
2. Regression verification — confirm existing functionality still works
3. Manual verification — list items for me to verify
4. Browser verification (if applicable) — verify UI acceptance criteria

Report results and confirm ready to proceed to Phase {N+1}.
```

---

## Recovery Prompts

Use these when execution is interrupted or blocked.

### Resume After Blocker

Use this when a blocker has been resolved and you want to continue.

```
The blocker for Task {X.Y.Z} has been resolved.

Resolution: {describe what was fixed or provided}

Continue execution from Task {X.Y.Z}. Pick up where you left off.
```

### Handle Scope Discovery

Use this when new work is discovered that's outside the current task scope.

```
While working on Task {X.Y.Z}, I discovered: {description of issue or opportunity}

Add this to TODOS.md with appropriate context and priority, then continue with the current task scope. Do not expand scope without approval.
```

### Retry Failed Task

Use this when a task failed and you want to retry with fresh context.

```
Task {X.Y.Z} failed previously. Error context: {brief description of what went wrong}

Start fresh on Task {X.Y.Z}:
1. Re-read the task definition and acceptance criteria
2. Review what was attempted before
3. Take a different approach to avoid the previous failure

Do not repeat the same failing approach.
```

### Skip to Specific Task

Use this to jump to a specific task (e.g., after manual fixes).

```
Skip to Task {X.Y.Z} in EXECUTION_PLAN.md.

Context: {why we're skipping, what was done manually}

Begin execution from this task. Verify any dependencies are met before starting.
```

---

## Tips

- **Always run Phase Prep before Phase Start** — Catching missing prerequisites early saves time
- **Use checkpoints religiously** — They catch issues before they compound
- **Fresh context per task** — Each task should start with fresh context as specified in AGENTS.md
- **Track discoveries in TODOS.md** — Don't let scope creep derail execution
