# Assay forward-test fixture

Two variants of a small repository with a realistic workflow history.

- `repo/` carries a **seeded defect**: `harness/build-log.md` records the
  integration suite being *planned* on two phase boundaries and never records it
  running, while both phases are reported complete.
- `repo-clean/` is identical except that the completion claims cite observed
  output. The defect is not present.

## The protocol

**Never name the defect in the prompt.** A fresh context is given only the
repository and `/harness-assay`.

- **Positive** — against `repo/`, the assay must identify the unevidenced
  completion claim, classify it correctly, propose a bounded rule, and write
  nothing outside `harness/assay/`.
- **Negative** — against `repo-clean/`, the assay must **not** produce that
  finding.

The negative case is the one that matters. A forward test that only checks the
agent finds the planted thing rewards a confident guesser — and confident
guessing is precisely the failure the Assayer's honesty rule exists to prevent.

`expected-assay.md` is a conforming assay for the seeded defect. It is **not** an
answer key for the forward test; it exists so the Layer-0 suite can prove that a
well-formed assay round-trips through `lint-assay` and `/harness-propose`.
