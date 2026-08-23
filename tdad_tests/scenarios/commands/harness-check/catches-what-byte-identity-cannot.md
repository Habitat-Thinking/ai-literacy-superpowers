---
component: harness-check
component_type: command
tier: structural
---

# Scenario: /harness-check catches what byte-identity cannot

## Given

The whole epic exists because an agent that both diagnoses failures and writes
the rules can rationalise its own findings. The Registrar holds `Write` over
governance artifacts, so the compensating controls have to be mechanical.

Region drift is one of them, and it is not sufficient. An agent could reword the
rule **in the accepted record** and recompile: the region would then match the
corpus exactly, every byte-identity check would pass, and the rule in force would
quietly differ from the one a human approved. Only history can see that.

There is also a window the mechanism cannot close — a record accepted but never
committed has no accepted revision to compare against — and the honest move is to
name it rather than let a skip read as a pass.

## When

`ai-literacy-superpowers/commands/harness-check.md` is read from the filesystem.

## Then

**Frontmatter:** `name: harness-check`, a description stating it is read-only,
exits non-zero on divergence, and is a CI entry point rather than something
anyone types.

**Body:**

- Tabulates all six checks: corpus validity, malformed markers, never applied,
  region drift, report drift, frozen record.
- States that a failure is a **build failure, not a warning**, and why — a
  governance check that can be ignored is one that will be.
- Explains the frozen-record check by contrast with region drift, naming the
  co-ordinated edit that byte-identity would pass.
- States the known limit — an uncommitted accepted record is skipped with a note
  — and **forbids presenting that note as a pass**.
- Distinguishes drift whose cause is the generated region (compile repairs it)
  from drift whose cause is the corpus, where "the question is whether that
  change was approved, and the answer is not a command".
- Treats a frozen-record violation as serious: show the human the diff, never
  recompile to make it agree, and let them choose restore or supersede.

**Boundaries:** writes nothing, repairs nothing, and never passes because a
problem looked cosmetic.
