# Orchestrator + TDD-agent — TDAD discipline for agent artefacts — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-09 |
| Status | Draft — pending user review |
| Author | claude-opus-4-7[1m] (interactive session) |
| Plugin version target | v0.36.0 (minor — behavioural change to two agents) |
| PR ceremony | feature — full diaboli (spec + code) and choice-cartograph |
| Related work | PR #285 (SDK runner for Layer 2/3), PR #305 (ONBOARDING regen with TDAD content), PR #308 (docs-strict-build constraint), `tdad_tests/` suite, design spec `2026-05-09-command-tdad-testing-design.md` |

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

- Adding a HARNESS.md constraint requiring scenarios for new agent
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
   `<descriptor>.md` if multiple scenarios apply).
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
   `tdad_tests/scenarios/<type>/<name>/<descriptor>.md` authored at
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
