---
name: vision-audit
description: Compare VISION.md against current toolkit state and report alignment with traffic-light scoring.
allowed-tools: Read, Glob, Grep, Bash
---

# Vision Audit

Evaluate toolkit alignment with VISION.md **and** compare against modern SDLC outcomes.

This audit is both backward-looking (are we following our stated vision?) and forward-looking (are we achieving the outcomes that modern SDLC requires, or intentionally avoiding them?).

**Key principle:** Focus on *outcomes*, not practices or tools. "Code is verified before commit" is an outcome—whether via local tests, preview deployments, or AI verification is a tactical choice that can evolve.

## Scope

This skill is **toolkit-specific**. It audits the AI Coding Toolkit repository against its own VISION.md and SDLC_REFERENCE.md. It is not synced to target projects.

## Trigger

Manual only. Run `/vision-audit` when you want to check alignment.

## Prerequisites

- **VISION.md** must exist in the repository root
- **SDLC_REFERENCE.md** must exist in the repository root

If either is missing, exit with error and suggest creating them.

---

## Workflow

```
Vision Audit Progress:
- [ ] Phase 1: Parse VISION.md sections
- [ ] Phase 2: Gather evidence from codebase
- [ ] Phase 3: Evaluate vision alignment (R/Y/G scoring)
- [ ] Phase 4: Compare against SDLC_REFERENCE.md
- [ ] Phase 5: Classify gaps (ADDRESSED / AVOIDED / OPPORTUNITY)
- [ ] Phase 6: Generate combined report
- [ ] Phase 7: Provide actionable recommendations
```

---

## Part A: Vision Alignment Audit

### Phase 1: Parse VISION.md

Read VISION.md and extract auditable items:

| Section | What to Extract |
|---------|-----------------|
| **Problem** | Context only (not scored) |
| **Aspiration** | Core goal to measure against |
| **Principles** | Each numbered principle (priority order) |
| **AI Strengths** | Items under "Lean on these strengths" |
| **AI Weaknesses** | Items under "Guard against these weaknesses" |
| **Scope - In** | What should be present |
| **Scope - Out** | What should NOT be present (used for SDLC gap classification) |
| **Success** | Each success criterion |

### Phase 2: Gather Evidence

Scan the codebase for evidence:

| Source | What to Look For |
|--------|------------------|
| `.claude/skills/` | Skill complexity, count, patterns |
| `.claude/commands/` | Legacy commands |
| `README.md` | Feature claims, workflow descriptions |
| `AGENTS.md` | Workflow rules, guardrails |
| `docs/` | Documentation coverage |
| `*.md` prompts | Spec/plan generation patterns |

### Phase 3: Evaluate Vision Alignment

For each extracted vision item, assign a score:

| Score | Meaning | Criteria |
|-------|---------|----------|
| 🟢 Green | Aligned | Clear evidence, no contradictions |
| 🟡 Yellow | Partial | Some evidence, incomplete or mixed |
| 🔴 Red | Misaligned | Contradicting evidence or violation |

---

## Part B: SDLC Gap Analysis

### Phase 4: Compare Against SDLC Reference

Read SDLC_REFERENCE.md and check each practice:

**For each SDLC practice (P1.1, C2.1, T4.1, etc.):**

1. **Search for evidence** that the toolkit addresses this practice
2. **Check VISION.md scope** to see if this practice falls in-scope or out-of-scope
3. **Classify the gap** (see Phase 5)

### Phase 5: Classify Gaps

For each SDLC practice, determine its status:

#### ACHIEVED
The toolkit achieves this outcome (regardless of specific practice used).

```
✅ Outcome 4.1: Code Correctness Is Verified Before Commit
   ACHIEVED via: /verify-task, /code-verification, /phase-checkpoint
   Evidence: Tests enforced before task completion
```

#### INTENTIONALLY AVOIDED
The practice is out of scope per VISION.md, with clear reasoning.

```
⊘ Outcome 6.1: Deployments Are Automated and Consistent
   INTENTIONALLY AVOIDED
   Reason: VISION.md states "Downstream of verification (deployment, monitoring,
   iteration)" is out of scope. The toolkit stops at verified commits.

   This is correct because: The toolkit's value is reducing supervision overhead
   for AI coding, not replacing deployment infrastructure.
```

#### OPPORTUNITY
The practice is in-scope (or adjacent to scope) but not yet addressed.

```
💡 Outcome 1.3: Security Risks Are Considered Early
   OPPORTUNITY
   Relevance: Falls within "Planning" phase which is in-scope
   Gap: Limited security prompts during specification

   Recommendation: Add security consideration questions to spec Q&A
   (auth approach, data sensitivity, trust boundaries)

   Priority: MEDIUM (improves security without adding complexity)
   Effort: LOW (add prompts to existing skill)
```

### Classification Decision Tree

```
For each SDLC practice:
│
├─ Does toolkit address it?
│  └─ YES → ADDRESSED
│
├─ Is it explicitly out of scope in VISION.md?
│  └─ YES → INTENTIONALLY AVOIDED (explain why this is correct)
│
├─ Is it in-scope or adjacent to scope?
│  └─ YES → OPPORTUNITY (recommend action)
│
└─ Ambiguous?
   └─ Default to OPPORTUNITY with LOW priority
```

---

## Phase 6: Generate Combined Report

```
╔══════════════════════════════════════════════════════════════════╗
║                       VISION ALIGNMENT AUDIT                      ║
╚══════════════════════════════════════════════════════════════════╝

SUMMARY
───────
Vision Alignment: X of Y items (🟢 N / 🟡 N / 🔴 N)
SDLC Coverage:    X of Y outcomes achieved

════════════════════════════════════════════════════════════════════

PART A: VISION ALIGNMENT
────────────────────────

[Existing vision audit output - aspiration, principles, AI strengths/
weaknesses, scope alignment, success criteria with R/Y/G scores]

════════════════════════════════════════════════════════════════════

PART B: SDLC GAP ANALYSIS
─────────────────────────

SDLC PHASE: PLAN
────────────────
✅ P1.1 Requirements documentation      ADDRESSED (specs, prompts)
✅ P1.2 User story mapping              ADDRESSED (acceptance criteria)
✅ P1.3 Technical design documents      ADDRESSED (/technical-spec)
💡 P1.4 Threat modeling                 OPPORTUNITY (see recommendations)
⊘ P1.5 Estimation & capacity planning  AVOIDED (out of scope: project mgmt)
✅ P1.6 Dependency analysis             ADDRESSED (tech spec prompts)
✅ P1.7 Definition of Done              ADDRESSED (acceptance criteria)
⊘ P1.8 Backlog grooming                AVOIDED (out of scope: project mgmt)

SDLC PHASE: CODE
────────────────
✅ C2.1 Version control (Git)           ADDRESSED (git workflow built-in)
✅ C2.2 Branching strategy              ADDRESSED (phase branches)
✅ C2.3 Code review / PR process        ADDRESSED (/codex-review)
✅ C2.4 Coding standards                ADDRESSED (lint in verification)
⊘ C2.5 Pair/mob programming            AVOIDED (out of scope: multi-dev)
✅ C2.6 Documentation as code           ADDRESSED (/update-docs)
✅ C2.7 Secrets management              ADDRESSED (/security-scan)
✅ C2.8 AI coding assistants            ADDRESSED (this is the toolkit)
✅ C2.9 Modular architecture            ADDRESSED (tech spec prompts)

[... continue for each SDLC phase ...]

════════════════════════════════════════════════════════════════════

COVERAGE SUMMARY BY PHASE
─────────────────────────

| Phase    | Addressed | Avoided | Opportunity | Total |
|----------|-----------|---------|-------------|-------|
| Plan     | 5         | 2       | 1           | 8     |
| Code     | 8         | 1       | 0           | 9     |
| Build    | 2         | 4       | 1           | 7     |
| Test     | 8         | 2       | 2           | 12    |
| Release  | 3         | 3       | 2           | 8     |
| Deploy   | 0         | 9       | 0           | 9     |
| Operate  | 0         | 8       | 0           | 8     |
| Monitor  | 0         | 9       | 0           | 9     |
| Security | 3         | 1       | 1           | 5     |
| Quality  | 3         | 1       | 1           | 5     |
| Collab   | 1         | 2       | 1           | 4     |
|----------|-----------|---------|-------------|-------|
| TOTAL    | 33        | 42      | 9           | 84    |

Note: High "Avoided" count in Deploy/Operate/Monitor is expected per
VISION.md scope ("Downstream of verification is out of scope").
```

---

## Phase 7: Actionable Recommendations

For each OPPORTUNITY, provide:

```
════════════════════════════════════════════════════════════════════

OPPORTUNITIES (Prioritized)
───────────────────────────

HIGH PRIORITY
─────────────

💡 T4.5 SAST (Static Application Security Testing)
   Gap: /security-scan exists but doesn't run SAST tools
   Recommendation: Integrate Semgrep or similar into /security-scan
   Effort: MEDIUM
   Impact: HIGH (catches vulnerabilities earlier)

   Implementation hint: Add `semgrep --config auto` to security-scan
   workflow, similar to existing dependency scanning.

MEDIUM PRIORITY
───────────────

💡 P1.4 Threat modeling
   Gap: No security considerations in spec phase
   Recommendation: Add security prompts to /technical-spec
   Effort: LOW
   Impact: MEDIUM (shift-left security)

   Implementation hint: Add "Security Considerations" section to
   TECHNICAL_SPEC_PROMPT.md asking about auth, data sensitivity, etc.

💡 R5.5 Feature flags
   Gap: No guidance on gradual rollout
   Recommendation: Document feature flag patterns in docs/
   Effort: LOW
   Impact: LOW-MEDIUM (optional best practice)

   Implementation hint: Add docs/feature-flags.md with patterns,
   don't build tooling (violates simplicity principle).

LOW PRIORITY
────────────

💡 Q10.1 DORA metrics
   Gap: No metrics tracking for toolkit effectiveness
   Recommendation: SKIP - would violate simplicity principle
   Note: User can track externally if desired

════════════════════════════════════════════════════════════════════

INTENTIONALLY AVOIDED (Validation)
──────────────────────────────────

The following practices are correctly avoided per VISION.md scope:

Deploy Phase (D6.1-D6.9): All avoided
  ✓ Correct: "Downstream of verification" is out of scope

Operate Phase (O7.1-O7.8): All avoided
  ✓ Correct: "monitoring, iteration" explicitly out of scope

Monitor Phase (M8.1-M8.9): All avoided
  ✓ Correct: Same as above

Multi-developer (C2.5, L11.1-L11.3): Avoided
  ✓ Correct: "Multi-developer coordination" explicitly out of scope

No misaligned "avoided" items found.
```

---

## Report Principles

1. **Be specific** — Reference actual files, skills, and code
2. **Justify avoidance** — Every AVOIDED item needs a VISION.md citation
3. **Prioritize opportunities** — Don't overwhelm with low-value suggestions
4. **Respect principles** — Don't recommend features that violate simplicity
5. **Forward-looking** — This audit should drive roadmap, not just compliance

---

## Edge Cases

### SDLC_REFERENCE.md Missing

```
WARNING: SDLC_REFERENCE.md not found.

Running vision alignment audit only (Part A).
Create SDLC_REFERENCE.md to enable gap analysis (Part B).
```

### Practice Partially Addressed

When a practice is partially addressed:
- List as ADDRESSED with a note about limitations
- OR list as OPPORTUNITY if the gap is significant

```
🔶 T4.11 Test coverage metrics
   PARTIALLY ADDRESSED
   Current: /verify-task checks tests exist
   Gap: No coverage threshold enforcement

   Recommendation: LOW priority - coverage metrics can add noise
```

### New SDLC Practices

If SDLC_REFERENCE.md has practices not covered in this skill's examples:
- Apply the same classification logic
- Use the decision tree to determine ADDRESSED/AVOIDED/OPPORTUNITY
