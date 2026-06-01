# `/assess` — ALCI Part D operational axes + Habitat Build Gap — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-01 |
| Status | Draft — awaiting plan approval |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Driving change | Upstream framework: ALCI extended with **Part D — Operational Axes** and the **Habitat Build Gap** diagnostic |
| Upstream refs | `ai-literacy-for-software-engineers` commits `f13d388` ("Adopt Habitat Maturity Model into framework — per-level rubric + ALCI Part D", #327) and `542f325` ("Add unified cognitive+operational dimensions matrix to Part II", #330). Framework source: `framework/framework.md` Appendix M (Part D, lines ~4051–4172) and Appendix U (The Cognitive–Operational Gap). |
| Plugin version target | `ai-literacy-superpowers` v0.39.1 → v0.40.0 (behavioural change to a command, skill, and agent) |
| PR ceremony | Cross-repo feature. Local spec (this file) satisfies the spec-first gate; PR links the upstream framework commits. Lighter path chosen by the human: spec → implement → integrate (adversarial + cartographer gates skipped for this change). |

---

## 1. Premise

The AI Literacy framework's assessment instrument — the **AI Literacy
Collaboration Index (ALCI)** — was extended in 2026-05 with a new
**Part D: Operational Axes**. Parts A–C measure where a team sits in
the *cognitive* literacy progression (what its members can think and
do). Part D measures what the team's *habitat actually delivers* across
four operational axes:

- **Composition** — how structurally sophisticated the agent topology is.
- **Testing** — how rigorously the collaboration's output is verified.
- **Observability** — how visible agent activity is and how tight the
  feedback loop back into agent behaviour is.
- **Governance** — how formal and enforceable the team's governance over
  AI use is.

Each axis is placed L1–L5. The cognitive position (level placement from
Part A) and the operational position (the mean of the four Part D axes)
together produce the **Habitat Build Gap** — a coherence diagnostic:

```text
Habitat Build Gap = level_placement − operational_axes_mean
```

The plugin's `/assess` command currently produces a cognitive-level
assessment (a single level + three-discipline maturity + a standalone
Governance Dimension). It does not surface the operational axes or the
Habitat Build Gap. This spec brings `/assess` into line with the
framework's latest ALCI.

## 2. Fixed decisions (human-set, not re-litigated here)

1. **Hybrid administration.** `/assess` places the four operational axes
   **evidence-first** by default (gather observable repo evidence per
   axis and place each L1–L5, mirroring how the command already places
   the cognitive level), and **offers the full 40-statement ALCI Part D
   survey as an opt-in** for teams that want the rigorous instrument.
2. **Keep both governance views, cross-referenced.** The existing
   standalone **Governance Dimension** section (the governance deep-dive
   with the `/governance-constrain` ladder) is retained. The new
   **Governance operational axis** is added as the operational summary.
   Each cross-references the other; the axis is the one-line operational
   placement, the Dimension is the deep-dive. The Governance axis score
   feeds the operational axes mean.
3. **Local spec referencing upstream** (this document) for the
   spec-first gate.

## 3. The four operational axes

Source: framework `framework.md` Appendix M, Part D. Each axis is placed
L1–L5 using the framework's per-level markers (reproduced condensed
below; the agent reference carries the full marker text).

| Axis | What it measures | L1 → L5 shape (condensed) |
| --- | --- | --- |
| **Composition** | Agent topology sophistication | single ad-hoc agent → saved prompts/critic → primary+read-only critics, documented → harness-composed bounded ensembles → self-orchestrating constellations |
| **Testing** | Verification rigour | manual inspection → unit tests + mutation → behaviour+business tests, agent tests before merge → comprehensive automation + system regression → multi-perspective + prod-like + agent-authored plans |
| **Observability** | Agent-activity visibility + feedback loop | inspect by eye → searchable logs + basic metrics → instrumented dashboards at cadence → cross-team aggregation + perception-reality calibration → closed-loop (outputs feed agent behaviour) |
| **Governance** | Formality/enforceability of AI-use governance | implicit/trust-based → informal norms → written constitution enforced → policy-as-code in CI → continuous certification with evidence |

### 3.1 Evidence signals per axis (evidence-first path)

The assessor maps observable repo signals to an axis placement. Working
signal map (extends `references/sophistication-markers.md` and
`tool-config-evidence.md`):

- **Composition** — count and shape of custom agents; presence of
  read-only critic/reviewer agents; orchestrator with safety gates;
  agent-team docs in AGENTS.md; multi-agent workflow scripts.
- **Testing** — test suites; coverage enforcement; mutation testing
  config + cadence; tests-before-merge CI gates; system/regression
  suites; agent-authored test scenarios (e.g. `tdad_tests/`).
- **Observability** — logging of agent activity; metrics capture
  (token/latency/cost); dashboards; observability snapshots at cadence;
  perception-reality calibration; OTel config; closed-loop signals.
- **Governance** — HARNESS.md constraint count + enforcement ratio;
  policy-as-code CI checks; falsifiable constraints; governance audit
  cadence; institutional-frame modelling. (Reuses the existing
  Governance Dimension evidence.)

Where repo evidence is ambiguous for an axis, the assessor may ask **one
or two** clarifying questions for that axis (consistent with the
command's existing 3–5 question budget) rather than guessing.

## 4. The Habitat Build Gap

Source: framework `framework.md` Appendix M ("Habitat Build Gap")
and Appendix U ("The Cognitive–Operational Gap").

```text
Habitat Build Gap = level_placement − operational_axes_mean
```

Both values are on the 0–5 scale; the gap is signed. Interpretation
regimes (framework working defaults):

| Gap | Name | Interpretation |
| --- | --- | --- |
| `abs(gap) < 0.5` | **Coherent** | Team and habitat at the same level; collaboration well-supported. |
| `gap ≥ +0.5` | **Ambition outpaces enablement** | Team thinks at a higher level than the habitat supports — build the habitat the team's thinking implies. |
| `gap ≤ −0.5` | **Inherited habitat** | Habitat is more mature than current practice — literacy uplift before further harness extension. |

The headline signal is **coherence**, not the size of the level. A
coherent L2/L2 team is healthier than an incoherent L4/L1 team.

Output format (matches the framework's worked example):

```text
Level placement (from cognitive assessment): L3
Operational axes mean (Part D):              L2.0
  Composition:    L2
  Testing:        L2
  Observability:  L1
  Governance:     L3
Habitat Build Gap:                           +1.0
Interpretation:                              Ambition outpaces enablement
```

## 5. Hybrid administration

### 5.1 Evidence-first (default)

During the existing Phase 1b broader signal scan, the assessor also
gathers the per-axis evidence (§3.1) and places each axis L1–L5,
citing evidence per axis exactly as it cites evidence for the cognitive
level. This adds no new interactive friction beyond the occasional
per-axis clarifying question.

### 5.2 Full survey (opt-in)

After the evidence-first placement, the command offers:

> "Place the operational axes from observable evidence (default), or
> administer the full 40-statement ALCI Part D survey (≈10 min) for a
> rigorous score?"

On opt-in, the assessor administers the 40 statements (4 axes × 5 levels
× 2 statements) on the framework's Strongly-Disagree→Strongly-Agree
scale, taking the higher-scoring level per axis. The survey statements
are carried in a new reference file (`references/operational-axes.md`)
sourced verbatim from framework Part D so they stay faithful and
auditable. Survey scores replace the evidence-first placement for that
run; the assessment document records which mode was used.

## 6. Changes per artifact

| Artifact | Change |
| --- | --- |
| `ai-literacy-superpowers/skills/ai-literacy-assessment/SKILL.md` | Add an "Operational Axes (ALCI Part D)" scoring section: the four axes, the evidence-first placement heuristic, the opt-in survey, and the Habitat Build Gap computation + interpretation regimes. |
| `.../references/assessment-template.md` | Add two sections to the document template: `## Operational Axes (ALCI Part D)` (a 4-row table: axis · placement L1–L5 · evidence) and `## Habitat Build Gap` (the level/axes-mean/gap/interpretation block). Cross-reference the existing Governance Dimension from the Governance axis row. |
| `.../references/operational-axes.md` (**new**) | The four axes' full L1–L5 marker statements (the 40 survey statements) sourced verbatim from framework Part D, plus the evidence-signal map (§3.1). Single source for both administration modes. |
| `.../references/sophistication-markers.md`, `tool-config-evidence.md` | Add the operational-axis evidence signals (§3.1) so the existing evidence references cover them. |
| `ai-literacy-superpowers/agents/assessor.agent.md` | Phase 1b: gather per-axis evidence. Document generation: emit the Operational Axes + Habitat Build Gap sections and compute the gap. Reconcile the existing **Governance Dimension** section with the new **Governance axis** (cross-reference; the axis is the operational summary, the Dimension the deep-dive; the axis score feeds the axes mean). Add the opt-in survey path. |
| `ai-literacy-superpowers/commands/assess.md` | Step 4 (Document): add the Operational Axes + Habitat Build Gap sections. Step 5 (validation checkpoint): verify the new sections exist, the axes mean is computed, and the gap + interpretation are present and internally consistent (gap = level − mean, interpretation matches the regime). Add the §5.2 opt-in survey prompt to the flow. |
| `docs/plugins/ai-literacy-superpowers/how-to/run-an-assessment.md` | Document the operational axes, the hybrid administration, and how to read the Habitat Build Gap. |
| `ai-literacy-superpowers/.claude-plugin/plugin.json`, `README.md` badge, `CHANGELOG.md`, marketplace entry `version` | Version bump 0.39.1 → 0.40.0. |
| `tdad_tests/tests/` | Structural tests (see §10). |

## 7. Governance reconciliation

- The standalone **Governance Dimension** section (assessor agent +
  template) is **retained** unchanged in substance — it remains the
  governance deep-dive with the `/governance-constrain` improvement
  ladder.
- The new **Governance operational axis** is the one-line operational
  placement (L1–L5) that sits alongside Composition/Testing/Observability
  and feeds the operational axes mean.
- **Cross-reference both ways**: the Governance axis row in the
  Operational Axes table links to the Governance Dimension section ("see
  Governance Dimension for the deep-dive"); the Governance Dimension
  section notes that its operational placement is summarised as the
  Governance axis. The two must report a **consistent** governance level
  — the validation checkpoint (§6, step 5) checks they do not diverge.

## 8. Out of scope

- Parts A–C of the ALCI are unchanged (the cognitive level placement,
  deep-dives, and lived-experience items).
- The framework-document per-level Habitat Maturity Snapshot tables and
  the unified Part II matrix are framework-doc presentation, not
  `/assess` output; not reproduced here.
- Portfolio aggregation (`/portfolio-assess`) consuming the Habitat
  Build Gap is a **possible follow-up**, not this change. The assessment
  document's existing single level number stays parseable by the
  portfolio aggregator; the new sections are additive and do not break
  it.

## 9. Versioning

A behavioural change to a command, skill, and agent → **minor bump**
0.39.1 → **0.40.0** (CLAUDE.md Semantic Versioning: "0.MINOR.0 — new
skills, agents, commands, or behavioural changes"). Update the four
locations: `plugin.json`, README badge, CHANGELOG, marketplace entry
`version`. The top-level marketplace listing `version` is unaffected by
a plugin behavioural change (per the listing-vs-entry precedent).

## 10. Acceptance scenarios (structural, offline)

1. **Template has the new sections** — `assessment-template.md` contains
   `## Operational Axes (ALCI Part D)` and `## Habitat Build Gap`.
2. **Template Operational Axes table** names all four axes (Composition,
   Testing, Observability, Governance) with a placement and an evidence
   column.
3. **Habitat Build Gap formula** is documented as
   `level_placement − operational_axes_mean` with the three named
   interpretation regimes (Coherent / Ambition outpaces enablement /
   Inherited habitat).
4. **SKILL.md documents Part D** — the four axes, evidence-first
   placement, the opt-in survey, and the gap computation.
5. **New reference file** `references/operational-axes.md` exists and
   names the four axes with L1–L5 markers.
6. **Assessor agent** documents gathering per-axis evidence, emitting the
   two new sections, and computing the gap; and cross-references the
   Governance Dimension ↔ Governance axis.
7. **Command** documents the new document sections and a validation
   checkpoint covering them (gap = level − mean; interpretation matches
   regime; governance axis and Dimension consistent).
8. **Hybrid opt-in** — the command/skill documents both the evidence-first
   default and the opt-in 40-statement survey.
9. **Version triplet at 0.40.0** — plugin.json, marketplace entry, and
   CHANGELOG heading all show 0.40.0; the top-level marketplace listing
   `version` is unchanged.
10. **Docs** — `run-an-assessment.md` documents the operational axes and
    the Habitat Build Gap.

(Behavioural acceptance — that a live `/assess` run actually places the
axes from evidence and computes a correct gap — is documentation-only at
the structural layer, consistent with how the plugin's other commands
are tested offline.)

## 11. Upstream linkage

This change tracks the framework. The PR body links the upstream
commits (`f13d388`, `542f325`). If the framework's Part D markers or the
Habitat Build Gap regimes change upstream, `references/operational-axes.md`
and the SKILL's regime table are the sync points.
