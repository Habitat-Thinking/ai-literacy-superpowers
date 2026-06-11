---
spec: docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md
date: 2026-06-11
mode: code
diaboli_model: claude-opus-4-8
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "The charter cites 'lines 153–158' of estimate-record-format.md as the operative definition of the normalisation the mechanical cost-omission rule depends on, but #377 will edit that same file, silently desyncing the load-bearing line reference."
    evidence: "agents/cost-estimator.agent.md:163 — 'applying the S1 join-key normalisation from estimate-record-format.md (lines 153–158) before deciding a tier is unmapped'; the normalisation today lives at estimate-record-format.md:153-158, but spec §6.1/§2.2 split a format-reference mutation out to #377, which by definition shifts those lines."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Cite the section heading ("Stage/tier normalisation (the
      join key)") instead of the line range, so #377's edits to
      estimate-record-format.md cannot desync the reference.
  - id: O2
    category: implementation
    severity: high
    claim: "The mechanical cost-omission rule the spec was redesigned to make non-discretionary still ends in an open-ended 'or otherwise ungrounded' catch-all, re-admitting the agent judgment §6.2/O4 removed."
    evidence: "agents/cost-estimator.agent.md:171-173 — 'Omit cost_usd ... whenever ANY exercised stage's tier is unmapped by the binding table — or otherwise ungrounded.' The two enumerated mechanical checks (tier-mapping, model-key) are crisp; 'or otherwise ungrounded' names no test, so an instance decides for itself what counts as ungrounded."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Remove the open "or otherwise ungrounded" catch-all (the
      two enumerated checks ARE the mechanical rule), or replace it with the
      explicit S1 three-grounding-state enumeration — close the discretion the
      catch-all reopened.
  - id: O3
    category: risk
    severity: medium
    claim: "The honest-fallback generated_by value 'tier:Standard' is hard-coded as a literal in the charter; if MODEL_ROUTING.md ever re-tiers cost-estimator, the charter emits a tier label that no longer matches its own routing row, with no mechanism to catch the drift."
    evidence: "agents/cost-estimator.agent.md:202 hard-codes 'generated_by: cost-estimator / tier:Standard' and :204 grounds it in 'your MODEL_ROUTING.md Agent Routing row, which you read anyway' — but the literal 'Standard' is written into the prose, not derived from the row the agent reads. Story #9 (spec §7) names this coupling; the implementation pins one side of it."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Instruct the agent to echo the tier it READS from its own
      MODEL_ROUTING Agent Routing row, rather than emitting the literal
      "Standard", so a future re-tier cannot silently desync the provenance.
  - id: O4
    category: risk
    severity: medium
    claim: "The charter's grounding-read policy does not require MODEL_ROUTING.md to be read before the agent commits to emit-vs-refuse, yet two of the four refusal triggers (absent / tableless MODEL_ROUTING.md) depend on having attempted that read — leaving the refusal/emit routing's ordering implicit for a model: inherit instance."
    evidence: "agents/cost-estimator.agent.md:20-31 makes 'Your first action' the SKILL.md read; the 'Grounding-source read policy' at :298-302 says to read MODEL_ROUTING.md but states no point at which the read must precede the refusal decision at :222-235. Trigger 3 (readable-but-tableless) requires the agent to have parsed the two named tables before classifying the situation; nothing sequences that read ahead of an emit attempt."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Add an explicit step: read and parse MODEL_ROUTING.md's two
      tables BEFORE deciding emit-vs-refuse, so the refusal routing isn't left to
      instance ordering.
  - id: O5
    category: scope
    severity: medium
    claim: "The agents reference page's count and pipeline-size prose are now inaccurate after adding cost-estimator, shipping a reference that is wrong on the day it merges — the exact docs-parity failure the project's docs-review convention exists to prevent."
    evidence: "docs/plugins/ai-literacy-superpowers/reference/agents.md:6 'The plugin ships 13 agents' and :20 'These eight agents form the spec-first development pipeline' — the file now carries 15 '###' agent entries and the pipeline section lists nine (orchestrator, carpaccio, spec-writer, advocatus-diaboli, choice-cartographer, cost-estimator, tdd-agent, code-reviewer, integration-agent). FR-16/scenario coverage asserts the cost-estimator entry exists but not that the surrounding counts were corrected."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Reconcile the reference page's count prose: "ships 13
      agents" → 15, "These eight agents form the spec-first development pipeline"
      → nine.
  - id: O6
    category: specification quality
    severity: low
    claim: "The plan instructs the implementer to edit a CHANGELOG path that does not exist, so the version-bump task as written cannot be executed faithfully and an implementer must silently improvise the real location."
    evidence: "plans/2026-06-11-cost-estimator-agent.md:63-64 and :364 name 'ai-literacy-superpowers/CHANGELOG.md' as the file to add the 0.42.0 entry to; no such file exists (Glob for **/CHANGELOG.md returns model-cards/, diagnostic-legibility/, and root CHANGELOG.md). The 0.42.0 entry was in fact written to the repo-root CHANGELOG.md, not the path the plan specifies."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Correct the plan's CHANGELOG path from the non-existent
      ai-literacy-superpowers/CHANGELOG.md to the repo-root CHANGELOG.md.
---

## O1 — implementation — high

### Claim

The charter operationalises its single most safety-critical mechanical check —
the tier-mapping normalisation that decides whether cost is emitted or
omitted — by citing a *line range* in another file: "lines 153–158" of
`estimate-record-format.md`. That file is the one artefact this whole slice was
re-architected to leave untouched precisely because a sibling slice (#377) owns
and will mutate it. The moment #377 adds or moves a line above line 158, the
charter's citation points at the wrong text, and a future reader (human or agent)
following the citation reads something other than the normalisation rule.

### Evidence

`agents/cost-estimator.agent.md:163`:

> applying the S1 **join-key normalisation** from `estimate-record-format.md`
> (lines 153–158) **before** deciding a tier is unmapped

The normalisation today does live at `estimate-record-format.md:153-158`
("Stage/tier normalisation (the join key)"). But spec §2.2 and §6.1 split a
format-reference mutation out to **#377**, and §5.3's conflict-flag note even
anticipates a validator change to that same file. Any edit #377 makes above line
158 desyncs this citation.

### Why this matters

The normalisation is load-bearing: §6.2 states that without it "a correctly-mapped
split tier ... would be falsely reported unmapped on a spacing mismatch and cost
over-omitted." A charter is an instruction artefact — an agent instance that
follows a stale line citation to the wrong paragraph could apply the wrong (or no)
normalisation and over-omit cost on the dominant implementer stage. The citation
should name the section heading ("Stage/tier normalisation (the join key)"), which
is stable across edits, not a line range into a file a known-pending slice will
rewrite. This is a code-time finding invisible at spec time: the spec described the
normalisation by behaviour; the implementation chose a brittle pointer to encode it.

## O2 — implementation — high

### Claim

The central spec-mode adjudication (O4, accepted) removed the discretionary
"load-bearing" test so the agent stays emit-not-decide: the omission rule was made
purely mechanical — two yes/no checks. The implemented rule keeps those two checks
but appends "or otherwise ungrounded," an open-ended residual clause with no
defined test. That clause re-opens exactly the discretionary surface O4 closed: an
instance must now decide, on its own reading, what "otherwise ungrounded" covers.

### Evidence

`agents/cost-estimator.agent.md:171-173`:

> **Omit `cost_usd` ... whenever ANY exercised stage's tier is unmapped by the
> binding table — or otherwise ungrounded.** No judgment about whether the
> unmapped tier is "load-bearing."

The two preceding checks (tier-mapping at :160-169, model-key at :179-184) are
crisp and falsifiable. "or otherwise ungrounded" names no third mechanical
predicate. The sentence asserts "no judgment about whether the tier is
load-bearing" — but says nothing about the judgment the catch-all itself invites.

### Why this matters

The skill's charter is the only thing standing between the design and a
misbehaving agent, and O4's whole point was that "choosing which record shape to
emit on the agent's own read of it is a derived decision the tool boundary cannot
constrain." A catch-all that reads as "...and any other case you judge ungrounded"
is the same drift in a thinner disguise. Two instances reading "otherwise
ungrounded" can diverge: one treats a coarse-but-present Model Breakdown (S1 state
2) as covered, another does not. The clause should either be deleted (the two
enumerated checks are the mechanical rule) or replaced with an explicit closed
enumeration mapping to the S1 three grounding states. As written, the
determinism the revision was built to achieve is not fully delivered in the prose
an instance actually follows.

## O3 — risk — medium

### Claim

The `generated_by` honest-fallback value is hard-coded as the literal string
`tier:Standard` in the charter prose. The spec frames this value as *grounded in*
the MODEL_ROUTING.md Agent Routing row the agent reads (the Story #9 coupling). By
pinning the literal into the instruction rather than deriving it from the row, the
implementation creates a silent desync: re-tier the agent in MODEL_ROUTING.md and
the charter keeps emitting `tier:Standard`, now provenance that contradicts the
routing table it claims to be grounded in.

### Evidence

`agents/cost-estimator.agent.md:201-204`:

> record the routing tier you are specced at:
> `generated_by: cost-estimator / tier:Standard`. The `tier:` prefix marks the
> value as a routing-tier label ... grounded in your `MODEL_ROUTING.md` Agent
> Routing row, which you read anyway.

The literal `Standard` is written into the charter; the claim that it is "grounded
in your MODEL_ROUTING.md row" is asserted but not enforced — nothing instructs the
agent to read the tier *from* the row and echo it. The MODEL_ROUTING.md row
(`MODEL_ROUTING.md:17`) is the actual source of truth; the charter duplicates its
value as a constant.

### Why this matters

Hard-coded provenance that purports to be grounded is the milder cousin of the
fabricated-provenance failure §5.4 exists to prevent: the value looks honest but
can become false without any code change. The fix is cheap — instruct the agent to
echo the tier it reads from its own Agent Routing row rather than emitting a literal
— and keeps the §7 "the tier label here is the honest fallback" claim true over time.
A reviewer focused on CUPID/literate qualities would pass this prose; the drift only
bites when MODEL_ROUTING.md changes, which is precisely the kind of latent coupling
a code-time adversarial pass should surface.

## O4 — risk — medium

### Claim

The refusal/emit routing depends on the agent having attempted to read and parse
MODEL_ROUTING.md's two tables (triggers 2 and 3), but the charter sequences only
the SKILL.md read as a "first action" and states the MODEL_ROUTING.md read in a
later, unordered "read policy" section. For a non-deterministic `model: inherit`
instance, nothing guarantees the grounding read precedes the emit-vs-refuse
decision — leaving the most consequential branch in the agent's behaviour
implicitly ordered.

### Evidence

`agents/cost-estimator.agent.md:20-31` makes the SKILL.md load the explicit "Your
first action." The MODEL_ROUTING.md read appears only at :298-302 ("Grounding-source
read policy") with no sequencing relative to the refusal logic at :222-235. Trigger
3 (`agents/cost-estimator.agent.md:228-235`, readable-but-tableless) is *defined by*
the result of parsing those two tables — a state the agent can only reach by having
read them first.

### Why this matters

The empty-snapshot-vs-refuse distinction is, per the plan, "the single most likely
implementation error to guard against" (plan:140-141). An instance that begins
emitting before confirming MODEL_ROUTING.md parses could produce a cost-omitted
record where a `REFUSED:` was required (tableless MODEL_ROUTING.md), or vice versa.
The behavioural scenarios fixture-pin the grounding so they *can* still grade the
outcome, but the charter — the artefact that constrains a live, unfixtured dispatch
— leaves the read-before-decide ordering to the model's discretion. An explicit
"before deciding emit-vs-refuse, read and parse MODEL_ROUTING.md's two tables"
step would close it.

## O5 — scope — medium

### Claim

Adding the cost-estimator entry to the agents reference left the page's own
self-describing counts stale: it still states "13 agents" and "eight agents form
the spec-first development pipeline," while the file now carries fifteen agent
entries and the pipeline section enumerates nine. The reference ships inaccurate on
the day it merges.

### Evidence

`docs/plugins/ai-literacy-superpowers/reference/agents.md:6`: "The plugin ships 13
agents organised into three groups"; `:20`: "These eight agents form the spec-first
development pipeline." The file's `###` headings now number fifteen, and the
Pipeline Agents section lists nine (orchestrator, carpaccio, spec-writer,
advocatus-diaboli, choice-cartographer, cost-estimator, tdd-agent, code-reviewer,
integration-agent). The Tool Summary table at :345 correctly includes the
cost-estimator row, so the body and the counts now disagree.

### Why this matters

CLAUDE.md's Docs Site Review convention requires reference pages to be current "on
the day it ships," and the spec's own §12/FR-16 invoked the docs-reference-parity
gate. The cost-estimator row was added but the surrounding counts were not
reconciled, so the parity the slice claimed to satisfy is only partial. This is a
code-time finding: the spec said "a reference-page entry for the new agent"
(§12) — true and done — but the implementation reveals the entry was inserted
without updating the count prose the same file maintains, which the spec text could
not have anticipated.

## O6 — specification quality — low

### Claim

The plan directs the implementer to write the CHANGELOG entry to a path that does
not exist in the repository. The faithful executor either fails the step or
silently substitutes the real path — and the latter is what happened, masking the
plan defect.

### Evidence

`plans/2026-06-11-cost-estimator-agent.md:64` ("ai-literacy-superpowers/CHANGELOG.md
# MODIFIED: new 0.42.0 entry") and `:364` ("`ai-literacy-superpowers/CHANGELOG.md`:
new `## 0.42.0 — 2026-06-11` heading"). No `ai-literacy-superpowers/CHANGELOG.md`
exists; CHANGELOG.md files are at the repo root, `model-cards/`, and
`diagnostic-legibility/`. The 0.42.0 entry was correctly written to the root
`CHANGELOG.md:3`, not the path the plan names.

### Why this matters

The outcome here is correct, so this is low severity — but a plan that names a
non-existent file teaches the implementer to ignore the plan's paths, which is a
slow-acting erosion of plan-as-contract. It also means the plan's later
version-consistency check (:377-389) and the CHANGELOG instruction reference
different real files than they print, so a future maintainer reusing this plan as a
template inherits the wrong path. Worth a one-line correction; not a blocker.

## Explicitly not objecting to

- **The S1 format reference being untouched**: I read `estimate-record-format.md`
  in full and confirmed the agent emits against it exactly as-merged — no field
  added, no validation line changed, and the cost-omitted directory-path
  convention (`observability/costs/`) matches the reference's worked Example 1 — so
  the §2.3 "pure consumer" boundary holds; I am not re-raising the adjudicated
  O1/O2/O3 from the spec round.
- **The behavioural oracle determinism**: each of the eight behavioural scenarios
  grades only frontmatter conformance, presence/absence of named fields/markers, or
  the `REFUSED:` prefix, and each explicitly disclaims exact token numbers and prose
  wording (e.g. the `human_gate_time` "present and not a range, never its caveat
  content" carve-out) — the §8 descope is honoured, so I am not objecting that the
  scenarios smuggle a semantic judgement.
- **The tool boundary and version-consistency wiring**: `tools: [Read, Glob, Grep]`
  is exact, `model: inherit` is correct, and the 0.42.0 bump is consistent across
  plugin.json, the CHANGELOG entry, and (per the plan's own check) marketplace.json
  and README — the emit-not-write mechanism is enforced by construction, so I am not
  manufacturing a trust-boundary objection.
- **The MODEL_ROUTING.md Standard-tier row**: the new `cost-estimator | Standard`
  row reads consistently with the tdd-agent precedent and the §7 rationale; the tier
  *choice* is a decision-archaeology matter (no failure shape), so under the Routing
  Rule it belongs to the Cartographer, not here — I note only the *coupling* risk
  (O3), not the choice itself.
