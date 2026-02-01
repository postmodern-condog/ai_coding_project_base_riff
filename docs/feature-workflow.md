# Feature Development Workflow

This guide covers adding features to existing projects using the toolkit's feature workflow.

## Overview

Features are isolated in their own directories under `features/<name>/`, enabling multiple concurrent features without document conflicts.

## Quick Start

```bash
# From your project directory (after /setup):
cd ~/Projects/existing-app

/feature-spec analytics
/feature-technical-spec analytics
/feature-plan analytics

# Then execute from the feature directory:
cd features/analytics
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
├── DEFERRED.md                  # Project-wide deferred requirements
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

Note: `DEFERRED.md` lives at the project root (not in feature directories) since deferred items often span features or apply to the whole project.

## Output Documents

| Document | Purpose |
|----------|---------|
| `FEATURE_SPEC.md` | Defines *what* the feature does and *why* |
| `FEATURE_TECHNICAL_SPEC.md` | Defines *how* the feature integrates technically |
| `EXECUTION_PLAN.md` | Breaks feature work into phases, steps, and tasks |
| `AGENTS_ADDITIONS.md` | Additional workflow guidelines to merge into existing `AGENTS.md` |

## Deferred Requirements

During spec Q&A, when you mention something is "out of scope," "v2," or "for later," the toolkit prompts you to capture it:

```
"Would you like to save this to your deferred requirements?"
○ Yes, capture it — I'll ask a few quick questions to document it
○ No, skip — Don't record this
```

If you choose to capture, it asks clarifying questions (what's being deferred, why, notes for later) and immediately appends to `PROJECT_ROOT/DEFERRED.md`. This prevents good ideas from getting lost during rapid specification work.

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
│   /feature-spec <name>  ────→  FEATURE_SPEC.md                          │
│       ↓                                                                 │
│   /feature-technical-spec <name>  ──→  FEATURE_TECHNICAL_SPEC.md        │
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
│   /feature-plan <name>  ────→  EXECUTION_PLAN.md                        │
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
