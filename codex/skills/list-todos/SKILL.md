---
name: list-todos
description: Emulates the AI Coding Toolkit's Claude Code command /list-todos (analyze TODOS.md, prioritize items, and produce implementation guidance without guessing when requirements are unclear). Triggers on "/list-todos" or "list-todos".
---

# /list-todos (Codex)

Analyze and prioritize TODO items from `TODOS.md`.

## Directory Guard

Confirm `TODOS.md` exists in the current working directory. If not, stop and ask the user where their project TODOs live.

## Workflow

1. Read `TODOS.md`.
2. Load context by scanning:
   - `PRODUCT_SPEC.md`
   - `TECHNICAL_SPEC.md`
   - `AGENTS.md`
   - `EXECUTION_PLAN.md`
3. Extract actionable TODOs and ignore completed items.
4. For each TODO, evaluate:
   - Requirements clarity (Low/Medium/High)
   - Ease of implementation (Low/Medium/High; if clarity is Low, set to "Cannot assess")
   - Value to project (Low/Medium/High; if clarity is Low, set to "Cannot assess")
5. Compute priority score:
   - If clarity is Low, cap at 3/10.
6. Output a prioritized list with:
   - implementation notes (for Medium/High clarity)
   - open questions (for Low clarity)

Do not infer missing requirements. Ask questions instead.
