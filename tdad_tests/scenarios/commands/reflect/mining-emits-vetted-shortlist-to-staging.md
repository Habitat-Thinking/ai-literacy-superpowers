---
component: reflect
component_type: command
tier: behavioural
fixture: reflection-corpus-with-recurring-theme
---

# Scenario: a live --mine run emits a clustered, adversarially-filtered shortlist to the staging artefact and writes nothing to AGENTS.md (AC-1, agent-backed)

## Given

An append-only reflection corpus (the `reflections/active/` fragments
aggregated in `REFLECTION_LOG.md`) containing a recurring theme, and the
**Claude Code runtime present**.

## When

`/reflect --mine` runs.

## Then

- It emits a **clustered, adversarially-filtered shortlist** of promotion
  candidates to the staging artefact **`REFLECTION_STAGING.md`** — each
  candidate carrying its proposed rule, its source fragment(s), and the
  "would this have prevented a real mistake?" verdict + evidence.
- It writes **nothing to `AGENTS.md`** — AGENTS.md is byte-for-byte
  unchanged (INV-1).

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in the
spec (§6 decision 3). Live clustering/filtering of a real corpus and the
actual workflow dispatch require the Claude Code workflow runtime; they
cannot run on a tree without it (where `--mine` degrades to guidance only).

The structural shadows of this scenario are the deterministic AC-4
(`declares-cluster-filter-shortlist-shape-adapts-template.md` — the
cluster→filter→shortlist shape is declared), AC-5
(`declares-inv1-staging-only-never-agents-md.md` — the staging-only /
never-AGENTS.md boundary is declared), and AC-6
(`declares-staging-candidate-shape-and-lifecycle.md` — the candidate shape is
declared). The *live* byte-identity (running `--mine` leaves AGENTS.md's
bytes identical) is asserted here, not in any deterministic check.

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a Layer-2/3
agent-backed scenario standing as the runtime promise the structural shadows
declare. It must **not** be promised as CI-checkable.
