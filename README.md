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
- **Automatic spec verification** — After generating each document, the `spec-verification` skill checks for lost context and quality issues
- **Code verification built in** — Every task has testable acceptance criteria; the `code-verification` skill enforces them
- **Security scanning** — Dependency audits, secrets detection, and static analysis integrated into checkpoints
- **Git workflow** — One branch per phase, auto-commit per task, human reviews before push
- **Stuck detection** — Agents escalate to humans when hitting repeated failures instead of spinning
- **Tool agnostic** — Works with both Claude Code and Codex CLI via shared skill directories
- **Two workflows** — Greenfield projects start from scratch; feature development integrates with existing code
- **Brownfield support** — Feature workflow includes technical debt assessment and human decision markers for legacy codebases

## What You End Up With

```
your-project/
├── PRODUCT_SPEC.md          # What you're building
├── TECHNICAL_SPEC.md        # How it's built
├── EXECUTION_PLAN.md        # Tasks with acceptance criteria
├── AGENTS.md                # Workflow rules for AI agents
├── .claude/
│   ├── commands/            # Execution commands (copied from toolkit)
│   └── skills/              # Code verification + security scanning
├── .codex/skills/           # Same skills for Codex CLI
└── [your code]
```

These documents persist across sessions, enabling any AI agent to pick up where another left off.

## Quick Start (Claude Code)

### 1. Clone the Toolkit
```bash
git clone https://github.com/yourusername/ai_coding_project_base.git
cd ai_coding_project_base
```

### 2. Initialize & Generate (from toolkit directory)

```bash
# Still in ai_coding_project_base directory:
/setup ~/Projects/my-new-app       # Copy execution commands + skills
/product-spec ~/Projects/my-new-app       # Define what you're building
/technical-spec ~/Projects/my-new-app     # Define how it's built
/generate-plan ~/Projects/my-new-app      # Create EXECUTION_PLAN.md + AGENTS.md
```

### 3. Execute (from your project directory)

```bash
cd ~/Projects/my-new-app
/fresh-start           # Orient to project, load context
/phase-prep 1          # Check prerequisites for Phase 1
/phase-start 1         # Execute Phase 1 (creates branch, commits per task)
/phase-checkpoint 1    # Run tests, security scan, verify completion
# Review changes, then: git push origin phase-1
```

**For adding features to existing projects:**
```bash
# From toolkit directory:
/setup ~/Projects/existing-app            # Copy execution commands + skills
/feature-spec ~/Projects/existing-app     # Define the feature
/feature-technical-spec ~/Projects/existing-app
/feature-plan ~/Projects/existing-app

# From your project:
cd ~/Projects/existing-app
# Merge AGENTS_ADDITIONS.md into AGENTS.md
/fresh-start
/phase-prep 1
/phase-start 1
/phase-checkpoint 1
# Review changes, then: git push origin phase-1
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
│       ↓                                                                 │
│   [Auto-Verify] ─────────────→  Check context preservation & quality    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           PLANNING PHASE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   GENERATOR_PROMPT  ─────────→  EXECUTION_PLAN.md                       │
│                                  AGENTS.md                              │
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

## Slash Commands Reference

### Generation Commands (run from toolkit directory)

| Command | Description |
|---------|-------------|
| `/setup [path]` | Copy execution commands + skills to target project |
| `/product-spec [path]` | Generate PRODUCT_SPEC.md through Q&A |
| `/technical-spec [path]` | Generate TECHNICAL_SPEC.md (requires PRODUCT_SPEC.md) + auto-verify |
| `/generate-plan [path]` | Generate EXECUTION_PLAN.md + AGENTS.md + auto-verify |
| `/feature-spec [path]` | Generate FEATURE_SPEC.md through Q&A |
| `/feature-technical-spec [path]` | Generate FEATURE_TECHNICAL_SPEC.md + auto-verify |
| `/feature-plan [path]` | Generate EXECUTION_PLAN.md + AGENTS_ADDITIONS.md + auto-verify |
| `/verify-spec <type>` | Manually verify a spec document (technical-spec, execution-plan, etc.) |

### Execution Commands (run from your project directory)

| Command | Description |
|---------|-------------|
| `/fresh-start` | Orient to project structure, load context |
| `/phase-prep N` | Check prerequisites before starting phase N |
| `/phase-start N` | Execute all tasks in phase N autonomously |
| `/phase-checkpoint N` | Run tests and verification after phase N |
| `/verify-task X.Y.Z` | Run code-verification on a specific task |
| `/security-scan` | Scan for security vulnerabilities in deps, code, and secrets |
| `/list-todos` | Analyze and prioritize TODO items with implementation guidance |
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

## Automatic Spec Verification

After generating `TECHNICAL_SPEC.md`, `EXECUTION_PLAN.md`, or their feature equivalents, the toolkit automatically runs verification to catch two types of problems:

### Context Preservation

Ensures nothing important is lost as requirements flow through the document chain:

```
PRODUCT_SPEC.md → TECHNICAL_SPEC.md → EXECUTION_PLAN.md
```

For each upstream document, verification extracts key items (features, constraints, edge cases) and confirms they appear in the downstream document—either directly, consolidated into broader items, or explicitly deferred.

### Quality Checks

Scans for common specification anti-patterns:

| Issue Type | Example | Why It Matters |
|------------|---------|----------------|
| Vague language | "API should be fast" | Can't write tests for unmeasurable requirements |
| Missing rationale | "Use Redis" | Without "why", future decisions lack context |
| Undefined contracts | "POST /users" without request shape | Implementation will guess or stall |
| Untestable criteria | "Should feel intuitive" | Acceptance criteria must be verifiable |
| Scope creep | Feature in tech spec not in product spec | Requirements should flow downstream, not appear spontaneously |

### Interactive Repair

When issues are found, verification presents each one with resolution options:

```
ISSUE 1 of 2: Vague Language
Location: TECHNICAL_SPEC.md, Section "Performance"
Problem: "API responses should be fast" is unmeasurable

How would you like to resolve this?
○ Use suggested: "API responses return within 200ms p95" (Recommended)
○ Specify custom target
○ Remove requirement
```

Fixes are applied automatically based on your choices, then re-verified.

## Security Scanning

The toolkit includes integrated security scanning that runs automatically during `/phase-checkpoint` and can be invoked manually via `/security-scan`.

### What It Checks

| Category | Examples | Severity |
|----------|----------|----------|
| **Dependency vulnerabilities** | Known CVEs in npm/pip/cargo packages | CRITICAL-LOW |
| **Hardcoded secrets** | AWS keys, GitHub tokens, API keys, private keys | CRITICAL-HIGH |
| **Insecure code patterns** | `eval()`, SQL concatenation, disabled SSL verification | HIGH-MEDIUM |

### How It Works

1. **Auto-detects tech stack** from package.json, requirements.txt, Cargo.toml, etc.
2. **Runs appropriate tools** (`npm audit`, `pip-audit`, pattern matching)
3. **Presents findings** with severity levels and fix suggestions
4. **Offers resolution options** for each CRITICAL/HIGH issue
5. **Blocks checkpoint** if unresolved CRITICAL/HIGH issues remain

### Manual Scanning

```bash
/security-scan              # Full scan (deps + secrets + code)
/security-scan --deps       # Dependency vulnerabilities only
/security-scan --secrets    # Secrets detection only
/security-scan --code       # Static analysis only
/security-scan --fix        # Auto-fix where possible
```

## Git Workflow

During execution, the toolkit follows a structured git workflow:

### One Branch Per Phase

```
main
  └── phase-1 (branch)
        ├── task(1.1.A): Add user model       ← step 1.1
        ├── task(1.1.B): Add user routes
        ├── task(1.2.A): Add auth middleware   ← step 1.2 (continues on same branch)
        └── task(1.2.B): Add login endpoint
```

- **One branch per phase** — Not per step or task
- **One commit per task** — Immediately after task verification passes
- **Sequential commits** — Each task builds on the previous
- **No auto-push** — Human reviews at checkpoint before pushing

### Why This Model

- **Atomic rollback** — Can revert individual tasks via commit
- **Clear history** — Task IDs in commit messages provide traceability
- **Human control** — Push only after checkpoint verification passes
- **Simple branches** — One branch to manage per phase, not per step

## Stuck Detection

Agents can get stuck in loops, repeatedly failing on the same issue. The toolkit detects this and escalates to human intervention.

### Escalation Triggers

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Consecutive task failures | 3 tasks | Pause phase |
| Same error pattern | 2 occurrences | Pause and report |
| Verification loop | 5 attempts on same criterion | Mark task blocked |
| Test flakiness | Same test passes then fails | Flag for review |

### What Happens

When stuck, the agent stops and presents:
- Pattern description (what keeps failing)
- Last 3 errors
- Possible causes
- Options: skip task, modify criteria, try different approach, abort phase

This prevents agents from burning tokens on unfixable issues and ensures human judgment is applied where needed.

## Brownfield / Legacy Support

The feature development workflow (`/feature-spec`, `/feature-technical-spec`) includes special handling for legacy codebases.

### Technical Debt Assessment

When generating `FEATURE_TECHNICAL_SPEC.md`, the toolkit identifies:
- Undocumented functions with unclear behavior
- Tightly coupled components that resist change
- Missing test coverage in affected areas
- Deprecated patterns the feature must work around

### Human Decision Markers

For decisions requiring human judgment, specs include explicit markers:

```
⚠️ REQUIRES HUMAN DECISION: Database migration strategy
Options:
1. Online migration with dual-write — Lower risk, higher complexity
2. Offline migration with downtime — Simpler, requires maintenance window
Recommendation: Option 1 for production, Option 2 for staging
```

### Migration Risk Checklist

Feature specs include a checklist:
- [ ] Data migration required? Reversible?
- [ ] Breaking changes to existing APIs?
- [ ] Dependent services affected?
- [ ] Feature flags needed for gradual rollout?
- [ ] Rollback plan if deployment fails?

## AGENTS.md Size Limit

Research shows LLMs follow ~150 instructions consistently. Beyond this, instruction-following degrades.

The toolkit enforces this:
- **≤150 lines**: Optimal
- **151-200 lines**: Warning with suggestion to split
- **>200 lines**: Fails validation

If your AGENTS.md grows too large, split project-specific rules into subdirectory `.claude/CLAUDE.md` files that load on-demand.

### Manual Verification

Run verification manually anytime:

```bash
/verify-spec technical-spec      # Verify TECHNICAL_SPEC.md
/verify-spec execution-plan      # Verify EXECUTION_PLAN.md
/verify-spec feature-technical   # Verify FEATURE_TECHNICAL_SPEC.md
/verify-spec feature-plan        # Verify feature EXECUTION_PLAN.md
```

## Using Web Interfaces (Claude, ChatGPT, etc.)

The slash commands optimize for **workflow integration and consistency**, but web-based LLM interfaces may produce **higher quality specification documents** in certain scenarios. Consider the trade-offs:

### When Web Interfaces May Be Better

| Scenario | Why |
|----------|-----|
| **Greenfield product specs** | Web search enables competitor analysis, market research, and industry best practices |
| **Complex product decisions** | Extended thinking modes provide deeper reasoning on trade-offs |
| **Rich reference material** | Projects/uploads let you include user research, brand guides, competitor docs |
| **Document iteration** | Artifact panels make it easier to refine sections while viewing the whole |

### When Slash Commands Are Better

| Scenario | Why |
|----------|-----|
| **Feature development** | Needs codebase access to understand existing patterns and constraints |
| **Technical specs** | Benefits from reading actual code, not just descriptions |
| **Workflow velocity** | Documents land in the right place, ready for next step |
| **Team consistency** | Same environment produces predictable, uniform outputs |

### Hybrid Workflow

You can generate specs in a web interface and continue execution in Claude Code:

**For greenfield projects:**
```bash
# 1. In Claude/ChatGPT web interface:
#    - Paste contents of PRODUCT_SPEC_PROMPT.md
#    - Complete the Q&A, copy the resulting markdown

# 2. Save to your project:
#    - Create PRODUCT_SPEC.md in your target directory

# 3. Continue in Claude Code (from toolkit directory):
/technical-spec ~/Projects/my-app    # Reads your PRODUCT_SPEC.md
/generate-plan ~/Projects/my-app

# 4. Execute normally:
cd ~/Projects/my-app
/fresh-start
/phase-prep 1
/phase-start 1
```

**For feature development:**
```bash
# 1. In web interface:
#    - Paste contents of FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md
#    - Include relevant context about your existing app
#    - Copy the resulting markdown

# 2. Save to your project:
#    - Create FEATURE_SPEC.md in your target directory

# 3. Continue in Claude Code (from toolkit directory):
/feature-technical-spec ~/Projects/my-app    # Benefits from codebase access
/feature-plan ~/Projects/my-app

# 4. Execute normally
```

### Prompt Files for Web Use

The raw prompts are available for copy-paste into any LLM:

| Document | Prompt File |
|----------|-------------|
| PRODUCT_SPEC.md | `PRODUCT_SPEC_PROMPT.md` |
| TECHNICAL_SPEC.md | `TECHNICAL_SPEC_PROMPT.md` |
| FEATURE_SPEC.md | `FEATURE_PROMPTS/FEATURE_SPEC_PROMPT.md` |
| FEATURE_TECHNICAL_SPEC.md | `FEATURE_PROMPTS/FEATURE_TECHNICAL_SPEC_PROMPT.md` |

**Note:** EXECUTION_PLAN.md and AGENTS.md generation (`GENERATOR_PROMPT.md`) requires reading the spec files, so these are best done in Claude Code where file access is available.

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
├── .claude/
│   ├── commands/
│   │   ├── setup.md                 # /setup — Initialize new project (toolkit only)
│   │   ├── product-spec.md          # /product-spec — Generate product spec (toolkit only)
│   │   ├── technical-spec.md        # /technical-spec — Generate tech spec (toolkit only)
│   │   ├── generate-plan.md         # /generate-plan — Generate execution plan (toolkit only)
│   │   ├── feature-spec.md          # /feature-spec — Generate feature spec (toolkit only)
│   │   ├── feature-technical-spec.md # /feature-technical-spec (toolkit only)
│   │   ├── feature-plan.md          # /feature-plan — Generate feature plan (toolkit only)
│   │   ├── verify-spec.md           # /verify-spec — Verify spec document (toolkit only)
│   │   ├── fresh-start.md           # /fresh-start — Orient to project (copied to target)
│   │   ├── phase-prep.md            # /phase-prep N — Check prerequisites (copied to target)
│   │   ├── phase-start.md           # /phase-start N — Execute phase (copied to target)
│   │   ├── phase-checkpoint.md      # /phase-checkpoint N — Run checks (copied to target)
│   │   ├── verify-task.md           # /verify-task X.Y.Z — Verify task (copied to target)
│   │   ├── security-scan.md         # /security-scan — Security scanning (copied to target)
│   │   ├── list-todos.md            # /list-todos — Prioritize TODOs (copied to target)
│   │   └── progress.md              # /progress — Show progress (copied to target)
│   └── skills/
│       ├── code-verification/
│       │   └── SKILL.md             # Code verification skill (copied to target)
│       ├── security-scan/
│       │   └── SKILL.md             # Security scan skill (copied to target)
│       └── spec-verification/
│           └── SKILL.md             # Spec verification skill (toolkit only)
├── .codex/
│   └── skills/
│       ├── code-verification/
│       │   └── SKILL.md             # Code verification skill (copied to target)
│       └── security-scan/
│           └── SKILL.md             # Security scan skill (copied to target)
├── docs/                            # Additional documentation
├── deprecated/                      # Legacy prompts (kept for reference)
├── CLAUDE.md                        # Claude Code configuration
└── TODOS.md                         # Task tracking
```

## License

MIT
