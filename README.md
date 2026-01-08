# AI Coding Project Toolkit

A structured prompt framework for building software with AI coding assistants. Instead of ad-hoc prompting, this toolkit provides a systematic workflow that produces documents AI agents can execute against autonomously.

## The Problem

AI coding assistants are powerful but inconsistent. Without structure:
- Scope creeps and requirements get forgotten
- Code quality varies between sessions
- No verification that acceptance criteria are met
- Context is lost between conversations
- Behavior differs across tools (Claude Code, Codex CLI, etc.)

## The Solution

A three-phase workflow with reusable prompts:

1. **Specification** — Guided Q&A extracts clear requirements into `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md`
2. **Planning** — Generator prompts produce `EXECUTION_PLAN.md` (tasks with acceptance criteria) and `AGENTS.md` (workflow rules)
3. **Execution** — AI agents work autonomously within guardrails, with human checkpoints between phases

## Key Features

- **Documents as contracts** — Specs and plans are artifacts AI agents execute against, not just notes
- **Verification built in** — Every task has testable acceptance criteria; the `code-verification` skill enforces them
- **Tool agnostic** — Works with both Claude Code and Codex CLI via shared skill directories
- **Two workflows** — Greenfield projects start from scratch; feature development integrates with existing code

## What You End Up With

```
your-project/
├── PRODUCT_SPEC.md          # What you're building
├── TECHNICAL_SPEC.md        # How it's built
├── EXECUTION_PLAN.md        # Tasks with acceptance criteria
├── AGENTS.md                # Workflow rules for AI agents
├── .claude/skills/...       # Code verification (Claude Code)
├── .codex/skills/...        # Code verification (Codex CLI)
└── [your code]
```

These documents persist across sessions, enabling any AI agent to pick up where another left off.

## Quick Start (Claude Code)

### 1. Clone the Toolkit
```bash
git clone https://github.com/yourusername/ai_coding_project_base.git
cd ai_coding_project_base
```

### 2. Initialize Your Project
Open Claude Code in the toolkit directory and run:
```
/setup ~/Projects/my-new-app
```

This copies all necessary files (commands, skills, prompts) to your project.

### 3. Generate Documents & Execute

**For a new project:**
```
cd ~/Projects/my-new-app
/product-spec        # Define what you're building
/technical-spec      # Define how it's built
/generate-plan       # Create EXECUTION_PLAN.md + AGENTS.md
/fresh-start         # Orient to project, load context
/phase-prep 1        # Check prerequisites for Phase 1
/phase-start 1       # Execute Phase 1
```

**For a new feature:**
```
cd ~/Projects/existing-app
/feature-spec             # Define the feature
/feature-technical-spec   # Define integration approach
/feature-plan             # Create EXECUTION_PLAN.md + AGENTS_ADDITIONS.md
/fresh-start              # Orient to project, load context
/phase-prep 1             # Check prerequisites for Phase 1
/phase-start 1            # Execute Phase 1
```

### Alternative: Manual Setup

If not using Claude Code, copy files manually and use `START_PROMPTS.md` for guidance.

## Workflow Overview

### Greenfield Projects

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SPECIFICATION PHASE                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your Idea                                                             │
│       ↓                                                                 │
│   PRODUCT_SPEC_PROMPT  ──────→  PRODUCT_SPEC.md                         │
│       ↓                                                                 │
│   TECHNICAL_SPEC_PROMPT  ────→  TECHNICAL_SPEC.md                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           PLANNING PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   GENERATOR_PROMPT  ─────────→  EXECUTION_PLAN.md                       │
│                                  AGENTS.md                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                          EXECUTION PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Add generated documents to project root                               │
│       ↓                                                                 │
│   START_PROMPTS  ────→  Execute phases iteratively with AI agents       │
│                                                                         │
│   Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3 → ...           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Adding Features to Existing Projects

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

## Slash Commands Reference

### Setup & Document Generation

| Command | Description |
|---------|-------------|
| `/setup [path]` | Initialize a project with toolkit files |
| `/product-spec` | Generate PRODUCT_SPEC.md through Q&A |
| `/technical-spec` | Generate TECHNICAL_SPEC.md (requires PRODUCT_SPEC.md) |
| `/generate-plan` | Generate EXECUTION_PLAN.md + AGENTS.md |
| `/feature-spec` | Generate FEATURE_SPEC.md through Q&A |
| `/feature-technical-spec` | Generate FEATURE_TECHNICAL_SPEC.md |
| `/feature-plan` | Generate EXECUTION_PLAN.md + AGENTS_ADDITIONS.md |

### Execution & Monitoring

| Command | Description |
|---------|-------------|
| `/fresh-start` | Orient to project structure, load context |
| `/phase-prep N` | Check prerequisites before starting phase N |
| `/phase-start N` | Execute all tasks in phase N autonomously |
| `/phase-checkpoint N` | Run tests and verification after phase N |
| `/verify-task X.Y.Z` | Run code-verification on a specific task |
| `/progress` | Show progress through EXECUTION_PLAN.md |

## Output Documents

### Greenfield Projects

| Document | Purpose |
|----------|---------|
| `PRODUCT_SPEC.md` | Defines *what* you're building and *why* |
| `TECHNICAL_SPEC.md` | Defines *how* it will be built technically |
| `EXECUTION_PLAN.md` | Breaks work into phases, steps, and tasks with acceptance criteria |
| `AGENTS.md` | Workflow guidelines for AI agents (TDD policy, context management, guardrails) |

### Feature Development

| Document | Purpose |
|----------|---------|
| `FEATURE_SPEC.md` | Defines *what* the feature does and *why* |
| `FEATURE_TECHNICAL_SPEC.md` | Defines *how* the feature integrates technically |
| `EXECUTION_PLAN.md` | Breaks feature work into phases, steps, and tasks |
| `AGENTS_ADDITIONS.md` | Additional workflow guidelines to merge into existing `AGENTS.md` |

## Tips for Best Results

1. **Be specific with your initial idea** — The more detail you provide upfront, the fewer clarification rounds needed

2. **Accept or push back on recommendations** — The prompts include AI recommendations with confidence levels; feel free to override them

3. **Keep specs updated** — If scope changes during development, update your specs to keep agents aligned

4. **Use phase checkpoints** — Each phase ends with verification; don't skip these

5. **Track follow-ups in TODOS.md** — The framework encourages capturing scope creep items rather than addressing them immediately

## File Structure

```
ai_coding_project_base/
├── PRODUCT_SPEC_PROMPT.md           # Greenfield: Product specification prompt
├── TECHNICAL_SPEC_PROMPT.md         # Greenfield: Technical specification prompt
├── GENERATOR_PROMPT.md              # Greenfield: Execution plan generator
├── START_PROMPTS.md                 # Execution prompts for all workflows
├── FEATURE_PROMPTS/                 # Feature development prompts
│   ├── FEATURE_SPEC_PROMPT.md       # Feature: Product specification prompt
│   ├── FEATURE_TECHNICAL_SPEC_PROMPT.md  # Feature: Technical specification prompt
│   └── FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md  # Feature: Execution plan generator
├── .claude/                         # Claude Code configuration (copy to new projects)
│   ├── commands/                    # Slash commands
│   │   ├── setup.md                 # /setup — Initialize new project
│   │   ├── product-spec.md          # /product-spec — Generate product spec
│   │   ├── technical-spec.md        # /technical-spec — Generate tech spec
│   │   ├── generate-plan.md         # /generate-plan — Generate execution plan
│   │   ├── feature-spec.md          # /feature-spec — Generate feature spec
│   │   ├── feature-technical-spec.md # /feature-technical-spec — Generate feature tech spec
│   │   ├── feature-plan.md          # /feature-plan — Generate feature plan
│   │   ├── fresh-start.md           # /fresh-start — Orient to project
│   │   ├── phase-prep.md            # /phase-prep N — Check prerequisites
│   │   ├── phase-start.md           # /phase-start N — Execute phase
│   │   ├── phase-checkpoint.md      # /phase-checkpoint N — Run checks
│   │   ├── verify-task.md           # /verify-task X.Y.Z — Verify task
│   │   └── progress.md              # /progress — Show progress
│   └── skills/
│       └── code-verification/
│           └── SKILL.md             # Code verification skill
├── .codex/                          # Codex CLI skills (copy to new projects)
│   └── skills/
│       └── code-verification/
│           └── SKILL.md             # Code verification skill
├── docs/                            # Additional documentation
├── deprecated/                      # Legacy prompts (kept for reference)
├── CLAUDE.md                        # Claude Code configuration
└── TODOS.md                         # Task tracking
```

## License

MIT
