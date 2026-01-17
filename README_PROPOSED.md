# AI Coding Project Toolkit

A structured workflow (prompts + Claude Code slash commands) for getting from an idea to an agent-executable plan, and then executing that plan with verification guardrails.

This repository is the **toolkit**. You typically run its commands against a **separate target project directory** that will receive generated files like `PRODUCT_SPEC.md`, `TECHNICAL_SPEC.md`, `EXECUTION_PLAN.md`, and `AGENTS.md`.

## What You Get

The workflow produces durable “contracts” that make autonomous execution more reliable:

- `PRODUCT_SPEC.md` — Problem, audience, platform, core flows, MVP scope
- `TECHNICAL_SPEC.md` — Architecture and technical decisions tied to product needs
- `EXECUTION_PLAN.md` — Phases/steps/tasks with testable acceptance criteria
- `AGENTS.md` — Execution rules for agents (TDD, verification, git workflow, stop conditions)

For feature work (brownfield), the toolkit generates feature-local equivalents under `features/<name>/`.

## How It Works (High Level)

1. **Specify** — Guided Q&A produces specs
2. **Plan** — Generator produces an execution plan + agent workflow rules
3. **Execute** — Agents complete tasks one-at-a-time with verification after each task and checkpoints between phases

## Quick Start

### 1) Clone and open in Claude Code

Clone this repository and open it in Claude Code so the slash commands in `.claude/commands/` are available.

### 2) Greenfield: Generate specs + plan for a new project

From this toolkit directory:

- `/product-spec <project-path>`
- `/technical-spec <project-path>`
- `/generate-plan <project-path>`

Then switch to your target project:

```bash
cd <project-path>
/fresh-start
/phase-prep 1
/phase-start 1
```

### 3) Feature development: Add a feature to an existing project

From this toolkit directory:

- `/feature-spec <project-path>/features/<feature-name>`
- `/feature-technical-spec <project-path>/features/<feature-name>`
- `/feature-plan <project-path>/features/<feature-name>`

Then execute from the feature directory:

```bash
cd <project-path>/features/<feature-name>
/fresh-start
/phase-prep 1
/phase-start 1
```

## Verification Guardrails

The toolkit is designed so each task is verifiable and agents stop when uncertainty is high:

- **Spec verification** — Ensures downstream docs preserve upstream requirements and flags vague/untestable language.
- **TDD enforcement** — `/verify-task` checks tests exist for criteria and (when possible) whether tests were written first.
- **Security scanning** — Dependency audit + secrets detection + basic insecure-pattern checks (typically at phase checkpoints).
- **Stuck detection** — Agents pause and escalate on repeated failures/loops.

## Repository Layout

```
ai_coding_project_base/
├── .claude/
│   ├── commands/                  # Slash commands (Claude Code)
│   └── skills/                    # Skills (verification/security/etc.)
├── FEATURE_PROMPTS/               # Feature workflow prompt templates
├── docs/                          # Static docs assets
├── deprecated/                    # Legacy/reference-only prompts
├── PRODUCT_SPEC_PROMPT.md
├── TECHNICAL_SPEC_PROMPT.md
├── GENERATOR_PROMPT.md
├── START_PROMPTS.md
├── TODOS.md
└── AGENTS.md                      # How agents should work in this toolkit repo
```

## Working on This Repo

- See `AGENTS.md` for contribution workflow rules for agents operating inside this toolkit.
- Run `npm run lint` to validate Markdown formatting.

## Notes on Using Web LLM Interfaces

You can use a web UI (Claude/ChatGPT) to iterate on specs, then bring final markdown into your project directory and continue planning/execution in Claude Code where file access and verification workflows are strongest.

## License

MIT
