# Generator Prompt Updates (Proposed)

This document proposes updates to GENERATOR_PROMPT.md so that every acceptance
criterion is machine-verifiable (or explicitly marked human-only) and includes
verification metadata that tooling can consume.

## 1) Add Verification Metadata to Task Format

Proposed addition under each task in EXECUTION_PLAN.md:

```
**Acceptance Criteria:**
- [ ] (TEST) User can log in with email and password
  - Verify: test "should log in with email and password"
- [ ] (BROWSER:DOM) Login form shows email and password fields
  - Verify: route /login, selector [data-testid="login-form"]
- [ ] (MANUAL) Copy matches brand tone
  - Reason: subjective review
```

Notes:
- Require a verification type for every criterion.
- Require a verification method (test name, command, route/selector, or manual
  reason).
- Keep manual criteria to a minimum (suggest: max 1 per task).

## 2) Define Verification Types in PART 2

Add a small glossary in PART 2 of GENERATOR_PROMPT.md:

```
Verification Types:
- TEST: Verified by running a test (name or file path).
- LINT: Verified by lint command.
- TYPE: Verified by typecheck command.
- BUILD: Verified by build command.
- SECURITY: Verified by security scan.
- BROWSER:DOM|VISUAL|NETWORK|CONSOLE|PERFORMANCE|ACCESSIBILITY: Verified via MCP.
- MANUAL: Requires human judgment. Must include a reason.
```

## 3) Pre-Phase Setup with Check Method

Update Pre-Phase Setup items to include a verification check:

```
### Pre-Phase Setup
- [ ] ENV VAR: STRIPE_API_KEY
  - Verify: `printenv STRIPE_API_KEY`
- [ ] SERVICE: Redis reachable
  - Verify: `redis-cli ping`
```

## 4) Phase Checkpoint Format

Require explicit automation vs manual sections, and allow browser checks to be
expressed in the same verification schema:

```
### Phase 1 Checkpoint

**Automated:**
- [ ] Tests pass
- [ ] Lint passes
- [ ] Coverage >= 80%

**Human Required:**
- [ ] Validate onboarding copy tone
  - Reason: subjective content review
```

## 5) Task Quality Checks (Generator Prompt)

Add these checks to the "Task quality checks" list:
- Every acceptance criterion includes a verification type.
- Every acceptance criterion includes a verification method.
- Manual criteria include a reason and are kept to a minimum.

Add these to "Red flags":
- Criterion lacks verification type or method.
- Manual criteria used without a reason.

## 6) AGENTS.md Guidance (Small Additions)

Recommend a short note in AGENTS.md (if space allows):
- Agents must use verification metadata from EXECUTION_PLAN.md.
- If metadata is missing, add it and confirm ambiguous methods.

## 7) Spec Verification Updates (Optional)

Update spec-verification rules to flag criteria missing verification metadata as
CRITICAL (new Q-EP rule), once the format is adopted.
