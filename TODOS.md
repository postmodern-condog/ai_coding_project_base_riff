# TODO

## In Progress

- [ ] **[P0 / High]** Deep audit of automation verification — ensure all components needed for human-free verification are present (see below)
- [ ] **[P0 / High]** Make workflow portable across CLIs/models without breaking Claude Code "clone-and-go" sharing
- [ ] **[P1 / Medium]** Add optional path arguments to execution commands to reduce wrong-directory friction
- [ ] Persistent learnings/patterns file for cross-task context (see below)
- [ ] Compare web vs CLI interface for generation workflow (see below)
- [ ] Issue tracker integration (Jira, Linear, GitHub Issues)
- [ ] Intro commands for each Step
- [ ] Verify that the Playwright MCP integration works
- [ ] Git worktrees for parallel task execution (see below)
- [ ] Session logging for automation opportunity discovery (see below)
- [ ] **[P1 / High]** Parallel Agent Orchestration (see below)
- [ ] **[P2 / Medium]** Spec Diffing and Plan Regeneration (see below)
- [ ] **[P2 / Medium]** Human Review Queue (see below)
- [x] Add `/list-todos` command (see below) — DONE
- [x] Recovery & Rollback Commands — DONE (phase-rollback, task-retry, phase-analyze)

## Future Concepts

### Deep Audit of Automation Verification

Comprehensive review of the toolkit's verification system to ensure fully autonomous operation without human intervention.

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
