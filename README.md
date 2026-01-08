# AI Coding Project Toolkit

A structured prompt framework for building software products with AI coding assistants. This toolkit guides you through product specification, technical design, and implementation planning—producing documents that AI agents can execute against.

## What This Solves

AI coding assistants are powerful but work best with clear, structured context. This toolkit provides prompts that help you:

1. **Define what to build** — through guided product and technical specifications
2. **Plan how to build it** — with phased execution plans and acceptance criteria
3. **Execute systematically** — using prompts designed for iterative, agent-driven development

## Quick Start

### Option 1: Clone the Repository
```bash
git clone https://github.com/yourusername/ai_coding_project_base.git
```

### Option 2: Copy the Files
Download and copy these files to your project:

**For greenfield projects:**
- `PRODUCT_SPEC_PROMPT.md`
- `TECHNICAL_SPEC_PROMPT.md`
- `GENERATOR_PROMPT.md`
- `START_PROMPTS.md`

**For adding features to existing projects:**
- `FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md`
- `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md`
- `FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md`
- `START_PROMPTS.md`

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

## Step-by-Step Usage

### Greenfield Projects

#### Step 1: Product Specification

Paste `PRODUCT_SPEC_PROMPT.md` into your AI assistant along with your idea.

The AI will ask questions to clarify:
- What problem the app solves
- Who the target users are
- Core user experience
- MVP features
- Data requirements

**Output:** `PRODUCT_SPEC.md`

```markdown
# Example output snippet:
## Problem Statement
Users struggle to track their daily habits consistently...

## Target Users
- Primary: Young professionals (25-35) seeking self-improvement
- Secondary: Students building study routines
```

#### Step 2: Technical Specification

Paste `TECHNICAL_SPEC_PROMPT.md` along with your `PRODUCT_SPEC.md`.

The AI will guide you through:
- Architecture decisions
- Tech stack selection
- Data models
- API contracts
- Implementation sequence

**Output:** `TECHNICAL_SPEC.md`

```markdown
# Example output snippet:
## Tech Stack
- Frontend: Next.js 14 with App Router
- Database: SQLite with Drizzle ORM
- Styling: Tailwind CSS

## Data Models
### Habit
| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Primary key |
| name | string | Habit name |
| frequency | enum | daily/weekly/custom |
```

#### Step 3: Generate Execution Plan

Paste `GENERATOR_PROMPT.md` along with your `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md`.

**Output:** `EXECUTION_PLAN.md` and `AGENTS.md`

```markdown
# Example EXECUTION_PLAN.md snippet:
## Phase 1: Foundation

### Step 1.1: Project Setup

#### Task 1.1.A: Initialize Project Structure

**What:** Create Next.js project with required dependencies

**Acceptance Criteria:**
- [ ] Project runs with `npm run dev`
- [ ] Tailwind CSS configured and working
- [ ] Basic folder structure in place

**Files:**
- Create: `src/app/page.tsx` — Landing page
- Create: `src/app/layout.tsx` — Root layout
```

#### Step 4: Execute with START_PROMPTS

1. Add the generated `EXECUTION_PLAN.md` and `AGENTS.md` to your project root
2. Use the prompts in `START_PROMPTS.md` to guide execution:
   - **Fresh start** — Orient the AI to your project structure
   - **Phase prep** — Check prerequisites before starting a phase
   - **Phase start** — Execute all tasks in a phase autonomously

---

### Adding Features to Existing Projects

#### Step 1: Feature Specification

Paste `FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md` into your AI assistant along with your feature idea.

**Output:** `FEATURE_SPEC.md`

#### Step 2: Feature Technical Specification

Paste `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md` along with your `FEATURE_SPEC.md`.

**Output:** `FEATURE_TECHNICAL_SPEC.md`

#### Step 3: Generate Feature Execution Plan

Paste `FEATURE_PROMPTS/FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md` along with:
- Your `FEATURE_SPEC.md`
- Your `FEATURE_TECHNICAL_SPEC.md`
- Your existing `AGENTS.md` (required input)

**Output:** `EXECUTION_PLAN.md` and `AGENTS_ADDITIONS.md`

#### Step 4: Execute with START_PROMPTS

1. Add the generated `EXECUTION_PLAN.md` to your project root
2. Merge `AGENTS_ADDITIONS.md` into your existing `AGENTS.md`
3. Use the prompts in `START_PROMPTS.md` to guide execution:
   - **Phase prep** — Check prerequisites before starting a phase
   - **Phase start** — Execute all tasks in a phase autonomously

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
├── docs/                            # Additional documentation
├── deprecated/                      # Legacy prompts (kept for reference)
├── CLAUDE.md                        # Claude Code configuration
└── TODOS.md                         # Task tracking
```

## License

MIT
