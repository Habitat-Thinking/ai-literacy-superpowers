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

### 2.4 Invocation surface (v0.3.0)

At v0.3.0 the agent is dispatched via Claude Code's bare `Task`
tool — there is no `/diagnose` slash-command in this slice. The
invocation contract:

- `subagent_type`: `diagnostic-legibility`
- `description`: a short imperative (e.g. "Model the auth module")
- `prompt`: free-text that names the `scope` and any additional
  context. The minimum prompt shape is:

  ```text
  scope: <directory path | file list | free-text description>
  ```

  Additional context (e.g. "focus on the public API surface only")
  is appended as a second paragraph.

The dispatcher (orchestrator agent, command, or human) is
responsible for persisting the agent's returned YAML to a path of
its choosing — the agent itself does not write. This is the
"agent-emit + dispatcher-persist + human-disposes" pattern from
AGENTS.md ARCH_DECISIONS, shared with `model-card-researcher`,
`advocatus-diaboli`, and `choice-cartographer`.

A `/diagnose` slash-command that wraps this dispatch and handles
file-write conventions is the deliverable of parent S4 (issue
#333), out of scope here. The how-to page in this slice (§6.5,
§7.1) documents the bare-Task-tool pattern as the v0.3.0
invocation surface and links forward to S4 for the eventual
command surface.

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
five-question structure (§3.5).

Shared construction is a **design choice**, not a logical
consequence of the shared schema. The two are independent
decisions: one could legitimately ship two construction loops — one
targeting architectural moving parts, one targeting domain concepts
— against the same record type, with each loop's prompts tuned for
its dimension's failure modes. The schema does not foreclose that.
Shared construction is chosen here for three reasons:

1. **Complexity scaling.** The agent file's prompt complexity scales
   roughly linearly with the number of distinct construction loops.
   One shared loop is one prompt section to write, maintain, and
   reason about; two bifurcated loops are two. At v0.3.0 there is
   no signal that one shared loop under-serves either dimension.

2. **Dimension-flavoured emphasis already gives dimension-aware
   behaviour.** Per O4 / §3.5 / §4.3, the agent explicitly
   weights Q5 heavily for domain elements and Q1 heavily for
   architectural elements. The cross-dimension differentiation is
   already operational without bifurcating the construction loop.

3. **Recoverable.** If signal emerges from disposition data that
   the two dimensions need genuinely different construction
   sequences (not just weightings), the agent file can be split
   into two construction loops without changing the schema, the
   spec's external contract, or downstream consumers. The
   architectural cost of starting shared and splitting later is
   bounded; the cost of starting bifurcated and merging later is
   roughly equivalent. The default of *one shape* wins on Occam.

Sub-slicing notes (line 140 of the slicing record) excluded
"per-model bespoke vs. parameterised prompts" as a separate slice
on the grounds that the construction-loop question is
implementation-level prompt crafting — that exclusion still holds,
but the *choice* of shared-vs-bespoke is named here explicitly so
future readers know it was deliberate rather than inherited from
the schema decision.

### 3.4 Fresh-sub-context self-challenge — three alternatives weighed

Three candidate architectures for the challenge step were
considered:

1. **One-context self-challenge.** The agent drafts each element
   and, in the same continuous reasoning context, asks the five
   challenge questions of its own draft and revises in place.
   Simplest. The named failure mode is **self-confirmation**: an
   LLM in a single context that has just argued for a draft is
   statistically biased toward defending it rather than disagreeing
   with it. The challenge step risks degenerating into
   rubber-stamping, which makes the `challenge_notes[]` field
   window-dressing rather than evidence of due diligence.

2. **Two-agent dispatch.** A separate `diagnostic-legibility-challenger`
   agent file with its own charter and tool boundary. The constructor
   emits draft elements; the challenger reads them and emits
   challenge notes; the constructor (or dispatcher) merges.
   Maximal independence. Cost: doubles the agent-file surface for a
   v0.3.0 capability — twice the prompt to maintain, twice the
   versioning ceremony, twice the place a future reader needs to
   look to understand the cycle.

3. **Fresh-sub-context self-challenge (selected).** The same agent
   file runs the challenge step in an explicit context-separation
   segment: the construction protocol ends, the agent re-reads the
   evidence as an adversarial reviewer, and the five questions are
   asked from that adversarial framing with the explicit instruction
   to **disagree where the evidence allows**. One agent file, one
   dispatch, but two reasoning postures within it — *construct* and
   *challenge* — separated by an explicit prompt-segment boundary.

The middle option is selected because it addresses the
self-confirmation failure mode named in (1) without doubling the
agent-file surface named in (2). The independence comes from the
explicit re-framing rather than from a separate context; the cost
is a few extra paragraphs in the agent file's reasoning protocol
(operationalised in §4.3) rather than a whole second file.

The mechanism is the agent file's prompt itself: §4.3's
"Construction protocol" section will name an explicit
**Challenge segment** that begins after all elements are drafted.
That segment includes:

- An instruction to re-read the evidence cited on each draft
  element with no prior commitment to the draft's conclusions.
- An adversarial framing line ("You are now the challenger. Your
  job is to find what is wrong with the draft, not to confirm it.").
- The five questions (§3.5), asked with explicit permission and
  instruction to **disagree where the evidence allows** — silence is
  not the safe answer.
- The dimension-flavoured weighting from §3.5 applied per element.

This is structurally a "fresh sub-context" without invoking a second
agent: the framing instructions induce the agent to treat the
challenge segment as separate work, even though the model context
window is shared. If disposition data shows this still degenerates to
self-confirmation (e.g. an unusually high rate of sentinel-only
`challenge_notes[]` across diverse scopes), the architecture can
escalate to (2) — a separate challenger agent — without changing the
schema or the spec's external contract.

The progression (1) → (3) → (2) is the natural escalation path; we
ship the middle option first because it is the cheapest move that
takes the failure mode seriously rather than deferring it.

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

#### What each question is meant to catch (rationale)

The five questions are not a primitive — they are a working hypothesis
about what failure modes the agent's drafts most commonly exhibit.
Each question targets a distinct failure mode:

- **Q1 (Boundary)** catches **smearing** — drafting a single element
  whose `name` covers two genuinely separable things. Most common for
  architectural elements ("auth + session" treated as one component
  when they are two).
- **Q2 (Evidence)** catches **ungrounded claim** — the description
  asserts something the cited evidence does not actually support.
  This is the closest analogue to a fabrication check.
- **Q3 (Confounders)** catches **near-misses** — neighbouring
  artefacts in the codebase that share enough surface with the
  element to be confused with it (e.g. two similarly-named domain
  terms with different semantics). The element's identity is
  sharpened by naming what it is *not*.
- **Q4 (Confidence)** catches **calibration drift** — claiming
  `confidence: high` when the evidence is thin, or `low` when the
  evidence is in fact dense. This is the meta-level honesty check
  that the schema's `confidence` field exists to support.
- **Q5 (Description integrity)** catches **textbook-definition
  drift** — writing a generic definition that could apply to any
  codebase rather than describing what this specific concept means
  here. Most common for domain elements (writing "an aggregate is a
  cluster of related entities" instead of "the `Cart` aggregate
  groups line items and applied promotions for one checkout session").

These five together are the working cover — *boundary, ground,
identity-by-contrast, calibration, specificity*. They are not
claimed to be complete. The choice of five (and not three or seven)
is a hypothesis revisable from disposition data: the agent's own
`challenge_notes` corpus across real invocations is the falsification
surface. If a recurring failure mode does not map to any of the five,
the cover is missing a question. If two questions consistently produce
identical notes, the cover has redundancy. Both signals are observable
without changing the schema. A later slice may add, drop, or merge
questions on that evidence.

Each question is asked of the draft element. Where a question
surfaces a change, the element is revised and the surfacing-question
+ resolution is appended to `challenge_notes[]` as a single string
prefixed with `Q<N> (question name):` — e.g. `Q1 (boundary):`,
`Q5 (description integrity):` — followed by a description of what
surfaced and how it was resolved. The `Q<N>` prefix is mandatory and
machine-parseable; the parent S3 cross-check (issue #332) groups
notes by question prefix.

When a challenge runs and all five questions surface no changes, the
element receives the single sentinel note:

```text
Challenge applied; no questions surfaced changes
```

verbatim, with no `Q<N>` prefix. The sentinel is the only exception
to the prefix convention. This rule makes the field unambiguous:
**empty `challenge_notes[]` means the challenge protocol did not
run; a non-empty list means it did.** Without the sentinel, an empty
list would be observationally indistinguishable from a skipped
challenge — a problem for the downstream S3 cross-check, which
relies on `challenge_notes[]` as evidence of due diligence.

The five questions are dimension-agnostic but apply with
dimension-flavoured emphasis: domain elements pressure-test against
question 5 most heavily (the "textbook definition" trap), and
architectural elements pressure-test against question 1 most heavily
(the "smeared two services" trap). The agent file operationalises
this in its construction protocol (§4.3) as an explicit per-element
weighting step, not as decorative guidance.

### 3.6 Sentinel for the empty-scope degenerate case

When the agent inspects the scope and finds no architectural or
domain elements to draft (e.g. the scope is an empty directory, or
a file list containing only generated artefacts with no human
content), it does not return two empty collections. Instead it
emits a single placeholder element under whichever collection it
attempts first (architectural by convention) with the literal
`name` value:

```text
(empty scope)
```

— exactly this string, parentheses included. The element carries
`confidence: low`, an empty `evidence: []`, and a description that
names the degenerate scope condition (e.g. "Scope `./src/foo/` was
inspected and yielded no architectural moving parts or domain
concepts; this placeholder marks the empty result"). The
`challenge_notes[]` field carries the O2 sentinel
(`Challenge applied; no questions surfaced changes`).

Why the literal `(empty scope)` and not a low-confidence
candidate? Per the schema, low confidence with empty evidence is
already permitted for "agent flagged a candidate without ground"
cases. The sentinel `name` lets a downstream consumer
pattern-match exactly on `name == "(empty scope)"` to distinguish
"scope yielded nothing" from "agent flagged an evidence-less
candidate" — the two failure modes that would otherwise be
indistinguishable. Avoids changing the schema. Documented in §6.3
and again in the agent file's anti-patterns section.

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
  drafts the two collections. Two explicit phases separated by a
  prompt-segment boundary, per §3.4:

  **Phase A — Construction** (one continuous reasoning context):
  - read the schema template first
    (`diagnostic-legibility/templates/legibility-element.md`)
  - inspect the scope (Glob/Grep/Read)
  - draft architectural elements (one per evident "moving part") —
    populate `name`, `description`, `evidence[]`, and a starting
    `confidence` per the honesty rules
  - draft domain elements (one per evident concept term)
  - if the scope yields nothing, emit the `(empty scope)` sentinel
    placeholder per §3.6 and skip to emission with the O2 sentinel
    note pre-populated

  **Phase B — Challenge segment** (explicit re-framing per §3.4):
  - begin with the framing instruction: *"You are now the
    challenger. Your job is to find what is wrong with the drafts
    above, not to confirm them. Re-read the evidence on each
    element with no prior commitment to the draft's conclusions.
    Disagree where the evidence allows — silence is not the safe
    answer."*
  - for each draft element, apply the five questions (§3.5) with
    **dimension-flavoured weighting** as an explicit per-element
    step:
    - **When challenging a domain element**, weight Q5
      (description integrity) heavily and probe specifically for
      textbook-definition drift — does this description say
      something specific about *this* codebase, or could it be
      lifted verbatim into another project?
    - **When challenging an architectural element**, weight Q1
      (boundary) heavily and probe specifically for smeared
      services — is this one moving part, or two that share a
      directory or a name prefix and got collapsed into one?
    - The remaining three questions (Q2 evidence, Q3 confounders,
      Q4 confidence) are asked of every element with equal
      weight.
  - where a question surfaces a change, revise the element and
    append a `challenge_notes[]` entry prefixed `Q<N> (question
    name):` per §3.5
  - where all five surface nothing for an element, append the
    sentinel `Challenge applied; no questions surfaced changes`
  - emit the full `LegibilityModel` YAML

- `## The five-question challenge` — the questions from §3.5,
  copy-pasted verbatim, with one paragraph per question explaining
  what it is meant to catch (the rationale from the new §3.5
  rationale block). The dimension-flavoured weighting is repeated
  here as a one-paragraph reminder; the full operational guidance
  lives in the Construction protocol Phase B above.
- `## Honesty rules` — `confidence: low` for unevidenced candidates,
  empty `evidence: []` permitted only when confidence is `low`,
  prefer "I am not sure" over fabrication. The `(empty scope)`
  sentinel from §3.6 is documented here too as the honest answer
  to "scope yielded nothing".
- `## Anti-patterns` — list of failure modes the agent should
  avoid:
  - padding `challenge_notes[]` with no-op resolutions to look
    diligent
  - writing generic textbook descriptions (Q5 failure)
  - two architectural elements that are really one (Q1 failure)
  - omitting the `Q<N>` prefix on challenge notes
  - leaving `challenge_notes[]` empty when the challenge ran
    (must use the sentinel)
  - skipping the Phase B re-framing and conflating construction
    with challenge in one continuous flow

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
And every element has a non-empty challenge_notes list — either
    one or more "Q<N> (question name): ..." entries when a question
    surfaced a change, or the single sentinel
    "Challenge applied; no questions surfaced changes" when no
    question surfaced a change
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
**I want** the agent to surface a sentinel placeholder rather
than emit two empty lists
**So that** I can distinguish "scope yielded nothing" from
"agent flagged an evidence-less candidate" from "agent failed
silently".

```gherkin
Given a scope that the agent cannot find architectural or domain
    elements in (e.g., an empty directory)
When the agent runs
Then the output contains exactly one LegibilityElement
And that element's name is the literal string "(empty scope)"
And that element has confidence: low
And that element has an empty evidence list
And that element's description names the degenerate scope condition
And that element's challenge_notes carries the sentinel
    "Challenge applied; no questions surfaced changes"
```

The literal `(empty scope)` name (parentheses included) is the
pattern-match handle for downstream consumers. See §3.6 for the
rationale and §3.5 for the challenge-notes sentinel.

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
- **A separate challenger agent file (two-agent dispatch).** §3.4
  weighs this as alternative (2) and defers it; the ship is the
  middle option — fresh-sub-context self-challenge within one
  agent file. Escalation to a separate challenger remains
  available if disposition data shows the middle option still
  degenerates to self-confirmation.
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
- **`plugin_version` at integration time:** the `plugin_version`
  field in `.claude-plugin/marketplace.json` is a pointer to the
  current `ai-literacy-superpowers` plugin release. It is **not
  owned by this PR**. The header and §6.4 acceptance hard-code
  `0.39.1` as the spec-time snapshot, but the operative rule at
  merge-time is:

  > If `main` has bumped `ai-literacy-superpowers`'s
  > `plugin_version` between spec-time and merge-time, take
  > `main`'s value verbatim during the integration-agent's rebase.
  > This PR only owns the `diagnostic-legibility` entry's
  > `plugins[]` version bump (0.2.0 → 0.3.0). Conflicts on
  > `plugin_version` are resolved in favour of `main`.

  The version-consistency CI check passes as long as the
  `diagnostic-legibility` entry's `version` matches
  `diagnostic-legibility/.claude-plugin/plugin.json`; the
  `plugin_version` pointer is checked independently against the
  `ai-literacy-superpowers` plugin and is not coupled to this
  slice.

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
| Shared vs bespoke protocol across dimensions | Shared, parameterised — design choice not inherited from schema (§3.3) |
| Challenge step independence: one-context vs fresh-sub-context vs dispatch | Fresh-sub-context self-challenge — explicit re-framing within one agent file (§3.4) |
| Number and form of challenge questions | Five questions (boundary, evidence, confounders, confidence, description integrity) — working hypothesis revisable from disposition data (§3.5) |
| `challenge_notes[]` semantics for "challenged but clean" | Sentinel note `Challenge applied; no questions surfaced changes`; empty list means "not challenged" (§3.5) |
| `challenge_notes[]` entry prefix format | Mandatory `Q<N> (question name):` prefix, sentinel exempt (§3.5) |
| Dimension-flavoured emphasis operationalisation | Explicit per-element weighting step in Construction protocol Phase B (§4.3) — Q5 heavy for domain, Q1 heavy for architectural |
| Degenerate "empty scope" output | Literal sentinel name `(empty scope)`, parens included, with O2 sentinel note (§3.6, §6.3) |
| Invocation surface at v0.3.0 | Bare Task-tool dispatch (`subagent_type: diagnostic-legibility`); `/diagnose` command deferred to parent S4 / #333 (§2.4) |
| Agent name | `diagnostic-legibility` (the only agent in the plugin at v0.3.0) |
| Tool boundary | Read, Glob, Grep — matches the three sibling read-only emitters |
| Per-version bump | diagnostic-legibility 0.2.0 → 0.3.0 (minor: new behaviour and new component); marketplace listing unchanged at 0.4.0; `plugin_version` pointer taken from `main` at integration time (§9) |

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
