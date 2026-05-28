# Diagnostic Legibility — sub-S2b — Challenge protocol and working agent — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-28 |
| Status | Draft |
| Author | claude-opus-4-7[1m] (interactive session with russmiles) |
| Slice | sub-S2 of the meta-iteration record at `docs/superpowers/slices/dl-s2-two-model-agent.md` (which is itself S2 of the parent record `docs/superpowers/slices/diagnostic-legibility-plugin.md`) |
| Parent issue | #335 (Diagnostic Legibility sub-S2b) |
| Up-stack parent issue | #331 (S2 — auto-closes when #335 merges per its own comment) |
| Plugin version target | `diagnostic-legibility` v0.2.0 → v0.3.0 |
| Marketplace listing | Unchanged at v0.4.0; `plugin_version` (pointer to `ai-literacy-superpowers`) unchanged at v0.39.1 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Related work | S1 of parent shipped (PR #334, scaffold v0.1.0); sub-S1 of meta-iteration shipped (PR #336, schema v0.2.0); sibling pattern anchors are `model-cards/agents/model-card-researcher.agent.md` and `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md` |

---

## 1. Premise

The schema is settled (PR #336 shipped `LegibilityElement` and the
`LegibilityModel` wrapper at v0.2.0). What is still missing is the
agent that *constructs* and *refines* the two model collections.

Issue #335 commissions the working agent. The cargo of this slice is:
the agent file, the challenge-refine cycle that populates
`challenge_notes[]` on each element, and enough surrounding
documentation that a human can invoke it against a real codebase
scope and read the two refined model collections back out.

The decision focus this slice owns is the **shape of the
challenge-refine cycle**. Three candidate architectures are named in
the meta-iteration's S2 section (`docs/superpowers/slices/dl-s2-two-model-agent.md`,
lines 102–110). One of those three is selected here; the rationale is
in §3.

What this slice deliberately does *not* own: cross-checking the two
models against each other (parent S3, issue #332) and the
human-facing surfacing format (parent S4, issue #333). The agent
emits two refined collections; whatever the human reads next is
out of scope.

## 2. The agent's contract

### 2.1 Input

- **`scope` (required)** — a directory path, a file list, or a free-text
  description of the area to be modelled. Examples:
  - `./src/auth/`
  - `src/checkout/cart.py, src/checkout/order.py`
  - `"the checkout flow across services A and B"`

  The agent does not enforce one form. The free-text form is
  acceptable when the scope is conceptual rather than directory-bounded.

### 2.2 Output

A single markdown response containing a `LegibilityModel` instance
serialised as YAML, per the schema at
`diagnostic-legibility/templates/legibility-element.md`. The agent
does **not** write the file; the dispatching command (or human user)
writes the response to whatever path they choose. This mirrors the
`model-card-researcher` agent's read-only emitter pattern (AGENTS.md
ARCH_DECISIONS, "agent-emit + dispatcher-persist + human-disposes").

### 2.3 Trust boundary

`Read`, `Glob`, `Grep`. No `Write`, no `Edit`, no `Bash`. The agent
inspects the codebase scope and returns content as a string. This
matches the three sibling read-only emitters: `advocatus-diaboli`,
`choice-cartographer`, `model-card-researcher`. The pattern is
named and load-bearing in AGENTS.md.

## 3. The challenge-refine cycle — decision

The decision focus of this slice. Three candidates from the
sub-slicing record:

(a) **Single-pass critique-revise.** One challenge, one revision.
    Challenge artefact discarded.
(b) **Retained-challenge single-pass.** Same as (a), but the
    challenge questions and their resolutions are retained as
    `challenge_notes[]` on each element.
(c) **Iterative loop with stopping condition.** Challenge–revise
    until stable or budget exhausted.

**Selected: (b) retained-challenge single-pass.**

### 3.1 Why (b) over (a)

The schema already commits to a `challenge_notes[]` field on every
`LegibilityElement`. The schema spec (sub-S2a) names the field as
"What the challenge-refine step surfaced and how it was resolved."
Option (a) would either populate the field with reconstructed notes
(authoring something after the fact, weakening evidence quality) or
leave the field empty (defeating the schema decision). Option (b)
makes the field load-bearing without changing the schema. The
schema and the protocol agree.

The downstream consumer (parent S3, the cross-check) will want
diagnostic context. Knowing *what was challenged* and *what was
revised* is the diagnostic context. Retaining it is cheap;
reconstructing it later is expensive and lossy.

### 3.2 Why (b) over (c)

The iterative loop adds variable token cost and a stopping-condition
sub-decision (token budget? change-rate threshold? fixed iteration
count?). At v0.3.0 there is no measured signal that single-pass
under-refines. Adding the loop now is premature optimisation in the
absence of disposition data on what is being missed.

The loop architecture is not foreclosed by (b): a later slice can
add iteration on top of (b) by repeating the challenge-revise step
and appending to `challenge_notes[]` per iteration. The schema
accommodates this without breaking. The conservative move is to
ship (b) first, observe a handful of real invocations, and decide
whether the loop earns its keep on evidence.

### 3.3 Shared protocol across both dimensions

The challenge protocol is **the same shape** for both architectural
and domain elements, parameterised on the dimension. The schema is
shared (PR #336 settled this); the prompt construction is symmetric;
the challenge questions are dimension-flavoured but follow the same
five-question structure (§3.5). Sub-slicing notes (line 140 of the
slicing record) explicitly excluded "per-model bespoke vs.
parameterised prompts" as a separate slice — the schema decision
already implied parameterisation.

### 3.4 Self-challenge in one multi-turn context, not dispatch

The agent runs the challenge-revise as a single self-directed
sequence inside its own context, not as a second agent dispatch.
Rationale:

- A second-pass dispatch would need a separate challenger agent
  with its own file, charter, and tool boundary. That doubles the
  surface area to maintain for a v0.3.0 capability.
- A self-challenge in one context preserves the agent's
  evidence chain: the same context that drafted the element raises
  objections against it. The challenge prompt can reference the
  evidence the constructor saw directly.
- Other sibling agents (advocatus-diaboli is the closest reference)
  emit in a single pass; the diagnostic-legibility agent's
  self-challenge is one more step in that pass, not a separate
  dispatch.

A later slice may revisit this if disposition data shows that
self-blindness is a recurring failure mode. The agent's own context
can fail to see things a fresh context would catch; that is real.
But again, no signal yet — ship the simpler shape first.

### 3.5 The five-question challenge structure

Each `LegibilityElement` is challenged through five questions, asked
once per element (the single pass in 3.1):

1. **Boundary** — is the `name` actually a single thing, or did I
   smear two things together?
2. **Evidence** — does the cited evidence actually support the
   `description` as written?
3. **Confounders** — what nearby thing is *not* this element but
   could be mistaken for it?
4. **Confidence** — am I overclaiming on the `confidence` field
   given the evidence?
5. **Description integrity** — is the description specific to this
   codebase, or am I writing a generic textbook definition?

Each question is asked of the draft element. Where a question
surfaces a change, the element is revised and the surfacing-question
+ resolution is appended to `challenge_notes[]`. Questions that
surface nothing add no note (avoid noise — empty notes are not
evidence of due diligence).

The five questions are dimension-agnostic but apply with
dimension-flavoured emphasis: domain elements pressure-test against
question 5 most heavily (the "textbook definition" trap), and
architectural elements pressure-test against question 1 most heavily
(the "smeared two services" trap).

## 4. The agent file

### 4.1 Path

`diagnostic-legibility/agents/diagnostic-legibility.agent.md`

The agent name is `diagnostic-legibility`. Single agent in the
plugin's `agents/` directory at v0.3.0. Replaces the `.gitkeep`
placeholder from v0.1.0.

### 4.2 Frontmatter

```yaml
---
name: diagnostic-legibility
description: Use to build two refined models of a codebase scope — architectural moving parts and domain concepts — using the schema at diagnostic-legibility/templates/legibility-element.md. Constructs each element, applies a five-question self-challenge cycle, and retains challenge notes on every element. Returns a LegibilityModel as YAML; the dispatching command or human writes the file.
tools: Read, Glob, Grep
model: inherit
---
```

### 4.3 Sections

The agent file follows the sibling-agent shape:

- `# Charter` — what the agent does and what it does not do.
- `## Inputs` — `scope` (required), serialisation choices for the
  three forms in §2.1.
- `## Output` — a `LegibilityModel` as YAML, single markdown
  response, no file write.
- `## Trust boundary` — Read/Glob/Grep, the rationale from §2.3.
- `## Construction protocol` — how the agent reads the scope and
  drafts the two collections. Calls out:
  - read the schema template first
  - inspect the scope (Glob/Grep/Read)
  - draft architectural elements (one per evident "moving part")
  - draft domain elements (one per evident concept term)
  - apply the five-question challenge to each, populating
    `challenge_notes[]`
  - emit the full `LegibilityModel` YAML
- `## The five-question challenge` — the questions from §3.5,
  copy-pasted, with one paragraph per question explaining what it
  is looking for.
- `## Honesty rules` — `confidence: low` for unevidenced candidates,
  empty `evidence: []` permitted only when confidence is `low`,
  prefer "I am not sure" over fabrication.
- `## Anti-patterns` — list of failure modes the agent should
  avoid: padding `challenge_notes[]` with no-op resolutions,
  generic textbook descriptions, two architectural elements that
  are really one, etc.

### 4.4 Length

Target: 150–250 lines. Comparable to `model-card-researcher`
(140 lines) and `advocatus-diaboli` (103 lines). Longer than
absolutely necessary is fine; the agent file is loaded as system
prompt context and a few extra lines on protocol clarity is good
value for the token cost.

## 5. Worked invocation example (for the agent file's body, and for docs)

### 5.1 Input

```text
scope: ./diagnostic-legibility/
```

### 5.2 Expected output shape (truncated)

```yaml
scope: "./diagnostic-legibility/"
generated_at: "2026-05-28T14:00:00Z"
generated_by: "diagnostic-legibility / claude-sonnet-4-6"
architectural:
  - name: LegibilityElement template
    description: |
      The schema artefact at templates/legibility-element.md.
      Documentation-only — referenced by the agent's prompt but
      not loaded as code. Defines the contract every emitted
      element follows.
    evidence:
      - path: diagnostic-legibility/templates/legibility-element.md
    confidence: high
    challenge_notes:
      - "Q1 (boundary): initially treated the template and the wrapper as one element; revised to keep them as the LegibilityModel wrapper section of the same file, naming this element the template-as-contract."
domain:
  - name: LegibilityElement
    description: |
      The unit of legibility — one row of the model. Distinct from
      LegibilityModel (the wrapper carrying both collections).
      The ubiquitous-language term in this plugin's docs.
    evidence:
      - path: diagnostic-legibility/templates/legibility-element.md
        excerpt: "# LegibilityElement"
    confidence: high
    challenge_notes:
      - "Q5 (description integrity): first draft was generic ('a row of data'); revised to name the contrast with LegibilityModel."
```

The example demonstrates: dimensional symmetry, evidence with
optional excerpts, the `Q<N>` prefix in `challenge_notes` linking
back to the five-question structure.

## 6. User stories and acceptance scenarios

### 6.1 Story — the agent is invokable

**As** a developer with a target codebase scope
**I want** to dispatch the `diagnostic-legibility` agent with a
scope
**So that** I receive a `LegibilityModel` with both collections
refined through the challenge cycle.

```gherkin
Given the merged main on this PR
When I dispatch the diagnostic-legibility agent with scope ./src/auth/
Then I receive a single markdown response
And the response contains a LegibilityModel YAML block
And the block has scope, generated_at, generated_by, architectural,
    and domain fields per the LegibilityModel schema
And at least one of architectural or domain is non-empty
And every element has populated challenge_notes (or an explicit
    empty list when no question surfaced a change)
```

### 6.2 Story — challenge notes carry diagnostic context

**As** a human reading the agent's output
**I want** to see what was challenged and what was revised
**So that** I can decide whether to trust the refined element or
investigate further.

```gherkin
Given an agent output for a non-trivial scope
When I read any LegibilityElement with at least one challenge note
Then the note names a question prefix (Q1–Q5)
And the note describes what surfaced and how it was resolved
And the note is grounded in the element's evidence, not a generic
    statement
```

### 6.3 Story — the agent refuses degenerate outputs

**As** the dispatching command
**I want** the agent to surface a low-confidence placeholder rather
than emit two empty lists
**So that** I can distinguish "scope yielded nothing" from "agent
failed silently".

```gherkin
Given a scope that the agent cannot find architectural or domain
    elements in (e.g., an empty directory)
When the agent runs
Then the output contains at least one LegibilityElement
And that element has confidence: low
And its description names the degenerate scope condition
```

### 6.4 Story — the plugin version reflects the new agent

**As** the marketplace consumer
**I want** the diagnostic-legibility plugin version to bump when
the agent is added
**So that** caches and version checks know the plugin has changed.

```gherkin
Given the merged main on this PR
When I read diagnostic-legibility/.claude-plugin/plugin.json
Then the version is "0.3.0"
And the entry in .claude-plugin/marketplace.json for diagnostic-legibility
    also shows version "0.3.0"
And the top-level marketplace `version` is unchanged at "0.4.0"
And the `plugin_version` field is unchanged at "0.39.1"
And diagnostic-legibility/CHANGELOG.md has a new entry for 0.3.0
```

### 6.5 Story — docs explain how to invoke the agent

**As** a future reader of the docs site
**I want** to find a how-to page explaining how to invoke the
diagnostic-legibility agent and read its output
**So that** I can use the plugin without reading the agent file
itself.

```gherkin
Given the merged main on this PR
When I navigate to docs/plugins/diagnostic-legibility/how-to/
Then there is a page on invoking the diagnostic-legibility agent
And the page names the input form (scope)
And the page shows a worked example of the output
And the page links to the schema reference at templates/legibility-element.md
```

## 7. Files to add and modify

### 7.1 New files

| Path | Purpose |
| --- | --- |
| `diagnostic-legibility/agents/diagnostic-legibility.agent.md` | The working agent (§4). Replaces the `agents/.gitkeep` placeholder from v0.1.0. |
| `docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md` | How-to page (§6.5). |
| `docs/plugins/diagnostic-legibility/how-to/index.md` | Quadrant landing page; minimal — one paragraph plus a link to the how-to. Per the docs convention, the quadrant folder is created only when there is at least one page. |
| `docs/plugins/diagnostic-legibility/explanation/challenge-refine-protocol.md` | Concept page explaining the five-question challenge, why retained-challenge single-pass was chosen, and how `challenge_notes[]` connects schema to runtime. Linked from the how-to. |
| `docs/plugins/diagnostic-legibility/explanation/index.md` | Quadrant landing page. |

### 7.2 Removed files

| Path | Reason |
| --- | --- |
| `diagnostic-legibility/agents/.gitkeep` | Replaced by the agent file. The directory no longer needs a placeholder. |

### 7.3 Modified files

| Path | Change |
| --- | --- |
| `diagnostic-legibility/.claude-plugin/plugin.json` | Bump `version` `0.2.0` → `0.3.0`. |
| `diagnostic-legibility/CHANGELOG.md` | New `## 0.3.0 — 2026-05-28` entry naming the agent addition and the sub-S2b disposition that produced it. |
| `.claude-plugin/marketplace.json` | Bump the `diagnostic-legibility` entry in `plugins[]` from `version: "0.2.0"` to `"0.3.0"`. Top-level `version` and `plugin_version` unchanged. |
| `README.md` (repo root) | Update the `diagnostic-legibility` badge from `v0.2.0` to `v0.3.0` and the marketplace table row's Version column. |
| `diagnostic-legibility/README.md` | Add a brief "Available agents" section referencing `diagnostic-legibility.agent.md`. |
| `docs/plugins/diagnostic-legibility/index.md` | Update the "Status" section to reflect v0.3.0 and the new agent; surface the how-to and explanation pages as live links. |

## 8. Out of scope

The slice narrowing keeps the following out of scope:

- **Cross-checking the two models against each other.** Reserved
  for parent S3 / issue #332.
- **The human-facing surfacing interface.** Reserved for parent
  S4 / issue #333.
- **An iterative challenge loop.** §3.2 explicitly defers this; the
  ship is single-pass retained-challenge.
- **A second-pass challenger agent dispatch.** §3.4 explicitly
  defers this; the ship is self-challenge in one context.
- **A runtime validator for `LegibilityElement` instances.** The
  schema spec (sub-S2a) explicitly deferred this; nothing changes
  here.
- **Dimension-bespoke challenge prompts.** §3.3 commits to one
  shared protocol across both dimensions. Per-dimension prompt
  variation is implementation-level prompt-string crafting, not a
  design gate.
- **TDAD scenarios under `tdad_tests/scenarios/agents/diagnostic-legibility/`.**
  The TDAD-scenario-check workflow (`tdad-scenario-check.yml`,
  lines 5–10) is scoped to `ai-literacy-superpowers/skills/`,
  `/agents/`, and `/commands/` paths. The diagnostic-legibility
  plugin is out of scope for the workflow. Adding scenarios for
  diagnostic-legibility components is a separate question of
  whether the TDAD discipline should extend across plugins; that
  is a meta-decision that belongs to a future spec, not this
  slice.
- **Docs-reference parity entries in
  `docs/plugins/ai-literacy-superpowers/reference/agents.md`.**
  The docs-reference-parity workflow is also scoped to the
  `ai-literacy-superpowers` plugin. The diagnostic-legibility
  plugin's reference pages do not yet exist (no reference quadrant
  in the docs landing page). When and how to scaffold those is a
  future decision.

## 9. Compatibility and rollout

- **Backwards compatibility:** the diagnostic-legibility plugin
  was v0.2.0 (schema-only). Adding an agent does not break any
  consumer because no consumer existed at v0.2.0 except the
  marketplace cache hooks, which key on version strings.
- **Cache behaviour:** `sync-marketplace-cache.sh` fires when
  `.claude-plugin/marketplace.json` differs from `origin/main` —
  this PR triggers it because the per-plugin version bumps.
  `sync-to-global-cache.sh` rsyncs the new agent into the
  versioned plugin cache.
- **CI gates:**
  - Spec-first is satisfied by this spec being the first commit
    on the branch.
  - Version consistency: diagnostic-legibility's plugin.json
    (0.3.0) matches its marketplace entry (0.3.0).
  - TDAD scenario check: no-op (the workflow is scoped to
    `ai-literacy-superpowers/`).
  - Docs-reference parity check: no-op (same scoping).
  - Markdown lint, docs-build: must pass; the new how-to and
    explanation pages need to render cleanly.

## 10. Open questions resolved during brainstorming

| Question | Decision |
| --- | --- |
| Challenge protocol shape | Retained-challenge single-pass (§3.1) |
| Shared vs bespoke protocol across dimensions | Shared, parameterised (§3.3) |
| Self-challenge in one context vs second-pass dispatch | Single-context self-challenge (§3.4) |
| Number and form of challenge questions | Five questions: boundary, evidence, confounders, confidence, description integrity (§3.5) |
| Agent name | `diagnostic-legibility` (the only agent in the plugin at v0.3.0) |
| Tool boundary | Read, Glob, Grep — matches the three sibling read-only emitters |
| Per-version bump | diagnostic-legibility 0.2.0 → 0.3.0 (minor: new behaviour and new component); marketplace listing unchanged at 0.4.0; plugin_version pointer unchanged at 0.39.1 |

## 11. References

- Issue #335 — this slice's parent.
- Issue #331 — up-stack S2 commission (auto-closes when #335 ships).
- Sub-slicing record: `docs/superpowers/slices/dl-s2-two-model-agent.md`.
- Parent slicing record: `docs/superpowers/slices/diagnostic-legibility-plugin.md`.
- Sub-S2a (schema) spec:
  `docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md`.
- Schema artefact:
  `diagnostic-legibility/templates/legibility-element.md`.
- Sibling agent pattern anchors:
  - `model-cards/agents/model-card-researcher.agent.md`
  - `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md`
- AGENTS.md ARCH_DECISIONS — "agent-emit + dispatcher-persist + human-disposes" pattern.
- `CLAUDE.md` — Semantic Versioning and Marketplace Versioning sections.
