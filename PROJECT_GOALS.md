# PROJECT_GOALS.md — Workflow Architecture

> What's the simplest architecture that gives me parallel, fire-and-forget AI workstreams across multiple projects, without breaking the automation I've already built?

---

## Goals

### G1 — Parallel Workstreams Within a Single Project
Run multiple independent AI workstreams simultaneously on the same codebase (e.g., feature A on one branch, bug fix B on another) without manual context-switching.

### G2 — Fire-and-Forget Automation
Kick off a workstream and walk away. Each stream should execute autonomously — running tools, making commits, opening PRs — without requiring babysitting or manual approvals mid-flight.

### G3 — Single Unified Context (Preferred)
Ideally, all workstreams are visible and orchestratable from one place. Avoid having to switch between completely separate UIs, terminals, or dashboards to manage parallel work.

### G4 — Maximum Automation
Leverage the highest degree of automation possible. The existing toolkit (skills, hooks, browser verification, auto-verify, etc.) represents the current best-in-class setup — any new architecture must match or exceed this level.

### G5 — Cross-Project Orchestration
Support kicking off AI workstreams across different projects (not just KineticBI). A workflow engine that only works within a single repo is insufficient.

### G6 — Skills Portability
Skills (like `/codex-consult`, `/create-pr`, `/auto-verify`) should work across agents and tools. Prefer open, portable skill formats. Candidate consolidation layer: [skills.sh](https://skills.sh/docs).

### G7 — Preserve Existing Automation
Browser verification automation, manual verification workflows, PostHog analytics hooks, and the broader dev workflow built into this repo must continue to function. Replacing the toolkit is fine only if the replacement covers all existing capabilities.

---

## Non-Goals

### NG1 — Tool Allegiance
No loyalty to any specific tool. Claude Code is home base today because it best supports the goals — that can change. The constraint is capability, not brand.

### NG2 — Complex Git Mechanics for Their Own Sake
Git worktrees, branch strategies, etc. are implementation details. The goal is parallel work, not a specific branching model. If a tool handles isolation differently (containers, cloud sandboxes), that's fine.

### NG3 — Tool Proliferation
Avoid adopting many loosely-integrated tools that each handle one piece. Prefer fewer tools that compose well over a sprawling toolchain.

### NG4 — Premature Optimization
Don't architect for 50 parallel agents. The real need is 2–5 concurrent workstreams per project, with room to grow.

---

## Constraints

### C1 — Port Conflicts
Parallel dev servers (Next.js, Supabase, etc.) must not collide on ports. Any architecture must address this — via dynamic port allocation, containers, tunneling, or preview deployments.

### C2 — Browser/Manual Verification Automation
The existing setup for automated browser verification (`/auto-verify`) and manual verification workflows is tightly integrated and hard to replicate. It currently doesn't work well in worktree environments. Any solution must either:
- Make verification work in the new parallel environment, OR
- Provide an equivalent verification mechanism

### C3 — Environment File Provisioning
`.env` files, `node_modules`, and other `.gitignore`d dependencies don't automatically propagate to worktrees or new workspaces. The architecture must handle environment bootstrapping for each workstream.

### C4 — Git Branch Exclusivity
Multiple agents cannot checkout the same branch simultaneously (fundamental Git constraint). Parallel workstreams require separate branches, which means the architecture must handle branch creation and isolation.

### C5 — macOS Development Environment
Primary development is on macOS. Solutions must be macOS-compatible (or cloud-based with local tooling).

---

## Current Toolkit (Preserve or Replace)

| Capability | Current Implementation | Status |
|---|---|---|
| AI coding agent | Claude Code (CLI) | Primary tool |
| Cross-model consultation | `/codex-consult` skill (Codex CLI) | Working |
| Browser verification | `/auto-verify` skill | Working, fragile in worktrees |
| Manual verification | Custom automation | Working |
| PR creation | `/create-pr` skill | Working |
| Spec generation | `/product-spec`, `/technical-spec`, `/feature-spec` | Working |
| Analytics | PostHog hooks | Working |
| Multi-workspace | Conductor (Mac app) | Used, has limitations |

---

## Key Tension

> "I can't figure out a clean way to achieve the goals I have with all the tools available without violating one or more of the things I'm trying to achieve."

The fundamental challenge: parallelism requires isolation (separate branches, ports, environments), but the existing automation assumes a single, fully-configured workspace. Bridging this gap without losing automation capabilities is the core architectural problem.

---

## Evaluation Criteria for Solutions

1. **Parallelism** — Can it run 2–5 independent workstreams on the same project?
2. **Autonomy** — Can each workstream run to completion without human intervention?
3. **Automation preservation** — Does the existing skill/hook/verification toolkit work?
4. **Simplicity** — Is it the minimum viable architecture? Can it be understood in 5 minutes?
5. **Portability** — Does it work across projects, not just KineticBI?
6. **Environment isolation** — Ports, deps, env files — all handled cleanly?
7. **Observability** — Can I see what all workstreams are doing from one place?
