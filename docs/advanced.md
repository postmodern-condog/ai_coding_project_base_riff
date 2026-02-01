# Advanced Topics

## Adopting Existing Repositories

If you're already working in another repository and want to start using this toolkit:

```bash
# 1. Set environment variable (one-time, in ~/.zshrc or ~/.bashrc):
export AI_CODING_TOOLKIT="$HOME/Projects/ai_coding_project_base"

# 2. From the toolkit directory, copy execution assets:
/setup ~/Projects/my-existing-app

# 3. Start a new Claude Code session in the adopted repo:
cd ~/Projects/my-existing-app
claude

# 4. Generate specs and plan:
/product-spec .
/technical-spec .
/generate-plan .

# 5. Execute:
/fresh-start
/configure-verification
/phase-start 1
```

This workflow is useful when you've been discussing a feature in another repo and decide you want to use the toolkit's structured approach.

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

## Optional Ad-Hoc Tools

These tools are available for on-demand use but are **not part of the standard workflow**.

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

**Not recommended for:** Running automatically after every task.

## Local Claude Code Settings

If you use local (machine-specific) Claude Code permissions:

1. Copy `.claude/settings.local.example.json` → `.claude/settings.local.json`
2. Customize as needed

The `.claude/settings.local.json` file is gitignored.
