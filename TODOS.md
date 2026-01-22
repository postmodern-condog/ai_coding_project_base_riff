# TODO

## In Progress

- [x] **[P0 / High]** Deep audit of automation verification — ensure all components needed for human-free verification are present (see below) — DONE (84292a8)
- [ ] **[P0 / High x0.5]** Make workflow portable across CLIs/models without breaking Claude Code "clone-and-go" sharing
- [ ] **[P1 / Medium]** Verification logging and manual intervention analysis (see below)
- [ ] **[P1 / Medium]** Add optional path arguments to execution commands to reduce wrong-directory friction
- [ ] **[P1 / Medium]** Fix nested `.claude/` directories shadowing parent commands — When a
  subdirectory has `.claude/` for local settings (e.g.,
  `features/sprint5/.claude/settings.local.json`), Claude Code stops searching and doesn't
  find parent commands. Options: `/workspace` command to set up subdirs with symlinks, or
  document the workaround (`ln -s ../../.claude/commands .claude/commands`)
- [x] Persistent learnings/patterns file for cross-task context (see below) — DONE
- [x] **[P1 / Medium]** Add `/capture-learning` command for simple learnings capture (see below) — DONE
- [ ] **[P2 / Low]** Add `/quick-feat` command for very simple features (see below)
- [ ] **[P1 / Medium]** Enhance `/phase-prep` to show human prep for future phases (clarified, see below)
- [ ] **[P1 / Medium x2]** Prompt user to enable `--dangerously-skip-permissions` before `/phase-start` (see below)
- [ ] **[P1 / Medium x2]** Auto-advance steps without human intervention (see below)
- [ ] **[P2 / Low x1.5]** Investigate the need for `/bootstrap` and `/adopt` — What do these commands enable? Are they redundant or do they serve distinct use cases? Clarify their purpose and whether both are needed
- [ ] Compare web vs CLI interface for generation workflow (see below)
- [ ] Issue tracker integration (Jira, Linear, GitHub Issues)
- [ ] Intro commands for each Step — **DEFERRED** (unclear requirements, needs more thought)
- [ ] Verify that the Playwright MCP integration works
- [ ] **[P2 / Low]** Add Codex skill pack installation option to `/setup` or `/generate-plan` — Allow users to opt-in to copying the codex commands via `scripts/install-codex-skill-pack.sh` (see below)
- [ ] Git worktrees for parallel task execution (see below)
- [ ] Session logging for automation opportunity discovery (see below)
- [ ] **[P1 / High x0.5]** Parallel Agent Orchestration (see below)
- [ ] **[P2 / Medium]** Spec Diffing and Plan Regeneration (see below)
- [ ] **[P2 / Medium x0.6]** Human Review Queue (see below)
- [ ] **[P1 / Medium]** Structure phase-checkpoint to verify local before production (clarified, see below)
- [x] **[P1 / Medium]** Deferred Requirements Capture — Auto-capture "v2" and "out of scope" items during spec generation (clarified, see below) — DONE
- [x] **[P1 / Medium]** Create `/gh-init` command with local git init and auto-detection (clarified, see below) — DONE
- [ ] **[P1 / Medium]** Enhance `/phase-prep` with detailed setup instructions — Research docs and provide step-by-step guidance for Pre-Phase Setup items (see below)
- [x] Add `/list-todos` command (see below) — DONE
- [x] Recovery & Rollback Commands — DONE (phase-rollback, task-retry, phase-analyze)
- [x] **[P1 / Medium]** Pre-push hook to check if README/docs need updating — Before every push, analyze recent commits and prompt if documentation appears outdated relative to code/command changes — DONE

## Future Concepts

### Auto-Advance Steps Without Human Intervention

Automatically proceed through the workflow when all prerequisites are met, reducing manual command entry.

**Clarifications (from Q&A 2026-01-22):**
- **Default behavior**: Auto-advance ON by default; use `--pause` flag to disable
- **Delay**: 15-second countdown before auto-advancing
- **UX**: Show countdown with interrupt hint: "Auto-advancing in 15s... (press Enter to pause)"
- **Trigger condition**: ONLY auto-advance when everything is green (all automated checks pass, no human tasks required)
- **Stop conditions**: If ANY human intervention required (incomplete prep items, manual verification items), stop and wait
- **Configuration**: Configurable in `.claude/settings.local.json`:
  ```json
  {
    "autoAdvance": {
      "enabled": true,
      "delaySeconds": 15
    }
  }
  ```

**Command boundaries where auto-advance applies:**

| After... | If all green... | Auto-start... |
|----------|-----------------|---------------|
| `/phase-checkpoint N` | All criteria verified, no manual items | `/phase-prep N+1` |
| `/phase-prep N+1` | All setup complete, no human tasks | `/phase-start N+1` |

**What does NOT auto-advance:**
- `/phase-prep` with incomplete human setup items (e.g., "Create Stripe account")
- `/phase-checkpoint` with unverifiable manual items
- Any step that encounters errors or failures

**Session report when auto-advance stops:**
- When the auto-advance sequence eventually stops (due to human intervention required, error, or final phase complete), generate a summary report
- Report includes:
  - Every command executed during the auto-advance session
  - Outcome of each command (success, failure, manual items found)
  - Total phases/steps completed
  - Reason for stopping
  - Any items now requiring human attention
- Format example:
  ```
  AUTO-ADVANCE SESSION COMPLETE
  =============================

  Commands executed:
  1. /phase-checkpoint 1 → ✓ All criteria passed
  2. /phase-prep 2 → ✓ All setup complete
  3. /phase-start 2 → ✓ All tasks completed
  4. /phase-checkpoint 2 → ⚠ Manual verification required

  Summary:
  - Phases completed: 1 (Phase 2)
  - Steps completed: 4
  - Duration: 12m 34s
  - Stopped: Manual verification items detected

  Requires attention:
  - [ ] Verify payment flow works end-to-end (localhost:3000/checkout)
  - [ ] Confirm email notifications received
  ```

**Implementation approach:**
1. Add `autoAdvance` config parsing to settings loader
2. Modify `/phase-checkpoint` to check next phase readiness on success
3. Add 15s countdown with stdin interrupt detection
4. Modify `/phase-prep` to auto-trigger `/phase-start` when all green
5. Add `--pause` flag to both commands to override
6. Track commands executed during auto-advance session
7. Generate summary report when sequence stops

---

### Prompt for `--dangerously-skip-permissions` Before `/phase-start`

Detect permission mode and suggest switching to dangerous mode for uninterrupted autonomous execution.

**Clarifications (from Q&A 2026-01-22):**
- **Prompt timing**: Once per project, on first `/phase-start`
- **Storage**: Remember choice in `.claude/settings.local.json`
- **On accept**: Enable dangerous mode, don't prompt again
- **On decline**: Remember preference, proceed with normal permissions, never re-prompt
- **Reset**: Users can manually edit `.claude/settings.local.json` to change preference (document this)

**Proposed UX:**

```
PERMISSION MODE CHECK
=====================

For autonomous phase execution, Claude Code works best with
`--dangerously-skip-permissions` enabled. This allows:
- Uninterrupted task execution
- Automatic file creation and modification
- Running build/test commands without prompts

⚠️  This grants Claude broad access to your project directory.
   Only enable if you trust the execution plan.

Enable dangerous mode for this project?
[Yes, enable] [No, keep prompts]
```

**Settings format:**
```json
{
  "permissionMode": {
    "prompted": true,
    "dangerous": true  // or false if declined
  }
}
```

**Implementation approach:**
1. At start of `/phase-start`, check if `permissionMode.prompted` exists in settings
2. If not prompted yet, show the permission mode prompt
3. Store user's choice in `.claude/settings.local.json`
4. If dangerous mode enabled, remind user how Claude Code was started (may need restart with flag)
5. Document manual reset in README or `/help` output

---

### Verification Logging and Manual Intervention Analysis

Track and analyze manual verification interventions to identify optimization opportunities.

**Clarifications (from Q&A 2026-01-17):**
- **Log location**: Per-project logs (each project has its own log file, no central dependency)
- **Time tracking**: Optional time input after each manual check (prompt but allow skipping)
- **Pre-categorization**: Both - generate hints at plan generation time (AUTOMATABLE vs HUMAN_REQUIRED), but allow reclassification during execution based on available tools
- **Actionable recommendations**: Auto-create TODOS.md entries for high-impact automation opportunities with details

**Problem:**
- No visibility into how much time is spent on manual verification
- No data on which types of manual checks recur across projects
- Can't prioritize automation efforts without understanding the manual burden
- No feedback loop from execution experience back to spec generation

**Goals:**
1. Log every manual verification intervention with context (project, phase, type, item)
2. Categorize interventions: truly-human-required vs. automatable-with-tools
3. Aggregate data across projects to identify patterns
4. Generate reports showing highest-impact automation opportunities
5. Feed insights back into GENERATOR_PROMPT.md to reduce non-automatable criteria

**Key Questions:**
- Where should logs live? Per-project or centralized in orchestrator?
- How to capture time spent without adding friction?
- Should checkpoint items be pre-categorized at generation time?
- How to surface actionable recommendations (not just reports)?

**Related to:** Deep Audit of Automation Verification, Orchestrator `/verification-report`

---

### Deferred Requirements Capture

Automatically capture requirements marked as "v2", "out of scope", or "future" during spec generation so they don't get lost.

**Clarifications (from Q&A 2026-01-22):**
- **File scope**: Project-wide single DEFERRED.md at project root
- **Estimates**: No priority/effort estimates at deferral time; estimate later when planning v2
- **Duplicates**: List each occurrence with source spec (don't dedupe; useful for seeing patterns)

**Problem:**
- During PRODUCT_SPEC and TECHNICAL_SPEC Q&A, many good ideas get deferred to "v2" or marked "out of scope for MVP"
- These decisions are captured in the spec documents but scattered across sections
- When it's time to plan v2, there's no consolidated list of what was intentionally deferred
- Some deferred items may be forgotten entirely if not in a searchable location

**Proposed Solution:**

Create a `DEFERRED.md` file that gets auto-populated during spec generation:

```markdown
# Deferred Requirements

> Auto-generated during specification. Items marked for future versions or explicitly descoped.

## From PRODUCT_SPEC.md (2026-01-20)

| Requirement | Reason Deferred | Original Section |
|-------------|-----------------|------------------|
| Social sharing | Out of scope for MVP | User Features |
| Mobile app | V2 - focus on web first | Platform Support |
| Multi-tenancy | Enterprise feature | Architecture |

## From TECHNICAL_SPEC.md (2026-01-20)

| Requirement | Reason Deferred | Original Section |
|-------------|-----------------|------------------|
| GraphQL API | REST sufficient for MVP | API Design |
| Redis caching | Premature optimization | Performance |
```

**Implementation approach:**

1. **Update spec prompts** — Add instruction to identify and tag deferred items during Q&A
2. **Auto-extract on save** — After PRODUCT_SPEC.md or TECHNICAL_SPEC.md is written, parse for deferred patterns:
   - "out of scope"
   - "v2" / "version 2" / "future version"
   - "deferred"
   - "not in MVP"
   - "later" / "future"
3. **Create/append DEFERRED.md** — Consolidate findings with source attribution
4. **Link from TODOS.md** — Reference DEFERRED.md for v2 planning
5. **`/plan-v2` command** — When ready, generate execution plan from DEFERRED.md items

**Integration points:**
- `/product-spec` — Extract deferred items after document generation
- `/technical-spec` — Extract deferred items after document generation
- `/feature-spec` — Extract deferred items (append to existing DEFERRED.md)
- `/bootstrap` — Should also scan for deferred patterns in existing docs

**Questions to answer:**
- Should deferred items have priority/effort estimates captured at deferral time?
- How to handle conflicts when same item is deferred in multiple specs?
- Should DEFERRED.md be per-feature or project-wide?

---

### Deep Audit of Automation Verification

Comprehensive review of the toolkit's verification system to ensure fully autonomous operation without human intervention.

**Clarifications (from Q&A 2026-01-17):**
- **Priority approach**: Work on acceptance criteria patterns AND browser/UI verification in parallel for faster overall progress
- **Scope**: Full audit covering all 8 areas documented (not a minimal MVP pass)

**Problem:**
- The orchestrator revealed that progress tracking has gaps
- Verification results aren't always persisted
- Some checks require human judgment that could be codified
- No guarantee that all acceptance criteria are machine-verifiable

**Audit Scope:**

1. **Acceptance Criteria Auditability**
   - Can every acceptance criterion type be verified automatically?
   - What criteria patterns require human judgment?
   - Should GENERATOR_PROMPT.md enforce "machine-verifiable" criteria only?
   - Categorize criteria types: CODE (file exists, exports), TEST (passes), LINT, TYPE, BUILD, BROWSER, MANUAL

2. **Verification Tool Coverage**
   - What verification tools exist? (tests, type-check, lint, security scan)
   - What's missing? (visual regression, accessibility, performance)
   - For each criterion type, what tool verifies it?
   - Gap analysis: criteria types with no automated verification

3. **State Persistence Completeness**
   - Does every verification result get persisted to phase-state.json?
   - Are verification timestamps recorded?
   - Is there an audit trail of what was verified and when?
   - Can the orchestrator reconstruct verification history?

4. **Pre-Phase Setup Verification**
   - Can pre-phase requirements (env vars, services) be verified automatically?
   - What checks can confirm environment is ready?
   - Should `/phase-prep` block if requirements aren't met?

5. **Checkpoint Automation**
   - Which "Manual Verification" items could be automated?
   - What MCP tools (Playwright, etc.) would enable automation?
   - Should checkpoints fail-closed if manual items can't be verified?

6. **Browser/UI Verification**
   - Is Playwright MCP integration complete and tested?
   - What UI acceptance criteria patterns are supported?
   - Visual regression testing: is it integrated?
   - **Tool Comparison:** Evaluate and compare browser automation options:
     | Tool | Type | Strengths | Weaknesses | Use Case |
     |------|------|-----------|------------|----------|
     | Chrome DevTools MCP | MCP server | Already integrated, direct CDP access | Chrome-only, requires running browser | Real-time interaction, debugging |
     | Claude for Chrome | Browser extension | User's actual browser context | Requires manual browser, not headless | Manual verification assistance |
     | Puppeteer | Node library | Mature, well-documented, headless | Requires custom scripting, Chrome-focused | Automated test suites |
     | Playwright MCP | MCP server | Multi-browser, modern API, headless | Separate MCP server to configure | Cross-browser automated verification |
   - Questions to answer:
     - Which tool best fits autonomous verification (no human browser needed)?
     - Can multiple tools complement each other (e.g., Playwright for CI, DevTools for interactive)?
     - What's the setup complexity vs. verification capability trade-off?
     - Should the toolkit recommend a primary tool or support multiple?

7. **Test Quality Verification**
   - Is TDD compliance actually enforced or just reported?
   - Can we verify tests are meaningful (not just "no errors")?
   - Should failing TDD compliance block task completion?

8. **Blocker Detection & Resolution**
   - Are all blocker types detectable automatically?
   - Can some blockers be resolved without human intervention?
   - What's the escalation path for truly-human-required blockers?

**Deliverables:**

1. **Gap Analysis Document** — What can't be verified automatically today
2. **Verification Matrix** — Criterion type → verification tool → automation status
3. **Recommended Enhancements** — Prioritized list of improvements
4. **GENERATOR_PROMPT.md Updates** — Enforce verifiable criteria patterns
5. **New Commands/Skills** — Fill verification gaps

**Success Criteria:**
- Every acceptance criterion in EXECUTION_PLAN.md has an automated verification path
- `/phase-checkpoint` can run fully unattended (or explicitly flags what needs human)
- Orchestrator can determine project health without parsing conversations
- Clear separation between "automation-ready" and "human-required" verification

### Portable Workflow Kit (Adapters + Model Router)

Create a single source of truth for skills/prompts/commands/rules while supporting multiple “hosts” (e.g. Claude Code today, other CLIs later) and swappable models/providers.

**Key requirement:** Preserve the current Claude Code experience for sharing (no mandatory build step; keep repo root layout as-is), with portability features as optional “sidecar” adapters.

**Proposed approach:**
- Define tool-agnostic workflow assets (skills, slash command specs, prompt templates, policies)
- Add thin host adapters that render/mount those assets into each host’s required format/layout
- Add a capability-based model router config (task type → required capabilities → preferred model list) so models/providers can be swapped without rewriting skills/prompts
- Add a drift guard (CI or pre-commit) only if adapter outputs are generated/committed

### Persistent Learnings/Patterns File

Address the context limitation where learning from task N doesn't transfer to task N+1 due to fresh context per task.

**Problem:**
- AI agents start each task with fresh context (by design, to avoid stale state)
- But this means patterns discovered in Task 1.1.A are forgotten by Task 1.2.A
- Research shows "Memory Bank files" improve AI coding outcomes (Made by Agents 2025)

**Proposed Solution:**

Create a `LEARNINGS.md` file that agents update as they discover project patterns:

```markdown
# Discovered Patterns

> Auto-updated by AI agents during task execution.
> Read this file at the start of each task.

## Error Handling
- Use `Result<T, Error>` pattern, not try/catch (Task 1.2.A)
- All API errors return `{ error: { code, message } }` shape (Task 2.1.A)

## Testing
- Mock auth using `createMockUser()` from test-utils (Task 1.3.B)
- Use `vi.mock()` not `jest.mock()` — this is a Vitest project (Task 1.1.A)

## Conventions
- API endpoints return `{ data, error, meta }` shape (Task 2.1.A)
- Use `snake_case` for DB columns, `camelCase` for JS (Task 1.4.A)

## Gotchas
- `user.permissions` is lazy-loaded, always await it (Task 2.3.B)
- The `config` module has side effects on import (Task 1.5.A)
```

**Implementation approach:**

1. Add `LEARNINGS.md` to `/fresh-start` context loading
2. Update task execution protocol to:
   - Read LEARNINGS.md before starting
   - Append new discoveries to LEARNINGS.md after task completion
3. Define what qualifies as a "learning":
   - Non-obvious patterns that differ from common defaults
   - Project-specific conventions
   - Gotchas that caused debugging time
4. Keep file under ~100 lines (summarize/dedupe periodically)

**Questions to answer:**
- Should this be auto-generated or human-curated?
- How to prevent the file from growing unbounded?
- Should learnings be categorized by phase or topic?

### `/capture-learning` Command (Simple Learnings Capture)

A lightweight alternative to a full "compound documentation" system — a simple command to append learnings to a structured file.

**Inspiration:** compound-engineering-plugin's `/workflows:compound` command, but stripped down to essentials.

**Problem:**
- VISION.md explicitly calls for "capture deferred items, TODOs, and other important learnings"
- Full "knowledge compounding" systems are complex (YAML frontmatter, cross-references, pattern promotion)
- Most projects just need a simple way to jot down what was learned

**Proposed Implementation:**

**Command:** `/capture-learning`

**Behavior:**
1. Prompt for learning content (or accept inline: `/capture-learning "Use vi.mock not jest.mock"`)
2. Prompt for category (optional): Error Handling, Testing, Conventions, Gotchas, Performance
3. Append to `LEARNINGS.md` with timestamp and current task context

**Output format in LEARNINGS.md:**
```markdown
# Discovered Patterns

> Append-only learnings file. Read at task start.

## Testing
- Use `vi.mock()` not `jest.mock()` — this is a Vitest project (2026-01-22, Task 1.1.A)
- Mock auth using `createMockUser()` from test-utils (2026-01-22, Task 1.3.B)

## Gotchas
- `user.permissions` is lazy-loaded, always await it (2026-01-22, Task 2.3.B)
```

**Integration:**
- `/fresh-start` loads LEARNINGS.md into context
- `/phase-start` reminds agent to check LEARNINGS.md
- `/phase-checkpoint` prompts: "Any learnings to capture from this phase?"

**Simplicity constraints:**
- No YAML frontmatter
- No cross-references or "related issues"
- No "promotion to required reading"
- Just structured markdown with timestamps

**Files to create:**
- `.claude/commands/capture-learning.md`

---

### `/quick-feat` Command for Simple Features

A streamlined version of `/feature-spec` for very simple features that don't warrant full specification ceremony.

**Problem:**
- `/feature-spec` is designed for substantial features requiring detailed specification
- For simple features ("add a logout button", "show user avatar in header"), full spec is overkill
- But skipping specs entirely loses the benefits of planning

**Proposed Implementation:**

**Command:** `/quick-feat <description>`

**Example:**
```bash
/quick-feat "Add logout button to navbar"
```

**Behavior:**
1. Ask 2-3 clarifying questions max (not the full spec Q&A)
2. Generate a minimal plan inline (not a separate EXECUTION_PLAN.md)
3. Execute immediately with verification
4. Commit with conventional commit message

**Output:**
```
QUICK FEATURE: Add logout button to navbar

Clarifications:
- Location: Right side of navbar, after user name
- Behavior: Call /api/auth/logout, redirect to /login
- Style: Match existing navbar buttons

Plan:
1. Add LogoutButton component
2. Wire to auth API
3. Add to Navbar component

Executing...
✓ Created src/components/LogoutButton.tsx
✓ Added to Navbar.tsx
✓ Verified: Button renders, logout API called on click

Committed: feat(auth): add logout button to navbar
```

**Guardrails:**
- If feature touches >3 files, suggest `/feature-spec` instead
- If clarification reveals complexity, escalate to full spec
- Still runs verification (just inline, not phase-checkpoint)

**Use cases:**
- UI tweaks
- Single-endpoint additions
- Configuration changes
- Bug fixes that are really small features

**Files to create:**
- `.claude/commands/quick-feat.md`

---

### Enhanced `/phase-prep` with Future Phase Preview

Add a second section to `/phase-prep` output showing human prep requirements for future phases, allowing users to front-load setup work.

**Clarifications (from Q&A 2026-01-22):**
- **Detail level**: Human items only (accounts, API keys, manual setup tasks)
- **Scope**: All remaining phases (not limited)
- **Default behavior**: Always show future preview (no flag needed)

**Problem:**
- `/phase-prep N` only shows prep for phase N
- Users often want to knock out all manual setup at once (create all accounts, get all API keys)
- Currently must run `/phase-prep` for each phase to see what's needed
- Discovering a Phase 3 blocker mid-project is frustrating

**Proposed Enhancement:**

Update `/phase-prep` output format:

```
PHASE 2 PREP
============

## Current Phase Requirements

Pre-Phase Setup:
- [x] Database migrations run
- [ ] Stripe API keys in .env

Human Tasks:
- [ ] Create Stripe test account at https://dashboard.stripe.com

## Future Phase Preview

### Phase 3: Notifications
Human Setup Required:
- Create SendGrid account
- Configure SMTP credentials

### Phase 4: Deployment
Human Setup Required:
- Create Vercel project
- Configure production database
- Set up domain DNS

---
TIP: Complete future setup now to avoid blockers later.
Run `/phase-prep 3` for detailed Phase 3 instructions.
```

**Implementation:**
1. Parse EXECUTION_PLAN.md for all phases
2. Extract "Pre-Phase Setup" and human-required items from each
3. Display current phase in detail
4. Display future phases in summary (just the human items, not full instructions)
5. Offer to show detailed instructions for any future phase

**Benefits:**
- Users can batch all account creation / credential gathering
- Reduces mid-project interruptions
- Surfaces potential blockers early
- Matches how experienced developers front-load admin work

**Files to modify:**
- `.claude/commands/phase-prep.md`

---

### `/list-todos` Command

Add a command that reads TODOS.md and produces an AI-analyzed prioritized list.

**Command:** `/list-todos`

**Input:** Reads `TODOS.md` from project root

**Output:** For each TODO item, produce:

```markdown
## 1. {TODO Title}

**Priority Score:** {1-10}
**Ranking Factors:**
- Requirements Clarity: {Low|Medium|High} — {brief explanation}
- Ease of Implementation: {Low|Medium|High} — {brief explanation}
- Value to Project: {Low|Medium|High} — {brief explanation}

**Implementation Notes:**
{AI's assessment of how to implement this item, key steps, estimated complexity}

**Open Questions:**
- {Question that, if answered, would improve requirements clarity}
- {Another question}

**Suggested Next Action:** {What to do next: clarify requirements, implement, defer, or remove}

---
```

**Sorting:** Items sorted by priority score (highest first), with ties broken by value to project.

**Use cases:**
- Sprint planning: Which TODOs to tackle next
- Backlog grooming: Identify items needing clarification
- Scope decisions: See effort vs value trade-offs

**Implementation approach:**
1. Create `.claude/commands/list-todos.md`
2. Command reads TODOS.md
3. For each item, AI analyzes based on project context (reads specs, codebase)
4. Outputs prioritized markdown list

### Codex Skill Pack Installation Option

Add a configuration step to `/setup` or `/generate-plan` that offers to install the Codex skill pack for users who also use OpenAI's Codex CLI.

**Problem:**
- The toolkit includes a `codex/skills/` directory with skills adapted for Codex CLI
- Users who use both Claude Code and Codex CLI must manually run `scripts/install-codex-skill-pack.sh`
- No discoverability of this feature during project setup

**Proposed Solution:**

Add an optional prompt during `/setup` or `/generate-plan`:

```
Do you also use OpenAI Codex CLI? (y/N)
→ y

Installing Codex skill pack to ~/.codex/skills...
  - Installed: code-verification
  - Installed: security-scan
  - ...
Done. Restart Codex CLI to pick up new skills.
```

**Implementation options:**

1. **Add to `/setup`** (recommended)
   - Prompt during initial project setup
   - Only runs once per project
   - Fits naturally in "configure your environment" flow

2. **Add to `/generate-plan`**
   - Prompt after plan generation
   - Could be re-run when adding new features
   - Less intuitive location

**Script details (`scripts/install-codex-skill-pack.sh`):**
- Copies skills from `codex/skills/` to `$CODEX_HOME/skills` (default: `~/.codex/skills`)
- Supports `--method symlink` for development (auto-updates)
- Supports `--force` to overwrite existing skills
- Supports custom `--dest` for non-standard Codex installations

**Clarifications (from Q&A 2026-01-22):**
- **Detection**: Auto-detect if `codex` command is in PATH before prompting — don't confuse users who don't use Codex
- **Scope**: Global install (once per machine) — skills installed to `~/.codex/skills`, available to all projects
- **Method**: Use symlinks — auto-updates when toolkit updates, best for development
- **Skill updates**: Symlinks handle this automatically — document that `git pull` on toolkit auto-updates Codex skills (no extra tooling needed)

**Implementation approach:**
1. In `/setup`, check if `which codex` succeeds (or `command -v codex`)
2. If Codex detected, prompt: "Codex CLI detected. Install toolkit skills? [Yes/No]"
3. If yes, run `scripts/install-codex-skill-pack.sh --method symlink`
4. Track in `.claude/settings.local.json` that this was done (don't re-prompt)
5. Document in README: "Codex skills auto-update when you `git pull` the toolkit"

---

### Subagents (Claude Code only)

Add pre-built subagents in `.claude/agents/` for specialized tasks with isolated context:

| Subagent | Purpose | Tools |
|----------|---------|-------|
| `code-reviewer.md` | Review code and report issues (read-only) | Read, Grep, Glob |
| `security-auditor.md` | Scan for vulnerabilities | Read, Grep, Glob, Bash |
| `test-writer.md` | Generate tests for a file | Read, Write, Edit, Bash |
| `doc-generator.md` | Generate documentation | Read, Write, Glob |

**Why subagents instead of skills:**
- Context isolation — work doesn't pollute main agent's context
- Parallel execution — multiple subagents can work simultaneously
- Different tool permissions — e.g., read-only reviewer vs writer
- Self-contained tasks — returns result and is done

### GitHub Actions Integration

Add `.github/workflows/claude-review.yml` for automated CI/CD:

**Capabilities:**
- Automatic PR review against AGENTS.md standards
- Verify acceptance criteria from EXECUTION_PLAN.md
- Security scanning on pull requests
- Interactive mode responding to @claude mentions
- Scheduled maintenance (weekly audits, dependency checks)

**Setup:** Run `/install-github-app` in Claude Code terminal

**Example workflow:**
```yaml
name: Claude PR Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v5
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Review this PR against @AGENTS.md standards.
            Check acceptance criteria in @EXECUTION_PLAN.md.
            Post findings as PR comments.
```

### Manual Testing: Web vs CLI Generation Workflow

Compare the quality and experience of generating specification documents via web interfaces vs Claude Code slash commands.

**Test matrix:**

| Document | Web Interface | Claude Code | Notes |
|----------|---------------|-------------|-------|
| PRODUCT_SPEC.md | [ ] Claude web | [ ] `/product-spec` | Greenfield project |
| PRODUCT_SPEC.md | [ ] ChatGPT | [ ] `/product-spec` | Same idea, different LLM |
| TECHNICAL_SPEC.md | [ ] Claude web | [ ] `/technical-spec` | Feed same PRODUCT_SPEC |
| FEATURE_SPEC.md | [ ] Claude web | [ ] `/feature-spec` | Existing codebase context |

**Evaluation criteria:**

1. **Research depth** — Did web search add meaningful insights (competitors, best practices)?
2. **Recommendation quality** — Were confidence levels and reasoning better?
3. **Document completeness** — Any gaps in the output structure?
4. **Iteration experience** — How easy was it to refine sections?
5. **Time to completion** — Total time including copy/paste overhead for web
6. **Workflow friction** — Manual steps required to continue in Claude Code

**Test procedure:**

1. Pick a non-trivial app idea (e.g., "invoice management for freelancers")
2. Run through generation with both interfaces using identical initial descriptions
3. Save outputs side-by-side for comparison
4. Continue both through `/technical-spec` and `/generate-plan` in Claude Code
5. Note any issues with web-generated specs when consumed by later stages

**Questions to answer:**

- Does the hybrid workflow (web spec → CLI execution) work smoothly?
- Are there formatting or structure issues when web output is consumed by `/technical-spec`?
- Is the quality delta worth the workflow friction?
- Should we recommend web for product specs but CLI for technical specs?

### Issue Tracker Integration

Add optional integration with issue trackers (Jira, Linear, GitHub Issues) to link work to tickets and automate status updates.

**Research findings:**
- 40% fewer manual update errors with automated integrations
- 30% faster sprint cycles when AI-to-PR flows are automated
- Reduces context switching between tools

**Proposed implementation:**

1. **Optional `--issue` flag on `/phase-start`:**
   ```bash
   /phase-start 1 --issue PROJ-123
   ```

   Behavior:
   - Creates branch with issue ID: `phase-1-PROJ-123`
   - Includes issue reference in commit messages: `task(1.1.A): Add login [PROJ-123]`
   - Comments on issue when phase starts
   - Updates issue status on `/phase-checkpoint` completion

2. **Issue linking in EXECUTION_PLAN.md:**
   ```markdown
   ## Phase 1: Authentication
   **Issue:** PROJ-123

   ### Step 1.1: Login Form
   **Issue:** PROJ-124 (sub-task)
   ```

3. **Supported integrations (priority order):**

   | Platform | CLI Tool | Status Update API |
   |----------|----------|-------------------|
   | GitHub Issues | `gh issue` | gh api |
   | Linear | `linear` CLI | GraphQL API |
   | Jira | `jira` CLI | REST API |

4. **Configuration in AGENTS.md:**
   ```markdown
   ## Issue Tracking (Optional)

   **Platform:** GitHub Issues | Linear | Jira
   **Project:** {project key or repo}
   **Auto-update:** true | false
   ```

**Questions to answer:**
- Should issue linking be per-phase or per-task?
- How to handle offline/disconnected scenarios?
- Should we auto-create sub-issues for tasks?

### Git Worktrees for Parallel Task Execution

Enable parallel execution of independent tasks within a step using git worktrees.

**Context:**
- The GENERATOR_PROMPT.md already considers parallelizability when breaking out tasks within steps
- Tasks within a step that have no dependencies on each other could theoretically run simultaneously
- Git worktrees allow multiple branches/working directories checked out at once

**Concept:**
```
step-1.1/
├── task-1.1.A (worktree 1) ── Agent 1 working
├── task-1.1.B (worktree 2) ── Agent 2 working (parallel, no dependency on A)
└── task-1.1.C (waiting)    ── Depends on A, must wait
```

**Research Findings (January 2026):**

#### Orchestration Options

| Approach | Max Concurrency | Isolation | Complexity |
|----------|-----------------|-----------|------------|
| Task Tool | 10 subagents | Shared filesystem | Low |
| Git worktrees | Unlimited | Full directory isolation | Medium |
| Docker containers | Unlimited | Full process isolation | High |

**Task Tool (Recommended for most cases):**
- Supports up to 10 concurrent subagents via `subagent_type` parameter
- Subagents share filesystem but have isolated context
- Good for tasks that don't touch the same files
- Example: Running tests while generating docs

**Git Worktrees (For file-conflict-prone tasks):**
- Each worktree is a separate checkout of the repo
- Full isolation — parallel agents can modify same files
- Requires merge step at the end
- Commands: `git worktree add`, `git worktree remove`

**Conflict Prevention Strategies:**

1. **Static analysis before parallel execution:**
   - Parse task file lists from EXECUTION_PLAN.md
   - Flag overlapping files as sequential-only
   - Only parallelize tasks with disjoint file sets

2. **File locking (simpler):**
   - First agent to touch a file "claims" it
   - Other agents wait or skip conflicting tasks

3. **Optimistic with merge (git worktrees):**
   - Run all tasks in parallel
   - Merge worktrees at step completion
   - Human resolves any conflicts

#### Recommended Implementation

**Phase 1: Task Tool parallelism (no worktrees)**
- Parse EXECUTION_PLAN.md for tasks marked `parallel: true`
- Spawn up to 10 subagents via Task Tool
- Wait for all to complete before next step
- Works today with no git changes

**Phase 2: Git worktrees (optional, for heavy parallelism)**
- Add `/parallel-step` command
- Creates worktree per parallel task
- Merges all worktrees on step completion
- Handles conflicts with human escalation

**Open questions (answered):**
- ~~What orchestrator mechanism?~~ → Task Tool for simple cases, worktrees for isolation
- ~~How to detect/prevent conflicts?~~ → Static file list analysis from EXECUTION_PLAN.md
- ~~Is complexity worth it?~~ → Task Tool parallelism is low-complexity; start there
- ~~How does this interact with phase-branch model?~~ → Worktrees branch off phase branch, merge back

**Remaining work:**
1. Add `parallel: true/false` flag to EXECUTION_PLAN.md task format
2. Update GENERATOR_PROMPT.md to emit parallel flags
3. Create `/parallel-step` command using Task Tool
4. (Optional) Add git worktree support for full isolation

### Session Logging for Automation Opportunity Discovery

Capture session summaries to identify manual steps and patterns that could be automated with new skills or slash commands.

**Problem:**
- We don't have visibility into what manual interventions happen during sessions
- Patterns that repeat across sessions are candidates for automation
- No feedback loop from usage → improvements

**Proposed Solution:**

Use Claude Code's `SessionEnd` hook to log session data, then analyze logs to find automation opportunities.

**Implementation approach:**

1. **Create `SessionEnd` hook** (`.claude/hooks/session-end.sh`):
   ```bash
   #!/bin/bash
   # Receives JSON via stdin: {session_id, transcript_path, cwd, hook_event_name}
   SESSION_DATA=$(cat)
   SESSION_ID=$(echo "$SESSION_DATA" | jq -r '.session_id')
   TRANSCRIPT_PATH=$(echo "$SESSION_DATA" | jq -r '.transcript_path')

   mkdir -p "${CLAUDE_PROJECT_DIR}/.claude/logs"

   # Extract patterns from transcript
   # - Tasks completed (TodoWrite calls)
   # - Questions asked (AskUserQuestion calls)
   # - Manual verifications mentioned
   # - Errors encountered

   cat >> "${CLAUDE_PROJECT_DIR}/.claude/logs/sessions.jsonl" << EOF
   {"session_id": "$SESSION_ID", "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)", ...}
   EOF
   ```

2. **Configure hook in `.claude/settings.json`:**
   ```json
   {
     "hooks": {
       "SessionEnd": {
         "type": "command",
         "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/session-end.sh\"",
         "timeout": 30000
       }
     }
   }
   ```

3. **Create `/session-notes` skill** for manual context:
   - Prompts user/agent to summarize what was done
   - Captures info the hook can't extract (e.g., "had to manually restart the dev server")
   - Appends to `.claude/logs/session-notes.jsonl`

4. **Create `/analyze-sessions` skill** for pattern analysis:
   - Reads `.claude/logs/sessions.jsonl`
   - Identifies: repeated manual steps, common blockers, frequent questions
   - Outputs: "Automation opportunities" report

5. **Propagate to generated projects:**
   - Update `/setup` to copy hook configuration
   - Both this toolkit repo and generated projects get logging
   - Central aggregation possible (optional)

**What to capture:**

| Data Point | Source | Automation Signal |
|------------|--------|-------------------|
| Tasks completed | TodoWrite tool calls | Which task types are common |
| Questions asked | AskUserQuestion calls | Ambiguous requirements to clarify in specs |
| Manual verifications | Transcript text parsing | Steps to add to phase-checkpoint |
| Errors/blockers | Transcript text parsing | Common issues to add to LEARNINGS.md |
| Tool usage patterns | Tool call frequency | Workflow optimizations |

**Two deployment contexts:**

1. **This toolkit repo** — Track generation/development sessions
2. **Generated projects** — Track execution sessions (copy hook during `/setup`)

**Feedback loop:**

```
Sessions → Logs → /analyze-sessions → New skills/commands → Better sessions
```

**Questions to answer:**
- How much can we extract automatically vs needing manual `/session-notes`?
- Should logs be per-project or aggregated centrally?
- Privacy considerations for transcript data?
- How often to run `/analyze-sessions`? Weekly? Per-phase?

**Resources:**
- [Claude Code Hooks documentation](https://code.claude.com/docs/en/hooks)
- `SessionEnd` hook receives: `session_id`, `transcript_path`, `cwd`, `permission_mode`
- Hooks run with 60s timeout (configurable)

### Parallel Agent Orchestration

Enable parallel execution of independent tasks to dramatically speed up phase completion.

**Context:**
- Boris Cherny (Claude Code creator) runs 5-10 Claude instances simultaneously
- The EXECUTION_PLAN.md already marks tasks within steps as potentially parallelizable
- Current workflow executes tasks sequentially even when independent

**Proposed Implementation:**

1. **`/phase-start-parallel N`** command:
   - Parse EXECUTION_PLAN.md to identify independent tasks within each step
   - Spawn parallel Claude instances via Task tool (up to 10 subagents)
   - Each agent works in isolation on its assigned task
   - Orchestrator waits for all tasks in step to complete before proceeding
   - Merge results and handle any conflicts

2. **Parallelization detection:**
   - Tasks with `Depends On: None` or only depending on prior steps = parallelizable
   - Tasks depending on other tasks in same step = must wait
   - Add explicit `parallel: true/false` flag to EXECUTION_PLAN.md format

3. **Conflict handling:**
   - Pre-analyze file lists from EXECUTION_PLAN.md
   - Flag overlapping files as sequential-only
   - For unavoidable conflicts: git worktrees for full isolation

**Example execution:**
```
Step 1.1 (sequential):
  Task 1.1.A → Task 1.1.B (1.1.B depends on 1.1.A)

Step 1.2 (parallel):
  ┌── Task 1.2.A (Agent 1) ──┐
  ├── Task 1.2.B (Agent 2) ──┼── Wait for all → Merge → Step 1.3
  └── Task 1.2.C (Agent 3) ──┘
```

**Benefits:**
- 2-5x speedup for phases with many independent tasks
- Matches how experienced developers parallelize work
- Utilizes available compute capacity

**Implementation phases:**
1. Add `parallel: true/false` to GENERATOR_PROMPT.md output
2. Create `/step-parallel` command using Task tool
3. Add orchestration logic for waiting and merging
4. (Optional) Git worktree support for file-conflict cases

### Spec Diffing and Plan Regeneration

Handle mid-project spec changes gracefully without losing progress.

**Problem:**
- Specs often change during development (scope changes, clarifications, pivots)
- Currently no way to see what changed or assess impact
- No way to regenerate only affected parts of EXECUTION_PLAN.md

**Proposed Commands:**

1. **`/spec-diff`** — Show what changed in specs
   ```bash
   /spec-diff                    # Diff all specs against last committed version
   /spec-diff TECHNICAL_SPEC.md  # Diff specific file
   /spec-diff --from HEAD~5      # Diff against specific commit
   ```

   Output:
   ```
   SPEC CHANGES
   ============

   TECHNICAL_SPEC.md:
   + Added: Section "Caching Layer" (new requirement)
   ~ Modified: Section "API Endpoints" (changed response format)
   - Removed: Section "Legacy Migration" (descoped)

   PRODUCT_SPEC.md:
   ~ Modified: MVP Features (removed "social sharing")
   ```

2. **`/plan-impact`** — Assess which tasks are affected by spec changes
   ```bash
   /plan-impact
   ```

   Output:
   ```
   IMPACT ANALYSIS
   ===============

   Affected by "Caching Layer" addition:
   - NEW: Need to add caching tasks (suggest Phase 2, Step 2.3)

   Affected by "API Endpoints" change:
   - Task 2.1.A: Update response format (acceptance criteria outdated)
   - Task 2.1.B: Modify client calls (depends on 2.1.A)
   - Task 3.2.A: Update tests (uses old response shape)

   Affected by "Legacy Migration" removal:
   - Task 4.1.A: Can be deleted (no longer needed)
   - Task 4.1.B: Can be deleted (no longer needed)

   Summary: 2 tasks outdated, 2 tasks deletable, 1 new area needed
   ```

3. **`/plan-regenerate`** — Regenerate affected portions of the plan
   ```bash
   /plan-regenerate --from 2       # Regenerate from Phase 2 onward
   /plan-regenerate --tasks 2.1.A,2.1.B  # Regenerate specific tasks only
   /plan-regenerate --preview      # Show what would change without applying
   ```

   Behavior:
   - Preserves completed tasks (marked `[x]`)
   - Updates outdated acceptance criteria
   - Adds new tasks for new requirements
   - Removes tasks for descoped features
   - Shows diff before applying

**Implementation approach:**
1. Store spec hashes in `.claude/spec-versions.json` for change detection
2. Create semantic diffing (not just text diff) for structured analysis
3. Map spec sections to EXECUTION_PLAN.md tasks via `Spec Reference` field
4. Integrate with GENERATOR_PROMPT.md for partial regeneration

### Structure Phase-Checkpoint: Local Before Production

Update `/phase-checkpoint` to always verify local environment first, followed by production verification.

**Clarifications (from Q&A 2026-01-22):**
- **Output format**: Two distinct sections: "## Local Verification" then "## Production Verification"
- **Order enforcement**: Local verification items always come first, production second
- **Dependencies**: If local verification fails, stop there — don't run/show production checks

**Problem:**
- Current checkpoint output may suggest production verification before local is confirmed
- Users should always verify locally before deploying/pushing to production
- Mixing local and production checks makes it unclear what to do first

**Proposed Output Structure:**

```
PHASE 2 CHECKPOINT
==================

## Local Verification

✓ Tests pass (npm test)
✓ Type check passes (npm run typecheck)
✓ Dev server starts (npm run dev)
[ ] Manual: Verify login flow works at localhost:3000

## Production Verification

(Blocked: Complete local verification first)

- [ ] Verify staging deployment
- [ ] Check production logs for errors
```

**Implementation:**
1. Categorize each acceptance criterion as LOCAL or PRODUCTION
2. Output LOCAL section first, run those checks
3. Only output/run PRODUCTION section if LOCAL passes completely
4. Update GENERATOR_PROMPT.md to tag criteria with environment

---

### Human Review Queue

Aggregate items awaiting human attention for team workflows.

**Problem:**
- Multiple agents may be working on different tasks
- Items needing human review are scattered across:
  - Blocked tasks in EXECUTION_PLAN.md
  - Items in TODOS.md
  - Checkpoint approvals pending
  - Spec ambiguities flagged
- No single view of "what needs my attention"

**Proposed Command:**

**`/review-queue`** — Show all items awaiting human action

```
REVIEW QUEUE
============

## Blocking (must resolve to continue)

1. **Task 2.1.A Blocked**
   - Issue: Missing API credentials for payment service
   - Blocked since: 2h ago
   - Action: Provide STRIPE_API_KEY in .env

2. **Phase 2 Checkpoint Pending**
   - Waiting since: 30m ago
   - Manual checks: 3 items to verify
   - Action: Run /phase-checkpoint 2

## Decisions Needed

3. **Spec Ambiguity: Authentication Method**
   - Source: Task 1.3.A
   - Options: JWT vs Session cookies
   - Flagged: TECHNICAL_SPEC.md Section 4
   - Action: Clarify preference

4. **Alternative Approach Selection**
   - Source: /task-retry 2.2.B --alternative
   - Options: 3 approaches proposed
   - Action: Choose approach to try

## Review Requested

5. **Code Review: Phase 1 Implementation**
   - Files changed: 12
   - Tests: All passing
   - Action: Review before push

## Informational

6. **TODOS.md Items: 5 pending**
   - High priority: 2
   - Action: /list-todos for details

---
Total items: 6 | Blocking: 2 | Decisions: 2 | Reviews: 1
```

**Features:**
- Aggregates from multiple sources (EXECUTION_PLAN.md, TODOS.md, git state)
- Prioritizes by urgency (blocking > decisions > reviews > info)
- Shows time waiting for each item
- Provides direct action command for each item
- Updates in real-time as items are resolved

**Integration points:**
- `/phase-start` adds blocked tasks to queue
- `/task-retry --alternative` adds decision items
- `/phase-checkpoint` adds pending reviews
- Spec verification adds ambiguity flags

**Implementation approach:**
1. Create `.claude/review-queue.json` to track pending items
2. Hook into existing commands to add/remove items
3. Build `/review-queue` command to aggregate and display
4. Add notifications when queue grows (optional)

### Create `/gh-init` Command

New command for git repository initialization with smart project detection.

**Clarifications (from Q&A 2026-01-22):**
- **Command name**: `/gh-init` (avoids overlap with existing `github-init` skill)
- **.gitignore**: Auto-detect project type (Node/Python/etc.) from existing files
- **Trigger points**: Both `/fresh-start` and `/phase-prep` should offer to run `/gh-init` when no git repo exists

**Problem:**
- `/phase-prep` or `/fresh-start` may detect that the project directory is not a git repository
- User must manually run `git init`, create `.gitignore`, make initial commit
- This is friction that could be automated with user consent

**`/gh-init` behavior:**

```
/gh-init

No git repository found. Initializing...

Detected: Node.js project (found package.json)

Creating .gitignore with:
  - node_modules/
  - dist/
  - .env*
  - .claude/settings.local.json
  ... (15 patterns total)

Running: git init
Running: git add .
Running: git commit -m "Initial commit"

✓ Git repository initialized with 1 commit.

Create GitHub remote? [Yes, public] [Yes, private] [No, done]
```

**Project type detection:**
| File Found | Project Type | .gitignore Template |
|------------|--------------|---------------------|
| package.json | Node.js | node_modules, dist, .env*, etc. |
| requirements.txt / pyproject.toml | Python | __pycache__, venv, .env*, etc. |
| Cargo.toml | Rust | target/, Cargo.lock (if lib), etc. |
| go.mod | Go | bin/, vendor/ (if used), etc. |
| (none detected) | Generic | .env*, credentials, *.pem, etc. |

**Always-included patterns (all project types):**
- `.env*`
- `**/credentials*`
- `**/*.pem`
- `.claude/settings.local.json`

**Integration with workflow commands:**
- `/fresh-start`: If no .git, offer "Would you like to initialize a git repo? Run /gh-init"
- `/phase-prep`: If no .git, show as blocking item with "Run /gh-init to resolve"

**File to create:** `.claude/commands/gh-init.md`

---

### Enhanced `/phase-prep` with Detailed Setup Instructions

When `/phase-prep` detects incomplete Pre-Phase Setup items, provide detailed step-by-step instructions instead of just listing them.

**Problem:**
- Current `/phase-prep` outputs: "Human must complete: Create Supabase project"
- User doesn't know the exact steps, what values to copy, or where to put them
- Results in context-switching to search for documentation
- Slows down project setup and introduces errors

**Proposed Enhancement:**

When Pre-Phase Setup items are incomplete, `/phase-prep` should:

1. **Read and parse each setup item** from EXECUTION_PLAN.md
2. **Research relevant documentation** (WebFetch/WebSearch as needed)
3. **Generate detailed step-by-step instructions** including:
   - Direct links to dashboards/consoles
   - Exact field values to enter
   - What to copy and where to paste it
   - Verification steps to confirm completion
4. **Output a complete guide** the user can follow sequentially

**Example transformation:**

Before (current):
```
Pre-Phase Setup:
- [ ] Create Supabase project at https://supabase.com/dashboard
- [ ] Note the project URL and anon key from Settings > API
- [ ] Create .env file with SUPABASE_URL and SUPABASE_ANON_KEY
```

After (enhanced):
```
PRE-PHASE SETUP GUIDE
=====================

## Step 1: Create Supabase Project

1. Go to https://supabase.com/dashboard
2. Sign in or create account
3. Click "New Project" (green button, top right)
4. Fill in:
   - Organization: Select or create one
   - Name: `notesbrain` (or your preference)
   - Database Password: Click "Generate" and SAVE THIS (needed later)
   - Region: Choose closest to your users
5. Click "Create new project"
6. Wait 2-3 minutes for provisioning

## Step 2: Get Credentials

1. In Supabase dashboard, click "Project Settings" (gear icon)
2. Click "API" in the left menu
3. Copy these values:
   - Project URL: `https://xxxxx.supabase.co` → SUPABASE_URL
   - anon public key: `eyJ...` → SUPABASE_ANON_KEY

## Step 3: Create .env File

Create `.env` in project root with:
\`\`\`
SUPABASE_URL=<paste Project URL>
SUPABASE_ANON_KEY=<paste anon public key>
\`\`\`

## Verification

Run `/phase-prep 1` again to confirm all items complete.
```

**Implementation approach:**

1. **Update `/phase-prep` command:**
   - After detecting incomplete setup items, enter "guidance mode"
   - For each item, identify the service/tool involved
   - Look up or generate detailed instructions

2. **Create setup instruction templates:**
   - Store common setup patterns in `.claude/setup-guides/`
   - Templates for: Supabase, Firebase, Stripe, Auth0, etc.
   - Include version-dated instructions (services change UIs)

3. **Dynamic research fallback:**
   - If no template exists, use WebFetch to pull current docs
   - Extract key steps and format consistently

4. **Service detection heuristics:**
   - "Supabase" → use Supabase guide
   - "Firebase" / "FCM" → use Firebase guide
   - "Create .env" → generate env file template from context

**Files to modify:**
- `.claude/commands/phase-prep.md` — Add guidance generation logic
- Create: `.claude/setup-guides/supabase.md`
- Create: `.claude/setup-guides/firebase.md`
- Create: `.claude/setup-guides/common-env.md`
