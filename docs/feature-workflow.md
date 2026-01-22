# Feature Development Workflow

This guide covers adding features to existing projects using the toolkit's feature workflow.

## Overview

Features are isolated in their own directories under `features/<name>/`, enabling multiple concurrent features without document conflicts.

## Quick Start

```bash
# From toolkit directory:
/feature-spec ~/Projects/existing-app/features/analytics
/feature-technical-spec ~/Projects/existing-app/features/analytics
/feature-plan ~/Projects/existing-app/features/analytics   # Also copies execution commands

# From your feature directory:
cd ~/Projects/existing-app/features/analytics
/fresh-start             # Detects feature mode, creates feature/analytics branch
/configure-verification  # Set test/lint/typecheck/build/dev server commands
/phase-prep 1
/phase-start 1
/phase-checkpoint 1
```

## Directory Structure

Each feature gets its own directory with isolated planning documents:

```
your-project/
├── AGENTS.md                    # Shared workflow rules
├── features/
│   ├── analytics/
│   │   ├── FEATURE_SPEC.md
│   │   ├── FEATURE_TECHNICAL_SPEC.md
│   │   ├── EXECUTION_PLAN.md
│   │   └── AGENTS_ADDITIONS.md
│   └── notifications/
│       ├── FEATURE_SPEC.md
│       ├── FEATURE_TECHNICAL_SPEC.md
│       ├── EXECUTION_PLAN.md
│       └── AGENTS_ADDITIONS.md
└── [your code]
```

## Output Documents

| Document | Purpose |
|----------|---------|
| `FEATURE_SPEC.md` | Defines *what* the feature does and *why* |
| `FEATURE_TECHNICAL_SPEC.md` | Defines *how* the feature integrates technically |
| `EXECUTION_PLAN.md` | Breaks feature work into phases, steps, and tasks |
| `AGENTS_ADDITIONS.md` | Additional workflow guidelines to merge into existing `AGENTS.md` |

## Git Branching

For feature development, `/fresh-start` creates nested branches:

```
main
  └── feature/analytics (branch)
        └── phase-1 (branch)
              ├── task(1.1.A): ...
              ├── task(1.1.B): ...
              └── task(1.2.A): ...
```

## Merging AGENTS_ADDITIONS.md

After generating the feature plan, merge `AGENTS_ADDITIONS.md` into your project's main `AGENTS.md`:

1. Review the additions for feature-specific rules
2. Add relevant sections to your `AGENTS.md`
3. Remove or consolidate any duplicate guidance

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SPECIFICATION PHASE                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your Feature Idea                                                     │
│       ↓                                                                 │
│   FEATURE_SPEC_PROMPT  ──────→  FEATURE_SPEC.md                         │
│       ↓                                                                 │
│   FEATURE_TECHNICAL_SPEC_PROMPT  ────→  FEATURE_TECHNICAL_SPEC.md       │
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           PLANNING PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Inputs: Specs + existing AGENTS.md                                    │
│       ↓                                                                 │
│   FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT  ─→  EXECUTION_PLAN.md        │
│                                                  AGENTS_ADDITIONS.md    │
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                          EXECUTION PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Add generated documents to project root                               │
│   Merge AGENTS_ADDITIONS.md into existing AGENTS.md                     │
│       ↓                                                                 │
│   START_PROMPTS  ────→  Execute phases iteratively with AI agents       │
│                                                                         │
│   Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3 → ...           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```
