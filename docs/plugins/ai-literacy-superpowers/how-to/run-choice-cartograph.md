---
title: Run the Choice Cartographer
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 39
redirect_from:
  - /how-to/run-choice-cartograph/
  - /how-to/run-choice-cartograph.html
---

# Run the Choice Cartographer

Run `/choice-cartograph` to map the implicit decisions a spec has made — the
defaults inherited, the alternatives unspoken, the patterns unnamed, the
consequences accepted — and emit each one as a *choice story* for human
disposition.

## When to use this

- After `/diaboli` (spec mode) dispositions are resolved and before you
  approve the plan. The Choice Cartographer reads both the spec and the
  adjudicated objection record; it depends on the diaboli's dispositions
  being settled to apply its routing rule cleanly.
- When a spec is substantially edited after a choice-story record already
  exists (the command regenerates the record; prior dispositions are lost
   — this is intentional, mirroring the diaboli pattern).
- When working outside the full orchestrator pipeline and you want
  decision archaeology on demand.

The Cartographer is not adversarial review. It does not raise objections.
If you want the strongest objections to a spec, run `/diaboli`. If you
want the silent decisions surfaced as a navigable map, run
`/choice-cartograph`. The two roles are partitioned by the **Routing
Rule** (see step 3).

This release is spec-mode only. Code-mode behaviour is tracked under
[issue #209](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/209).

---

## 1. Run `/choice-cartograph <spec-path>`

Pass the path to the spec file. Single positional argument — there is
no `--mode` flag yet.

```text
/choice-cartograph docs/superpowers/specs/2026-04-27-my-feature.md
```

The slug is derived from the spec filename by stripping the date prefix
and `.md` extension. For example, `2026-04-27-my-feature.md` →
`my-feature`.

Output path: `docs/superpowers/stories/my-feature.md`

---

## 2. Read the choice-story record

The record has two parts:

**YAML frontmatter** — a machine-readable list of stories, each with:

- `id` — Story #1, #2, … in order of leverage
- `lens` — one or more of: `forces`, `alternatives`, `defaults`,
  `patterns`, `consequences`, `coherence`
- `title` — a short evocative phrase (4–8 words) naming the choice
- `disposition` — starts as `pending`; you fill this in
- `disposition_rationale` — starts as `null`; you write this

**Prose body** — one `## Story #N` section per entry with:

- **Context** — 2–4 sentences situating the choice
- **Forces** — tensions the spec resolved
- **Options not taken** — 2–3 realistic alternatives
- **Choice as written** — what the spec actually chose (including
  silent choices)
- **Consequences** — what the choice forecloses
- **Pattern** — named pattern with citation, or `—`
- **Notes** — optional, for the curator

Read the prose, not just the frontmatter. The narrative is where the
choice's texture lives.

---

## 3. Apply the Routing Rule when reading

If a story reads more like an objection ("this will fail because…")
than a choice ("this chose X over Y"), the agent broke the routing
rule. The deterministic test is:

> A choice story belongs in the Cartographer's record iff: removing it
> would leave a decision unrecorded but no failure undetected.
>
> An objection belongs in the diaboli's record iff: removing it would
> leave a class of failures undetected.

Stories that fail the test by leaning toward failure are routing
errors — flag them when you adjudicate. The agent is calibrated by
your dispositions over time.

---

## 4. Write dispositions inline

Open the choice-story record and fill in `disposition` and
`disposition_rationale` for each story in the YAML frontmatter.

Valid `disposition` values (pick one — no compounds):

- `accepted` — the choice is intentional; the story is sufficient
  documentation. The most common disposition for sound specs.
- `revisit` — **deferred**. The choice is captured-but-to-be-revisited
  later. Use this when the team has acknowledged the decision but
  isn't ready to finalise it. The rationale field captures *why* the
  revisit is deferred. This is a passing disposition at the
  merge-time HARNESS gate — `revisit` means "considered and noted",
  not "spec needs to change before merge". A common use is "we'll
  re-evaluate when we have more data after running with this for a
  cycle."
- `promoted` — the choice is durable enough to carry forward as an
  AGENTS.md ARCH_DECISION or a HARNESS.md constraint. The promotion
  mechanism is tracked at
  [issue #211](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/211).
  For now, ticking `promoted` records intent without producing routing.

If a story surfaces a choice you genuinely want to change in the spec
*before* merging, edit the spec directly (or re-run `/spec-writer`)
and re-run `/choice-cartograph` afterwards — the old story record
will be overwritten with a fresh map. This is the "the agent surfaced
something I want to change" path; it is not a disposition value.

**This step cannot be delegated back to an agent.** The Cartographer's
trust boundary is read-only — it cannot write dispositions. This is
structural: a human must engage with the choices and write a rationale
before the pipeline proceeds. That engagement is the mechanism. If you
find yourself wanting to have an agent fill in the dispositions, the
gate is not working.

The plan-approval gate is **soft** — it surfaces a
`cartograph_pending_count` field and allows you to proceed even with
unresolved stories. The merge-time HARNESS constraint **PRs have
adjudicated choice stories** is the forcing function. Resolving
dispositions at plan-approval time is cheaper for compound learning
because the spec context is fresh.

---

## 5. Update the spec if you want to change a captured choice

If a story surfaces a choice you genuinely want to revise *before*
merging, edit the spec (directly or via `/spec-writer`) and re-run
`/choice-cartograph` afterwards. The old story record is overwritten
with a fresh map; old dispositions are not preserved. This is
intentional — a substantially revised spec deserves a fresh map.

`revisit` dispositions do not require a spec edit. They are deferred
considerations the team has acknowledged but isn't acting on now;
the rationale field carries the thinking. Treat `accepted`,
`revisit`, and `promoted` as three legitimate landing states — none
of them block merge.

---

## 6. What you have now

An adjudicated choice-story record with all dispositions filled and
all rationales written.

- The plan-approval gate surfaces `cartograph_pending_count` but
  allows progression.
- The merge-time HARNESS constraint blocks PR merge while any story
  is `pending`.
- The record lives at `docs/superpowers/stories/<slug>.md`,
  symmetric with `docs/superpowers/objections/<slug>.md`.

As records accumulate, disposition and lens patterns become visible
in `/superpowers-status` Section 8 and the harness-health snapshot
Cartographer panel. Cross-record patterns (frequent `revisit`
dispositions on the `defaults` lens, for example) carry interpretive
signal about which kinds of decisions tend to need spec edits.

---

## Next steps

- Once all dispositions are filled, return to the orchestrator
  pipeline and present the plan for approval; proceed to tdd-agent
  only after plan approval
- See [Decision Archaeology](decision-archaeology.md)
  for the conceptual background on intent debt, cognitive debt, and
  why the Cartographer is paired with the diaboli rather than
  replacing it
