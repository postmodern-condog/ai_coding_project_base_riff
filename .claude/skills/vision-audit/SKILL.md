---
name: vision-audit
description: Compare VISION.md against current toolkit state and report alignment with traffic-light scoring.
allowed-tools: Read, Glob, Grep, Bash
---

# Vision Audit

Evaluate how well the current toolkit aligns with VISION.md principles, scope, and success criteria.

## Scope

This skill is **toolkit-specific**. It audits the AI Coding Toolkit repository against its own VISION.md. It is not synced to target projects.

## Trigger

Manual only. Run `/vision-audit` when you want to check alignment.

## Prerequisites

VISION.md must exist in the repository root. If missing, exit with error:

```
ERROR: VISION.md not found.

This skill requires a VISION.md document to audit against.
```

---

## Workflow

```
Vision Audit Progress:
- [ ] Phase 1: Parse VISION.md sections
- [ ] Phase 2: Gather evidence from codebase
- [ ] Phase 3: Evaluate alignment for each item
- [ ] Phase 4: Generate report with summary
- [ ] Phase 5: Provide actionable suggestions
```

---

## Phase 1: Parse VISION.md

Read VISION.md and extract auditable items from each section:

### Sections to Extract

| Section | What to Extract |
|---------|-----------------|
| **Problem** | Context only (not scored) |
| **Aspiration** | Core goal to measure against |
| **Principles** | Each numbered principle (priority order) |
| **AI Strengths** | Each bullet under "Lean on these strengths" |
| **AI Weaknesses** | Each bullet under "Guard against these weaknesses" |
| **Scope - In** | What should be present |
| **Scope - Out** | What should NOT be present |
| **Success** | Each success criterion |

### Expected Structure

```markdown
## Problem
[context]

## Aspiration
[main goal]

## Principles
1. **Name** — Description
2. **Name** — Description
...

## AI Strengths and Weaknesses
**Lean on these strengths:**
- Item
- Item

**Guard against these weaknesses:**
- Item
- Item

## Scope
**In scope:** ...
**Out of scope:**
- Item
- Item

## Success
- Criterion
- Criterion
```

---

## Phase 2: Gather Evidence

Scan the codebase to gather evidence for evaluation:

### Evidence Sources

| Source | What to Look For |
|--------|------------------|
| `.claude/skills/` | Skill complexity, count, patterns |
| `.claude/commands/` | Legacy commands, complexity |
| `README.md` | Feature claims, workflow descriptions |
| `AGENTS.md` | Workflow rules, guardrails |
| `docs/` | Documentation depth and coverage |
| `*.md` prompts | Spec/plan generation patterns |
| Git history | Recent changes, commit patterns |

### Evidence Gathering Commands

```bash
# Count skills and their sizes
find .claude/skills -name "SKILL.md" | wc -l
wc -l .claude/skills/*/SKILL.md

# Check for complexity indicators
grep -r "MUST\|REQUIRED\|mandatory" .claude/skills/

# Review README size and structure
wc -l README.md

# Check for scope creep indicators
grep -ri "deploy\|monitor\|CI/CD\|multi-user" .claude/
```

---

## Phase 3: Evaluate Alignment

For each extracted item, assign a traffic-light score based on evidence:

### Scoring Criteria

| Score | Meaning | Criteria |
|-------|---------|----------|
| 🟢 Green | Aligned | Clear evidence of alignment, no contradictions |
| 🟡 Yellow | Partial | Some evidence, but incomplete or mixed signals |
| 🔴 Red | Misaligned | Contradicting evidence, or clear violation |

### Evaluation Guidelines

**Principles:**
- **Simplicity over capability**: Are skills concise? Is README under 500 lines? Few mandatory steps?
- **Flexibility over guardrails**: Are workflows optional? Can users skip steps? No forced patterns?
- **90% rule**: Are features broadly useful? No niche enterprise features?

**AI Strengths (are we leveraging?):**
- Explicit instructions → AGENTS.md exists, skills have clear steps
- Rigorous testing → Verification skills exist, TDD enforced
- Clear specifications → Spec prompts produce structured output
- Bounded tasks → Tasks have acceptance criteria, phases are scoped

**AI Weakness Guards (are we protecting?):**
- Context loss → State files exist, `/fresh-start` loads context
- Scope creep → Phases enforce boundaries, specs capture scope
- Inconsistent quality → Verification at checkpoints
- Stuck loops → Escalation paths documented, stuck detection exists

**Scope:**
- In-scope: Spec → Plan → Execute → Verify chain exists
- Out-of-scope: No deployment tools, no monitoring, no multi-dev coordination

**Success Criteria:**
- Evaluate whether each criterion is achievable with current toolkit

---

## Phase 4: Generate Report

Output a terminal report with this structure:

```
╔══════════════════════════════════════════════════════════════════╗
║                       VISION ALIGNMENT AUDIT                      ║
╚══════════════════════════════════════════════════════════════════╝

SUMMARY
───────
Overall: X of Y items aligned

  🟢 Green:  N items
  🟡 Yellow: N items
  🔴 Red:    N items

════════════════════════════════════════════════════════════════════

ASPIRATION
──────────
"Reduce the overhead of supervising AI coding to near-zero."

🟢 ALIGNED
   Evidence: Verification is automated, state persists across sessions,
   phase workflow minimizes manual intervention.

════════════════════════════════════════════════════════════════════

PRINCIPLES
──────────

1. Simplicity over capability
   🟡 PARTIAL
   Evidence: Most skills are focused, but README is 425 lines (above
   300 ideal). Some skills have complex multi-phase workflows.

2. Flexibility over guardrails
   🟢 ALIGNED
   Evidence: All phase commands are optional. Users can skip verification.
   No mandatory workflows.

3. 90% rule
   🟢 ALIGNED
   Evidence: Features target solo developers. No enterprise-specific
   tooling (RBAC, audit logs, etc.).

════════════════════════════════════════════════════════════════════

AI STRENGTHS (Leveraging)
─────────────────────────

✓ Following explicit instructions
  🟢 AGENTS.md provides clear workflow rules. Skills have step-by-step phases.

✓ Rigorous testing when enforced
  🟢 /phase-checkpoint runs verification. TDD enforcement exists.

[... continue for each strength ...]

════════════════════════════════════════════════════════════════════

AI WEAKNESS GUARDS (Protecting)
───────────────────────────────

✓ Context and progress loss
  🟢 /fresh-start loads context. Phase state persists in files.

✓ Scope creep
  🟡 Phases enforce boundaries, but no automatic scope-creep detection.

[... continue for each weakness ...]

════════════════════════════════════════════════════════════════════

SCOPE ALIGNMENT
───────────────

In-scope items:
  🟢 Specification → /product-spec, /technical-spec exist
  🟢 Planning → /generate-plan exists
  🟢 Execution → /phase-start exists
  🟢 Verification → /phase-checkpoint, /verify-task exist

Out-of-scope (should NOT exist):
  🟢 No deployment tools found
  🟢 No monitoring tools found
  🟢 No multi-developer coordination

════════════════════════════════════════════════════════════════════

SUCCESS CRITERIA
────────────────

1. "Developer can run full workflow and end up with verified code..."
   🟢 ACHIEVABLE — Full command chain exists and is documented.

2. "Time-to-completion drops because supervision overhead is minimal"
   🟡 PARTIAL — Automation exists but some manual steps remain.

[... continue for each criterion ...]
```

---

## Phase 5: Actionable Suggestions

For each Yellow or Red item, provide specific suggestions:

```
════════════════════════════════════════════════════════════════════

SUGGESTIONS FOR IMPROVEMENT
───────────────────────────

🟡 Simplicity over capability
   → Consider migrating README sections to docs/ (currently 425 lines)
   → Review /update-docs skill for potential simplification

🟡 Scope creep protection
   → Add scope-drift detection to /phase-checkpoint
   → Consider warning when tasks exceed original spec boundaries

🟡 Time-to-completion
   → Document expected time savings vs manual coding
   → Add metrics collection for supervision time (optional)
```

### Suggestion Guidelines

- Be specific and actionable
- Reference specific files or skills when relevant
- Prioritize high-impact, low-effort improvements
- Don't suggest changes that violate other principles (e.g., don't add complexity to fix scope creep)

---

## Edge Cases

### VISION.md Has Non-Standard Structure

If VISION.md doesn't match expected structure:
- Extract what sections exist
- Note which sections are missing
- Audit only the sections present
- Suggest adding missing sections if they would be valuable

### Ambiguous Evidence

When evidence is unclear:
- Default to Yellow (partial alignment)
- Note the ambiguity in the evidence section
- Suggest clarifying the vision statement or adding explicit indicators

### New Principles Added

If VISION.md has additional sections not covered above:
- Attempt to evaluate them using the same R/Y/G criteria
- Note them as "Additional Principles" in the report
