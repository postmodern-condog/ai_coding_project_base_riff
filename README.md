# AI Coding Project Toolkit

A structured prompt framework for building software with AI coding assistants. Instead of ad-hoc prompting, this toolkit provides a systematic workflow that produces documents AI agents can execute against autonomously.

## TL;DR

**What is this?** A prompt generator that creates structured workflows for AI coding projects. Not an application — a framework that produces executable specifications.

**How does it work?** Three phases:

1. **Specify** — Guided Q&A produces `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md`
2. **Plan** — Generator creates `EXECUTION_PLAN.md` (tasks with acceptance criteria) and `AGENTS.md` (workflow rules)
3. **Execute** — AI agents work autonomously with human checkpoints between phases

**Who is it for?** Developers using AI coding assistants who want structured, repeatable workflows instead of ad-hoc prompting.

## Prerequisites

Before using this toolkit, you need:

- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's CLI for Claude (primary interface for slash commands)
- **Git** — Required for the branching and commit workflow
- **Node.js + npm** (optional) — Only needed for markdown linting during development

Not using Claude Code? See [Alternative: Manual Setup](#alternative-manual-setup) for copy-paste prompts that work with any LLM.

## The Problem

AI coding assistants are powerful but inconsistent. Without structure:
- Scope creeps and requirements get forgotten
- Code quality varies between sessions
- No verification that acceptance criteria are met
- Context is lost between conversations

## The Solution

A three-phase workflow with reusable prompts:

1. **Specification** — Guided Q&A extracts clear requirements into `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md`
2. **Planning** — Generator prompts produce `EXECUTION_PLAN.md` (tasks with acceptance criteria) and `AGENTS.md` (workflow rules)
3. **Execution** — AI agents work autonomously within guardrails, with human checkpoints between phases

## Key Features

- **Documents as contracts** — Specs and plans are artifacts AI agents execute against, not just notes
- **Automatic spec verification** — After generating each document, the `spec-verification` skill checks for lost context and quality issues
- **Code verification built in** — Every task has testable acceptance criteria; the `code-verification` skill enforces them
- **TDD enforcement** — Verification checks that tests exist, were written before implementation, and have meaningful assertions
- **Security scanning** — Dependency audits, secrets detection, and static analysis integrated into checkpoints
- **Git workflow** — One branch per phase, auto-commit per task, human reviews before push
- **Stuck detection** — Agents escalate to humans when hitting repeated failures instead of spinning
- **Two workflows** — Greenfield projects start from scratch; feature development integrates with existing code
- **Brownfield support** — Feature workflow includes technical debt assessment and human decision markers for legacy codebases
- **MCP tool detection** — Commands automatically detect available MCP servers and adapt behavior accordingly

## What You End Up With

```
your-project/
├── PRODUCT_SPEC.md          # What you're building (greenfield)
├── TECHNICAL_SPEC.md        # How it's built (greenfield)
├── EXECUTION_PLAN.md        # Tasks with acceptance criteria (greenfield)
├── AGENTS.md                # Workflow rules for AI agents
├── features/                # Feature development (optional)
│   └── analytics/           # Each feature in its own directory
│       ├── FEATURE_SPEC.md
│       ├── FEATURE_TECHNICAL_SPEC.md
│       ├── EXECUTION_PLAN.md
│       └── AGENTS_ADDITIONS.md
├── .claude/
│   ├── commands/            # Execution commands
│   └── skills/              # Code verification + security scanning
└── [your code]
```

These documents persist across sessions, enabling any AI agent to pick up where another left off.

## Quick Start

```bash
# 1. Clone the toolkit
git clone https://github.com/yourusername/ai_coding_project_base.git
cd ai_coding_project_base

# Open this folder in Claude Code to use the slash commands in .claude/commands/

# 2. Initialize & Generate (from toolkit directory)
/setup ~/Projects/my-new-app           # Copy execution commands + skills
/product-spec ~/Projects/my-new-app    # Define what you're building
/technical-spec ~/Projects/my-new-app  # Define how it's built
/generate-plan ~/Projects/my-new-app   # Create EXECUTION_PLAN.md + AGENTS.md

# If any of these output files already exist, do not overwrite them blindly:
# prefer making a backup (or committing to git) before replacing.

# 3. Execute (from your project directory)
cd ~/Projects/my-new-app
/fresh-start           # Orient to project, load context
/phase-prep 1          # Check prerequisites for Phase 1
/phase-start 1         # Execute Phase 1 (creates branch, commits per task)
/phase-checkpoint 1    # Run tests, security scan, verify completion
# Review changes, then: git push origin phase-1
```

### Optional: Local Claude Code Settings

If you use local (machine-specific) Claude Code permissions, copy:

- `.claude/settings.local.example.json` → `.claude/settings.local.json`

The `.claude/settings.local.json` file is intentionally ignored by git.

### Feature Development

Features are isolated in their own directories under `features/<name>/`:

```bash
# From toolkit directory:
/setup ~/Projects/existing-app           # Prompts for feature name, creates features/<name>/
/feature-spec ~/Projects/existing-app/features/analytics
/feature-technical-spec ~/Projects/existing-app/features/analytics
/feature-plan ~/Projects/existing-app/features/analytics

# From your feature directory:
cd ~/Projects/existing-app/features/analytics
/fresh-start             # Detects feature mode, creates feature/analytics branch
/phase-prep 1
/phase-start 1
/phase-checkpoint 1
```

This enables multiple concurrent features without document overwrites. Each feature has its own EXECUTION_PLAN.md while sharing the project's AGENTS.md.

### Adopting Existing Repositories

If you're already working in another repository and want to start using this toolkit:

```bash
# 1. Set environment variable (one-time, in ~/.zshrc or ~/.bashrc):
export AI_CODING_TOOLKIT="$HOME/Projects/ai_coding_project_base"

# 2. From the orchestrator (ai_coding_orchestrator), adopt the repo:
/adopt ~/Projects/my-existing-app

# 3. Start a new Claude Code session in the adopted repo:
cd ~/Projects/my-existing-app
claude

# 4. Generate an execution plan from your existing context:
/bootstrap    # Converts your description/spec into an actionable plan

# Or use the full workflow:
/product-spec .
/technical-spec .
/generate-plan .

# 5. Execute:
/fresh-start
/phase-start 1
```

This workflow is useful when you've been discussing a feature in another repo and decide you want to use the toolkit's structured approach.

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
| `/setup [path]` | Initialize project with execution commands + skills |
| `/product-spec [path]` | Generate product specification |
| `/technical-spec [path]` | Generate technical specification |
| `/generate-plan [path]` | Generate execution plan and AGENTS.md |
| `/feature-spec [path]` | Generate feature specification |
| `/feature-technical-spec [path]` | Generate feature technical specification |
| `/feature-plan [path]` | Generate feature execution plan |
| `/verify-spec <type>` | Verify spec document for quality issues |
| `/bootstrap` | Generate execution plan from existing context (for adopted projects) |

### Execution Commands (run from your project directory)

| Command | Description |
|---------|-------------|
| `/fresh-start` | Orient to project, load context |
| `/phase-prep N` | Check prerequisites for phase N |
| `/phase-start N` | Execute phase N (creates branch, commits per task) |
| `/phase-checkpoint N` | Run tests, security scan, verify completion |
| `/verify-task X.Y.Z` | Verify specific task acceptance criteria |
| `/security-scan` | Run security checks (deps, secrets, code) |
| `/list-todos` | Analyze and prioritize TODO items |
| `/progress` | Show progress through execution plan |

### Recovery Commands (run from your project directory)

| Command | Description |
|---------|-------------|
| `/phase-analyze N` | Analyze what went wrong in phase N |
| `/phase-rollback N` | Rollback to end of phase N (or task ID) |
| `/task-retry X.Y.Z` | Retry a failed task with fresh context |

## Optional Ad-Hoc Tools

These tools are available for on-demand use but are **not part of the standard workflow**. Use them when you have a specific need.

### Tech Debt Check

Analyzes the codebase for technical debt patterns: code duplication, complexity, large files, and common AI code smells.

```bash
# Invoke the skill directly (Claude Code will find it in .claude/skills/)
"Run a tech debt check on this codebase"
```

**When to use:**
- Periodic codebase health audits (e.g., end of sprint)
- Before major refactoring to identify hotspots
- When onboarding to an unfamiliar codebase

**Not recommended for:** Every phase checkpoint (adds overhead without proportional value).

### Code Simplifier

A Claude Code plugin that refines recently-written code for clarity and consistency.

```bash
# Install (one-time, user scope)
claude plugin install code-simplifier

# Use
"Run code-simplifier on the files I just modified"
```

**When to use:**
- After completing a complex feature, for a polish pass
- When code review feedback indicates clarity issues
- Before sharing code with others

**Not recommended for:** Running automatically after every task (the code should be written well initially).

## Output Documents

### Greenfield Projects

| Document | Purpose |
|----------|---------|
| `PRODUCT_SPEC.md` | Defines *what* you're building and *why* |
| `TECHNICAL_SPEC.md` | Defines *how* it will be built technically |
| `EXECUTION_PLAN.md` | Breaks work into phases, steps, and tasks with acceptance criteria |
| `AGENTS.md` | Workflow guidelines for AI agents (TDD policy, test quality standards, mocking policy, context management, guardrails) |

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

## TDD Enforcement

The toolkit enforces Test-Driven Development through the `/verify-task` command, which includes a TDD compliance check.

### What It Verifies

| Check | Description |
|-------|-------------|
| **Test existence** | Every acceptance criterion has a corresponding test |
| **Test-first** | Tests were committed before or with implementation (via git history) |
| **Test effectiveness** | Tests have meaningful assertions and descriptive names |

### TDD Compliance Report

When running `/verify-task`, you'll see:

```
TDD COMPLIANCE: Task 1.2.A
-----------------------
Tests Found: 3/3 criteria covered
Test-First: PASS
Issues: None
```

If tests are missing or were written after implementation, the report flags the issue:

```
TDD COMPLIANCE: Task 1.2.A
-----------------------
Tests Found: 2/3 criteria covered
Test-First: WARNING
Issues:
- [Criterion 3] Missing test
- [Criterion 1] Test added after implementation
```

### Test Quality Standards

The generated `AGENTS.md` includes test quality standards that agents follow:

- **AAA Pattern** — Tests use Arrange-Act-Assert structure
- **Naming** — Tests use `should {behavior} when {condition}` format
- **Coverage** — Happy path, edge cases, error cases, state changes
- **Independence** — No shared mutable state between tests

### Mocking Policy

`AGENTS.md` also includes mocking guidelines:

- **What to mock** — External APIs, databases, file system, time, random values
- **What not to mock** — Code under test, pure functions
- **Mock hygiene** — Reset between tests, prefer dependency injection

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
- **Unpushed commits check** — Before creating a phase branch, prompts if current branch has unpushed commits

### Feature Branches

For feature development, `/fresh-start` creates a `feature/<name>` branch:

```
main
  └── feature/analytics (branch)
        └── phase-1 (branch)
              ├── task(1.1.A): ...
```

### Why This Model

- **Atomic rollback** — Can revert individual tasks via commit
- **Clear history** — Task IDs in commit messages provide traceability
- **Human control** — Push only after checkpoint verification passes
- **Simple branches** — One branch to manage per phase, not per step
- **Isolated features** — Feature work branches off main, phase branches off feature

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

## Development

### Markdown Linting

The toolkit includes markdown linting to maintain documentation quality:

```bash
npm run lint      # Check for issues
npm run lint:fix  # Auto-fix where possible
```

The `.markdownlint.json` config is tuned for prompt template files, disabling rules that cause false positives when code blocks contain markdown examples.

**Rules enforced:**
- Line length (max 300 chars, excluding code blocks and tables)
- Consistent list markers (dashes)
- Trailing whitespace and newlines
- Duplicate sibling headings

## File Structure

```
ai_coding_project_base/
├── PRODUCT_SPEC_PROMPT.md           # Greenfield: Product specification prompt
├── TECHNICAL_SPEC_PROMPT.md         # Greenfield: Technical specification prompt
├── GENERATOR_PROMPT.md              # Greenfield: Execution plan generator
├── START_PROMPTS.md                 # Execution prompts for all workflows
├── FEATURE_PROMPTS/                 # Feature development prompts
│   ├── FEATURE_SPEC_PROMPT.md
│   ├── FEATURE_TECHNICAL_SPEC_PROMPT.md
│   └── FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md
├── .claude/
│   ├── commands/                    # Slash commands
│   │   ├── setup.md
│   │   ├── product-spec.md
│   │   ├── technical-spec.md
│   │   ├── generate-plan.md
│   │   ├── feature-spec.md
│   │   ├── feature-technical-spec.md
│   │   ├── feature-plan.md
│   │   ├── verify-spec.md
│   │   ├── bootstrap.md             # Quick plan from existing context
│   │   ├── fresh-start.md
│   │   ├── phase-prep.md
│   │   ├── phase-start.md
│   │   ├── phase-checkpoint.md
│   │   ├── verify-task.md
│   │   ├── security-scan.md
│   │   ├── list-todos.md
│   │   └── progress.md
│   └── skills/
│       ├── code-verification/       # Multi-agent verification with sub-agents
│       │   └── SKILL.md
│       ├── security-scan/
│       │   └── SKILL.md
│       ├── spec-verification/
│       │   └── SKILL.md
│       └── tech-debt-check/
│           └── SKILL.md
├── docs/                            # Additional documentation
├── deprecated/                      # Legacy prompts (kept for reference)
├── package.json                     # npm scripts for linting
├── .markdownlint.json               # Markdown lint configuration
├── .gitignore                       # Excludes node_modules
├── CLAUDE.md                        # Claude Code configuration
└── TODOS.md                         # Task tracking
```

## License

MIT
