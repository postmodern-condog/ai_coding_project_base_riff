# Evaluation Best Practices

For reliable multi-model verification, follow these patterns.

## Rubric-First Approach

Define clear evaluation criteria in the prompt before asking for verification. The prompt template uses structured categories (Completeness, Correctness, Clarity, Best Practices) as a rubric.

## Severity Classification

Use consistent severity levels:
- **CRITICAL**: Blocks progress, must be addressed
- **RECOMMENDATION**: Should be considered, doesn't block
- **POSITIVE**: Reinforces good patterns

This aligns with [OpenAI's evaluation best practices](https://platform.openai.com/docs/guides/evaluation-best-practices) for LLM-as-judge patterns.

## Handling Model Disagreement

When Claude and Codex disagree, follow these guidelines:

| Scenario | Action |
|----------|--------|
| **Both agree: PASS** | High confidence, proceed |
| **Both agree: NEEDS_ATTENTION** | High confidence, address issues |
| **Claude: PASS, Codex: NEEDS_ATTENTION** | Review Codex's specific findings — it may have researched current docs |
| **Claude: NEEDS_ATTENTION, Codex: PASS** | Trust Claude's context awareness, but note the disagreement |
| **Conflicting critical issues** | Present both perspectives to user for decision |

## Disagreement Signals

- If models disagree on >50% of findings, flag for human review
- If one model finds critical issues the other missed, always surface them
- Never silently discard findings from either model

## Resolution Strategies

1. **Union approach** (default): Surface all unique findings from both models
2. **Intersection approach**: Only flag issues both models identified (higher precision, lower recall)
3. **Weighted approach**: Weight findings by model strength (e.g., Codex for current docs, Claude for context)

**When in doubt:** Present disagreements to the user with context from both models. The goal is catching blind spots, not achieving false consensus.

## Portability Note

This skill uses the `.claude/skills/` directory structure with `allowed-tools` in YAML frontmatter, which is a convention in this toolkit.

For reference, official Claude Code documentation describes:
- Custom slash commands in `.claude/commands/`
- Subagents in `.claude/agents/` with `tools` field

See [Anthropic's slash commands documentation](https://docs.anthropic.com/en/docs/claude-code/slash-commands) for the official format.
