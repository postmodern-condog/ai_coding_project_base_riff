---
description: Analyze and prioritize TODO items from TODOS.md
allowed-tools: Read, Glob, Grep
---

Analyze the TODO items in TODOS.md and produce a prioritized list with implementation guidance.

## Process

1. **Read TODOS.md** from the project root
2. **Read project context** — Scan PRODUCT_SPEC.md, TECHNICAL_SPEC.md, AGENTS.md, and EXECUTION_PLAN.md if they exist
3. **Extract TODO items** — Parse all actionable items from TODOS.md
4. **Analyze each item** using the framework below
5. **Sort by priority score** (highest first), break ties by value to project
6. **Output the prioritized list**

## Analysis Framework

For each TODO item, evaluate:

### Ranking Factors

| Factor | Low | Medium | High |
|--------|-----|--------|------|
| **Requirements Clarity** | Vague, many unknowns | Some details, some gaps | Well-defined, actionable |
| **Ease of Implementation** | Complex, many dependencies, research needed | Moderate effort, some unknowns | Straightforward, clear path |
| **Value to Project** | Nice-to-have, edge case | Useful improvement | Core functionality, high impact |

### Priority Score Calculation

```
Priority = (Clarity + Ease + Value) / 3 × 10
```

Where each factor is scored 1-3 (Low=1, Medium=2, High=3), producing a 1-10 scale.

Adjust score based on:
- **Boost (+1-2):** Blocks other work, security-related, frequently requested
- **Reduce (-1-2):** Speculative, already has workaround, external dependency

## Output Format

```markdown
# TODOS Analysis

**Generated:** {date}
**Items Analyzed:** {count}
**Project:** {project name from specs, or directory name}

---

## 1. {TODO Title}

**Priority Score:** {N}/10
**Ranking Factors:**
- Requirements Clarity: {Low|Medium|High} — {one sentence explanation}
- Ease of Implementation: {Low|Medium|High} — {one sentence explanation}
- Value to Project: {Low|Medium|High} — {one sentence explanation}

**Implementation Notes:**
{2-4 sentences on how to implement: key files to modify, approach, dependencies, estimated scope}

**Open Questions:**
- {Question that would improve requirements clarity}
- {Another question, if applicable}

**Suggested Next Action:** {One of: "Ready to implement", "Clarify requirements first", "Needs research", "Consider deferring", "Consider removing"}

---

## 2. {Next TODO Title}
{Same format}

---

## Summary

| Priority | Item | Score | Next Action |
|----------|------|-------|-------------|
| 1 | {title} | {N}/10 | {action} |
| 2 | {title} | {N}/10 | {action} |
| ... | ... | ... | ... |

**Ready to implement:** {count}
**Needs clarification:** {count}
**Consider deferring:** {count}
```

## Notes

- If TODOS.md doesn't exist, report: "No TODOS.md found in project root."
- Skip items that are clearly completed (checked boxes)
- Group related items if they should be tackled together
- Consider project phase — items relevant to current phase score higher
