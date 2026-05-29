# Changelog

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
