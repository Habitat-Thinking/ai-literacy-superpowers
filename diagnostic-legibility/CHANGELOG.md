# Changelog

## 0.5.0 — 2026-06-01

### On-demand `/diagnose` command (S4)

Ships the human-facing `/diagnose` command — the surfacing interface
that exercises the full S2 + S3 pipeline end-to-end and renders the
mutually-corrected models as a readable report. This is the **last
slice** of the diagnostic-legibility plugin's carpaccio decomposition;
parent issue #327 closes with it.

- **Command** (`commands/diagnose.md`): `/diagnose <scope> [--out <dir>]`
  — a single verb. Forwards `<scope>` to the agent verbatim, dispatches
  in `mode: full`, renders the returned `LegibilityModel` as markdown,
  and writes the report after a human accept/abort gate.
- **Report geometry**: a compact two-column cross-check **summary table**
  (Architectural | Domain — the at-a-glance side-by-side) plus two
  **stacked** `### Architectural model` / `### Domain model` bodies, each
  element grouping its `Q<N>` (self-challenge) then `CC<N>` (cross-check)
  notes in canonical order. The wrapper `cross_check_status`
  (`completed | skipped_asymmetric | not_run`) is surfaced in the header
  and summary. Correction counts are "elements revised" — elements
  carrying ≥1 `CC<N>` entry per direction, not raw entry counts.
- **Confirm-before-write gate**: the command prints a summary naming the
  resolved target path (flagging an overwrite), then writes only on
  human **accept**; an **abort** writes nothing and creates no
  directory. The accept gate — not the validation checkpoint — is the
  last line of defence before write.
- **Output**: reports default to `diagnostic-legibility/output/`
  (gitignored — derived, regenerable artefacts, never committed or
  rsynced into the plugin cache), filename
  `<scope-slug>-legibility-<YYYY-MM-DD>.md`; overridable with `--out`.
- **Refusal contract**: a `diagnostic-legibility refusal:` line is
  surfaced verbatim and aborts with no file written.
- **Validation checkpoint**: reads the rendered report back and checks
  header completeness, no `<DISPATCHER:` leak, both collections
  rendered, Q/CC ordering, and correction counts consistent with the
  parsed YAML; deviations fixed in place, the agent is not re-dispatched.
- **Docs**: new how-to (`run-the-diagnose-command.md`) and reference
  (`diagnose-command.md` + reference quadrant `index.md`);
  `invoke-the-agent.md` forward-link to #333 resolved to the new how-to.
- **Agent clarification** (rides this bump): the both-empty branch of
  the agent now states it emits `cross_check_status: skipped_asymmetric`
  explicitly (S4 spec-mode diaboli O2 — the empty-scope contract was
  previously undefined for this wrapper field).

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/dl-s4-diagnose-command-design.md`
(11 objections — 10 accepted, 1 deferred); choice-cartographer at
`docs/superpowers/stories/dl-s4-diagnose-command-design.md`
(8 stories: 2 promoted, 5 accepted, 1 revisit).

**Promoted to `AGENTS.md` from the cartographer's dispositions:**

- Story #1 — the gate-ordering invariant (the human disposition must
  *precede* the write; ordering is the invariant, not just the
  agent/command tool split). Sharpens the existing *agent-emit +
  dispatcher-persist + human-disposes* architecture entry.
- Story #8 — the declined-hand-off anti-pattern (a "natural home"
  hand-off in slice N does not bind slice N+1; re-file orphaned concerns
  as standalone issues). The orphaned invocation-persistence corpus for
  the Phase-C escalation trigger is re-filed as
  [#350](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/350).

**Marketplace**: the `diagnostic-legibility` listing entry version bumps
0.4.0 → 0.5.0 and its `description` is rewritten (the now-shipped
`/diagnose` command); the top-level listing `version` stays 0.4.0 (a
per-plugin entry description is the plugin's own contract, not the
listing contract — S1–S3 precedent).

S4 of the parent slicing record at
`docs/superpowers/slices/diagnostic-legibility-plugin.md`. Closes issue
#333 and parent issue #327.

## 0.4.0 — 2026-06-01

### Cross-check mechanism for mutual model correction (S3)

Adds Phase C (cross-check) to the `diagnostic-legibility` agent's
construction protocol. After Phase B (self-challenge) completes,
Phase C uses each refined collection (architectural, domain) to
challenge the other through five cross-check questions with
direction-flavoured weighting (CC1 heavy A→D; CC5 heavy D→A). The
agent emits a `LegibilityModel` whose elements carry both `Q<N>`
(self-challenge) and `CC<N>` (cross-check) entries; the model-level
`cross_check_status` field on the wrapper records the outcome.

- **Agent file**: extended with Phase C, the five cross-check
  questions, the structured refusal contract, and the two mode
  markers (full and cross-check-only).
- **Schema template**: `templates/legibility-element.md` adds an
  additive optional `cross_check_status` field on the
  `LegibilityModel` wrapper with three legal values (`completed`,
  `skipped_asymmetric`, `not_run`). v0.3.0 outputs remain valid;
  field-absence semantically means `not_run`.
- **Named direction-specific failure modes**:
  - A→D direction (CC1 weighted) targets *architectural-implicit
    assumption in domain description*.
  - D→A direction (CC5 weighted) targets *domain-concept smear in
    architectural element*.
  Both are working hypotheses revisable from disposition data.
- **Two mode markers**: `mode: full` (default — Phase A+B+C, the
  superset of v0.3.0) and `mode: cross-check-only` (Phase C only,
  against a fenced YAML payload). The earlier `mode: construct-only`
  was dropped at adjudication — no named consumer.
- **Subject-only audit trail**: `CC<N>` entries are written on the
  subject element only; side-effects on sibling elements are named
  in the subject's prose body rather than appended as duplicate CC
  entries on the side-effect element. One author per CC entry.
- **Structured refusal contract**: unrecognised mode value, missing
  preconditions, unfenced/multiple YAML blocks, or unsubstituted
  `<DISPATCHER: ...>` placeholders in `cross-check-only` mode
  trigger a structured refusal line. No silent fallback.
- **Two-layer ordering enforcement**: the agent self-verifies at
  emit time that `CC<N>` entries follow `Q<N>` entries in every
  element's `challenge_notes[]`, re-ordering in place if needed; a
  fixture-based structural test in `tdad_tests/` complements the
  emit-time check at CI time.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/dl-s3-cross-check-mechanism-design.md`
(10 objections, all accepted); choice-cartographer at
`docs/superpowers/stories/dl-s3-cross-check-mechanism-design.md`
(7 stories: 3 promoted, 4 accepted); code-mode diaboli at
`docs/superpowers/objections/dl-s3-cross-check-mechanism-design-code.md`
(4 objections — 0 critical/high; O1, O2, O4 accepted as
implementer-surface clarifications and absorbed here, O3 deferred to
S4 as the natural first test of the version-bump test pattern).

**Follow-up issues** opened from the cartographer's promoted
dispositions:

- [#347](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/347) —
  Promote: granularity-routing as schema-evolution discipline
  (paired Stories #1 + #4 — per-element facts route through prefix
  discipline on existing fields; model-level facts earn additive
  wrapper fields; single-writer invariant for audit-trail entries).
- [#348](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/348) —
  Promote: dispatcher-first error contracts for agent output
  (Story #6, third occurrence — agents producing structured output
  for programmatic consumers must specify a structured refusal shape
  and must not silently fall back on unrecognised input). Sister to
  the open #339 plugin_version promotion.

S3 of the parent slicing record at
`docs/superpowers/slices/diagnostic-legibility-plugin.md`. Closes
issue #332; parent issue #327 remains open until S4 (#333 — the
`/diagnose` command) also ships.

## 0.3.0 — 2026-05-28

### Two-model agent — challenge protocol and working agent (sub-S2b)

Ships the working `diagnostic-legibility` agent. The agent accepts a
codebase scope, drafts an architectural model and a domain model
against the `LegibilityElement` schema from v0.2.0, then runs a
**retained-challenge single-pass** cycle — five questions per element
in an explicit adversarial Phase B — and emits a `LegibilityModel`
YAML block with `challenge_notes[]` on every element.

- New agent file at `agents/diagnostic-legibility.agent.md` (~245
  lines, Read/Glob/Grep tool boundary, two-phase construction
  protocol with fresh-sub-context self-challenge per spec §3.4).
- Removes the `agents/.gitkeep` placeholder from v0.1.0.
- The five questions: *boundary, evidence, confounders, confidence,
  description integrity*. Each note carries a mandatory
  `Q<N> (question name):` prefix; the `Challenge applied; no
  questions surfaced changes` sentinel is the only exception.
- Empty-scope degenerate case is handled by the `(empty scope)`
  sentinel element name — exactly the literal string, parentheses
  included, so downstream consumers can pattern-match.
- New docs pages at `docs/plugins/diagnostic-legibility/how-to/`
  (invoke-the-agent how-to) and `…/explanation/` (challenge-refine
  protocol concept page).

Cross-check (parent S3, #332) and the human-facing `/diagnose`
command (parent S4, #333) remain out of scope. The how-to documents
bare Task-tool dispatch as the v0.3.0 invocation surface and links
forward to #333 for the command surface.

**Code-mode diaboli adjudication
(`docs/superpowers/objections/dl-s2b-challenge-protocol-design-code.md`):**
9 objections raised (4 high, 4 medium, 1 low); 7 accepted and
addressed in this PR, 2 deferred.

- O1 (high, prefix ambiguity) — Q\<N\> challenge-note prefix unified
  on the canonical `Q<N> (lowercase-name):` form; deprecated
  no-parens variants removed; structural test added.
- O2 (high, missing clock/model introspection) — `generated_at` and
  `generated_by` now emitted as `<DISPATCHER: ...>` placeholders;
  dispatcher fills at persistence.
- O3 (high, brittle test) — `test_marketplace_plugin_version_*`
  rewritten to compare against the canonical
  `ai-literacy-superpowers/.claude-plugin/plugin.json` `version`
  instead of a hard-coded literal; tracks main per spec §9.
- O4 (high, sentinel drift unguarded) — two static-text guards added
  asserting both literal sentinels appear in the agent body.
- O5 (medium, under-advertised contract) — agent description
  extended to name the Q\<N\> prefix and `(empty scope)` sentinel;
  matching test updated.
- O6 (medium, stale prose) — marketplace.json description and
  README Install section updated to reflect the v0.3.0 shipped agent.
- O8 (medium, Phase A ambiguity) — Phase A restructured: both-empty
  check fires after steps 3 *and* 4, asymmetric outputs (one
  collection populated, the other empty) explicitly named as valid.
- O7 (medium, observability gap) — *deferred*. The escalation
  trigger (sentinel-only ratio) needs invocation persistence, which
  belongs to parent S4 (#333). Explanation page updated to be
  honest about the gap at v0.3.0.
- O9 (low, plugin_version governance) — *deferred*. Already tracked
  at #339; current PR ships under existing per-spec discipline.

**Follow-up issues opened by the choice-cartographer adjudication
(`docs/superpowers/stories/dl-s2b-challenge-protocol-design.md`):**

- #338 — Meta-spec: cross-plugin discipline scoping (the *revisit*
  follow-up for Story #7 — TDAD-scenario-check and
  docs-reference-parity-check are currently scoped only to
  `ai-literacy-superpowers/`; whether they should extend to
  diagnostic-legibility and model-cards is a meta-decision deferred
  to a future spec).
- #339 — Promote: marketplace.json `plugin_version` cross-PR
  coordination rule (the *promoted* follow-up for Story #8 — the
  per-spec restatement of the merge-time rule should be promoted to
  `CLAUDE.md` so it governs every future PR without ceremony).

Sub-S2b of the meta-iteration recorded at
`docs/superpowers/slices/dl-s2-two-model-agent.md`. Closes issue
#335; parent issue #331 auto-closes per its own comment.

## 0.2.0 — 2026-05-26

### LegibilityElement schema

Adds the `LegibilityElement` schema artefact at
`templates/legibility-element.md`. The schema covers both the
architectural and domain dimensions of the diagnostic-legibility
agent (built in sub-S2b, issue #335) under a single flat record type;
the dimensions are typed by the collection wrapper `LegibilityModel`,
not by the record itself. Carries `name`, `description`, `evidence`
(list of `{path, excerpt?}`), `confidence` (low/medium/high), and
`challenge_notes`. Wrapper adds `scope`, `generated_at`,
`generated_by`, and the two collections.

Replaces the `templates/.gitkeep` placeholder from v0.1.0.

Validation is enforced by the agent during construction; no runtime
validator ships at this version.

Sub-S1 of the meta-iteration recorded at
`docs/superpowers/slices/dl-s2-two-model-agent.md`. Tracks parent
issue #331. Sub-S2b (challenge protocol + working agent) is deferred
to issue #335.

## 0.1.0 — 2026-05-26

### Scaffold

Initial plugin scaffold. Establishes the Diagnostic Legibility plugin
as a first-class entry in the marketplace.

- `.claude-plugin/plugin.json` declaring the plugin at v0.1.0 with the
  charter: *"Agents accountable for helping to maintain human
  understanding."*
- Empty placeholder directories `agents/`, `skills/`, `commands/`,
  `templates/` — structural signals for where future content lands.
- README documenting the charter, the v0.1.0 scaffold-only status,
  and links to the three deferred issues (#331 S2, #332 S3, #333 S4).
- Docs-site landing page at `docs/plugins/diagnostic-legibility/`.

No functional agents or commands yet — the first agent ships in
[#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331)
(S2).

Tracks parent issue [#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).
