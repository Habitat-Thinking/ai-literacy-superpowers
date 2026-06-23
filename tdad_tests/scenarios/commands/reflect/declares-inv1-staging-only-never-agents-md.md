---
component: reflect
component_type: command
tier: structural
---

# Scenario: the --mine section declares the INV-1 staging-only / never-AGENTS.md boundary and the human-promotes gate (AC-5 / FR-3, deterministic shadow of AC-2)

## Given

The mining-mode section of
`ai-literacy-superpowers/commands/reflect.md`.

## When

The `--mine` section is read.

## Then

- The section states the shortlist is written **only** to
  **`REFLECTION_STAGING.md`** and **never** to **`AGENTS.md`** (nor
  `HARNESS.md`/`CLAUDE.md`/`MODEL_ROUTING.md`). The tokens
  `REFLECTION_STAGING.md` and `AGENTS.md` are single unwrappable tokens
  (matched case-insensitively); the content test asserts the staging token,
  the `agents.md` token, "only", and "never" all co-occur on the lowercased
  section.
- The section states `AGENTS.md` stays **byte-for-byte unchanged** by mining
  until a human promotes. Keep the phrase "byte-for-byte" **unwrapped**; the
  content test asserts "byte-for-byte" (or "byte for byte") co-occurring with
  "unchanged".
- The section states the **human-curation** gate is preserved: a human still
  **promotes** from staging through the existing `Promoted:` flow — mining
  proposes, the human curates. Keep "human" and "promotes"/"Promoted" each
  **unwrapped**; the content test asserts "human" co-occurring with
  "promote"/"promoted" and "propose"/"proposes".

## Rubric

Deterministic structural shadow of AC-5 / FR-3 (and the deterministic shadow
of AC-2's AGENTS.md-immutability guarantee). This repo's deterministic layer
reads files; it does **not** run `/reflect --mine` and diff `AGENTS.md`. So
"byte-for-byte unchanged" is asserted here as a **declaration** — the doc
*states* mining writes only to staging and never to AGENTS.md, and that
promotion is a human act. The *live* byte-identity (running `--mine` leaves
AGENTS.md's bytes identical) is the agent-backed half of AC-1 and is **not**
over-promised as deterministic here.

The load-bearing specifics (INV-1, the critical boundary for this slice):

- mining writes **only** the staging file and **never** any of the four
  durable curated artefacts — the doc must not read as if mining may write
  AGENTS.md under any condition;
- promotion is and stays a **human** curator act through the **existing**
  `Promoted:` flow — mining proposes a better-vetted shortlist; it does not
  bypass, auto-promote, or replace the gate.

## Evaluation

Evaluated deterministically by
`tests/test_s6_reflection_mining_structural.py`
(`TestS6ReflectInv1Boundary`). RED now because the mining-mode section does
not exist, so the staging-only / never-AGENTS.md / byte-for-byte /
human-promotes phrases are absent.
