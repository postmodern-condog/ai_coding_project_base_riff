# Competitors & Landscape

Analysis of alternative AI-assisted development tools and our differentiation.

This document informs `/vision-audit` proposals by understanding what others do, what works, and where we can be uniquely valuable.

**Last updated:** 2026-01-28

---

## Competitors Analyzed

| Tool | Source | Focus |
|------|--------|-------|
| **Compound Engineering Plugin** | Local (`~/Projects/compound-engineering-plugin`) | Multi-agent workflows + knowledge compounding |
| **Get Shit Done (GSD)** | [GitHub](https://github.com/glittercowboy/get-shit-done) | Context engineering + parallel execution |
| **Spec Kitty** | [GitHub](https://github.com/Priivacy-ai/spec-kitty) | Multi-agent coordination + git worktrees |
| **GitHub Spec Kit** | [GitHub](https://github.com/github/spec-kit) | Spec-driven development templates |

---

## Philosophy Comparison

Each tool embodies a different philosophy about how AI should assist development:

| Tool | Core Philosophy |
|------|-----------------|
| **Compound Engineering** | "Each unit of work makes future work easier." Knowledge compounds over time through documented learnings. 80% planning/review, 20% execution. |
| **Get Shit Done** | "The complexity is in the system, not your workflow." Solves context rot through fresh contexts per task. Anti-enterprise, pro-solo-developer. |
| **Spec Kitty** | "Specification as coordination." Multiple AI agents work in parallel on isolated worktrees, coordinated by shared specs. |
| **GitHub Spec Kit** | "Specs are executable." Specifications generate implementations directly, with gated phases and checkpoints. |
| **AI Coding Toolkit (us)** | "Reduce supervision overhead to near-zero." Structured workflow with verification, designed to work reliably without constant human intervention. |

---

## Feature Matrix

### Workflow Phases

| Capability | Compound | GSD | Spec Kitty | Spec Kit | **Us** |
|------------|----------|-----|------------|----------|--------|
| Specification generation | ✓ | ✓ | ✓ | ✓ | ✓ |
| Technical planning | ✓ | ✓ | ✓ | ✓ | ✓ |
| Task breakdown | ✓ | ✓ | ✓ | ✓ | ✓ |
| Execution | ✓ | ✓ | ✓ | ✓ | ✓ |
| Verification | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Knowledge capture** | ✓✓ | ○ | ○ | ○ | ✓ |
| **Cross-model verification** | ○ | ○ | ○ | ○ | ✓ |

### Execution Model

| Capability | Compound | GSD | Spec Kitty | Spec Kit | **Us** |
|------------|----------|-----|------------|----------|--------|
| Parallel agent execution | ✓✓ | ✓ | ✓✓ | ○ | ○ |
| Fresh context per task | ○ | ✓✓ | ✓ | ○ | ○ |
| Git worktrees for isolation | ✓ | ○ | ✓✓ | ○ | ○ |
| Atomic commits per task | ✓ | ✓ | ✓ | ○ | ✓ |
| Phase branches | ○ | ○ | ○ | ○ | ✓ |

### Verification & Quality

| Capability | Compound | GSD | Spec Kitty | Spec Kit | **Us** |
|------------|----------|-----|------------|----------|--------|
| TDD enforcement | ○ | ○ | ○ | ○ | ✓✓ |
| Security scanning | ✓ | ○ | ○ | ○ | ✓ |
| Multi-agent code review | ✓✓ | ○ | ✓ | ○ | ✓ |
| Spec verification | ○ | ✓ | ✓ | ✓ | ✓ |
| Stuck detection/escalation | ○ | ○ | ○ | ○ | ✓ |

### Context Management

| Capability | Compound | GSD | Spec Kitty | Spec Kit | **Us** |
|------------|----------|-----|------------|----------|--------|
| Session recovery | ✓ | ✓✓ | ✓ | ○ | ✓ |
| State persistence | ✓ | ✓✓ | ✓ | ○ | ✓ |
| AGENTS.md / constitution | ✓ | ○ | ✓ | ✓ | ✓ |
| Learnings capture | ✓✓ | ○ | ○ | ○ | ✓ |

**Legend:** ✓✓ = strong/unique, ✓ = present, ○ = absent/minimal

---

## Strengths to Learn From

### From Compound Engineering Plugin

**Knowledge Compounding**
- `/workflows:compound` captures solutions *while context is fresh*
- Extracts prevention strategies, not just fixes
- Creates searchable, structured documentation
- *Our gap:* `/capture-learning` exists but isn't as systematic

**Specialized Agent Personas**
- 27 domain-specific agents (Rails reviewer, security sentinel, etc.)
- Parallel execution of multiple reviewers
- *Our gap:* We use general-purpose agents, not specialized personas

**Living Plans**
- Plans have checkboxes that track progress
- Creates audit trail of planned vs. delivered
- *Our opportunity:* EXECUTION_PLAN.md could be more interactive

---

### From Get Shit Done

**Context Rot Solution**
- Fresh 200k-token context per task executor
- Eliminates cumulative degradation
- *Our gap:* We don't explicitly manage context freshness

**Anti-Enterprise Philosophy**
- "Complexity in the system, not your workflow"
- Rejects ceremony for solo developers
- *Our alignment:* This matches our "90% rule" principle

**STATE.md Pattern**
- Captures decisions, blockers, position across sessions
- Explicit state file for recovery
- *Our opportunity:* Could enhance `/fresh-start` with richer state

---

### From Spec Kitty

**Git Worktree Parallelism**
- Each work package in isolated worktree
- Eliminates merge conflicts during parallel work
- *Our gap:* We use sequential phase branches, not parallel worktrees

**Live Kanban Dashboard**
- Visual progress tracking
- Real-time agent status
- *Our gap:* `/progress` is text-only, no visual dashboard

**Multi-Agent Coordination**
- 12+ different AI agents on single feature
- Agent-agnostic design
- *Our constraint:* We're Claude Code-native by design (VISION.md)

---

### From GitHub Spec Kit

**Gated Phases with Checkpoints**
- Explicit gates between specify → plan → tasks → implement
- Validation at each transition
- *Our similarity:* `/phase-prep` → `/phase-start` → `/phase-checkpoint`

**Agent-Agnostic Design**
- Works with Claude, Copilot, Gemini, Cursor, etc.
- Portable across tools
- *Our constraint:* We're Claude Code-native (intentional scope limit)

**Minimal Installation**
- `uv tool install` one-liner
- Low friction to start
- *Our gap:* We require cloning toolkit + setup

---

## Our Unique Differentiation

What we do that others don't (or can't easily copy):

### 1. Verification-First Architecture

No other tool emphasizes **verification as the core value prop**:
- TDD enforcement at task level
- Security scanning at checkpoints
- Cross-model verification (Codex reviews Claude's work)
- Stuck detection with escalation

Others focus on *generation*; we focus on *reliable generation*.

### 2. Supervision Overhead as the Metric

Our aspiration is explicit: "reduce supervision overhead to near-zero."

Others measure:
- Speed (Compound: "40% faster")
- Output (Spec Kit: "specs generate implementations")
- Coordination (Spec Kitty: "12 agents working together")

We measure: **How much can you trust the output without checking?**

### 3. Cross-Model Verification

No competitor has AI verifying AI with a different model:
- Codex reviews Claude's work
- Different training data catches different blind spots
- Research current docs before reviewing

This is architecturally unique and hard to replicate.

### 4. Simplicity as a Principle

Our VISION.md explicitly prioritizes simplicity:
- "Remove useful features if they add complexity"
- "90% rule" excludes niche features
- No enterprise ceremony

Compound has 27 agents. Spec Kitty has 13 commands. We aim for the minimum viable structure.

### 5. Document Chain as State

Others use:
- Databases (Spec Kitty kanban)
- Structured state files (GSD's STATE.md)
- Complex file structures (Compound's agent personas)

We use: **Markdown specs committed to git.**
- Any AI or human can read them
- No special tooling to inspect state
- Version controlled by default

---

## Gaps & Opportunities

Based on this analysis, potential improvements:

| Gap | Competitor Reference | Opportunity |
|-----|---------------------|-------------|
| Context rot | GSD's fresh contexts | Task isolation or context management |
| Parallel execution | Compound, Spec Kitty | Git worktree support for parallel tasks |
| Visual progress | Spec Kitty dashboard | Optional progress visualization |
| Installation friction | Spec Kit one-liner | Simpler onboarding path |
| Knowledge systematization | Compound's `/compound` | Enhanced `/capture-learning` workflow |
| Specialized reviewers | Compound's 27 agents | Domain-specific verification personas |

**Note:** Not all gaps should be filled. Each must pass our principles filter:
1. Does it add too much complexity? (Simplicity over capability)
2. Does it force a workflow? (Flexibility over guardrails)
3. Do 90% of solo developers want it? (90% rule)

---

## How This Document Is Used

The `/vision-audit` skill:

1. Reads this document during the RESEARCH phase
2. For each OPPORTUNITY identified in SDLC analysis, checks:
   - Do competitors address this? How?
   - Can we learn from their approach?
   - Can we do it differently/better?
3. Generates proposals that reference competitive positioning
4. Flags opportunities for differentiation

---

## Maintaining This Document

Update when:
- A major competitor releases significant updates
- New competitors emerge in the space
- Our differentiation changes (new capabilities added)
- Quarterly review during `/vision-audit`
