---
name: codex-review
description: Have OpenAI Codex review the current branch with documentation research. Use for second-opinion code reviews or when you want cross-AI verification.
allowed-tools: Bash, Read, Glob, Grep
---

# Codex Review

Invoke OpenAI's Codex CLI to review the current branch, with instructions to research relevant documentation before reviewing.

## When to Use

- You want a second opinion on your implementation
- You want cross-verification between different AI models
- The implementation uses tools/libraries where current docs would help
- You've completed a feature and want thorough review before merging

## Prerequisites

- Codex CLI installed (`codex --version` works)
- Valid OpenAI authentication (`codex login` completed)
- On a feature branch with commits to review

## Workflow

Copy this checklist and track progress:

```
Codex Review Progress:
- [ ] Step 1: Verify Codex CLI available
- [ ] Step 2: Gather branch context
- [ ] Step 3: Generate review prompt
- [ ] Step 4: Invoke Codex
- [ ] Step 5: Present results
```

## Step 1: Verify Codex CLI

```bash
codex --version
```

If not installed, inform the user and stop.

## Step 2: Gather Branch Context

Collect information about the current branch:

```bash
# Current branch name
git branch --show-current

# Commits on this branch (vs main)
git log --oneline main..HEAD 2>/dev/null || git log --oneline -10

# Changed files summary
git diff main...HEAD --stat 2>/dev/null || git diff HEAD~5 --stat

# Get the base branch if not main
git merge-base main HEAD 2>/dev/null
```

## Step 3: Generate Review Prompt

Write a prompt file to the scratchpad directory with this structure:

```markdown
# Pre-Review Research (REQUIRED)

Before reviewing the code, research the following documentation:

1. **[Technology-specific docs]**: Based on the files changed, identify key technologies and instruct Codex to research their current documentation.

2. **Project-specific patterns**: If there's a CLAUDE.md, AGENTS.md, or similar, reference the coding standards.

# Review Context

Branch: `{branch_name}`
Commits: {commit_count} commits
Files changed: {file_count} files

## Commits on this branch:
{commit_list}

## Key Changes:
{summary_of_changes}

# Review Instructions

Provide a thorough code review covering:

1. **Correctness**: Logic errors, edge cases, potential bugs
2. **Best Practices**: Does the code follow established patterns?
3. **Consistency**: Are changes applied consistently?
4. **Documentation**: Are changes well-documented where needed?
5. **Potential Issues**: Security, performance, maintainability concerns

Use `git diff main...HEAD` to see the full changes.
Provide specific file:line references for any issues found.
Categorize findings by severity: critical, major, minor, suggestion.
```

## Step 4: Invoke Codex

```bash
# Create output file
OUTPUT_FILE="/tmp/codex-review-output-$(date +%s).txt"

# Execute with timeout (10 minutes default)
timeout 600 bash -c "cat {prompt_file} | codex exec \
  --sandbox danger-full-access \
  -c 'approval_policy=\"never\"' \
  -c 'features.search=true' \
  -o $OUTPUT_FILE \
  -"
EXIT_CODE=$?

# Handle exit codes
if [ $EXIT_CODE -eq 124 ]; then
  echo "ERROR: Codex timed out after 10 minutes"
  # Partial output may still be available
elif [ $EXIT_CODE -ne 0 ]; then
  echo "ERROR: Codex exited with code $EXIT_CODE"
fi

# Read and clean up
if [ -f "$OUTPUT_FILE" ]; then
  CODEX_OUTPUT=$(cat "$OUTPUT_FILE")
  rm -f "$OUTPUT_FILE"
else
  echo "WARNING: No output file produced"
fi
```

**Flags explained:**
- `--sandbox danger-full-access`: Enables network access for documentation research
- `-c 'approval_policy="never"'`: Non-interactive execution
- `-c 'features.search=true'`: Enable web search for documentation research
- `-o $OUTPUT_FILE`: Write final response to file for reliable parsing
- `-`: Read prompt from stdin
- `timeout 600`: 10 minute limit for review tasks

## Step 5: Present Results

Parse and present the Codex output to the user:

1. **Summary**: Quick overview of findings
2. **Critical/Major Issues**: Highlight anything requiring immediate attention
3. **Minor Issues & Suggestions**: List for consideration
4. **Positive Findings**: What Codex found well-done

Ask if the user wants to address any of the issues found.

## Error Handling

**If Codex CLI not found:**
```
Codex CLI is not installed or not in PATH.

Install: https://github.com/openai/codex
Then run: codex login
```

**If authentication fails:**
```
Codex authentication failed. Run:
  codex login
```

**If no commits on branch:**
```
No commits found on this branch relative to main.
Nothing to review.
```

**If Codex times out:**
- Report partial output if available
- Suggest running with a simpler prompt or fewer files

## Customization

The user can provide optional arguments:

- **Focus area**: `/codex-review security` - Focus review on security concerns
- **Base branch**: `/codex-review --base develop` - Compare against different base
- **Model**: `/codex-review --model o3` - Use specific Codex model

Parse these from the skill argument and adjust the prompt accordingly.
