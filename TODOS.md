# TODO

## In Progress

- [ ] Compare web vs CLI interface for generation workflow (see below)
- [ ] Issue tracker integration (Jira, Linear, GitHub Issues)
- [ ] Intro commands for each Step
- [ ] Verify that the Chrome DevTools integration works
- [ ] Git worktrees for parallel task execution (see below)
- [ ] Cross-tool compatibility with config generation (see below) — combines former "Cross-Tool Compatibility" and "Autonomous Execution Permissions"
- [ ] Address Claude Code dependency — slash commands only work in Claude Code (see below)
- [x] Add `/list-todos` command (see below) — DONE

## Future Concepts

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

**Note:** Subagents are Claude Code-specific. Codex CLI does not support `.codex/agents/`.

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

**Requirements:**
1. Orchestrator-level functionality to:
   - Analyze task dependencies within a step
   - Spawn parallel agents for independent tasks
   - Manage git worktrees (create, merge, cleanup)
   - Coordinate completion and handle conflicts
2. Merge strategy when parallel tasks complete
3. Conflict resolution when tasks touch same files unexpectedly

**Open questions:**
- What orchestrator mechanism? (Claude Code subagents? External script?)
- How to detect/prevent conflicts before they happen?
- Is the complexity worth the speed gain for typical projects?
- How does this interact with the current phase-branch model?

**Potential approach:**
- Add `parallel: true/false` flag to task definitions in EXECUTION_PLAN.md
- Create `/parallel-step` command that uses worktrees
- Keep sequential execution as default, parallel as opt-in

### Cross-Tool Compatibility with Config Generation

Generate tool-specific configuration files to make the toolkit work with AI coding tools beyond Claude Code.

**Goal:** When running `/setup`, generate configs for the user's preferred tool(s) so the workflow works across different AI assistants.

**Tools to support (priority order):**

| Tool | Type | Config Format | Slash Command Equivalent |
|------|------|---------------|-------------------------|
| Cursor | IDE | `.cursor/rules/*.mdc` | Rules with glob patterns |
| Codex CLI | CLI | Research needed | Research needed |
| Aider | CLI | `.aider.conf.yml` | Conventions file |
| Windsurf | IDE | Custom instructions | TBD |
| Continue | IDE extension | `.continue/config.json` | TBD |

**Config generation approach:**

1. **Translate AGENTS.md to tool-specific rules**
   - Parse AGENTS.md sections
   - Generate equivalent config for target tool
   - Example: AGENTS.md "Git Conventions" → Cursor rule file

2. **Generate permission configs**
   - Each tool has different permission models:
     - Claude Code: `allowed-tools` in commands, `settings.json`
     - Codex CLI: sandbox mode flags
     - Cursor: Less restrictive by default
   - Generate appropriate permission setup for autonomous execution

3. **Proposed `/setup` enhancement:**
   ```bash
   /setup ~/my-project                    # Claude Code only (default)
   /setup ~/my-project --tool=cursor      # Also generate Cursor configs
   /setup ~/my-project --tool=aider       # Also generate Aider configs
   /setup ~/my-project --tool=all         # Generate all supported configs
   ```

**Permission categories to handle:**

| Category | Examples | Risk Level |
|----------|----------|------------|
| File operations | Create, edit, delete files | Medium |
| Shell execution | npm install, pytest, build commands | High |
| Git operations | Commit, branch, push | Medium |
| Environment access | Read env vars, secrets | High |

**Deliverables:**

1. Research each tool's config format and document findings
2. Create config generators for top 2-3 tools
3. Add `--tool` flag to `/setup`
4. Documentation for manual setup with unsupported tools
5. Permission manifest in EXECUTION_PLAN.md (per-phase requirements)

### Address Claude Code Dependency

Currently, the toolkit's slash commands (`.claude/commands/`) only work in Claude Code. This limits adoption for users of other tools.

**Current state:**

| Component | Claude Code | Codex CLI | Other Tools |
|-----------|-------------|-----------|-------------|
| Slash commands (`/phase-start`, etc.) | ✅ Works | ❌ Not supported | ❌ Not supported |
| Skills (`.claude/skills/`) | ✅ Works | ✅ Works (via `.codex/skills/`) | ❓ Manual reference |
| Spec documents | ✅ Works | ✅ Works | ✅ Works |
| AGENTS.md | ✅ Works | ✅ Works | ✅ Works |
| Prompt files | ✅ Works | ✅ Manual paste | ✅ Manual paste |

**Problem:** The "magic" of the toolkit is in the slash commands. Without them, users must manually paste prompts and follow START_PROMPTS.md, losing much of the workflow automation.

**Options to address:**

1. **Documentation-only approach**
   - Clearly document that slash commands are Claude Code only
   - Improve START_PROMPTS.md for manual usage
   - Accept this as a limitation

2. **Tool-specific command equivalents**
   - Research if Codex CLI has command/alias system
   - Research Cursor's command palette integration
   - Generate equivalent automation for each tool

3. **External CLI wrapper**
   - Create a standalone CLI (`ai-toolkit`) that works outside Claude Code
   - Wraps the prompts and invokes the user's preferred AI tool
   - More work but truly tool-agnostic

**Questions to answer:**

1. Does Codex CLI have a slash command or alias equivalent?
2. What percentage of users are on Claude Code vs other tools?
3. Is the external CLI wrapper worth the maintenance burden?
4. Should we just accept Claude Code as the "premium" experience?

**Minimum viable action:**

- Update README to clearly state slash commands are Claude Code specific
- Improve documentation for manual usage with other tools
- Defer tool-specific command generation to cross-tool compatibility work
