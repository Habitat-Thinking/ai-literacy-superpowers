---
spec: docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md
date: 2026-05-28
mode: spec
cartographer_model: claude-opus-4-7[1m]
stories:
  - id: 1
    lens: [forces, coherence]
    title: Five-question cover as falsifiable hypothesis
    disposition: accepted
    disposition_rationale: "Working-hypothesis frame is the right stance for a v0.3.0 cover. The named falsification surface (challenge_notes[] corpus across real invocations) is what the next /diagnose iterations are responsible for inspecting. The quiet failure mode the story flags — nobody actually looking — is real but bounded: parent S3 cross-check is the first natural reader."
  - id: 2
    lens: [patterns, consequences]
    title: Q<N> prefix as lightweight in-string schema
    disposition: accepted
    disposition_rationale: "Mandated convention with one documented exemption (the Story #3 sentinel). S3's tolerance level will shape future pressure on this convention — that's the right consumer to discover whether the prefix is genuinely load-bearing or decorative."
  - id: 3
    lens: [patterns, defaults]
    title: Sentinel values disambiguate runtime intent
    disposition: accepted
    disposition_rationale: "The coherence observation (two sentinels = one idiom) is valuable; both literals are documented in the spec and the agent file. Promotion to a cross-plugin pattern is plausible but premature — the diagnostic-legibility plugin is the only place the idiom currently appears. Revisit if a second plugin reaches for the same shape."
  - id: 4
    lens: [alternatives, consequences]
    title: Reasoning posture as architectural surface
    disposition: accepted
    disposition_rationale: "Three alternatives weighed, middle option chosen and operationalised as a prompt-segment boundary in §4.3 Phase B. The escalation path to two-agent dispatch is named with a falsifiable trigger (high sentinel-only rate, low note diversity). This is the cleanest architectural defence in the spec."
  - id: 5
    lens: [defaults, alternatives]
    title: Shared construction is choice, not consequence
    disposition: accepted
    disposition_rationale: "Recording the choice is the value — recoverability is conditional on someone noticing it was a choice. The story itself is the noticing surface. If §3.3 is ever pruned in a future edit, this story remains as the project's memory that the conflation is wrong."
  - id: 6
    lens: [patterns, consequences]
    title: Dimension weighting as protocol step, not guidance
    disposition: accepted
    disposition_rationale: "Mechanism-over-decoration is the right framing. The dimension-weighting sentences in §4.3 Phase B are now load-bearing prompt content and any future trim of the agent file must treat them as protected — that protection should propagate into the agent file's literate-programming preamble."
  - id: 7
    lens: [defaults, coherence]
    title: Discipline scoping inherited from workflow boundary
    disposition: revisit
    disposition_rationale: "Genuinely silent choice; the diagnostic-legibility plugin and any future sister plugins inherit discipline-light defaults without explicit consent. Open a follow-up issue for a meta-spec titled 'cross-plugin discipline scoping' that decides whether TDAD-scenario-check, docs-reference-parity-check, and similar PR-gates should extend across all marketplace plugins or stay scoped to ai-literacy-superpowers. This slice's PR description must link the follow-up issue."
  - id: 8
    lens: [consequences, patterns]
    title: plugin_version as cross-PR shared mutable state
    disposition: promoted
    disposition_rationale: "Genuine project-wide invariant — every PR touching marketplace.json inherits the same coordination problem. Belongs in CLAUDE.md or HARNESS.md, not restated per-spec. Promotion target: a Marketplace Versioning subsection in CLAUDE.md saying 'plugin_version is owned by ai-literacy-superpowers PRs; per-plugin entries are owned by their respective plugin PRs; conflicts resolve in favour of the field's owner.' The actual promotion mechanism is a follow-up; this disposition is the signal."
  - id: 9
    lens: [alternatives, consequences]
    title: Bare Task-tool dispatch as v0.3.0 surface
    disposition: accepted
    disposition_rationale: "Slice-boundary discipline is the right load-bearing reason. The forward-link in the how-to is the hand-off contract; S4's PR (issue #333) is on the hook to update the how-to when /diagnose ships. The hand-off must be explicit in the S4 spec's file inventory."
---

## Story #1 — Five-question cover as falsifiable hypothesis

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§3.5)
**Lens:** forces, coherence
**Refs:** O1

**Context.** The challenge-refine cycle is the agent's anti-hallucination
value proposition. The spec commits to exactly five questions — boundary,
evidence, confounders, confidence, description integrity — and threads
them through the schema's `challenge_notes[]` field, the agent file's
protocol, and the downstream S3 cross-check. The number five and the
particular five are not derived; they are asserted with rationale and
explicitly marked as a working hypothesis.

**Forces.** Completeness of the challenge cover versus prompt economy:
more questions catch more failure modes but bloat the agent's reasoning
and produce noisier `challenge_notes[]`. Defending a primitive count
versus admitting the count is a guess: a "settled five" calcifies on
first ship; an "admitted hypothesis" invites revision but signals
under-confidence. The spec resolves toward admitted hypothesis with a
named falsification surface (the agent's own `challenge_notes` corpus
across real invocations).

**Options not taken.**
- Three questions (boundary + evidence + confidence) — tighter cover,
  loses confounders and textbook-definition drift; lower coverage of
  the specific failure modes the spec names.
- Eight or more — borrows from analogues (the diaboli skill's six
  categories) but at the cost of agent-context bloat and per-element
  cost.
- A dimension-bespoke cover (different questions for architectural vs.
  domain) — would have foreclosed the shared-protocol choice in §3.3.

**Choice as written.** Five named questions, each with a paragraph
explaining what failure mode it catches, plus an explicit "this is a
working hypothesis" frame and a named falsification surface. The five
are *boundary, ground, identity-by-contrast, calibration, specificity*
in semantic terms.

**Consequences.** The agent's `challenge_notes[]` corpus across real
invocations becomes data. If a recurring failure mode does not map to
any of the five, the cover is missing a question; if two questions
consistently produce identical notes, there is redundancy. Both are
schema-stable observations — adding or merging questions is an agent-
file change, not a schema break. The cover is structurally revisable
in a way that the schema itself is not.

**Pattern.** Working hypothesis with named falsification surface
(Popper). The closest software-engineering analogue is the
"tracer bullet" idiom (Hunt/Thomas, *The Pragmatic Programmer*) — ship
the smallest end-to-end thing, observe what it gets wrong, refine on
evidence rather than speculation. The five questions are the tracer
bullet for the challenge cover.

**Notes.** The disposition rationale on O1 named this stance explicitly;
this story records it as a choice the team is now responsible for. The
falsification only happens if someone is actually looking at the corpus
— a quiet failure mode worth naming.

---

## Story #2 — Q<N> prefix as lightweight in-string schema

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§3.5, §4.3)
**Lens:** patterns, consequences
**Refs:** O10, #1

**Context.** Each entry in `challenge_notes[]` is a free-text string,
per the schema. The spec mandates that every entry begin with
`Q<N> (question name):` — e.g. `Q1 (boundary):`. The prefix is not
required by the schema (challenge_notes is `list[str]` with no
internal structure); it is required by *this slice's* protocol.

**Forces.** Machine-readability for downstream consumers (the S3
cross-check wants to group notes by question) versus author overhead
(prose-like notes become slightly more rigid). Schema purity versus
in-string conventions: the schema deliberately stayed unopinionated
about note format, so the spec must impose discipline outside the
schema.

**Options not taken.**
- Structured `challenge_notes` records (`{question: int, name: str,
  note: str}`) — would have changed the schema; foreclosed by sub-S2a
  shipping schema as `list[str]`.
- A separate `challenged_by_question: {Q1: bool, Q2: bool, ...}` map
  on each element — denormalised, redundant with note content.
- No prefix convention — notes are free-text, downstream consumers
  parse heuristically or by content matching.

**Choice as written.** Mandatory `Q<N> (question name):` prefix in
every entry, with one explicit exemption (the sentinel from Story #3).
The S3 cross-check can group notes by parsing the prefix; no schema
change.

**Consequences.** The prefix is now part of the agent's output
contract — an implementer who omits it produces correct-by-schema but
incorrect-by-protocol output. The protocol layer becomes a second
contract surface that needs verification (an acceptance scenario in
§6.1 covers it). If the convention is later loosened, every existing
`challenge_notes` corpus becomes a mixed-format dataset.

**Pattern.** Lightweight in-string schema, also known as "tagged
strings" in DDD literature; cousin to log-format conventions like
`level=info component=foo message="..."`. The pattern accepts that the
underlying type is a string but adds machine-parseable discipline. The
risk is the well-known one: any string-based schema drifts without
enforcement; the spec depends on the agent following its prompt.

**Notes.** The S3 cross-check (parent issue #332) is the first
real consumer of the prefix. If S3 is built to be tolerant of
prefix-less notes, the convention pressure relaxes; if S3 hard-fails
on missing prefix, the convention pressure tightens.

---

## Story #3 — Sentinel values disambiguate runtime intent

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§3.5, §3.6, §6.3)
**Lens:** patterns, defaults
**Refs:** O2, O7

**Context.** Two sentinels are introduced in the same spec: the
`challenge_notes[]` entry `Challenge applied; no questions surfaced
changes` (signals "challenge ran, found nothing") and the element
`name: "(empty scope)"` (signals "scope yielded no elements"). Both
solve the same shape of problem — an observable state is ambiguous
without a marker — and both solve it by reserving a literal string as
a signal.

**Forces.** Disambiguation pressure (downstream consumers cannot tell
"didn't run" from "ran and clean", "no candidates" from "no evidence")
versus schema purity (adding fields, booleans, or status enums would
have been the heavier-weight resolution). Cheap (string literal) versus
robust (typed field).

**Options not taken.**
- A boolean `challenged: bool` on each element — schema change; would
  have been the typed-and-robust path.
- A top-level `scope_yielded_results: bool` on the LegibilityModel —
  schema change; cleaner data but heavier.
- Leave the ambiguity — the downstream S3 cross-check would need
  out-of-band knowledge to interpret empty lists or empty collections.

**Choice as written.** Two reserved literal strings. The first is a
sentinel note entry; the second is a sentinel element-name. Both are
documented in the spec and the agent file. Both are exact-match: the
note must be byte-for-byte `Challenge applied; no questions surfaced
changes`, the name must be byte-for-byte `(empty scope)` including
parentheses.

**Consequences.** Two new agreed-upon literals in the contract surface
that downstream code must know about. If either string is rephrased
casually (e.g. "Challenge applied; no changes surfaced") the
disambiguation breaks silently. The contract lives in three places —
the spec, the agent file, and the downstream consumer — and must agree
across them.

**Pattern.** Sentinel value, sibling to the Null Object pattern
(GoF) — a literal that stands in for an absent or distinguished state
without adding a new type. Also closely related to the "magic string"
anti-pattern; what saves it from being magic is that the strings are
documented and have exactly-one meaning. The risk transfers from "did
we forget to mark this?" to "did we type the literal correctly?".

**Notes.** Both sentinels were extracted from objections in the same
adjudication pass (O2 and O7). Treating them as one design choice
("how do we disambiguate observable runtime states with the existing
schema?") rather than two unrelated decisions is the coherence
observation. A future contributor reading either sentinel in isolation
may not see they belong to the same idiom.

---

## Story #4 — Reasoning posture as architectural surface

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§3.4, §4.3 Phase B)
**Lens:** alternatives, consequences
**Refs:** O3, O6

**Context.** The challenge step is where the agent's anti-hallucination
value lives. The spec names three architectures: (1) one-context
self-challenge, (2) two-agent dispatch, (3) fresh-sub-context within
one agent. It picks the middle option and operationalises it as an
explicit prompt-segment boundary inside the agent file: after
construction, the agent re-frames itself adversarially and re-reads
the evidence as a challenger.

**Forces.** Independence-of-perspective (the named failure mode
self-confirmation in §3.4 alternative 1) versus agent-file surface
cost (the named failure mode duplication in alternative 2). The middle
option says: independence can be induced by *framing*, not only by
*context separation*. The cost is a few extra paragraphs in the agent
file; the gamble is that adversarial framing produces enough
self-challenge signal to be worth shipping.

**Options not taken.**
- One-context self-challenge — simplest; named failure mode is
  rubber-stamping. Spec acknowledges and rejects.
- Two-agent dispatch — most independent; doubles file surface for a
  v0.3.0 capability. Spec acknowledges and defers (escalation path
  preserved).

**Choice as written.** A single agent file with two reasoning postures
induced by an explicit prompt-segment boundary. Phase A constructs;
Phase B re-frames the agent as a challenger and instructs it to
disagree where evidence allows. The boundary is the prompt itself.

**Consequences.** The agent's reasoning protocol becomes the primary
mechanism for independence-of-perspective. If the prompt's framing is
weak (e.g. an implementer writes "now review your work" instead of
"you are now the challenger; disagree where evidence allows"), the
mechanism degrades to alternative (1) without any structural signal
that it has done so. The escalation path to alternative (2) is named
in §3.4 — if disposition data shows the middle option still produces
rubber-stamped output (high sentinel-only rate, low note diversity),
the team has a documented next step.

**Pattern.** No widely-named pattern; closest analogue is
"role-prompting" in the LLM-application literature — inducing different
reasoning postures within one model context by changing the framing of
the prompt segment. Also resembles the "wear two hats" practice in
review traditions (an author reviews their own draft after a deliberate
context break, e.g. sleeping on it). Both rely on framing rather than
structural separation.

**Notes.** Story #6 (dimension weighting as protocol step) is the
sister mechanism — both choices treat prompt structure as
architecturally load-bearing rather than incidental. Together they
make the agent file's prompt a primary mechanism rather than a
description.

---

## Story #5 — Shared construction is choice, not consequence

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§3.3)
**Lens:** defaults, alternatives
**Refs:** O9

**Context.** The schema is shared across both dimensions (architectural
and domain elements use the same `LegibilityElement` record type — sub-
S2a settled this). The temptation is to treat shared construction
(one prompt loop emits both collections) as a logical consequence of
the shared schema. The spec resists that conflation: §3.3 argues
explicitly that shared construction is a *choice*, defensible on its
own merits, not an inheritance.

**Forces.** Inheritance economy (one loop is half the complexity of
two) versus dimension-specific care (architectural and domain elements
fail in different ways, and bespoke loops could tune for each). The
schema's silence on construction means the architectural choice is
genuinely independent — neither path is foreclosed.

**Options not taken.**
- Bifurcated loops with shared schema — two construction sequences,
  each tuned to its dimension's failure modes, both emitting into the
  same record type. Not foreclosed by the schema.
- Per-dimension agent files — full bifurcation, would have meant two
  agent files in `diagnostic-legibility/agents/`. Foreclosed by §3.4's
  one-file constraint and by the §3.3 reasoning.
- Schema-driven inference (no explicit choice) — the failure case
  this story is recording.

**Choice as written.** One shared construction loop, with dimension-
flavoured weighting (Story #6) as the per-element adaptation point.
The spec defends this on three grounds: linear complexity scaling,
dimension-aware behaviour delivered by weighting rather than
bifurcation, and recoverability if disposition data justifies a split.

**Consequences.** Future contributors reading the agent file see one
construction loop; their default assumption will be "shared because
schema". The spec's explicit framing is the only artefact that
prevents that assumption from becoming the explanation. If §3.3 is
forgotten or pruned in a future edit, the choice silently
re-conflates with the schema.

**Pattern.** Default-as-decision (also "implicit defaults made
explicit" — see Hunt/Thomas, Pragmatic Programmer, on the dangers of
inherited defaults). The pattern is recordkeeping: name the choice so
the future reader knows it was a choice. The story's job is the same
recordkeeping at a layer above the spec.

**Notes.** O9 was adjudicated as "low severity, recoverable" — the
choice is genuinely cheap to reverse. The point of recording it is
recoverability is conditional on someone noticing it was a choice;
this story is the noticing surface.

---

## Story #6 — Dimension weighting as protocol step, not guidance

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§3.5, §4.3 Phase B)
**Lens:** patterns, consequences
**Refs:** O4, #4, #5

**Context.** The spec asserts dimension-flavoured emphasis on the
challenge questions: domain elements pressure-test Q5 (description
integrity) heavily, architectural elements pressure-test Q1
(boundary) heavily. The flavouring could have been left as decorative
guidance ("apply the questions with awareness of dimension") or
operationalised as an explicit per-element step in the agent's
construction protocol. The spec chose the latter.

**Forces.** Mechanism (the flavouring actually shapes the agent's
behaviour) versus decoration (the flavouring is named but the agent
implements without it, and the spec's claim is unverified). Agent-
prompt economy (each per-element step costs prompt tokens and reader
attention) versus correctness-by-construction (a documented step is
testable).

**Options not taken.**
- Decorative-only — name the flavouring in §3.5 and trust the
  implementer to apply it. The failure mode O4 raised explicitly: an
  agent file that ignores the flavouring passes the spec's acceptance
  scenarios.
- Two construction loops with bespoke prompts — foreclosed by Story
  #5's shared-construction choice.
- Per-dimension question lists — also foreclosed by §3.5's shared
  five-question structure.

**Choice as written.** The construction protocol's Phase B (§4.3)
includes an explicit "when challenging a domain element, weight Q5
heavily" / "when challenging an architectural element, weight Q1
heavily" step. The agent's prompt operationalises the flavouring as a
discrete behaviour, not as ambient awareness.

**Consequences.** The agent file becomes architecturally load-bearing
in a specific way: deleting or weakening the dimension-weighting
sentence in §4.3 silently weakens the agent's output. A future
refactor of the agent file (e.g. trimming for prompt brevity) must
treat that sentence as protected. The escalation path is also
preserved — if dimension-weighting via prompt proves too weak, the
next move is bifurcated construction (Story #5's deferred alternative).

**Pattern.** Mechanism over decoration; closely related to
"executable specification" (the spec section *is* the implementation
contract for the prompt). The agent file is treated as code that
encodes design decisions, not as documentation that describes them.

**Notes.** Pairs with Story #4 (reasoning posture as architectural
surface) — both choices treat the agent's prompt structure as a
first-class mechanism rather than as incidental phrasing.

---

## Story #7 — Discipline scoping inherited from workflow boundary

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§8 Out of scope)
**Lens:** defaults, coherence
**Refs:** —

**Context.** The plugin's two PR-time gates for new component files —
TDAD-scenario-check and docs-reference-parity-check — are scoped by
path regex to `ai-literacy-superpowers/skills/`, `/agents/`, and
`/commands/`. The diagnostic-legibility plugin's `agents/` directory
is outside that scope. This slice ships a new agent file with no TDAD
scenario and no reference-page entry, and CI passes because the
gates do not apply.

**Forces.** Cross-plugin discipline consistency (the same rigor
applied to one plugin should arguably apply to all) versus
incrementalism (each plugin earns its discipline by experience, not
by symmetry). The choice to scope the workflows narrowly was made in
the workflows themselves, before diagnostic-legibility existed; this
slice silently inherits the absence.

**Options not taken.**
- Broaden the workflows to all plugins now — out of slice scope; a
  meta-decision belonging to a separate spec (§8 notes this).
- Author TDAD scenarios voluntarily — possible, but creates
  expectation drift (other plugins also have agents and would inherit
  the implicit expectation).
- Add a reference-page entry voluntarily — same drift risk; also the
  diagnostic-legibility plugin has no reference quadrant yet, so the
  entry would require scaffolding.

**Choice as written.** Ship the new agent file with no TDAD scenario
and no reference-page entry. §8 names this as inherited from workflow
scoping, not as a per-slice choice. The §8 entries explicitly defer
the meta-question ("should the discipline extend across plugins?") to
a future spec.

**Consequences.** The diagnostic-legibility plugin accumulates agent
files that no PR-time gate verifies. The first new constraint of the
plugin (e.g. its own TDAD discipline) will have to retroactively cover
the existing agent file or admit a gap. The cost of catching this
later grows with each agent file shipped without scenarios.

**Pattern.** Inherited default — the discipline boundary was set by
workflow design (one plugin in scope), not by spec design. The story
records that the boundary is a choice the project has now propagated
across two plugins; future plugin additions will inherit it again
unless the boundary is reconsidered explicitly.

**Notes.** This is the strongest "silent choice" candidate in the
spec — the slice ships discipline-light components and the
explanation lives in workflow files rather than in spec text. A
reasonable disposition is "revisit" with a forward-looking
disposition_rationale naming the meta-spec that would address it.

---

## Story #8 — plugin_version as cross-PR shared mutable state

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§9)
**Lens:** consequences, patterns
**Refs:** O8

**Context.** `.claude-plugin/marketplace.json` carries a top-level
`plugin_version` field that points to the current `ai-literacy-
superpowers` plugin release. This slice does not change that field
(it only bumps the `diagnostic-legibility` entry in `plugins[]`), but
it must touch the same file, and main may have moved between spec-
time and merge-time. §9 articulates the merge-time rule: take main's
`plugin_version` verbatim on conflict.

**Forces.** Spec correctness at authoring time (the spec asserts
`plugin_version: 0.39.1` as the spec-time snapshot) versus operational
correctness at merge time (whichever value main carries when the PR
lands is the one that matters). The two correctness criteria can
disagree silently if main moves.

**Options not taken.**
- Atomic per-PR ownership of `marketplace.json` (one PR at a time
  edits it) — would have foreclosed parallel work on different
  plugins.
- Splitting `marketplace.json` into per-plugin files — would address
  the shared-mutable-state problem at the cost of restructuring the
  marketplace contract with Claude Code.
- Leaving the conflict-resolution rule implicit — the previous
  approach, surfaced by O8 as a latent footgun.

**Choice as written.** A documented merge-time rule in §9: this PR
owns the `diagnostic-legibility` entry's version bump only; conflicts
on `plugin_version` are resolved in favour of main. The
integration-agent's rebase is the point of enforcement; the human
reviewing the rebase is the second line of defence.

**Consequences.** Every future PR touching `marketplace.json` inherits
the same shared-mutable-state coordination problem. The §9 rule is a
per-spec restatement of a project-wide invariant; that invariant
properly lives in HARNESS.md or in a project convention file, not in
each spec. The pattern of restating it per-spec is a workaround until
the invariant is promoted.

**Pattern.** Shared mutable state with conflict-resolution policy;
sibling to git-merge conventions for files with concurrent writers
(e.g. `CHANGELOG.md`'s "append under most-recent version" convention
in this codebase). The pattern recognises that some files are
unavoidably shared across PRs and the question becomes "what is the
merge rule?" rather than "how do we prevent the shared edit?".

**Notes.** A reasonable promotion target: a HARNESS.md constraint
("marketplace.json `plugin_version` is owned by ai-literacy-superpowers
PRs; per-plugin entries are owned by their respective plugin PRs;
conflicts resolve in favour of the field's owner"). If
disposition is `promoted`, this is the rationale.

---

## Story #9 — Bare Task-tool dispatch as v0.3.0 surface

**Source:** `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md` (§2.4, §6.5)
**Lens:** alternatives, consequences
**Refs:** O5

**Context.** The agent has no wrapping slash-command at v0.3.0. The
spec documents bare Task-tool dispatch as the invocation surface
(`subagent_type: diagnostic-legibility`, prompt names the scope). The
how-to page in the same slice documents this pattern, with a forward
link to parent S4 (issue #333) which will deliver `/diagnose`. The
diagnostic-legibility plugin therefore ships an agent that humans
must invoke through a lower-level surface than the model-card plugin's
`/model-card` command exposes.

**Forces.** Carpaccio's slice-boundary discipline (S2 ships the agent,
S4 ships the command) versus user ergonomics at v0.3.0 (every
invocation requires Task-tool literacy). The slice boundary is the
load-bearing reason; without it, the temptation to bundle command and
agent into one slice would erode the parent's carpaccio decomposition.

**Options not taken.**
- Ship a thin `/diagnose` command in this slice that wraps the agent
  without doing more — would have been low-cost but conflated S2
  with S4.
- Ship the agent without a how-to page — would have removed the
  surfacing problem at the cost of leaving the v0.3.0 release
  undocumented for users.
- Defer the agent file to S4 — would have collapsed S2 entirely.

**Choice as written.** Agent in S2, command in S4. The how-to page
documents bare Task-tool dispatch and forward-links to S4. The
v0.3.0 plugin is dispatchable but not commanded.

**Consequences.** Two readable surfaces (how-to page, agent file)
documenting an invocation pattern that the project's typical user
will not use directly once `/diagnose` exists. The how-to page will
need to be updated when S4 lands, replacing the Task-tool example
with the `/diagnose` example. The forward-link in the how-to is the
hand-off contract — if S4 lands without updating the how-to, the
plugin documentation goes stale.

**Pattern.** Slice-boundary discipline (Henrik Kniberg's elephant
carpaccio applied to design slices), trading short-term ergonomics
for long-term decomposition integrity. The cost is paid up-front in
documentation churn; the benefit is that each slice's deliverable is
genuinely scoped.

**Notes.** O5's adjudicated rationale named the forward-link
explicitly. The disposition here is whether the project is comfortable
shipping a v0.3.0 with a how-to that the user-facing surface will
supersede; the alternative is the deferred ergonomics. A reasonable
disposition is `accepted` with a note that S4's PR must update the
how-to.
