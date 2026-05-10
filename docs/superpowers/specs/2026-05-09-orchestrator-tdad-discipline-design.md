# Orchestrator + TDD-agent — TDAD discipline for agent artefacts — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-09 |
| Status | Draft — Amendment 2 applied 2026-05-09 (pivot); awaiting third-pass re-review |
| Author | claude-opus-4-7[1m] (interactive session) |
| Plugin version target | v0.36.0 (minor — behavioural change to two agents) |
| PR ceremony | feature — full diaboli (spec + code) and choice-cartograph |
| Related work | PR #285 (SDK runner for Layer 2/3), PR #305 (ONBOARDING regen with TDAD content), PR #308 (docs-strict-build constraint), `tdad_tests/` suite, design spec `2026-05-09-command-tdad-testing-design.md` |

---

## Amendment 2 — 2026-05-09: pivot — drop self-demonstration, harden the constraint

The second `/diaboli` pass surfaced 8 objections (5 high). The author
chose to pivot rather than amend further. The pivot reshapes the
spec around a smaller, sharper claim: **the discipline applies
forward to new components shipped after this PR merges**. The spec
no longer claims to demonstrate the discipline on its own author.
This Amendment supersedes the relevant parts of Amendment 1 and the
original spec. Where Amendment 2 contradicts Amendment 1 or the
original text, **Amendment 2 governs**.

### A2.1 Drop the in-PR scenarios for orchestrator and tdd-agent

Amendment 1 §A1.3 (the two-scenario plan) is dropped in full.
Amendment 1 §A1.7 steps 1 and 2 (author scenarios) are removed; the
remaining steps renumber to 1–8. The post-A1 `/diaboli` pass
surfaced — for the second time, after the original review's O4 —
that scenarios targeting Layer 1 only cannot fail before
implementation and cannot fail after, so calling them "RED phase"
is theatre. Rather than escalate to Layer 3 SDK fixtures (out of
scope per `command-tdad-testing-design.md` Amendment 1), the pivot
accepts that this PR ships forward-only discipline.

A1.8's rationale paragraph "demonstrate the discipline on its own
author" is removed. The remaining feature-ceremony rationale (a
behavioural change to two shipping agents per the project's semver
rules) stands and is sufficient.

### A2.2 Constraint becomes deterministic + tier-restricted

Replace Amendment 1 §A1.1's constraint with:

```text
### New plugin components must ship with a TDAD scenario

- **Rule**: When a PR adds a new file matching one of
  `ai-literacy-superpowers/skills/<name>/SKILL.md`,
  `ai-literacy-superpowers/agents/<name>.agent.md`, or
  `ai-literacy-superpowers/commands/<name>.md`, the same PR must
  include at least one scenario file at
  `tdad_tests/scenarios/<type>/<name>/<aspect>.md` whose
  YAML frontmatter declares `tier` as one of `structural`,
  `trigger`, or `behavioural`. Files with `tier: finding` do NOT
  satisfy the constraint (they are documentary, not falsifiable —
  see A2.3). The tdd-agent's `<aspect>.md` filename can be any
  non-`FINDING-`-prefixed kebab-case name; the existing corpus
  uses verb-phrase aspects like `creates-spec-with-acceptance-scenarios.md`
  or `identifies-violations.md`.
- **Enforcement**: deterministic
- **Tool**: `.github/workflows/tdad-scenario-check.yml` (runs a
  small bash check that lists added files matching the canonical
  paths via `git diff --name-only --diff-filter=A`, then verifies
  that `tdad_tests/scenarios/<type>/<name>/` contains at least one
  non-`FINDING-`-prefixed file with `tier:` in `{structural,
  trigger, behavioural}`)
- **Scope**: pr
```

Two changes from A1.1:

- **Enforcement: deterministic** rather than `agent` (post-A1 O1) —
  the check has no judgement component, and the project's pattern
  for analogous file-presence checks (`Spec-first commit ordering`,
  `Version consistency`) is deterministic CI workflows.
- **Tier whitelist** restricts `tier` to
  `{structural, trigger, behavioural}` (post-A1 O2) — closes the
  bypass where a new component could ship with a single
  `tier: finding` file at the canonical path.

### A2.3 FINDING- coexists with `<aspect>.md` as a separate category

The corpus today contains `tdad_tests/scenarios/commands/harness-init/FINDING-command-tdab-gap.md`,
which is a documentary architectural finding rather than a
falsifiable test scenario. Layer 3 has dedicated tests at
`tdad_tests/tests/test_layer3_behavioural.py:283-312`
(`TestHarnessInitCommandFinding.test_finding_scenario_exists`,
`test_finding_declares_finding_tier`) that depend on this prefix.

Amendment 2 names FINDING- as a recognised, separate artefact
category that:

- **Coexists** with `<aspect>.md` files in the same component
  directory.
- **Does not satisfy** the new HARNESS constraint (per A2.2's
  tier whitelist).
- **Should not be renamed** to `<aspect>.md`; the prefix is
  load-bearing for existing tests.
- **Is appropriate when** a component surfaces an architectural
  question that genuinely cannot be expressed as a falsifiable
  scenario today. A FINDING- file does not absolve the component
  of the constraint — at least one non-FINDING- scenario file is
  still required.

The tdd-agent's prose must reflect this distinction: the agent
authors `<aspect>.md` files for the RED phase; FINDING- authoring
remains a manual decision by the human author when the spec
surfaces an unresolvable architectural question.

### A2.4 Redact contradictions in original §1, §3, §5

The original §1 sentence "No new constraint is added to HARNESS.md
in this spec" is **superseded by Amendment 1 §A1.1 and Amendment 2
§A2.2**. The `<!-- amendment-redacted -->` markers are added inline
in the original text below to flag the contradicted sentences for
readers; the original wording is preserved beneath the markers for
auditability.

The original §3 "Out of scope" entry "Adding a HARNESS.md
constraint requiring scenarios for new agent artefacts" is
**superseded by A1.1 / A2.2** — same redaction marker applied.

The original §5 "30 days observation" paragraph is **fully
superseded by A1.2** (deferral removed); marker applied.

### A2.5 RED duality in the tdd-agent's prose: name it explicitly

A1.5 redefined "red" for the modification branch. Post-A1 O8
flagged that the original §4 "Confirms the structural layer is red"
prose was preserved verbatim and the agent file would now operate
two definitions simultaneously. Amendment 2 makes the directive in
§A1.7 step 3 explicit: when authoring the agent-artefact branch in
`tdd-agent.agent.md`, the implementer must (a) include the new
A1.5 RED definition for modifications, (b) keep the existing
"Confirming red" prose for the generic-test path unchanged, and (c)
add a one-sentence preamble at the top of the new branch noting
that "RED" carries a semantic extension specifically inside this
branch. The two definitions are not contradictory once the branch
boundary is named explicitly.

### A2.6 Revised acceptance criteria (replaces A1.9)

A future PR that **adds** a new skill, agent, or command must:

1. Include at least one scenario file at
   `tdad_tests/scenarios/<type>/<name>/<aspect>.md` (per A1.4)
   whose `tier` is one of `structural`, `trigger`, or
   `behavioural` (per A2.2).
2. Pass the deterministic CI check
   `.github/workflows/tdad-scenario-check.yml` at PR time.

A PR that **modifies** an existing skill, agent, or command:

1. Should review the existing scenario(s) and update them when the
   spec changes the contract; leave them unchanged when the spec is
   a non-behavioural refactor. Acknowledged as a judgement call
   (per original O3 / post-A1 O5) — no automated check exists for it.
2. Is not blocked by the HARNESS constraint (which scopes to *new*
   files), but the orchestrator-pipeline path-detection still fires
   to surface the question.

A PR that does NOT touch agent artefacts must not have a TDAD
scenario authored unnecessarily; the orchestrator's detection step
exits early.

This PR (the one shipping Amendment 2) is itself a modification PR
under the rule above. No scenarios are authored for the orchestrator
or tdd-agent edits; the discipline applies forward.

### A2.7 Revised implementation plan (replaces A1.7)

1. **Edit `ai-literacy-superpowers/agents/tdd-agent.agent.md`** —
   add the agent-artefact branch with the modification-branch RED
   semantics (per A1.5 + A2.5) and the filename convention (per
   A1.4 + A2.3 — `<aspect>.md` for new scenarios, FINDING- as a
   separate category not authored by tdd-agent).
2. **Edit `ai-literacy-superpowers/agents/orchestrator.agent.md`** —
   add the path-based detection step before pipeline step 2, with
   the scope acknowledgement note (per A1.10) for surfaces the
   detection rule does not cover (`hooks/`, `templates/`,
   `scripts/`).
3. **Add HARNESS constraint** "New plugin components must ship with
   a TDAD scenario" (per A2.2) and the corresponding deterministic
   workflow at `.github/workflows/tdad-scenario-check.yml`.
4. **Increment HARNESS.md Status** `Constraints enforced` count
   and the README harness badge accordingly (20/21 → 21/22).
5. **Bump plugin version** 0.35.5 → 0.36.0; update `plugin.json`,
   the README ai-literacy-superpowers badge, and the marketplace
   `plugin_version`.
6. **Add CHANGELOG entry** under v0.36.0 — date-stamped, theme-
   grouped per project conventions.
7. **Update `agent-orchestration.md`** docs page (or equivalent)
   to mention the new artefact-type branch + the new constraint.
8. **Run `python3 -m mkdocs build --strict` locally** to verify
   the docs change.

### A2.8 Known limitations carried forward

Three concerns from the post-A1 review are accepted as named
limitations:

- **Modification scope (post-A1 O5)** — the constraint scopes to
  new files only. Existing components can be modified without
  scenario coverage. The orchestrator pipeline surfaces the
  question for modifications but does not enforce an answer. If
  practice shows legitimate modifications silently skipping the
  discipline, a tighter rule is a follow-up spec.
- **LLM scenario quality (post-A1 O6)** — bad scenarios can pass
  the deterministic check (the check only verifies presence and
  tier, not falsifiability of `Then` clauses). Mitigation: the
  tdd-agent's RED-phase output is surfaced to the user before the
  implementer is dispatched; user reviews scenario quality. A
  Layer 1 test asserting non-empty `Then` sections is a follow-up
  if quality drift becomes observable.
- **`hooks/`, `templates/`, `scripts/` excluded** — same scope
  rationale as A1.10 carries forward.

These limitations ship with the spec, named explicitly. The pivot's
trade-off is honesty: the discipline is forward-only, the
enforcement covers new files, and the rest of the surface is
acknowledged rather than waved away.

---

## Amendment 1 — 2026-05-09: closing the enforcement gap, owning the limits

The first spec-mode `/diaboli` pass surfaced 12 objections; 7 at high
severity. The four load-bearing concerns are taken in directly:

- **O1 — Layer 1 isn't actually the forcing function.** The original
  spec asserted that the existing Layer 1 structural test catches
  missing scenarios. Reading `tdad_tests/tests/test_layer1_structural.py`
  shows it only enforces scenario coverage for the three named spike
  targets (`spec-writer`, `cupid-code-review`, `harness-init`), not
  the broader corpus. A new component shipped without a scenario
  passes Layer 1 silently today.
- **O4 — the spec doesn't apply its own discipline to itself.** The
  PR modifies two agent artefacts (`orchestrator.agent.md` and
  `tdd-agent.agent.md`) but the original implementation plan listed
  no scenario authoring step.
- **O5 — the "30-day observation" deferral is unowned.** Without a
  counter, owner, or scheduled review, the deferral is a silent
  no-op.
- **O8 — the filename convention is not what the corpus uses.** The
  existing scenario directories already use descriptive `<aspect>.md`
  filenames (`creates-spec-with-acceptance-scenarios.md`,
  `identifies-violations.md`, `triggers-on-cupid-query.md`), not
  `scenario.md`. The original spec invented a convention.

Amendment 1 supersedes the relevant parts of §1, §3, §4, §5, §6,
and §7 below. Where this Amendment contradicts the original text,
**this Amendment governs**. The original sections are preserved
unchanged after this Amendment for auditability.

### A1.1 Add a HARNESS constraint, drop the "Layer 1 catches it" claim

Replace the original spec's appeal to Layer 1 with an explicit
HARNESS constraint added in this same PR:

```text
### New plugin components must ship with a TDAD scenario

- **Rule**: When a PR adds a new file under
  `ai-literacy-superpowers/skills/<name>/SKILL.md`,
  `ai-literacy-superpowers/agents/<name>.agent.md`, or
  `ai-literacy-superpowers/commands/<name>.md`, the same PR must
  include at least one scenario file at
  `tdad_tests/scenarios/<type>/<name>/<aspect>.md` with valid TDAD
  frontmatter (`component`, `component_type`, `tier`).
- **Enforcement**: agent
- **Tool**: harness-enforcer agent (when the PR's diff adds files
  matching the canonical paths above, verify a corresponding
  scenario file exists)
- **Scope**: pr
```

This constraint becomes the post-merge forcing function the original
spec claimed. The "Tests must pass" unverified entry in HARNESS.md
remains as a separate item (TDAD layers run on PRs but apply to
scenario coverage of the suite, not to component-level scenario
existence).

### A1.2 The 30-day observation paragraph is removed

Per A1.1, the constraint provides ongoing enforcement. The original
"observe for 30 days; add the constraint if violations occur"
deferral is replaced by adding the constraint up front. Drop the
final paragraph of the original §5 "Trade-off — pipeline-only vs
pipeline + constraint" subsection.

### A1.3 Author scenarios for this PR's own changes

Both `orchestrator.agent.md` and `tdd-agent.agent.md` change
contract in this PR. Per the modification heuristic in §5 of the
original spec, scenarios should be authored or updated. The
revised implementation plan (A1.7 below) adds two scenarios:

- `tdad_tests/scenarios/agents/orchestrator/detects-agent-artefact-scope.md`
  — scenario describing how step 2 detects agent-artefact paths and
  passes the type to `tdd-agent`.
- `tdad_tests/scenarios/agents/tdd-agent/authors-scenario-for-agent-artefact.md`
  — scenario describing the RED-phase deliverable for agent-artefact
  scope.

Both scenarios target Layer 1 (structural — frontmatter and section
presence). Layer 3 (behavioural — full SDK invocation) is deferred
case-by-case per the companion `command-tdad-testing-design.md`
amendment.

### A1.4 Filename convention: descriptive `<aspect>.md`

The original spec specified `scenario.md` (or `<aspect>.md` if
multiple). The existing corpus uses descriptive `<aspect>.md`
filenames consistently:

- `tdad_tests/scenarios/agents/spec-writer/creates-spec-with-acceptance-scenarios.md`
- `tdad_tests/scenarios/skills/cupid-code-review/identifies-violations.md`
- `tdad_tests/scenarios/skills/cupid-code-review/triggers-on-cupid-query.md`

The convention is therefore: **`tdad_tests/scenarios/<type>/<name>/<aspect>.md`**,
where `<aspect>` is a kebab-case description of what the scenario
tests (typically a verb-phrase). One scenario per `<aspect>` file;
multiple files when a component has multiple distinct aspects to
verify. `scenario.md` is not used. The `tdd-agent`'s instructions
must reflect this convention.

### A1.5 Modification "RED" semantics

For modifications, the structural-layer test may pass before the
implementation is changed (the component file already exists). The
`tdd-agent`'s prose must define "red" for this branch as: *the
existing scenario does not yet capture the new behaviour described
in this spec* — not "the test fails." This is a semantic extension
of the agent's existing "Confirming red" charter, not a contradiction;
the agent's prose should make the extension explicit rather than
silently overload the term.

### A1.6 Layer-targeting precedence note

When this spec's tdd-agent output contract ("Layers targeted:
`[structural]` always; `[trigger]` for skills by default;
`[behavioural]` only when the spec calls it out") conflicts with
the per-component judgement in `command-tdad-testing-design.md`,
the per-component judgement governs. The defaults listed in this
spec are what the agent emits when the spec it is implementing is
silent on layer targeting; an explicit decision in the
implementation spec takes precedence.

### A1.7 Revised implementation plan

Replaces §7 of the original spec:

1. **Author scenario for orchestrator change** at
   `tdad_tests/scenarios/agents/orchestrator/detects-agent-artefact-scope.md`.
   This is the RED phase for the orchestrator modification.
2. **Author scenario for tdd-agent change** at
   `tdad_tests/scenarios/agents/tdd-agent/authors-scenario-for-agent-artefact.md`.
   This is the RED phase for the tdd-agent modification.
3. **Edit `ai-literacy-superpowers/agents/tdd-agent.agent.md`** —
   add the agent-artefact branch with corrected RED semantics
   (per A1.5), filename convention (per A1.4), and layer-targeting
   precedence note (per A1.6).
4. **Edit `ai-literacy-superpowers/agents/orchestrator.agent.md`** —
   add the path-based detection step before step 2, with the scope
   acknowledgement note (per A1.10 below) for the surfaces the
   detection rule does not cover.
5. **Add HARNESS constraint** "New plugin components must ship with
   a TDAD scenario" (per A1.1), increment the `Constraints enforced`
   count in HARNESS.md Status and the README badge accordingly.
6. **Bump plugin version** 0.35.5 → 0.36.0; update `plugin.json`,
   the README ai-literacy-superpowers badge, and the marketplace
   `plugin_version`.
7. **Add CHANGELOG entry** under v0.36.0 — date-stamped, theme-
   grouped per project conventions, naming the two agent edits, the
   new HARNESS constraint, and the two new scenarios.
8. **Update at least one docs page** that explains the orchestrator
   pipeline (likely `docs/plugins/ai-literacy-superpowers/explanation/agent-orchestration.md`)
   to mention the new artefact-type branch.
9. **Run `python3 -m mkdocs build --strict` locally** to verify the
   new docs change doesn't introduce broken links (closing the
   verification gap surfaced by PR #306 → #307; the PR-time
   `docs-build-check.yml` workflow added in PR #308 is now the
   primary forcing function but local verification still saves a
   round-trip).
10. **Open the PR** with full feature ceremony — no exemption label.

### A1.8 Why feature ceremony for two paragraphs of prose (O10)

Two reasons to keep feature ceremony rather than dropping to chore:

1. **Demonstrate the discipline on its own author.** A change that
   adds TDAD discipline to the pipeline benefits from being itself
   subjected to the spec-first / diaboli / cartograph discipline.
   Skipping ceremony to ship faster would undercut the message the
   change is trying to send.
2. **Behavioural change to two shipping agents.** The change isn't
   just docs; it modifies what `tdd-agent` and `orchestrator`
   actually do at pipeline run-time. Per CLAUDE.md's semver rules
   that's a minor bump, and minor-bumps default to feature ceremony
   in this project.

This rationale is recorded here in response to O10's "ceremony
calibrated to artefact" question. The choice is deliberate, not
habitual.

### A1.9 Revised acceptance criteria (replaces §6)

A future PR that **adds** a new skill, agent, or command and runs
through the orchestrator pipeline must:

1. Include at least one scenario file at
   `tdad_tests/scenarios/<type>/<name>/<aspect>.md` (per A1.4).
2. Have the scenario referenced in the implementer's context.
3. Pass the new HARNESS constraint "New plugin components must
   ship with a TDAD scenario" at PR time.

A PR that **modifies** an existing skill, agent, or command:

1. Should review the existing scenario(s) and update them when the
   spec changes the contract; leave them unchanged when the spec is
   a non-behavioural refactor. This is acknowledged as a judgement
   call (per O3) — no automated check exists for it.
2. Is not blocked by the HARNESS constraint (which scopes to *new*
   files), but the orchestrator-pipeline path-detection still fires
   to surface the question.

A PR that does NOT touch agent artefacts must not have a TDAD
scenario authored unnecessarily; the orchestrator's detection step
exits early.

### A1.10 Known limitations carried over (the residual minors)

Three of the diaboli's remaining concerns are not closed by this
Amendment; they are owned as known limitations of the discipline:

- **O2 — `hooks/`, `templates/`, `scripts/` are not in scope.** The
  detection rule remains skills/agents/commands only. Rationale:
  `templates/` are passive content (no agent behaviour to test);
  `scripts/` are tested at Layer 0 via the bash test suite (no
  scenario needed); `hooks/` are advisory and small enough that
  Layer 1 manifest validation is sufficient. If a future hook gains
  enough complexity to warrant a scenario, extend the rule then.
  The orchestrator's detection step prose names this exclusion
  explicitly so future readers do not read "all plugin surfaces."
- **O3 — modification heuristic is judgement-bound.** No automated
  test exists to falsify the modification-vs-refactor decision the
  `tdd-agent` makes for an existing-component change. The discipline
  fires reliably for new components (per A1.1's constraint); for
  modifications it surfaces the question but does not enforce an
  answer. This is accepted; if practice shows the discipline
  silently skipping legitimate modification cases, a tighter rule
  is a follow-up spec.
- **O6 — LLM authoring scenarios is a quality risk.** Mitigation:
  the `tdd-agent`'s RED-phase output is surfaced to the user before
  the implementer is dispatched (the orchestrator's existing user-
  surface pattern at gates). The user should review the scenario
  for falsifiability before approving. This is added to the
  orchestrator's pipeline as a soft surface; not a hard gate.

These limitations are not closed by this Amendment; they are
explicitly *acknowledged* and the spec ships with them named.

---

## 1. Summary

Refine the orchestrator pipeline so that when a feature targets an
**agent artefact** — a new or modified file under `skills/`, `agents/`,
or `commands/` inside `ai-literacy-superpowers/` — the RED-phase
deliverable produced by `tdd-agent` is a **TDAD scenario file** at
`tdad_tests/scenarios/<type>/<name>/`, not a generic test file. The
scenario file is the test artefact: it carries `Given / When / Then /
Rubric` sections that the implementation must satisfy.

Two files change:

1. `ai-literacy-superpowers/agents/tdd-agent.agent.md` — gain a
   "When the spec covers an agent artefact" branch that authors the
   scenario file as the RED deliverable, in addition to (or in place
   of) generic test files.
2. `ai-literacy-superpowers/agents/orchestrator.agent.md` — gain a
   one-line gate at step 2 that detects agent-artefact scope from the
   plan's file paths and passes that context to `tdd-agent`.

> **SUPERSEDED by Amendment 1 §A1.1 and Amendment 2 §A2.2** — a deterministic HARNESS constraint IS added in this PR. Original prose preserved below for auditability.

No new constraint is added to HARNESS.md in this spec. The existing
TDAD suite's Layer 1 structural tests (which scan
`tdad_tests/scenarios/`) are the post-merge forcing function;
post-merge enforcement remains where it is. This spec is about
authoring discipline, not about gating.

---

## 2. Why

### The current pipeline is ambiguous for agent-artefact work

The orchestrator's step 2 dispatches `tdd-agent` to "write failing
tests from the new scenarios." The tdd-agent's instructions are
language-agnostic with a Go example (`go test ./...`). Neither file
mentions:

- The TDAD four-layer architecture (`tdad_tests/`)
- That scenarios live as markdown files, not Python or Go test files
- That for skills/agents/commands, the "test" is a scenario the
  implementation makes pass, not a code-level assertion
- Where scenarios go (`tdad_tests/scenarios/<type>/<name>/`) or what
  shape they take (`Given / When / Then / Rubric`)

In practice this means: a feature PR that adds a new skill goes
through the orchestrator's pipeline, the tdd-agent writes
something-or-nothing at the test stage, and the scenario file gets
authored manually (if at all) at the implementation stage or
afterwards. The Layer 1 structural test then either fails the PR
post-merge (caught) or quietly accepts the artefact as
unverified-by-Layer-1 (silently bypassed).

### Why the seam between TDD and TDAD matters

The classical TDD discipline — write the failing test, watch it fail
for the right reason, then implement — is what the tdd-agent
captures for code work. The TDAD discipline applies the same shape
to agent artefacts: write the scenario describing the expected
behaviour (the failing test), then implement the agent / skill /
command (make it green), then verify by running the structural and
behavioural layers.

Without the seam being explicit, agent-artefact work either
short-circuits the TDD step or duplicates effort: the tdd-agent
authors something generic, and the implementer authors the scenario
later. Naming the seam aligns the pipeline with the discipline
already documented in `tdad_tests/README.md` and visible in the new
ONBOARDING.md and Contributing docs.

### Why path-based detection

The three directories `skills/`, `agents/`, `commands/` are the
canonical homes for the artefacts the TDAD suite verifies. Detection
by path is deterministic, cheap, and matches the structural test's
existing scope. Frontmatter-based detection would be more precise
but is redundant given the path convention is already enforced
(by the `Naming` and `File structure` conventions in HARNESS.md
Context).

---

## 3. Scope

### In scope

- Editing `ai-literacy-superpowers/agents/tdd-agent.agent.md` to add
  an "agent-artefact" branch that authors a scenario file as the RED
  deliverable.
- Editing `ai-literacy-superpowers/agents/orchestrator.agent.md` to
  add a path-based detection step before dispatching `tdd-agent` at
  step 2 of the pipeline, and to pass artefact-type context to the
  agent.
- Updating the tdd-agent's "Output to orchestrator" section so the
  orchestrator can read the scenario file path and include it in
  context for downstream agents (implementer, code-reviewer).
- Plugin version bump to 0.36.0 (minor — behavioural change to two
  agents that ship in `ai-literacy-superpowers/`).
- CHANGELOG entry under the new heading.
- Marketplace `plugin_version` sync.
- Docs propagation: at least one explanation or how-to page on the
  docs site that references the orchestrator pipeline must mention
  the new artefact-type branch (likely `the-harness-lifecycle.md`,
  `agent-orchestration.md`, or a new how-to). Verified during
  implementation.

### Out of scope

- > **SUPERSEDED by Amendment 1 §A1.1 and Amendment 2 §A2.2** — the constraint IS added in this PR.

  Adding a HARNESS.md constraint requiring scenarios for new agent
  artefacts. The Layer 1 structural test is the existing forcing
  function; a constraint would be redundant. If the pipeline change
  fails to bed in (i.e. PRs continue to land without scenarios), the
  constraint is a follow-up.
- Layer 3 (behavioural) opt-in policy. Per the
  `command-tdad-testing-design.md` amendment, Layer 3 is case-by-case
  per component; the tdd-agent's RED-phase deliverable is a Layer 1
  scenario. Layer 2 trigger tests (for skills) and Layer 3
  behavioural runs (for agents and commands) are decided per
  component during implementation and are not part of the RED-phase
  contract.
- Frontmatter-based detection. Path-based is sufficient (per the
  user's choice on the structural question — see the user-facing
  question record in this session).
- Refactoring the broader pipeline. Steps 1–1b, 3–4a, and 5 are
  unchanged.
- A new `tdad-agent` agent. Reuses the existing `tdd-agent` with an
  artefact-type branch, per the user's choice on the insertion-point
  question.

---

## 4. Architecture

### Detection

The orchestrator inspects the plan's intended file paths (the plan
already lists modules/files to be created or modified). If any file
path under `ai-literacy-superpowers/skills/`,
`ai-literacy-superpowers/agents/`, or
`ai-literacy-superpowers/commands/` appears in the plan, the
orchestrator marks the work as **agent-artefact scope** and passes
the context to `tdd-agent` along with the artefact's component type
(skill / agent / command) and slug.

If multiple artefact types appear (e.g. a feature ships a new skill
and a new command), the orchestrator passes a list. The tdd-agent
authors one scenario per artefact.

If no artefact path appears, the orchestrator dispatches `tdd-agent`
as today — generic test work.

### tdd-agent's RED-phase deliverable for agent-artefact scope

For each artefact in the scope list, tdd-agent:

1. Reads the spec to extract the intended behaviour.
2. Authors a scenario file at
   `tdad_tests/scenarios/<type>/<name>/scenario.md` (or
   `<aspect>.md` if multiple scenarios apply).
3. Each scenario file uses the canonical TDAD scenario format:

   ```markdown
   ---
   component: <name>
   component_type: <skill | agent | command>
   tier: structural | trigger | behavioural
   fixture: <optional fixture name>
   ---

   ## Given
   ...

   ## When
   ...

   ## Then
   - bullet list of falsifiable assertions

   ## Rubric
   prose explaining what makes the implementation acceptable in
   ambiguous cases
   ```

4. Confirms the structural layer is "red" — i.e. running
   `pytest tests/test_layer1_structural.py -v` from `tdad_tests/`
   reports the new component as missing or failing structural
   coverage. (For a brand-new component, the structural test fails
   because the component file does not exist yet; for a modified
   component, it may pass — that is acceptable, the scenario still
   captures intent.)
5. Returns to the orchestrator the scenario file path(s), the layers
   targeted, and the structural-layer status.

### Output contract

The tdd-agent's "Output to orchestrator" section grows two fields
when in agent-artefact scope:

- **Scenario files authored**: list of paths under
  `tdad_tests/scenarios/`
- **Layers targeted**: `[structural]` always; `[trigger]` for skills
  by default; `[behavioural]` only when the spec calls it out

The orchestrator passes these into the implementer's context so the
implementer knows which scenarios their implementation must satisfy.

### What does NOT change

- The orchestrator's pipeline steps 1, 1a, 1b, 3, 4, 4a, 5 are
  unchanged.
- The tdd-agent's behaviour for non-artefact work (Go / generic
  tests) is unchanged.
- HARNESS.md is unchanged.
- The TDAD test suite under `tdad_tests/` is unchanged.
- The spec-first ordering, diaboli gates, and choice-cartograph
  gates are unchanged.

---

## 5. Trade-offs and open questions

### Trade-off — pipeline-only vs pipeline + constraint

This spec deliberately does **not** add a HARNESS constraint. The
pipeline change shapes authoring; the existing Layer 1 structural
test catches violations post-merge. A constraint would catch
violations that bypass the orchestrator (chore PRs, manual edits)
but adds maintenance and may be redundant if the structural test
already fails such PRs.

> **SUPERSEDED by Amendment 1 §A1.2** — the 30-day deferral is removed; the constraint is added up-front. Original prose preserved below for auditability.

The decision is to ship the pipeline change first and observe
whether scenarios appear consistently for new components in the
30 days after this spec lands. If two or more agent-artefact PRs
land without scenarios in that window, add the HARNESS constraint
as a follow-up.

### Trade-off — tdd-agent branching vs new tdad-agent

A separate `tdad-agent` agent could carry the discipline cleanly
without complicating the existing tdd-agent. Rejected because:
(a) the orchestrator already dispatches tdd-agent at step 2, so a
new agent would require pipeline changes; (b) the discipline is
genuinely the same shape (RED → GREEN), just with a different
artefact type; (c) maintaining two agents that share a charter is
the failure mode the diaboli architectural decision (single agent,
two dispatches) was chosen to avoid.

### Open question — handling specs that mix artefact types and generic code

If a feature ships a new skill **and** a Go module (rare but
possible — e.g. a tool that ships both a skill and a CLI binary),
the tdd-agent would need to author both a TDAD scenario and a
generic test file. The spec assumes this is straightforward (the
agent does both, tracking outputs separately). If practice shows
this is awkward, refine in a follow-up.

### Open question — when the spec is for a component *modification*

A spec that modifies an existing skill/agent/command may not need a
new scenario — the existing scenario (if any) already captures
intent. The tdd-agent's branch should: (a) check whether a scenario
already exists for the component; (b) update or replace it if the
spec changes the contract; (c) leave it unchanged if the spec is a
non-behavioural refactor. This nuance lives in the tdd-agent's
instructions, not the orchestrator's.

---

## 6. Acceptance criteria

A future PR that ships a new skill, agent, or command and runs
through the orchestrator pipeline must:

1. Have a scenario file at
   `tdad_tests/scenarios/<type>/<name>/<aspect>.md` authored at
   step 2 (RED phase) of the orchestrator pipeline, before any
   implementation code is written.
2. Have the scenario referenced in the implementer's context (so the
   implementer knows what the implementation must satisfy).
3. Pass `pytest tests/test_layer1_structural.py -v` from
   `tdad_tests/` after the implementation is complete.

A PR that does **not** ship a new agent artefact (e.g. a hook
script change, a CHANGELOG-only PR, a docs-only PR) must:

1. Not have a TDAD scenario authored unnecessarily.
2. Not block on TDAD scope detection.

---

## 7. Implementation plan

1. Edit `ai-literacy-superpowers/agents/tdd-agent.agent.md`:
   - Add a "When the spec covers an agent artefact" section.
   - Document the scenario file format and path convention.
   - Update the "Output to orchestrator" section to include the new
     fields.
2. Edit `ai-literacy-superpowers/agents/orchestrator.agent.md`:
   - Add a one-paragraph "Detect agent-artefact scope" step before
     dispatching tdd-agent at step 2.
   - Document how the orchestrator passes artefact-type context to
     tdd-agent.
   - Update the pipeline summary at the top to mention the branch.
3. Bump `ai-literacy-superpowers/.claude-plugin/plugin.json` version
   from 0.35.5 to 0.36.0.
4. Update README.md plugin version badge.
5. Update CHANGELOG.md with a v0.36.0 entry.
6. Update `.claude-plugin/marketplace.json` `plugin_version` to
   0.36.0.
7. Update at least one docs page that explains the orchestrator
   pipeline (e.g. `docs/plugins/ai-literacy-superpowers/explanation/agent-orchestration.md`)
   to mention the new branch.
8. Run `mkdocs build --strict` locally to verify the new docs change
   doesn't introduce broken links.
9. Open the PR with full feature ceremony (no exemption label).

---

## 8. Risk

Low. The change is additive: existing pipeline behaviour for
non-artefact work is preserved; the new branch only fires when the
plan touches `skills/`, `agents/`, or `commands/`. No external
contracts change. The plugin version bump is the only consumer-
visible artefact.
