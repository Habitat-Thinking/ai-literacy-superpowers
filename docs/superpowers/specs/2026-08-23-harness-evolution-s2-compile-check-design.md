# Spec: Harness Evolution S2 — apply, compile and check

**Status:** Approved
**Date:** 2026-08-23
**Issue:** #536
**Epic:** Harness Evolution — the Harness Assayer and the Harness Registrar (#533)
**Depends on:** S0 (0.74.0) the schema and validator; S1 (0.75.0) the Registrar
and its write path.
**Scope:** `ai-literacy-superpowers` plugin — two commands, two script
subcommands, two schema additions, one generated report, one CI gate.
**Explicitly out of scope:** `/harness-review`, expiry lapse detection,
supersession, `/harness-timeline`, and the Assayer. S3–S5.

**Provenance:** the Harness Assayer / Harness Registrar build spec, supplied in
conversation 2026-08-23. Epic-level decisions recorded on #533.

---

## 1. Problem Statement

An accepted HDR currently changes nothing. It is a well-formed record of a
decision that has not been carried out.

This phase carries it out: the rule text reaches the artifact that owns it, every
surface gets a truthful account of how strongly the rule binds there, and a
deterministic check turns any divergence into a build failure.

## 2. The build spec's compilation model does not survive contact with this repo

The build spec says compilation "regenerates the marked regions of every control
surface", where a surface is `claude-code`, `copilot-cli`, `codex` and so on,
each with a list of `targets`.

Applied literally here, that puts **two generators on one file**.
`.github/copilot-instructions.md`, `.cursor/rules/constraints.mdc` and
`.windsurf/rules/constraints.md` are already generated — by `/convention-sync`,
from `HARNESS.md`, and enforced by the `Convention parity` constraint and
`check-convention-parity.py`. A second generator writing its own region into
those files would produce the same rule twice, in two voices, with two
mechanisms each believing it owned the outcome.

It is also ambiguous in a way the schema cannot resolve. A `claude-code` surface
whose `targets` are `[CLAUDE.md, .claude/agents/, .claude/hooks/]` does not say
which of the three an `agent-instruction` rule belongs in, and `.claude/agents/`
is a directory.

### 2.1 The reinterpretation: classification routes, surfaces report

- **`classification` decides where the rule text goes.** One accepted HDR writes
  to exactly one target artifact.
- **`surfaces` decides who is told about it, and the enforcement report is what
  it is told.**

This keeps every property the build spec was actually after — verbatim
application inside markers, an idempotent repair command, and a gap report as a
primary output — while removing the duplicate-generator collision and the
directory ambiguity.

It also makes the gap report sharper rather than weaker. Under the literal
reading, a rule compiled into five files looks like it reaches five surfaces.
Under this one, an `agent-instruction` rule reaching Copilot only if somebody
mirrors it is reported as exactly that.

## 3. Routing

`harness/surfaces.yaml` gains a top-level `routes` mapping:

```yaml
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md
```

Classifications not in `routes` — `agent-instruction`, `agent-reference`,
`script-validator`, `regression-test`, `new-agent` — write to the artifact named
by the HDR's own `target:` field, because no fixed rule can know which agent file
a given agent instruction belongs in.

`no-change` routes nowhere and is never compiled.

### 3.1 The `target` field

`target: <repo-relative path>` on the HDR. Required at **acceptance** for any
classification with no route and no `no-change` exemption; optional before then.

Requiring it at acceptance rather than at proposal is deliberate. An assay
finding may know the target — the contract carries an optional `target` in its
metadata and `/harness-propose` copies it — but frequently the Assayer has
identified a behaviour without deciding which of four agent files should own it.
That decision belongs to the human at the gate, next to the cost.

## 4. Compilation

`/harness-compile` regenerates, from `HARNESS.md`, `AGENTS.md` and the accepted
HDRs:

1. the generated region of every **target artifact** named by an accepted HDR,
2. `harness/decisions/index.md`,
3. `harness/enforcement-report.md`.

It is idempotent: running it twice produces byte-identical output. That property
is what lets `/harness-check` treat *any* difference as drift.

### 4.1 Markers

```markdown
<!-- BEGIN GENERATED: harness-registrar — do not edit by hand -->
<!-- END GENERATED: harness-registrar -->
```

Content outside the markers is never touched. When a target artifact exists but
has no markers, compilation appends the pair at end of file — this is the build
spec's one-time setup, where "nothing should change except the appearance of the
markers".

**Compilation refuses, writing nothing at all, when:**

- a target artifact does not exist — the Registrar creates records, not
  governance documents;
- a marker pair is malformed: an END before a BEGIN, a BEGIN with no END, or more
  than one pair in a file.

A malformed marker pair is the case worth refusing loudest. Guessing which BEGIN
belongs to which END is exactly how a generator eats hand-written content.

### 4.2 What a compiled rule looks like

```markdown
### HDR-2026-08-19-observed-evidence — Require observed evidence

_Intended: validated · claude-code: validated · copilot: advisory (gap) ·
provisional until 2026-11-19_

- **Rule**: A phase may not be reported complete on the strength of a planned
  command. Cite observed output.
```

The rule body is the four-backtick block from the HDR, byte for byte.

The enforcement line is deliberately rendered **at the point of reading**, not
only in the report. A rule that says `blocked` but is merely advisory on the
surface someone is reading should admit that where they are reading it.

Rules are ordered by HDR id, so the region is a pure function of the corpus.

## 5. The enforcement report

`harness/enforcement-report.md` states, for every accepted rule on every surface
it names, the enforcement level **intended** and the level **achieved**.

> The gap report is a primary output, not a diagnostic. Knowing which rules are
> actually enforced and which are merely written down is the point.

### 5.1 How `achieved` is derived

The ladder is `advisory` < `validated` < `blocked`.

1. If `intended` is in the surface's `supports`, the candidate is `intended`.
2. Otherwise the candidate is the highest supported level strictly below
   `intended`, or `none` when the surface supports nothing lower.
3. **The validator gate.** If the candidate is `validated` or `blocked` and the
   HDR declares no `validator` that resolves to a file that exists, the candidate
   degrades — to `advisory` where the surface supports it, otherwise to `none` —
   with the reason recorded.

Step 3 is the one that earns the report its keep. Without it, a rule declaring
`enforcement: blocked` and naming the `ci` surface reports as blocked while
nothing anywhere refuses anything. That is worse than no report: it is a
confident, legible, wrong answer, and it would be produced by the mechanism whose
entire purpose is distinguishing enforced from written down.

### 5.2 `validator`

`validator:` on the HDR — a path, or a list of paths, to the script, workflow, or
hook that actually enforces the rule. Optional; its absence is not an error, it
is a gap.

## 6. `/harness-check`

Read-only. Non-zero exit on any of:

| Check | Fails when |
| --- | --- |
| **Region drift** | A target artifact's generated region differs from what compilation would produce |
| **Unapplied** | An accepted HDR's target artifact has no generated region at all |
| **Report drift** | `enforcement-report.md` or `index.md` differ from a fresh compile |
| **Malformed markers** | Any target artifact has an unmatched or duplicated marker pair |
| **Frozen record** | An accepted HDR differs from its content at the commit that accepted it |
| **Corpus invalid** | `check-harness-decisions.py` fails |

`/harness-check` failing is a **build failure, not a warning**. It runs in
`.github/workflows/harness.yml` beside the other deterministic constraints.

### 6.1 The frozen-record check, and why byte-identity alone is not enough

Region drift catches a hand-edit to a compiled rule, because the region no longer
matches what the corpus would produce.

It does not catch the failure this epic was designed around. An agent with
`Write` could reword the rule **in the accepted HDR** and recompile: the region
would then match the corpus exactly, every byte-identity check would pass, and
the rule in force would quietly differ from the one the human approved.

So accepted HDRs are checked against git. For each, the check walks the file's
history, finds the first revision where `status: accepted`, and compares the
current content to that revision.

**Known limit, stated rather than papered over.** An accepted HDR that has never
been committed cannot be checked this way, so it is skipped with a note. That
window is closed by human review of the diff, which is the third gate and the one
this mechanism never tries to replace.

## 7. Acceptance folds application in

`/harness-accept` becomes: refuse-first, prompt for cost, then **one transaction**
that accepts, applies, and recompiles. If any step fails, nothing is written and
the HDR stays `proposed` — the S1 staging mechanism extended to cover the target
artifacts as well as the corpus.

### 7.1 Two gates, not four

Applying and compiling are deliberately **not** separate approval gates. Once an
HDR is accepted there is no decision left in either step, and a gate with no
decision behind it is the exact shape of approval theatre.

The two that remain are the two where a human is genuinely deciding something:
writing the cost, and reviewing the resulting diff.

## 8. Acceptance criteria

| ID | Criterion |
| --- | --- |
| C1 | `compile` creates a marker pair in a target artifact that lacks one, changing nothing else |
| C2 | Hand-written content outside the markers survives compilation byte for byte |
| C3 | The compiled rule body is byte-identical to the HDR's four-backtick block |
| C4 | `compile` is idempotent — a second run is byte-identical |
| C5 | `compile` refuses, writing nothing, when a target artifact does not exist |
| C6 | `compile` refuses, writing nothing, on a malformed marker pair (END before BEGIN, BEGIN with no END, two pairs) |
| C7 | Hand-editing a generated region fails `check` and is repaired by `compile` |
| C8 | Rewording a rule body inside the region fails `check` |
| C9 | An accepted HDR whose target has no region fails `check` as unapplied |
| C10 | `enforcement-report.md` reports intended vs achieved per surface, and marks a gap where they differ |
| C11 | A surface supporting only `advisory` degrades a `blocked` intent, reported as a gap, never silently |
| C12 | An `enforcement: blocked` HDR with no resolvable `validator` is reported as degraded, with the reason |
| C13 | A resolvable `validator` lifts the degradation |
| C14 | Editing an accepted HDR after its accepting commit fails the frozen-record check |
| C15 | An accepted HDR never committed is skipped by the frozen-record check with a note, not a failure |
| C16 | `accept` applies and compiles in one transaction; a failure at any step leaves the corpus and every target artifact byte-identical |
| C17 | `accept` refuses an HDR whose classification has no route and no `target` |
| C18 | A `no-change` HDR compiles nowhere and is absent from every region |
| C19 | `check` exits non-zero on report or index drift |

Tests live at `tdad_tests/layer0_deterministic/test-harness-compile.sh`.

## 9. Rejected alternatives

**Compiling into every surface's instruction files, as written.** Rejected per §2
— it collides with `/convention-sync` on three files in this repository and is
ambiguous where a surface lists a directory among its targets.

**Inserting rule text at a located position in the target document.** Rejected:
it requires the agent to choose an insertion point, which is judgement in the one
place the epic works hardest to remove it, and it makes idempotence a matter of
luck. Regenerating a whole region from the corpus is deterministic by
construction.

**Treating the enforcement gap as a check failure.** Rejected again, for the S0
reason: authors would declare the weakest enforcement any surface supports, and
the report would go quiet exactly when it had something to say.

**Trusting byte-identity alone.** Rejected per §6.1 — it is precisely the check
that a co-ordinated edit to the HDR and the region would pass.

**Deriving `achieved` from `supports` alone, without the validator gate.**
Rejected per §5.1. A report that says `blocked` when nothing refuses anything is
a confident wrong answer produced by the mechanism built to prevent them.
