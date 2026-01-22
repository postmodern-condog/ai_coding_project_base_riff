# AI Coding Project Toolkit

A structured framework for AI agents to build software autonomously—with verification, guardrails, and human oversight built in.

**[View Landing Page](https://benjaminshoemaker.github.io/ai_coding_project_base/)** · **[Example Project Output](https://github.com/benjaminshoemaker/calc-example)**

## TL;DR

**What is this?** A framework that turns ad-hoc AI prompting into a repeatable workflow with automatic verification.

**How does it work?** Three phases:

1. **Specify** — Guided Q&A produces `PRODUCT_SPEC.md` and `TECHNICAL_SPEC.md`
2. **Plan** — Generator creates `EXECUTION_PLAN.md` (tasks with testable acceptance criteria) and `AGENTS.md` (workflow rules)
3. **Execute** — AI agents work task-by-task with automatic verification after each one

**What makes execution robust?**

- **Code verification** — Multi-agent system checks each task against its acceptance criteria
- **TDD enforcement** — Verifies tests exist, were written first, and have meaningful assertions
- **Security scanning** — Dependency audits, secrets detection, and static analysis at checkpoints
- **Stuck detection** — Agents escalate to humans instead of spinning on failures
- **Git workflow** — One branch per phase, one commit per task, human review before push

**Who is it for?** Developers who want AI agents to write code reliably, not just occasionally.

## Prerequisites

- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's CLI for Claude (primary interface)
- **Git** — Required for the branching and commit workflow

Codex CLI users: see [Codex Setup](docs/codex-cli.md).

Not using Claude Code? See [Manual Setup](docs/manual-setup.md) for copy-paste prompts.

## Quick Start

```bash
# 1. Clone the toolkit
git clone https://github.com/benjaminshoemaker/ai_coding_project_base.git
cd ai_coding_project_base

# Open this folder in Claude Code to use the slash commands

# 2. Generate specs and plan (from toolkit directory)
/product-spec ~/Projects/my-new-app
/technical-spec ~/Projects/my-new-app
/generate-plan ~/Projects/my-new-app   # Also copies execution commands to your project

# 3. Execute (from your project directory)
cd ~/Projects/my-new-app
/fresh-start                # Orient to project, load context
/configure-verification     # Set test/lint/build commands for your stack
/phase-prep 1               # Check prerequisites
/phase-start 1              # Execute Phase 1 (creates branch, commits per task)
/phase-checkpoint 1         # Run tests, security scan, verify completion
# Review changes, then: git push origin phase-1
```

For feature development in existing projects, see [Feature Workflow](docs/feature-workflow.md).

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
│   /fresh-start  ────────────→  Orient to project, load context          │
│       ↓                                                                 │
│   /phase-start N  ──────────→  Execute phase (branch + commits)         │
│       ↓                                                                 │
│   /phase-checkpoint N  ─────→  Verify, test, security scan              │
│                                                                         │
│   Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3 → ...           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Adding Features to Existing Projects

See [Feature Workflow](docs/feature-workflow.md) for the complete guide. The pattern is similar:

```
/feature-spec → /feature-technical-spec → /feature-plan → /fresh-start → /phase-start
```

Features are isolated in `features/<name>/` directories, enabling concurrent feature development.

## Commands Reference

### Generation Commands (run from toolkit directory)

| Command | Description |
|---------|-------------|
| `/product-spec [path]` | Generate product specification |
| `/technical-spec [path]` | Generate technical specification |
| `/generate-plan [path]` | Generate execution plan and AGENTS.md |
| `/feature-spec [path]` | Generate feature specification |
| `/feature-technical-spec [path]` | Generate feature technical specification |
| `/feature-plan [path]` | Generate feature execution plan |
| `/verify-spec <type>` | Verify spec document for quality issues |
| `/bootstrap` | Generate plan from existing context |

### Setup Commands (run from toolkit directory)

| Command | Description |
|---------|-------------|
| `/setup [path]` | Initialize new project with toolkit structure |
| `/gh-init [path]` | Initialize git repo with smart .gitignore and optional GitHub remote |
| `/install-hooks [path]` | Install git hooks (pre-push doc sync check) |

### Execution Commands (run from your project directory)

| Command | Description |
|---------|-------------|
| `/fresh-start` | Orient to project, load context |
| `/configure-verification` | Set test/lint/build commands for your stack |
| `/phase-prep N` | Check prerequisites, preview future human items |
| `/phase-start N` | Execute phase N (creates branch, commits per task) |
| `/phase-checkpoint N` | Local-first verification, then production checks |
| `/verify-task X.Y.Z` | Verify specific task acceptance criteria |
| `/criteria-audit` | Validate acceptance criteria metadata |
| `/security-scan` | Run security checks (deps, secrets, code) |
| `/progress` | Show progress through execution plan |
| `/list-todos` | Analyze and prioritize TODO items |
| `/capture-learning` | Save project patterns to LEARNINGS.md |

See [Recovery Commands](docs/recovery-commands.md) for failure handling (`/phase-analyze`, `/phase-rollback`, `/task-retry`).

## What You Get

```
your-project/
├── PRODUCT_SPEC.md          # What you're building
├── TECHNICAL_SPEC.md        # How it's built
├── EXECUTION_PLAN.md        # Tasks with acceptance criteria
├── AGENTS.md                # Workflow rules for AI agents
├── LEARNINGS.md             # Discovered patterns (created as you work)
├── DEFERRED.md              # Deferred requirements (captured during Q&A)
├── .claude/
│   ├── commands/            # Execution commands (auto-copied)
│   ├── skills/              # Verification skills (auto-copied)
│   └── verification-config.json
└── [your code]
```

These documents persist across sessions, enabling any AI agent to pick up where another left off.

`LEARNINGS.md` is created as you work—use `/capture-learning` to save project-specific patterns, conventions, and gotchas. The `/fresh-start` command loads these learnings into context for each new task.

`DEFERRED.md` is populated during specification Q&A. When you mention something is "out of scope," "v2," or "for later," the toolkit prompts you to capture it with clarifying context so nothing gets lost.

## Workflow Automation

### Auto-Advance

After checkpoint verification passes, the toolkit can automatically advance to the next phase:

```
/phase-start 1 → /phase-checkpoint 1 → [15s countdown] → /phase-prep 2 → ...
```

Auto-advance triggers when:
- All local verification passes (tests, lint, build)
- All production verification passes (deployment, integration)
- `/phase-prep` shows all prerequisites are green

The countdown can be interrupted with Ctrl+C. When the sequence stops (prerequisite fails, verification fails, or interrupted), a session report shows all completed phases and blocking issues.

### Local-First Verification

Phase checkpoints run local verification first (tests, lint, security scan). Production verification (deployment, integration) only runs after local passes. This prevents wasted cycles on production checks when basic issues exist.

## How Verification Works

The toolkit enforces quality through multiple mechanisms:

- **Code Verification** — After each task, a sub-agent checks acceptance criteria. Tests must pass before the task is marked complete.
- **TDD Enforcement** — Verification checks that tests exist, were committed before implementation, and have meaningful assertions.
- **Security Scanning** — At checkpoints, the toolkit runs dependency audits, secrets detection, and static analysis. Critical issues block progress.
- **Spec Verification** — After generating specs, automatic verification ensures requirements flow through the document chain without loss.
- **Stuck Detection** — Agents escalate to humans after repeated failures instead of spinning forever.

For detailed documentation, see [Verification Deep Dive](docs/verification.md).

## Git Workflow

During execution:
- **One branch per phase** — `phase-1`, `phase-2`, etc.
- **One commit per task** — Immediately after verification passes
- **No auto-push** — Human reviews at checkpoint before pushing

```
main
  └── phase-1
        ├── task(1.1.A): Add user model
        ├── task(1.1.B): Add user routes
        └── task(1.2.A): Add auth middleware
```

For feature development, branches nest: `main → feature/analytics → phase-1`.

## File Structure

```
ai_coding_project_base/
├── PRODUCT_SPEC_PROMPT.md           # Spec generation prompts
├── TECHNICAL_SPEC_PROMPT.md
├── GENERATOR_PROMPT.md
├── START_PROMPTS.md
├── FEATURE_PROMPTS/                 # Feature workflow prompts
│   ├── FEATURE_SPEC_PROMPT.md
│   ├── FEATURE_TECHNICAL_SPEC_PROMPT.md
│   └── FEATURE_EXECUTION_PLAN_GENERATOR_PROMPT.md
├── .claude/
│   ├── commands/                    # All slash commands
│   ├── skills/                      # Verification skills
│   └── hooks/                       # Git hooks (pre-push doc check)
├── docs/                            # Detailed documentation
├── extras/                          # Landing page, optional tools
└── AGENTS.md                        # Toolkit contributor guidelines
```

## Documentation

- [Feature Workflow](docs/feature-workflow.md) — Adding features to existing projects
- [Verification Deep Dive](docs/verification.md) — TDD, security, spec verification details
- [Recovery Commands](docs/recovery-commands.md) — Handling failures and rollbacks
- [Web Interface Usage](docs/web-interfaces.md) — Using with ChatGPT, Claude web, etc.
- [Manual Setup](docs/manual-setup.md) — Copy-paste prompts for non-Claude-Code users
- [Advanced Topics](docs/advanced.md) — Brownfield support, AGENTS.md limits, optional tools
- [Codex CLI Setup](docs/codex-cli.md) — Using with OpenAI's Codex CLI

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.

```bash
npm run lint      # Check markdown
npm run lint:fix  # Auto-fix
```

## License

MIT
