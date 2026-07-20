# The decision-discipline triad

Three agents in the plugin form a single discipline for AI-augmented
decision streams. Each operates at a different layer; together they
regulate cadence, surface quality, and surface visibility.

## The three agents

### `carpaccio` — cadence governor

Acts at orchestrator step 0, before any spec exists. Reads the raw
task description, slices it into thin end-to-end-complete pieces,
and hard-gates the pipeline until the human dispositions each
slice. The discipline: **the human engages with one decision at a
time**, not the whole proposal at once.

### `advocatus-diaboli` — quality challenger

Acts on a completed artefact (spec or implementation). Raises the
strongest honest objections in six categories (premise, design,
threat, failure, operational, cost). Each objection ships with
`disposition: pending` for the human to fill. The discipline:
**every coherent proposal must defend itself against its
strongest opposition**.

### `choice-cartographer` — decision archaeologist

Acts on a completed spec, after diaboli dispositions are resolved.
Surfaces material decisions the spec implies — including the ones
the author did not notice they were making. Each story ships with
`disposition: pending` for the human to fill. The discipline:
**decisions made silently must be made visible**.

## Why three, not one

A single agent doing all three jobs would conflate three different
modes of cognitive engagement:

- **Carpaccio** asks *should we engage now, or break this into
  smaller engagements?*
- **Diaboli** asks *given we are engaging, what are the strongest
  objections to the proposal?*
- **Cartographer** asks *given the proposal stands, what decisions
  did it implicitly make?*

Each question demands a different stance from the human. Bundling
them produces decision fatigue and softens each individual
discipline. The three-agent split preserves the sharpness of each
question.

## The shared trust-boundary pattern

All three agents share a read-only tool boundary: `Read`, `Glob`,
`Grep`. None can write files. The orchestrator (or the
corresponding slash command) writes the artefact using content
the agent returns. Humans fill `disposition` fields inline; agents
cannot.

This is not a limitation — it is the mechanism. An agent that
could fill its own disposition fields would eliminate the
human-cognition gate that gives the artefact its value. The tool
boundary *is* the discipline.

## When each runs

```
Raw task description
  ↓
[carpaccio]    Step 0 — slice into pieces
  ↓ (per progressed slice)
[spec-writer]  Step 1 — write the spec
  ↓
[diaboli]      Step 1a — raise objections (spec mode)
  ↓
[cartographer] Step 1b — surface decisions
  ↓
[tdd-agent]    Step 2 — failing tests
  ↓
implementers   Step 3 — make tests green
  ↓
[code-reviewer] Step 4 — review
  ↓
[diaboli]      Step 4a — raise objections (code mode)
  ↓
[integration]  Step 5 — merge
```

## See also

- [Sentinels](sentinels.md) — the wider category the triad belongs to:
  agents whose object of care is the human's understanding and judgement.
- `/carpaccio` — manual invocation
- `/diaboli` — manual invocation
- `/choice-cartograph` — manual invocation
- Spec: `docs/superpowers/specs/2026-05-26-carpaccio-cadence-governor-design.md`
- Spec: `docs/superpowers/specs/2026-04-19-advocatus-diaboli-design.md`
- Spec: `docs/superpowers/specs/2026-04-27-choice-cartographer.md`
