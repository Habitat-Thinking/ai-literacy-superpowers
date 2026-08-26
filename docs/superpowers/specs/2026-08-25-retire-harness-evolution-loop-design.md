# Retire the harness evolution loop — design

**Status:** Approved
**Date:** 2026-08-25
**Issue:** #606 (superseded), #602 (superseded)
**Provenance:** The loop shipped across `docs/superpowers/harness-evolution-build-spec.md`
and the S0–S5 specs. This spec retires it and restores the reflection channel as
the single path into `HARNESS.md`.
**Scope:** the Assayer, the Registrar, the Harness Decision Record mechanism and
every command, script, test and doc page that serves them.
**Out of scope:** `/reflect`, `/harness-sync`, `/convention-sync`,
`/harness-audit`, `/harness-gc`, `/harness-constrain`, the nine non-loop
sentinels, and the `Sentinel integrity` constraint — all unchanged.

## 1. Why

The loop was built to govern how `HARNESS.md` changes: an Assayer reads evidence
and proposes, a human writes the cost, a Registrar applies, and `/harness-check`
fails the build when what is written down and what is in force disagree.

In practice it produced ceremony without proportionate return.

- **Four assays, ten findings, one accepted rule reaching a live artefact.**
  Two further accepted records target `.github/workflows/gc.yml`, where the
  change was already applied by hand.
- **The one `harness-loop` record ever proposed was rejected.** The
  classification that governs `HARNESS.md` itself has never been exercised.
- **The mechanism's own gates kept catching the mechanism.** The most recent
  assay finding was adjudicated and retired on the ground that its stated harm
  was false: `git log -S "### Template currency" -- HARNESS.md` already answers
  the question the finding said only a decision record could
  (`harness/assay/2026-08-25T23-46Z-assay.errata.md`).
- **The cost of a change compounded.** A single retirement consumed a spec at
  five revisions, three adversarial reviews, a choice-story pass, twelve
  objection dispositions, eight story dispositions, an assay, a second
  adversarial review, twelve more dispositions and an errata — to remove one
  version marker.

The simpler workflow it replaced is intact and needs no building.

## 2. Decision — the reflection channel is the way in

```text
work happens
    ↓
/reflect              a fragment records what was noticed
    ↓
a human reads them, with agentic support, and decides what is worth keeping
    ↓
HARNESS.md            the human writes the rule, in the right section
    ↓
/harness-sync         the control surfaces are brought into line
```

`HARNESS.md` is the master. It is human-curated. Nothing compiles into it, and
no mechanism gates a change to it beyond the ordinary PR review every other
change gets.

Git history is the record of what changed and why — the argument that retired
the last assay finding applies to the whole apparatus.

### 2.1 What is given up, stated plainly

- **Evidence thresholds.** No mechanism requires two assays before a rule enters.
- **A human-authored cost per rule.** No mechanism prompts for one.
- **Expiry.** No rule lapses automatically; `HARNESS.md` accretes unless someone
  prunes it.
- **`/harness-check`'s drift and frozen-record checks** for governance records,
  which no longer exist.

These were real properties. They are given up because the machinery that
provided them cost more than they returned, and because the reflection channel
plus PR review covers the same ground at a fraction of the ceremony. If
`HARNESS.md` accretes rules nobody can justify, that is the failure this
predicts, and the remedy is the quarterly `/governance-audit` that already
exists.

### 2.2 One rule in force is dropped

`HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one`
is compiled into `skills/advocatus-diaboli/SKILL.md` and is the only loop rule
reaching a live artefact. It is **dropped with the mechanism**, not migrated.

It entered through a process being retired. If the behaviour it names matters, it
will resurface through a reflection, which is the channel this spec restores.

## 3. What is removed

**Commands (8):** `harness-assay`, `harness-propose`, `harness-accept`,
`harness-check`, `harness-compile`, `harness-review`, `harness-timeline`,
`harness-board`.

**Agents (2):** `harness-assayer`, `harness-registrar`.

**Skill (1):** `harness-assay/`.

**Scripts (3):** `harness-registrar.py`, `check-harness-decisions.py`,
`harness-board.py`.

**Corpus:** `harness/` in full — `assay/`, `decisions/`,
`enforcement-report.md`, `surfaces.yaml`. Git history holds it.

**`HARNESS.md` constraints (2):** *Harness decision records are well-formed*,
*Harness governance is applied and undrifted*. Both name validators being
deleted.

**CI:** the two corresponding steps in `.github/workflows/harness.yml`.

**Generated region:** the compiled block in `skills/advocatus-diaboli/SKILL.md`,
per §2.2.

**Tests:** 13 Layer 0 test scripts, 11 TDAD scenarios, the `assay_seed`
fixtures, and the corresponding entries in `test_layer0_deterministic.py`.

**Docs:** nine pages deleted, five edited — enumerated by search at
implementation time, not by hand.

## 4. What survives, and why it is enough

| Surviving | Role |
| --- | --- |
| `/reflect` | Captures what was noticed, routed by signal type |
| `reflections/` | The corpus a human curates from |
| `AGENTS.md` | Turn-level learning, human-curated, unchanged |
| `HARNESS.md` | The master, human-curated |
| `/harness-sync`, `/convention-sync` | Reflect `HARNESS.md` into the control surfaces |
| `/harness-audit`, `/harness-gc` | Verify the harness matches reality |
| `/harness-constrain` | Author a constraint |
| `Sentinel integrity` + 9 sentinels | Unaffected — only 2 of 11 sentinels are loop agents |

`/reflect`'s signal routing already names `HARNESS.md` for `context` signals and
`/harness-constrain` for `failure` signals, so the path this spec restores is the
one the command already describes.

## 5. Acceptance criteria

1. None of the eight commands, two agents, one skill or three scripts exists.
2. `harness/` does not exist.
3. `HARNESS.md` declares neither removed constraint, and the three generated
   control surfaces carry neither.
4. `.github/workflows/harness.yml` contains no step invoking a deleted script.
5. `skills/advocatus-diaboli/SKILL.md` carries no generated region.
6. No Layer 0 test or TDAD scenario references a deleted component, and the full
   suite passes.
7. **Residue assertion.** A case-insensitive search across tracked files for
   `harness-assay`, `harness-propose`, `harness-accept`, `harness-check`,
   `harness-compile`, `harness-review`, `harness-timeline`, `harness-board`,
   `harness-registrar`, `check-harness-decisions`, `Harness Decision Record`,
   `harness/decisions`, `harness/assay`, `surfaces.yaml`, `enforcement-report`
   returns matches only in `CHANGELOG.md`, `REFLECTION_LOG.md`, `reflections/`,
   `assessments/`, `docs/superpowers/`, and `observability/snapshots/`.

Criteria 1–5 and 7 are deterministic. Criterion 6 is the existing suite.

Criterion 7 exists because hand enumeration of a removal surface failed three
times in the preceding phase. The search returned **74 tracked files** at
`9995863`; the §3 list is a reader's aid and the assertion is the guarantee.

## 6. Rejected alternatives

**Keep the loop and simplify it.** The last two sessions were attempts to do
exactly that — first repairing a nudge across five spec revisions, then
repairing the loop's own placement model. Both produced criticals. The loop's
cost is structural, not a matter of tuning.

**Keep the corpus as a historical archive.** Rejected on the argument that
retired the last assay finding: git history holds when, who and why, in more
detail than the records carry, and `git log` is one command.

**Migrate the four-mechanisms rule into `HARNESS.md`.** Considered and declined
(§2.2). Migrating one rule out of a retired mechanism preserves the rule and
loses the evidence chain that justified it; if the behaviour matters it should
re-enter through the channel being restored, with its own reflection behind it.

## 7. Version

Removes commands, agents and a skill: **minor**, `0.90.0` → `0.91.0`. Command
count 40 → 32.
