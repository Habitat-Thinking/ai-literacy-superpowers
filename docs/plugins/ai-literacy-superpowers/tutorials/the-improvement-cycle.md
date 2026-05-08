---
title: The Improvement Cycle
---
# The Improvement Cycle

This tutorial walks you through one complete improvement cycle: a
project assessed at Level 2 that you will take to Level 3 using the
assessment's improvement plan, then verify with a re-assessment.

Level 2 (Verification) means a project has automated tests, CI, and
systematic verification of AI output — but hasn't yet invested in
habitat engineering. Level 3 (Habitat Engineering) is the jump from
checking output to shaping input: you give AI agents the context,
constraints, and memory they need to work reliably without constant
correction.

Plan for thirty to forty-five minutes the first time through. The
cycle gets faster once the commands are familiar.

---

## Starting Point

Your project has:

- A CI workflow that runs tests
- A passing test suite
- Possibly some vulnerability scanning
- No `CLAUDE.md` (no context file for AI agents)
- No `HARNESS.md` (no declared constraints or enforcement)
- No `REFLECTION_LOG.md` (no captured learning)

This is a typical L2 project: the verification infrastructure exists,
but the habitat is empty. AI agents working in this repo have no
project-specific context — they operate on generic knowledge and
whatever they can infer from the code.

---

## Step 1: Run `/assess`

Open Claude Code in your project directory and run:

```text
/assess
```

The assessment runs in phases and takes about ten minutes.

### Phase 1: Observable evidence

The command scans your repository for signals at each framework level.
It checks for CI workflows, test coverage enforcement, vulnerability
scanning, `CLAUDE.md`, `HARNESS.md`, custom skills and agents,
specification files, and more. This takes a few seconds:

```text
Scanning repository for observable evidence...

Level 2 signals found:
  CI workflow:        .github/workflows/ci.yml ✓
  Test framework:     Jest (package.json) ✓
  Test enforcement:   npm test in CI ✓

Level 3 signals — not found:
  CLAUDE.md:          missing
  HARNESS.md:         missing
  Custom skills:      none
  REFLECTION_LOG.md:  missing
  Hooks config:       missing

Level 4+ signals — not found
```

### Phase 2: Clarifying questions

The command asks three to five questions to fill gaps that the scan
cannot answer — things like whether you verify AI output systematically
or whether the team has shared AI conventions. Answer these concretely.

```text
Question 1/4:
Do you verify AI-generated code before committing, or do you commit
if it looks right at a glance?

→ We run the tests, but no more than that.

Question 2/4:
Does your team have any shared conventions for how to prompt or work
with AI tools, or does each developer do it differently?

→ No shared conventions. Everyone works differently.
```

### Phase 3: Level assessment

After the questions, the command applies the scoring heuristic. The
assessed level is the highest level where you have substantial evidence
across all three disciplines: context engineering, architectural
constraints, and guardrail design. The weakest discipline sets the
ceiling.

```text
Assessment summary:

  Primary level:     L2 — Verification
  Context eng.:      L2 (tests in CI, no context file)
  Constraints:       L1 (no declared constraints)
  Guardrails:        L2 (CI gates, no agent constraints)

  Rationale: Tests are running in CI and AI output is verified,
  but there is no context file for AI agents and no declared
  constraints. Constraints are the weakest discipline at L1.

  Assessed level: L2
```

### Phase 4: Assessment document

The command writes a timestamped document to
`assessments/YYYY-MM-DD-assessment.md` with the full evidence list,
discipline scores, strengths, gaps, and recommendations. This document
drives the improvement plan.

{: .note }
> **Immediate adjustments.** After producing the assessment document,
> the command identifies habitat hygiene fixes it can apply right now
> without requiring discussion — updating a stale badge count, adding
> a missing entry to AGENTS.md. Review and accept or reject each one.
> These are small fixes, not the improvement plan.

---

## Step 2: Review the Gaps

After the immediate adjustments, the command shows you the gaps it
identified — what's missing for the next level:

```text
Gaps (what's needed for Level 3):

  1. No CLAUDE.md — agents have no project context
  2. No HARNESS.md — no declared constraints or enforcement
  3. No REFLECTION_LOG.md — no captured learning from sessions
  4. No harness constraints enforced in CI
```

Read through these. They are the raw input for the improvement plan.

The gaps also appear in section 7 of the assessment document, where
they are paired with specific recommendations — the commands and skills
that address each gap.

---

## Step 3: Choose Target Level

After the workflow operation recommendations (things you can do
differently with what you already have), the assessment invokes the
improvement plan. It first asks where you want to go:

```text
You're currently at Level 2 (Verification).

How far would you like to improve?

1. Level 3 — Habitat Engineering (recommended next step)
2. Level 4 — Specification Architecture
3. Level 5 — Sovereign Engineering
```

Choose Level 3. The plan generates improvements for the L2→L3
transition only. If you had chosen L4, the plan would include L2→L3
improvements first, then L3→L4 — higher targets include all
intermediate steps.

The plan then checks which L3 items are already closed. In our
starting project, none are:

```text
Generating improvement plan for L2 → L3...

Checking existing state:
  CLAUDE.md:         missing — gap open
  HARNESS.md:        missing — gap open
  REFLECTION_LOG.md: missing — gap open
  Hooks config:      missing — gap open
  CI enforcement:    not configured — gap open

Plan: 4 items (1 high, 2 medium, 1 low)
```

---

## Step 4: Walk Through the Improvement Plan

The plan presents one item at a time. You choose Accept, Skip, or
Defer for each.

**Accept** runs the command or skill immediately and waits for it to
finish before moving on.

**Skip** removes the item from this session and does not record it for
later.

**Defer** keeps the item in the plan but does not execute it now. It
appears in the next assessment's improvement plan as a carried-forward
item.

### Item 1: Run `/harness-init` (High priority)

```text
Improvement 1/4 (Level 2 → Level 3):
  Gap:      No CLAUDE.md or HARNESS.md — agents have no context or
            constraints
  Action:   Run /harness-init
  Priority: High — foundational. HARNESS.md is the L3 prerequisite.
            Nothing else at this level works without it.

  Accept / Skip / Defer?
```

Accept this one. `/harness-init` runs immediately — it discovers your
stack, walks you through a short convention interview, and generates
`HARNESS.md` and `CLAUDE.md`.

The discovery phase shows what the agent found:

```text
Scanning project structure...

Stack
  Primary language: TypeScript
  Build system:     npm / tsc
  Test framework:   Jest
  CI:               GitHub Actions (.github/workflows/ci.yml)

Existing enforcement
  Prettier configured (.prettierrc)
  ESLint configured (.eslintrc.json)
  No pre-commit hooks detected
  No secret scanner detected

Convention documentation
  README.md (found)
  No CLAUDE.md detected
```

The convention interview covers naming conventions, file structure,
error handling, and documentation standards — one topic at a time.
Answer specifically. The more concrete your answers, the more useful
`HARNESS.md` will be to agents.

After the interview, `HARNESS.md` is generated with your conventions
and initial constraints, `CLAUDE.md` is created with your stack
context, and a CI workflow is updated. The command commits both files.

Once `/harness-init` finishes, the improvement plan resumes with item 2.

### Item 2: Run `/harness-constrain` to promote a constraint (Medium priority)

```text
Improvement 2/4 (Level 2 → Level 3):
  Gap:      No secrets constraint — risk of accidental credential
            exposure in commits
  Action:   Run /harness-constrain to add a secret-scanning constraint
  Priority: Medium — closes a real security gap independently

  Accept / Skip / Defer?
```

Accept this one too. `/harness-constrain` asks what you want to
enforce, checks whether a tool is available (it looks for `gitleaks`),
and adds a constraint to `HARNESS.md`:

```text
Adding constraint: No secrets in source

gitleaks found at /usr/local/bin/gitleaks.

Constraint:
  Rule:        No API keys, tokens, passwords, or private keys in
               committed source files
  Enforcement: deterministic
  Tool:        gitleaks detect --source . --no-banner --exit-code 1
  Scope:       commit

Add this constraint? [Y/n]
```

Accept. The constraint is added to `HARNESS.md` and the enforcement
ratio updates. If gitleaks isn't installed, the constraint is added as
`unverified` — declared but not yet automated — with the install
command shown.

### Item 3: Run `/reflect` to capture the first reflection (Medium priority)

```text
Improvement 3/4 (Level 2 → Level 3):
  Gap:      No REFLECTION_LOG.md — learning from AI sessions is lost
  Action:   Run /reflect to capture the first reflection entry
  Priority: Medium — starts the learning loop that compounds over time

  Accept / Skip / Defer?
```

Accept. `/reflect` asks you three questions:

```text
What was just worked on?
→ Set up the project harness and ran the first AI literacy assessment.

What was surprising or unexpected?
→ The test coverage threshold was configured in package.json but not
  enforced in CI — we thought it was running.

What should future agents know about this area of the codebase?
→ Coverage enforcement is handled by the Jest config, not a separate
  tool. The CI step is "npm test", which runs Jest with coverage.
```

After you answer, `/reflect` classifies the signal type — in this
case, the coverage gap is a `failure` signal — and proposes a
constraint:

```text
Signal: failure — the coverage threshold existed but wasn't running.
This is a preventable check that should have caught the gap.

Proposed constraint:
  Rule:        Test coverage must meet the threshold defined in
               package.json before merging
  Enforcement: deterministic
  Tool:        npm test (Jest --coverage with threshold)
  Scope:       pr

Add this constraint? [Y/n]
```

Accept. The reflection entry is appended to `REFLECTION_LOG.md` and
the new constraint is added to `HARNESS.md`. The enforcement ratio
increases again.

### Item 4: Add hooks configuration (Low priority)

```text
Improvement 4/4 (Level 2 → Level 3):
  Gap:      No hooks configuration — commit-time constraints run
            in CI but not locally
  Action:   Configure pre-commit hooks via harness-engineering skill
  Priority: Low — useful but not blocking. CI enforcement exists.

  Accept / Skip / Defer?
```

Defer this one. You've already closed the most important gaps. Hooks
are a refinement that makes the developer experience faster (local
feedback instead of CI feedback), but the constraints are enforced
either way. You'll revisit this next quarter.

The plan records the deferred item and moves on.

---

## Step 5: Verify the New Harness

After the improvement plan completes, check what was built:

```text
/harness-status
```

Output:

```text
## Harness Status

Last audit: 2026-04-08 (0 days ago)

### Constraints: 3/3 enforced
- Deterministic: 3 (tool-backed)
  • Consistent formatting (Prettier, commit scope)
  • No secrets in source (gitleaks, commit scope)
  • Tests must pass with coverage threshold (Jest, pr scope)
- Agent:       0
- Unverified:  0

### Garbage Collection: 1/1 active
- Documentation freshness (weekly, agent)

### Drift: none detected

### Next Steps
- Run /harness-constrain to add or promote constraints
- Run /harness-audit for a full verification
```

All three constraints are enforced. The enforcement ratio is 3/3 —
every declared constraint is backed by a tool. This is the L3 target
state for constraints.

Open `HARNESS.md` to see the full picture: the Context section
records your conventions, the Constraints section shows the three
enforcement rules with their tools and scopes, and the Garbage
Collection section shows the weekly documentation freshness check.

---

## Step 6: Re-assess

Now re-run the assessment to see whether the improvements moved the
level:

```text
/assess
```

The scan finds the new files:

```text
Scanning repository for observable evidence...

Level 2 signals found:
  CI workflow:        .github/workflows/ci.yml ✓
  Test framework:     Jest (package.json) ✓
  Test enforcement:   npm test in CI ✓

Level 3 signals found:
  CLAUDE.md:          ✓
  HARNESS.md:         ✓ (3 constraints, 3 enforced)
  REFLECTION_LOG.md:  ✓ (1 entry)
  Custom agents/skills: none
```

The clarifying questions this time focus on how the new constraints
are actually used — are pre-commit hooks running, is the coverage
threshold being checked, are agents reading CLAUDE.md at session
start? Answer based on what you've observed so far.

The assessment result:

```text
Assessment summary:

  Primary level:     L3 — Habitat Engineering
  Context eng.:      L3 (CLAUDE.md with conventions)
  Constraints:       L3 (HARNESS.md, 3/3 enforced)
  Guardrails:        L2 (CI gates, no agent-level constraints yet)

  Rationale: CLAUDE.md provides project context, HARNESS.md declares
  three enforced constraints. Guardrails are still at L2 — the
  harness enforces formatting, secrets, and test coverage but does
  not yet include agent-specific safety gates. Weakest discipline
  is Guardrails at L2, but L3 requires substantial evidence across
  all three disciplines — context and constraints meet the bar, and
  L2 guardrails are sufficient for L3.

  Assessed level: L3
```

The README badge updates automatically:

```text
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_3-20B2AA?style=flat-square)](assessments/2026-04-08-assessment.md)
```

---

## Step 7: The Compound Effect

Take stock of what changed in this session:

**Before:** A project with CI and tests but no context for AI agents.
Every session started from scratch — agents read the code but had no
conventions, no constraints, no captured learning.

**After:**

- `CLAUDE.md` gives agents your naming conventions, file structure
  rules, and error handling patterns before they write a single line
- `HARNESS.md` declares three enforced constraints — formatting,
  secrets, and coverage — backed by tools that run at commit and PR
  time
- `REFLECTION_LOG.md` has the first entry, with a constraint derived
  from a real gap the assessment surfaced

The compound effect is that each improvement makes the next one
faster. Agents reading `CLAUDE.md` need fewer corrections. Constraints
catching issues automatically free up review time. Reflections
accumulate domain knowledge that would otherwise be re-discovered in
each session.

The next cycle — typically in three months — will start from L3 and
target L4 (Specification Architecture). The gaps for L4 are different:
specification files before code, an agent pipeline with a safety gate,
implementation plans. The same process applies: assess, choose target,
walk the plan, verify.

---

## Step 8: Schedule the Next Assessment

The final summary from `/assess` includes a suggested next assessment
date — typically three months out:

```text
Next assessment: 2026-07-08
```

Add this to your calendar or team planning tool. When the date
arrives, running `/assess` again takes the same fifteen minutes but
starts from a stronger baseline. The assessment finds what regressed
(stale conventions, constraints that drifted) and what progressed
(new skills, new agents, higher coverage).

The improvement cycle is not a one-time upgrade. It is a quarterly
practice that compounds over time — each cycle starts from where the
last one left off, and the level reflects actual habits rather than
aspirations.

---

## What You Have Now

After completing this tutorial you have:

- A `CLAUDE.md` that gives AI agents project context for every future
  session
- A `HARNESS.md` with three enforced constraints — formatting,
  secrets, and test coverage — that run automatically at commit and
  PR time
- A `REFLECTION_LOG.md` with the first entry and a constraint derived
  from a real gap
- An AI literacy assessment document at
  `assessments/YYYY-MM-DD-assessment.md` recording the L2→L3 journey
- A README badge showing Level 3
- A scheduled re-assessment three months from now

---

## Next Steps

- [From Assessment to Dashboard](from-assessment-to-dashboard.md) — run
  a portfolio assessment across multiple repos and generate a shareable
  dashboard
- [Getting Started](getting-started.md) — back to basics if you haven't
  set up the plugin yet
- [How-to: Add a Constraint](../how-to/add-a-constraint.md) — add
  individual constraints without running the full init flow
- [Reference: Commands](../reference/commands.md) — full specification for
  `/assess`, `/harness-init`, `/reflect`, and `/harness-constrain`
