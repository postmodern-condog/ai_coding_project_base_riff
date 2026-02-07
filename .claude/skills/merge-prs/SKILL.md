---
name: merge-prs
description: Merge multiple PRs with conflict resolution and CI failure auto-patching. Analyzes optimal merge order, resolves conflicts, pulls CI logs on failure, and fixes issues.
argument-hint: "[PR numbers] [--base BRANCH] [--strategy rebase|merge] [--dry-run] [--no-fix] [--no-security] [--force]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, AskUserQuestion
---

# Merge PRs

Merge multiple pull requests into a single integration branch with intelligent conflict resolution, risk scoring, security pre-flight, automated CI failure diagnosis, flaky test awareness, and bisection-based failure isolation.

## When to Use

- You have 2+ open PRs that need to land together or in sequence
- PRs may have conflicts with each other or with the base branch
- CI keeps failing on PRs and you want automated diagnosis + fixes
- You want to validate that all PRs work together before merging to main

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status` works)
- On a clean working tree (`git status` shows no uncommitted changes)
- All target PRs exist and are open

## Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `$1...$N` | No | all open | Space-separated PR numbers (e.g., `63 64 65 66`) |
| `--base` | No | `main` | Base branch to integrate against |
| `--strategy` | No | `merge` | `merge` (preserve commits) or `rebase` (linear history) |
| `--dry-run` | No | off | Analyze conflicts, risk, and order without merging |
| `--no-fix` | No | off | Skip auto-fix on CI failures (report only) |
| `--no-security` | No | off | Skip security pre-flight checks |
| `--force` | No | off | Proceed even if risk score is RED (>60) |

## Workflow

### Phase 0: Risk Assessment & Safety

Run this phase BEFORE any git operations. It gates whether the merge should proceed.

#### Step 0.1 — PR risk scoring

For each PR, compute a **risk score (0–100)** from these weighted factors:

| Factor | Weight | How to Compute |
|--------|--------|----------------|
| **Diff size** | 25% | `additions + deletions`. Score: 0–200 LOC → 0, 200–400 → 25, 400–800 → 50, 800+ → 100 |
| **File count** | 15% | Number of changed files. Score: 1–5 → 0, 6–15 → 30, 16–30 → 60, 30+ → 100 |
| **Hotspot overlap** | 25% | Files with high churn (>10 commits in last 90 days via `git log --since="90 days ago" --pretty=format: --name-only`). Score: (hotspot files in PR / total PR files) × 100 |
| **Test coverage ratio** | 20% | (test files changed / source files changed). Score: ratio ≥1.0 → 0, 0.5–1.0 → 30, <0.5 → 60, 0 tests → 100 |
| **PR staleness** | 15% | Days since PR branch diverged from base. Score: 0–3 days → 0, 4–7 → 30, 8–14 → 60, 14+ → 100 |

**Composite score**: Weighted average of all factors, rounded to nearest integer.

**Risk tiers**:
- **GREEN (0–30)**: Low risk — proceed automatically
- **YELLOW (31–60)**: Medium risk — proceed with caution, highlight concerns
- **RED (61–100)**: High risk — require `--force` or explicit user confirmation

Report risk scores:
```
Risk Assessment:
  PR  │ Score │ Tier   │ Top Factors
  ────┼───────┼────────┼─────────────────────────
  #64 │  12   │ GREEN  │ small diff, high test ratio
  #65 │   8   │ GREEN  │ tiny diff, no hotspots
  #66 │  34   │ YELLOW │ touches hotspot files
  #63 │  72   │ RED    │ 1149+742 LOC, 24 files, low test ratio
```

If any PR is RED and `--force` is not set, ask the user:
- "PR #63 has a RED risk score (72). Proceed anyway, skip this PR, or abort?"

#### Step 0.2 — PR classification (Rust-style tiers)

Auto-classify each PR into merge tiers based on its characteristics:

| Tier | Criteria | Merge Strategy |
|------|----------|----------------|
| **always** | Docs-only, test-only, config-only, <50 LOC | Batch freely, merge first |
| **maybe** | Standard feature/fix, 50–400 LOC, <10 files | Default — merge in dependency order |
| **iffy** | Touches CI config, build scripts, DB migrations, >400 LOC | Include sparingly, test carefully |
| **never** | >800 LOC, performance-sensitive, platform-dependent, >20 files | Merge individually, never batch |

**Detection heuristics**:
- `always`: All changed files match `*.md`, `*.test.*`, `*.config.*`, `.github/*`
- `iffy`: Changed files include `*.yml`, `*.toml`, `migrations/*`, `package.json`
- `never`: `additions + deletions > 800` OR `files > 20`
- `maybe`: Everything else

Report tiers alongside risk scores. Use tiers to compose the merge batch — `never`-tier PRs are excluded from batching and offered as individual merges after the batch.

#### Step 0.3 — Security pre-flight (skip if `--no-security`)

Run a lightweight security scan on each PR's diff:

**1. Secrets scan** — Check diff for high-entropy strings and known patterns:
```bash
gh pr diff <PR_NUMBER> | grep -iE '(api[_-]?key|secret|token|password|credential|private[_-]?key)\s*[:=]' || true
```

Also check for:
- AWS keys: `AKIA[0-9A-Z]{16}`
- Generic high-entropy: base64 strings >40 chars adjacent to key-like variable names
- `.env` file additions

**2. Dependency audit** — If `package.json` or `package-lock.json` changed:
```bash
# Check for new dependencies
gh pr diff <PR_NUMBER> -- package.json | grep '^\+.*"dependencies\|^\+.*"devDependencies' -A 50 | grep '^\+'
# Audit for known CVEs
npm audit --json 2>/dev/null | jq '.vulnerabilities | to_entries[] | select(.value.severity == "critical" or .value.severity == "high") | {name: .key, severity: .value.severity}'
```

**3. Report**:
```
Security Pre-flight:
  PR #63: ✓ No secrets detected, ✓ No new dependencies
  PR #65: ✓ No secrets detected, ⚠ package.json changed — 0 critical CVEs
  PR #66: ✓ Clean
```

**BLOCK** if secrets are detected (require user override). **WARN** on dependency changes with CVEs.

#### Step 0.4 — Pre-merge dry-run with `git merge-tree`

Before creating any branches, test mergeability using `git merge-tree` which operates entirely in the object database (no working tree changes):

```bash
# Fetch all PR branches
for PR in <pr-numbers>; do
  BRANCH=$(gh pr view $PR --json headRefName -q '.headRefName')
  git fetch origin "$BRANCH"
done

# Test pairwise mergeability (for conflict matrix)
git merge-tree --write-tree origin/<base> origin/<branch-A> 2>&1
# Exit code 0 = clean merge, non-zero = conflicts
# Output includes "CONFLICT" lines with file paths
```

This replaces the file-overlap heuristic from Phase 1 with **actual conflict detection**. Report results:

```
Dry-run Merge Results:
  main + #64: ✓ Clean merge
  main + #64 + #65: ✓ Clean merge
  main + #64 + #65 + #66: ✓ Clean merge
  main + #64 + #65 + #66 + #63: ⚠ 3 conflicts
    - src/lib/wizardScoring.ts (content conflict)
    - src/pages/api/properties.ts (content conflict)
    - package-lock.json (content conflict)
```

If `--dry-run` was specified and this step completes, STOP HERE and report the full analysis (risk scores, tiers, security, dry-run results).

---

### Phase 1: Discovery & Analysis

#### Step 1.1 — Gather PR metadata

```bash
gh pr list --state open --json number,title,headRefName,baseRefName,additions,deletions,files,mergeable,labels,createdAt
```

If specific PR numbers were given as arguments, filter to only those.
If no arguments, use ALL open PRs targeting the base branch.

For each PR, collect:
- PR number, title, branch name
- Changed files list (for conflict prediction)
- Addition/deletion count (for sizing)
- Mergeable status from GitHub
- Labels (for tier classification)
- Age (for staleness scoring)

Report a summary table:

```
PR  │ Branch                          │ Files │ +/-        │ Risk │ Tier   │ Mergeable
────┼─────────────────────────────────┼───────┼────────────┼──────┼────────┼──────────
#64 │ codex/run-codex-review-since-feb│ 3     │ +104/-2    │  12  │ always │ ✓
#65 │ codex/perform-automated-bug-scan│ 2     │ +6/-16     │   8  │ always │ ✓
#66 │ codex/assess-wizarddemo-flow    │ 4     │ +135/-26   │  34  │ maybe  │ ✓
#63 │ codex/run-tech-debt-check       │ 24    │ +1149/-742 │  72  │ never  │ ✓
```

#### Step 1.2 — Check CI status for each PR

For each PR, check the latest CI run status:

```bash
gh pr checks <PR_NUMBER> --json name,state,conclusion
```

Categorize each PR:
- **GREEN**: All checks passed
- **RED**: One or more checks failed
- **PENDING**: Checks still running
- **NONE**: No checks have run

If any PR is RED and `--no-fix` is NOT set, proceed to **Phase 2 (CI Triage)** for that PR before continuing.

If any PR is PENDING, wait up to 5 minutes (polling every 30s) then proceed.

#### Step 1.3 — Analyze pairwise conflicts

Use the `git merge-tree` results from Phase 0, Step 0.4. If Phase 0 was skipped (e.g., resumed mid-process), fall back to file overlap analysis:

```bash
# Get changed files for each PR
gh pr diff <PR_NUMBER> --name-only
```

Build a conflict matrix:
- **No overlap**: PRs touch completely different files — safe to merge in any order
- **File overlap**: Same file modified by multiple PRs — likely conflicts
- **Confirmed conflict**: `git merge-tree` reported CONFLICT — definite conflicts
- **High overlap**: >3 shared files — merge these adjacent in sequence

Report the conflict matrix:

```
Conflict Matrix (from dry-run merge):
         #63  #64  #65  #66
  #63     —    0    1✗   2✗  (✗ = confirmed conflict)
  #64     0    —    0    0
  #65     1✗   0    —    0
  #66     2✗   0    0    —

Confirmed conflicts: #63↔#66 (2 files), #63↔#65 (1 file)
```

#### Step 1.4 — Determine optimal merge order

**Ordering heuristic** (apply in priority):

1. **Dependency chain**: If PR-B's branch was created from PR-A's branch, merge A first. Detect via: `git merge-base --is-ancestor origin/<A> origin/<B>`
2. **Tier ordering**: `always` → `maybe` → `iffy`. `never`-tier PRs offered separately.
3. **Conflict minimization**: Merge PRs with fewest predicted conflicts first (greedy)
4. **Size ascending**: Smaller PRs first (fewer changes = fewer conflicts downstream)
5. **Test PRs first**: PRs that only add tests go before PRs that change implementation
6. **Refactors last**: Large refactoring PRs (high file churn) go last as they're most likely to conflict

Apply the heuristics and report the planned merge order:

```
Planned merge order:
  1. #64 (tier:always, tests only, 3 files, no conflicts)
  2. #65 (tier:always, small refactor, 2 files, no conflicts)
  3. #66 (tier:maybe, feature, 4 files, conflicts with #63)
  ────
  4. #63 (tier:never — offered separately, 24 files, conflicts with #65 #66)
```

Ask the user to confirm the merge order before proceeding. If a `never`-tier PR is included, highlight the risk.

---

### Phase 2: CI Triage (for RED PRs)

For each PR with failing CI checks:

#### Step 2.1 — Pull failure logs (structured extraction)

Use the **3-tier log retrieval chain** (see CI_DIAGNOSIS.md for details):

```bash
# Tier 1: Check Run Annotations (structured — file, line, message)
OWNER_REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
BRANCH=$(gh pr view <PR_NUMBER> --json headRefName -q '.headRefName')
RUN_ID=$(gh run list --branch "$BRANCH" --status failure --limit 1 --json databaseId -q '.[0].databaseId')

# Get check suite and check run IDs
gh api "repos/$OWNER_REPO/commits/$(gh pr view <PR_NUMBER> --json headRefOid -q '.headRefOid')/check-runs" \
  --jq '.check_runs[] | select(.conclusion == "failure") | {id, name, output: {annotations_count: .output.annotations_count}}'

# Get annotations (structured errors with file path + line number)
gh api "repos/$OWNER_REPO/check-runs/<CHECK_RUN_ID>/annotations" \
  --jq '.[] | {path: .path, line: .start_line, level: .annotation_level, message: .message}'
```

```bash
# Tier 2: Failed step logs (raw text — most common fallback)
gh run view "$RUN_ID" --log-failed 2>&1
```

```bash
# Tier 3: Full log tail (last resort)
gh run view "$RUN_ID" --log 2>&1 | tail -200
```

**Prefer Tier 1** when available — annotations give you structured `{file, line, message}` triples that can be directly mapped to edit operations. Fall through the chain on empty results.

#### Step 2.2 — Check for flaky tests

Before diagnosing a test failure as a real regression, check if it's a known flaky test:

**Flaky test detection strategy**:

1. **Check local flaky test registry** (if `.claude/flaky-tests.json` exists):
   ```json
   {
     "src/tests/someTest.test.ts::should handle concurrent requests": {
       "flake_count": 3,
       "last_flake": "2026-02-05",
       "last_pass": "2026-02-06"
     }
   }
   ```

2. **Check if the failing test file was modified by ANY of the PRs being merged**:
   - If NO PR modified the test or its source → likely flaky or infrastructure
   - If a PR DID modify the test's source → likely a real regression

3. **Retry strategy for suspected flakes**:
   ```bash
   gh run rerun <RUN_ID> --failed
   # Wait up to 10 minutes for result
   gh run watch <rerun_id> --exit-status
   ```
   - If the retry PASSES: flag as flaky, record in `.claude/flaky-tests.json`, continue
   - If the retry FAILS again: treat as genuine failure, proceed to diagnosis

4. **Never retry more than once.** Two consecutive failures = real failure regardless of flaky history.

#### Step 2.3 — Diagnose the failure

Parse the log output to identify the failure category:

| Category | Detection Pattern | Auto-fixable? |
|----------|-------------------|---------------|
| **TypeScript error** | `error TS\d+:` | Yes — read file, fix type |
| **ESLint violation** | `eslint.*error` or rule names | Yes — `npm run lint:fix` |
| **Test failure** | `FAIL.*\.test\.` or `AssertionError` | Maybe — read test + source |
| **Build error** | `Could not resolve`, `Module not found` | Yes — fix imports |
| **Env/secret missing** | `SUPABASE`, `API_KEY`, `undefined` | No — report to user |
| **Dependency issue** | `npm ERR!`, `ERESOLVE` | Maybe — `npm ci` or fix versions |
| **Timeout/infra** | `exceeded`, `SIGTERM`, `ENOMEM`, `ETIMEDOUT` | No — retry once, then report |

Report the diagnosis:
```
CI Failure Analysis for PR #63:
  Step: TypeCheck (step 4/7)
  Category: TypeScript error
  Error: src/pages/api/foo.ts(42,5): error TS2345: Argument of type 'string' is not assignable...
  Flaky: No (file was modified by this PR)
  Auto-fixable: Yes
```

#### Step 2.4 — Attempt auto-fix

If the failure IS auto-fixable and `--no-fix` is NOT set:

1. **Checkout the PR branch**:
   ```bash
   gh pr checkout <PR_NUMBER>
   ```

2. **Apply the fix** based on category:
   - **TypeScript errors**: Read the file, understand the type mismatch, apply minimal fix
   - **ESLint violations**: Run `npm run lint:fix`, if that doesn't fully resolve, manual edit
   - **Build errors**: Fix import paths, missing exports, module resolution
   - **Test failures**: Read both the test file and the source file. Determine if the test expectation is wrong (update test) or the source has a bug (fix source). **Never delete or skip tests.**

3. **Verify the fix locally**:
   ```bash
   .workstream/verify.sh
   ```

4. **If verify passes**, commit and push:
   ```bash
   git add <specific-files>
   git commit -m "$(cat <<'EOF'
   fix: resolve CI failure — <description>

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   EOF
   )"
   git push
   ```

5. **If verify fails again**, report the new failure to the user and ask whether to:
   - Attempt another fix (max 2 retries per PR)
   - Skip this PR and continue with others
   - Abort the merge process

**IMPORTANT**: After pushing a fix, wait for CI to start (up to 60s) and note that the full CI result will be validated in Phase 3.

If the failure is NOT auto-fixable, report to user:
```
PR #63 has a non-auto-fixable CI failure:
  Category: Missing environment secret
  Details: PUBLIC_SUPABASE_URL is not set in CI secrets
  Action needed: Add the secret in GitHub Settings → Secrets
```

Ask: "Skip this PR and continue, or abort?"

---

### Phase 3: Integration Merge

#### Step 3.1 — Create safety tag and integration branch

**Create a safety tag** before any merging (rollback point):
```bash
git checkout <base-branch>
git pull origin <base-branch>
git tag "pre-merge/$(date +%Y%m%d-%H%M%S)" <base-branch>
```

**Create the integration branch**:
```bash
git checkout -b integrate/<timestamp-or-descriptive-name>
```

Use a descriptive name when possible:
- `integrate/prs-63-64-65-66` for specific PRs
- `integrate/all-open-<date>` for all open PRs

#### Step 3.2 — Merge PRs sequentially (in determined order)

For each PR in the planned merge order:

```bash
# Fetch the PR's branch
git fetch origin <pr-branch>

# Attempt merge
git merge origin/<pr-branch> --no-edit
```

**If merge succeeds** (no conflicts):
```
✓ PR #64 merged cleanly
```

**If merge has conflicts**:

1. List conflicting files:
   ```bash
   git diff --name-only --diff-filter=U
   ```

2. For each conflicting file, read the conflict markers.

3. **Resolve conflicts intelligently**:

   **Strategy per conflict type:**

   | Conflict Type | Resolution Strategy |
   |---------------|---------------------|
   | **Import additions** (both PRs add imports) | Keep both, deduplicate |
   | **Adjacent line changes** (non-overlapping logic) | Keep both changes |
   | **Same line, different changes** | Analyze intent — usually the later PR's change incorporates the earlier one |
   | **Structural conflicts** (moved/renamed code) | Prefer the refactoring PR's structure, re-apply the other PR's logic changes |
   | **Type definition conflicts** | Union the type changes from both PRs |
   | **Test file conflicts** | Keep all tests from both PRs |
   | **package-lock.json** | `git checkout --theirs package-lock.json && npm install && git add package-lock.json` |

   **Decision framework**: Read enough context around the conflict to understand what each PR was trying to accomplish. The goal is to preserve BOTH PRs' intent. If unclear, ask the user.

4. After resolving all conflicts in a file, verify the file is syntactically valid (run `tsc --noEmit` on the file if TypeScript).

5. Mark resolved and continue:
   ```bash
   git add <resolved-files>
   git commit --no-edit
   ```

6. Report:
   ```
   ⚠ PR #66 had 2 conflicts:
     - src/lib/wizardScoring.ts: import additions (auto-resolved)
     - src/pages/wizarddemo.astro: adjacent changes (auto-resolved)
   ```

#### Step 3.3 — Run local verification

After ALL PRs are merged into the integration branch:

```bash
.workstream/verify.sh
```

**If all checks pass**:
```
✓ Integration branch passes all checks (typecheck, lint, test, build)
```
Proceed to Phase 4.

**If any check fails** and `--no-fix` is NOT set:

1. Diagnose the failure (same as Phase 2, Step 2.3)
2. These are likely **integration issues** — failures that only appear when multiple PRs combine:
   - Duplicate identifiers from merged imports
   - Type conflicts from independently modified interfaces
   - Test failures from changed behavior assumptions
3. Fix the integration issues
4. Re-run verification
5. Max 3 fix-verify cycles. If still failing after 3 attempts, proceed to **bisection** (Step 3.4).

When fixes are applied, commit them as:
```
fix: resolve integration conflicts between PRs #X and #Y

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

#### Step 3.4 — Bisection on persistent failure

If verification fails after 3 fix attempts, use **binary bisection** to isolate which PR introduced the failure:

**Algorithm**:
1. Split the merged PRs into two halves (by merge order)
2. Create a test branch with only the first half merged onto base
3. Run `.workstream/verify.sh` on the half-branch
4. If it passes → the culprit is in the second half. If it fails → culprit is in the first half.
5. Recurse into the failing half until a single PR is isolated.

```bash
# Example: 4 PRs merged, bisect into halves
git checkout <base-branch>
git checkout -b bisect-test
git merge origin/<pr-1-branch> --no-edit
git merge origin/<pr-2-branch> --no-edit
# Run verification on first half
.workstream/verify.sh
```

**For N PRs, this requires at most log2(N) verification runs** (e.g., 4 PRs = 2 runs, 8 PRs = 3 runs).

Once the culprit PR is identified:
```
Bisection result: PR #63 is the source of the integration failure.
  Failing check: test (vitest)
  Error: Expected computeScore to return 42, got 37
  The other 3 PRs (#64, #65, #66) integrate cleanly without #63.
```

Ask user:
- "Merge the passing subset (#64, #65, #66) without #63?"
- "Attempt to fix #63's integration issues?"
- "Abort entirely?"

---

### Phase 4: Finalize

#### Step 4.1 — Summary report

Present a complete summary:

```
Integration Summary
═══════════════════

Branch: integrate/prs-63-64-65-66
Base: main
Safety tag: pre-merge/20260207-143022

Risk scores: #64 (12/GREEN), #65 (8/GREEN), #66 (34/YELLOW), #63 (72/RED)
Security: ✓ No issues detected

PRs merged (in order):
  1. ✓ #64 — Add unit tests for wizard demo scoring helpers (clean)
  2. ✓ #65 — Update wizard demo scoring to reuse shared carry cost helper (clean)
  3. ⚠ #66 — Improve wizard demo predictions (2 conflicts resolved)
  4. ⚠ #63 — Refactor ID routes and services (5 conflicts resolved)

CI fixes applied:
  - PR #63: Fixed TypeScript error in src/pages/api/foo.ts
  - PR #66: Retried flaky test (passed on retry)

Integration fixes:
  - Resolved duplicate import in src/lib/wizardScoring.ts

Verification: ✓ All checks pass (typecheck, lint, test, build)
Total commits on integration branch: <N>
```

#### Step 4.2 — Generate changelog preview

Parse merged PR titles and categorize by conventional commit type:

```
Changelog Preview:
──────────────────
### Features
- Improve wizard demo predictions and explainability inputs (#66)

### Bug Fixes
- Update wizard demo scoring to reuse shared carry cost helper (#65)

### Refactoring
- Refactor ID routes and services for tech debt cleanup (#63)

### Tests
- Add unit tests for wizard demo scoring helpers (#64)
```

If PR titles do not follow conventional commit format, infer type from:
- Labels: `enhancement` → feat, `bug` → fix, `documentation` → docs
- File patterns: only `.test.*` files → test, only `.md` files → docs
- PR title keywords: "add" → feat, "fix" → fix, "refactor" → refactor, "update" → fix

Include this changelog in the PR body (Option 3) or commit message (Options 1/2).

#### Step 4.3 — Ask user for merge strategy

Present options:

```
How would you like to proceed?

1. Merge integration branch → main (squash)
   Creates a single commit on main with all changes

2. Merge integration branch → main (merge commit)
   Preserves individual PR commits with a merge commit

3. Close individual PRs and push integration branch (Recommended)
   Push the integration branch and create a new combined PR

4. Keep integration branch for review
   Don't merge yet — inspect the branch first
```

**Default recommendation**: Option 3 (new combined PR) — it preserves auditability and lets CI run on the combined result before merging to main.

#### Step 4.4 — Execute chosen strategy

**Option 1 (squash)**:
```bash
git checkout main
git merge --squash integrate/<name>
git commit -m "$(cat <<'EOF'
feat: merge PRs #63, #64, #65, #66

- #63: Refactor ID routes and services for tech debt cleanup
- #64: Add unit tests for wizard demo scoring helpers
- #65: Update wizard demo scoring to reuse shared carry cost helper
- #66: Improve wizard demo predictions and explainability inputs

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```
Then ask before pushing.

**Option 2 (merge commit)**:
```bash
git checkout main
git merge integrate/<name> --no-ff -m "merge: integrate PRs #63 #64 #65 #66"
```
Then ask before pushing.

**Option 3 (new PR)**:
```bash
git push -u origin integrate/<name>
gh pr create --base main --title "Integrate PRs #63, #64, #65, #66" --body "$(cat <<'EOF'
## Summary
Combined integration of multiple PRs with conflict resolution.

### PRs included
- #63: Refactor ID routes and services for tech debt cleanup
- #64: Add unit tests for wizard demo scoring helpers
- #65: Update wizard demo scoring to reuse shared carry cost helper
- #66: Improve wizard demo predictions and explainability inputs

### Risk Assessment
| PR | Score | Tier |
|----|-------|------|
| #64 | 12 | GREEN |
| #65 | 8 | GREEN |
| #66 | 34 | YELLOW |
| #63 | 72 | RED |

### Conflicts resolved
- {list of resolved conflicts}

### CI fixes applied
- {list of CI fixes}

### Changelog
{changelog preview from Step 4.2}

## Test plan
- [x] All individual PR tests pass
- [x] Integration verification passes (typecheck, lint, test, build)
- [x] Security pre-flight passed
- [ ] Manual review of conflict resolutions

Generated with [Claude Code](https://claude.com/claude-code) `/merge-prs`
EOF
)"
```

**Option 4 (keep for review)**:
Report the branch name and how to inspect it. No further action.

#### Step 4.5 — Post-merge validation (Options 1/2 only)

If the user chose to merge directly to main (Options 1 or 2):

1. **Poll CI on the merge commit** (up to 15 minutes):
   ```bash
   # Get the merge commit SHA
   MERGE_SHA=$(git rev-parse HEAD)
   # Wait for CI to complete
   gh run list --commit "$MERGE_SHA" --limit 1 --json databaseId,status,conclusion
   ```

2. **If CI passes**: Report success. Clean up:
   ```
   ✓ Post-merge CI passed. Integration complete.
   Safety tag 'pre-merge/20260207-143022' can be deleted when you're confident.
   ```

3. **If CI fails**: Automatically draft a revert PR:
   ```bash
   git checkout -b revert/integrate-<name> main
   git revert -m 1 HEAD --no-edit
   git push -u origin revert/integrate-<name>
   gh pr create --title "Revert: Integrate PRs #63, #64, #65, #66" --body "$(cat <<'EOF'
   ## Revert Reason
   Post-merge CI failed after integrating PRs #63, #64, #65, #66.

   **Failure**: {failure description from CI logs}

   ## Rollback
   This reverts the integration merge commit. The original integration
   branch `integrate/<name>` is preserved for debugging.

   Safety tag: `pre-merge/20260207-143022`
   EOF
   )"
   ```

   Report: "Post-merge CI failed. Revert PR drafted: <URL>. Review and merge to rollback."

---

### Phase 5: Cleanup

After the integration PR is merged (Option 3) or the direct merge succeeds (Options 1/2), **automatically prompt** for full cleanup. Do NOT wait for the user to ask.

#### Step 5.1 — Prompt for cleanup

Present the cleanup plan:

```
Integration complete! Ready to clean up?

This will:
  • Close original PRs #63, #64, #65, #66 (with "Included in #67" comment)
  • Delete remote branches for all original PRs
  • Delete the integration branch (local + remote)
  • Delete the safety tag
  • Switch to main and pull latest
  • Prune stale remote-tracking references
  • Delete local branches whose remotes are gone

Proceed? [Y/n]
```

If the user confirms (or says nothing indicating yes), execute all cleanup steps. If they decline, report what manual steps they'd need to take later.

#### Step 5.2 — Execute cleanup

**Close original PRs and delete their remote branches:**
```bash
for PR in <pr-numbers>; do
  gh pr close $PR --comment "Included in integration PR #<integration-pr>" --delete-branch
done
```

**Switch to main and pull:**
```bash
git checkout main
git pull origin main
```

**Delete local integration branch:**
```bash
git branch -D integrate/<name> 2>/dev/null
```

**Delete safety tag:**
```bash
git tag -d pre-merge/<timestamp> 2>/dev/null
```

**Prune stale remotes and delete orphaned local branches:**
```bash
git fetch --prune
# Delete local branches whose remote tracking branch is gone
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D
```

**Verify clean state:**
```bash
git status
git branch
```

#### Step 5.3 — Report final state

```
Cleanup Complete
════════════════
  ✓ PRs #63, #64, #65, #66 closed
  ✓ Remote branches deleted (4 PR branches + integration)
  ✓ Local integration branch deleted
  ✓ Safety tag deleted
  ✓ On main, up to date with origin

  Remaining local branches:
    * main
    (list any other local branches that still have remotes)

  Ready for new work.
```

---

## Error Handling

### Fatal errors (abort immediately)
- `gh auth status` fails → "Please run `gh auth login` first"
- Base branch doesn't exist → "Branch `<name>` not found"
- No open PRs found → "No open PRs targeting `<base>`"

### Recoverable errors
- Single PR fails to merge → Ask user: skip or abort
- CI fix fails after retries → Report and ask: skip PR or abort
- Integration verification fails → Bisect, then offer partial merge or abort
- Post-merge CI fails → Draft revert PR

### Cleanup on abort
If aborting mid-process:
```bash
git merge --abort 2>/dev/null
git checkout <original-branch>
git branch -D integrate/<name> 2>/dev/null
git branch -D bisect-test 2>/dev/null
```
Report: "Integration aborted. Cleaned up integration branch. You're back on `<original-branch>`."

**Safety tags are NEVER deleted automatically.** Report their names so the user can clean up when ready.

---

## CI Log Quick-Reference

Common `gh` commands used by this skill:

```bash
# Check Run Annotations (structured errors — best for auto-fix)
gh api repos/{owner}/{repo}/check-runs/{id}/annotations \
  --jq '.[] | {path, line: .start_line, level: .annotation_level, message}'

# List failed runs for a branch
gh run list --branch <BRANCH> --status failure --limit 3 --json databaseId,name,conclusion,startedAt

# Get failed step output
gh run view <RUN_ID> --log-failed

# Get full run log (fallback)
gh run view <RUN_ID> --log 2>&1 | tail -300

# Watch a run in progress
gh run watch <RUN_ID> --exit-status

# Re-run only failed jobs (for flaky test retry)
gh run rerun <RUN_ID> --failed

# Check PR status
gh pr checks <PR_NUMBER>
```

## Guardrails

- **NEVER force-push** to any branch during this process
- **NEVER delete remote branches** without explicit user confirmation (Phase 5 cleanup prompt counts as confirmation)
- **NEVER delete safety tags** without explicit user confirmation (Phase 5 cleanup prompt counts as confirmation)
- **NEVER merge directly to main** without user confirmation at Step 4.3
- **NEVER auto-merge RED-tier PRs** without `--force` or explicit confirmation
- **NEVER suppress security findings** — always report detected secrets/CVEs
- **Max 2 auto-fix attempts per PR** (Phase 2), **max 3 for integration** (Phase 3)
- **Max 1 flaky test retry** per failing test — two failures = real failure
- **Always preserve the original integration branch** until user confirms success
- If conflict resolution is ambiguous, **always ask the user** rather than guessing
- **Commit CI and integration fixes with clear messages** — never silent fixes
