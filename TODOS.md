# TODO

## In Progress

- [ ] Compare web vs CLI interface for generation workflow (see below)
- [ ] Issue tracker integration (Jira, Linear, GitHub Issues)
- [ ] Intro commands for each Step
- [ ] Verify that the Chrome DevTools integration works
- [ ] Add git worktrees support for parallel task execution
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

### Cross-Tool Compatibility

Investigate whether the generated project structure (`.claude/commands/`, `.claude/skills/`, spec documents) could be leveraged by AI coding tools beyond Claude Code and Codex CLI.

**Tools to investigate:**

| Tool | Type | Potential Integration |
|------|------|----------------------|
| Cursor | IDE | Rules files, `.cursor/` directory |
| Windsurf | IDE | Custom instructions |
| Aider | CLI | `.aider.conf.yml`, conventions files |
| Continue | IDE extension | `.continue/` config |
| GitHub Copilot Workspace | Cloud | Task definitions |
| Amazon Q Developer | IDE/CLI | Custom prompts |

**Questions to answer:**

1. What configuration formats do these tools use?
2. Can we generate tool-specific config files from our universal spec documents?
3. Is there a common subset that works across tools?
4. Should `/setup` generate configs for multiple tools?
5. Can AGENTS.md be translated into tool-specific rule formats?

**Potential deliverables:**

- `/setup --tool=cursor` flag to generate Cursor-compatible config
- Universal `AGENTS.md` → tool-specific rules converter
- Documentation on manual setup for unsupported tools

### Autonomous Execution Permissions

Investigate what permissions AI coding tools need for autonomous phase execution, and whether we can generate configuration files that pre-authorize these permissions.

**Permission categories to investigate:**

| Category | Examples | Risk Level |
|----------|----------|------------|
| File operations | Create, edit, delete files | Medium |
| Shell execution | npm install, pytest, build commands | High |
| Network access | API calls, package downloads | Medium |
| Git operations | Commit, branch, push | Medium |
| Environment access | Read env vars, secrets | High |

**Questions to answer:**

1. What permission models do different tools use?
   - Claude Code: `allowed-tools` in commands, `settings.json` allowlists
   - Codex CLI: sandbox mode, `--dangerously-skip-permissions`
   - Others: TBD
2. Can we generate permission config files during `/setup`?
3. Should AGENTS.md declare required permissions per phase?
4. Can we create a "permission manifest" that tools can read?
5. What's the minimum permission set for each phase type?

**Potential deliverables:**

- Permission manifest format in EXECUTION_PLAN.md (per-phase tool requirements)
- `/setup` generates tool-specific permission configs
- Documentation on permission requirements for autonomous execution
- "Dry run" mode that lists required permissions without executing
