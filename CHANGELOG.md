# Changelog

## 0.39.1 — 2026-05-28

### Fix — /superpowers-status disposition counting

`/superpowers-status` could over-report pending dispositions when an
objection or choice-story record contained the literal string
`disposition: pending` inside an `evidence:` or `claim:` field — a
common pattern when an objection itself critiques disposition handling.
A naive `grep -c "disposition: pending"` matched those prose occurrences
and reported them as unresolved entries. In 2026-05 this showed
`choice-cartographer.md` as having 3 pending dispositions when every
entry was in fact resolved.

- `commands/superpowers-status.md` now defines a shared "Disposition
  counting" algorithm before Section 7. The rule: count only lines
  matching `^    disposition: pending(\s|$)` within the first
  `---`…`---` frontmatter block. Provides an awk recipe agents and
  humans can paste, and notes that a YAML-aware parser (`yq`,
  `python -c "import yaml"`) is preferred when available.
- Sections 7 (Diaboli) and 8 (Cartographer) reference the shared
  algorithm so the same fix protects both panels.

### Chore — Bump Node.js 20 GitHub Actions before 2026-06-02 cutoff

- `spec-first-check.yml`: bumped `actions/github-script` from v7.0.1 (Node 20) to v9.0.0 (Node 24) ahead of GitHub's 2026-06-02 hard cutoff.

## 0.39.0 — 2026-05-26

### Carpaccio agent — cadence governor for AI-generated decision streams

Adds the `carpaccio` agent — the third member of the decision-discipline
triad alongside `advocatus-diaboli` (objections) and
`choice-cartographer` (decision visibility). Carpaccio is the cadence
governor: it sits at orchestrator step 0, before spec-writer, and
slices the raw task description into end-to-end-complete pieces so the
human engages with one decision at a time rather than the whole
proposal at once.

- New skill at `skills/carpaccio/SKILL.md` defining the charter, the
  routing rule (carpaccio vs spec-writer), the selectivity protocol,
  and the reasoning protocol.
- New references at `skills/carpaccio/references/slicing-lenses.md`
  (the five-lens vocabulary with priority order) and
  `skills/carpaccio/references/validation-checks.md` (the validation
  contract — frontmatter checks F1–F8, prose-body checks P1–P5).
- New agent at `agents/carpaccio.agent.md` with read-only trust
  boundary (Read/Glob/Grep). The orchestrator writes the slicing
  record; humans fill dispositions; the orchestrator drives
  `gh issue create` for accepted-but-not-progressed slices.
- New command at `commands/carpaccio.md` for manual invocation
  outside the orchestrator.
- New TDAD scenarios at `tdad_tests/scenarios/agents/carpaccio/` —
  six scenarios covering multi-decision slicing, atomic-task
  inseparability, mixed-independence sequencing, vague-task
  fallback to acceptance-criterion, revise-redispatch behaviour,
  and selectivity-cap respect.
- Orchestrator gains a new **Step 0** before spec-writer:
  dispatches carpaccio, validates the slicing record, hard-gates
  on `disposition` and `file_as_issue`, drives issue creation for
  accepted-not-progressed slices, dispatches spec-writer against
  the progressed slice's scope.
- New directory `docs/superpowers/slices/` holds slicing records,
  sibling to `objections/` and `stories/`.

Tracks issue #326.

## 0.38.0 — 2026-05-11

### Snapshot template gains two new sections

Two new sections added to the health snapshot template defined in
`ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`
and the writer/validator in
`ai-literacy-superpowers/commands/harness-health.md`:

- **Sustainable Pace** — longitudinal self-report capturing the
  depletable-collaborator signal (this month's pace: sustainable /
  at-edge / over-the-edge / unknown; optional note; trend vs previous
  snapshot). Closes the depletion-management gap raised in successive
  literacy assessments — pace becomes a tracked field instead of a
  by-feel judgement.
- **Portfolio Adoption** — adoption telemetry capturing the L5 →
  sovereign-across-an-organisation progression (plugin installs,
  /assess invocations from other projects, upstream PRs into
  `ai-literacy-for-software-engineers`, `agent-harness-enabled`
  tagged-repo count, trend). Most fields read `not tracked` until
  install telemetry is available, but capturing what *is* available
  starts the longitudinal record.

Section count moves from 14 to 16. Next `/harness-health` invocation
populates the new sections.

### Quarterly literacy assessment — Level 5 continuation

`assessments/2026-05-11-assessment.md` records the quarterly
re-assessment. Level 5 confirmed for the third consecutive sitting,
with deepening evidence: 81 commits, 6 minor releases, the TDAD
pillar shipped end-to-end and operationally adopted, governance
subsystem operating quarterly, monthly curation practised, ONBOARDING
regenerated immediately after TDAD landed.

Five workflow recommendations walked interactively and all five
accepted:

- R1 — run `/cost-capture` in this quarterly sitting (closes
  three-assessment-old gap)
- R2 — add a SessionStart hook surfacing AGENTS.md promoted patterns
  (filed as follow-up PR with its own spec)
- R3 — run `/harness-audit` in this sitting to refresh HARNESS.md
  Status counts via the proper mechanism
- R4 — sustainable-pace snapshot field (shipped in this PR)
- R5 — portfolio-adoption snapshot field (shipped in this PR)

### Habitat hygiene

- New `decks/` directory with `cognitive-debt-paydown.md` — a
  slide-deck source mapping the four-debt cycle onto the framework's
  three human-cognition gates (Choice Cartographer, Advocatus
  Diaboli, alternative-options agent architecture). Markdown-source
  format intended for Claude Design or any deck tool that consumes
  per-slide headings.
- HARNESS.md template-version marker bumped from `0.35.1` to `0.38.0`
  after `/harness-upgrade` confirmed the project's harness already
  contains every active and commented-out item present in the current
  template (24 constraints + 18 GC rules vs the template's 5 + 14).
- README Skills badge: 31 → 32 (catches the
  `component-design-with-tdad` skill added in v0.37.0)
- README marketplace table and Skills heading anchor: same
- README AI Literacy badge: link updated to point to the new
  2026-05-11 assessment
- README mechanism map: Skills count updated; STRICT loop CI workflow
  list now includes `docs-build-check.yml`,
  `spec-redaction-marker-check.yml`, `tdad-tests-fast.yml`, and
  `tdad-scenario-check.yml`

### Reflection

`REFLECTION_LOG.md` gains a new entry for the 2026-05-11 assessment.
Notable observations: drift on entry was immediate and mechanical
signal (README/HARNESS Status counts visibly stale within seconds —
the L5 epistemic gain at work); the TDAD pillar followed the same
six-step shipping arc as the governance subsystem six weeks ago,
making the arc a tacit pattern worth promoting to AGENTS.md
ARCH_DECISIONS; cost capture has been flagged in three consecutive
assessments and the gap is *operational habit*, not tool friction.

## 0.37.0 — 2026-05-10

### New skill — `component-design-with-tdad`

Methodology guidance for designing a new plugin component (skill,
agent, command, or backing script) with TDAD discipline integrated
from the start. The skill names the five design questions implied
by the four-layer TDAD architecture:

1. What component type is this?
2. Which TDAD layers does this component warrant?
3. What does the scenario's `Then` clause look like?
4. New file or modification of an existing component?
5. Scenario or finding?

Loadable by `spec-writer`, `tdd-agent`, or human brainstorming. Not
a gate — the forcing functions are the deterministic CI workflows
shipped in v0.36.0 (`tdad-tests-fast.yml`,
`tdad-scenario-check.yml`). This skill packages the design
intelligence those gates assume.

The choice of skill rather than a new agent is deliberate: cartograph
story #3 of the v0.36.0 introducing spec explicitly chose
single-`tdd-agent` + branch over a separate `tdad-agent`, citing the
architectural failure mode of "two agents that share a charter." A
new component-designer agent would have reversed that decision shape
on the same charter axis. A skill carries the design intelligence
reusably (loadable by either agent or human) without the dispatch
overhead.

Skill count: 30 → 31. No agent or command count change.

Issue #313 carries the in-scope / out-of-scope and the chore-PR
rationale per AGENTS.md STYLE on reflection-driven amendments.
REFLECTION_LOG.md captures the design-intelligence-gap signal that
drove the addition.

## 0.36.0 — 2026-05-10

### Feature — TDAD discipline for agent artefacts in the orchestrator pipeline

When the orchestrator detects that a feature spec touches a new file
under `ai-literacy-superpowers/skills/`, `agents/`, or `commands/`, it
now passes agent-artefact scope context to `tdd-agent`. The tdd-agent's
new agent-artefact branch authors a TDAD scenario file at
`tdad_tests/scenarios/<type>/<name>/<aspect>.md` (with `Given/When/Then/Rubric`
sections and `tier` declared as one of `structural`, `trigger`, or
`behavioural`) as the RED-phase deliverable, instead of a generic
test file. Detection is path-based; modification of an existing
component is acknowledged as a known limitation (the orchestrator
surfaces the question but does not enforce an answer).

### Constraint — `New plugin components must ship with a TDAD scenario`

New deterministic HARNESS constraint enforced at PR time via
`.github/workflows/tdad-scenario-check.yml`. The check verifies that
any added file matching the canonical component paths has a
corresponding scenario file with a non-`finding` tier. Files with
`tier: finding` (the documentary-finding category, e.g.
`FINDING-command-tdab-gap.md` in the corpus) coexist with scenarios
but do not satisfy the constraint. Modifications are out of scope —
only additions are gated.

The HARNESS Status `Constraints enforced` count moves from 20/21 to
21/22; the README badge follows.

### Discipline shipped forward-only

Per the spec at
`docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md`
(Amendment 2 §A2.6), this PR's modifications to `orchestrator.agent.md`
and `tdd-agent.agent.md` themselves do not author scenarios. The
discipline applies forward — to PRs that *add* a component after this
one merges. Both modified agent files carry an in-place forward-pointer
comment explaining the exemption (per the diaboli adjudication of O7).

### Spec ceremony

Three spec-mode `/diaboli` passes (12 → 8 → 8 objections, converging
on implementation polish), one `/choice-cartograph` pass (9 stories),
and one Amendment 2 pivot from self-demonstration to forward-only.
Both records have all dispositions resolved — no `pending`. Spec
preserves original prose with visible `> **SUPERSEDED**: …`
blockquote redaction markers (the cartograph promoted this convention
to AGENTS.md STYLE at the next curation pass).

## 0.35.5 — 2026-05-09

### Fix — `/harness-sync` consistently references `harness-audit-engine`

Three places in `harness-sync.md` referenced the skill informally as
`audit-engine` when its actual name is `harness-audit-engine`. The
prose was understandable to a human reader but failed strict
component-name resolution.

Surfaced by **TDAD Phase 1** (the new command-wiring test in
`tdad_tests/tests/test_command_wiring.py`), which parses every
command's body for `Dispatch the X agent` and `Read the X skill`
patterns and asserts each referenced component exists. This is
exactly the rename-without-callsite-update failure class Phase 1 was
designed to catch — and it did, on its first run, against three
commands (the other two — `assess` and `harness-init` — were false
positives in the regex's handling of `gh repo edit --add-topic
agent-harness-enabled`, fixed by adding a `(?!-)` negative lookahead
on the trailing keyword).

No functional behaviour change — the loader uses the `harness-audit-engine`
skill correctly today. Patch bump for the prose-consistency edit
that the new test required.

## 0.35.4 — 2026-05-09

### Fix — agent frontmatter now strict-YAML compliant (resolves #283)

Six agent files carried multi-line `description:` values with embedded
`<example>` blocks whose internal `Context:`, `user:`, `assistant:`
lines tripped strict YAML parsers. The Claude Code loader accepts
this convention; PyYAML and any other strict YAML library does not.
Surfaced by the TDAD Layer 1 frontmatter-strictness check (PR #282 /
issue #281).

Conversion to YAML literal block scalars (`description: |` followed
by a 2-space-indented multi-line body) for the six affected files:

- `assessor.agent.md`
- `governance-auditor.agent.md`
- `harness-auditor.agent.md`
- `harness-discoverer.agent.md`
- `harness-enforcer.agent.md`
- `harness-gc.agent.md`

Round-trip parsing verified each conversion preserves the description
text including all `<example>` blocks. The Layer 1 frontmatter
strictness test now PASSES (was a non-blocking SKIP listing all six
broken files); TDAD suite count moves from 22 passed / 8 skipped to
23 passed / 7 skipped.

Decision rationale (Option A from issue #283): the plugin is
documented at the framework level and likely to be consumed by
independent tooling over time; assuming the test runner is the only
non-Claude-Code consumer that will ever read these files was a
fragile assumption. Block scalars are well-supported by every YAML
library and remove the ambiguity at the source.

The resolved finding scenario (`tdad_tests/scenarios/agents/assessor/FINDING-frontmatter-yaml-strictness.md`)
has been removed; the architectural record lives in PR #282 and
issue #283 in git history.

## 0.35.3 — 2026-05-09

### Internal reorganisation — bash test scripts moved to tdad_tests/

The three internal bash test scripts and their 11 fixtures have been
relocated from `ai-literacy-superpowers/tests/` (inside the packaged
plugin) to `tdad_tests/layer0_deterministic/` (a sibling test
directory outside the packaged plugin). No functional change for
plugin consumers — the scripts under test
(`archive-promoted-reflections.sh`, `migrate-reflection-log.sh`,
`lib/reflection-log-helpers.sh`) remain in the packaged plugin and
ship unchanged.

This is purely an internal reorganisation, hence the patch bump:

- The TDAD suite now mirrors the framework's harness promotion ladder
  (Theme #10) explicitly: Layer 0 (deterministic plumbing, NEW), Layer
  1 (structural), Layer 2 (trigger), Layer 3 (behavioural).
- A pytest dispatcher (`tests/test_layer0_deterministic.py`) runs the
  three bash scripts as subprocesses and surfaces their FAIL output on
  failure. Bash kept as bash; Python only for the dispatcher.
- Markdown lint config migrated to `.markdownlint-cli2.jsonc` with an
  `ignores:` entry for the deliberately-malformed Layer 0 fixtures
  (one is named `reflection-log-promoted-trailing-space.md` because
  it tests the parser's trailing-whitespace handling).

Tracked at PR #289.

## 0.35.2 — 2026-05-08

### Fix — `/harness-sync` trust-boundary contradiction with HARNESS.md Status auto-fix

Resolves an internal inconsistency in the `/harness-sync` command spec.
Phase 3 step 3 declared HARNESS.md Status section accuracy auto-fixable
via `/harness-audit`, but step 7's trust-boundary guard listed HARNESS.md
in the rejected set. A live sync run hit this contradiction and had to
resolve it pragmatically inline; this PR codifies that resolution.

Changes:

- Step 7 trust-boundary allow-list now permits HARNESS.md changes
  scoped to the four-line Status block under the
  `<!-- Auto-updated by /harness-audit — do not edit manually -->`
  marker, with an additional scoped-diff check that rejects any hunk
  outside that region. Adds `observability/snapshots/**` to the
  allow-list (covers `/harness-health` snapshot creation, the other
  HARNESS.md-adjacent auto-fix the audit-engine declares).
- Phase 3 step 3 no longer says "invoke `/harness-audit`". Sync now
  inlines the Status block update directly. The full audit (which
  also writes the README badge and runs heavy constraint regression
  scans) remains a separate user-triggered action.
- The opening "What this command does NOT do" paragraph distinguishes
  curated-by-humans files (`AGENTS.md`, `REFLECTION_LOG.md`,
  `ONBOARDING.md`) from the narrowly-scoped HARNESS.md Status mutation
  that sync is allowed to make.
- Path A and Path B `git add` lines now stage every allow-listed
  surface (including HARNESS.md and snapshot directories); commit
  message guidance reflects the actual mix of surfaces synced.
- Error/Refusal table updated to match the new allow-list.
- The `sync-harness` how-to doc's "Branch and trust-boundary" section
  is rewritten to match the corrected spec — including the explicit
  note that everything above the Status block (Context, Constraints,
  Garbage Collection, Observability, Read-side filtering) is
  off-limits to sync.

No change to the `harness-audit-engine` skill — its `auto_fixable`
classification rule already permitted HARNESS.md Status section
mutation as a defined exception. Only the sync command spec lagged.

## 0.35.1 — 2026-05-08

### Chore — Bump HARNESS.md template-version marker to 0.35.1

Brings the project's HARNESS.md `template-version` comment in line with
the current plugin release. `/harness-upgrade` confirmed no new template
constraints, GC rules, or sections to surface — every active and
commented item from the cached template (baseline `0.29.0`) is already
present in this project's HARNESS.md, often customised with project-
specific content. The bump records that the upgrade was reviewed for
0.34.x and 0.35.x; no semantic change to the harness itself.

### Refinement — `/harness-sync` no longer auto-invokes `/harness-onboarding`

Removes the auto-invocation of `/harness-onboarding` from
`/harness-sync`'s Phase 3 apply step. ONBOARDING.md staleness still
appears in the unified drift table (audit-engine continues to detect
it), but it now appears as a `[manual]` row instead of `[auto]` —
sync prints "Run: /harness-onboarding" and exits without writing.

Rationale: ONBOARDING.md regen is a heavier mutation than
convention-file regen and benefits from the user's deliberate trigger.
Convention-file sync is a tight derive-from-HARNESS.md operation;
onboarding regen also pulls in AGENTS.md and REFLECTION_LOG.md and
produces a substantial human-facing document. Same-shape change as
template-drift and constraint-regression: surface the staleness, let
the user act.

The trust-boundary pre-commit guard's allow-list drops `ONBOARDING.md`
accordingly — sync never writes to it now.

Updates `/harness-sync`'s command file, the audit-engine skill's
classification table, the sync-harness how-to, the run-a-harness-audit
how-to, the-harness-lifecycle explanation, CLAUDE.md (root + template)
Monthly Operations, and the README Commands table.

## 0.35.0 — 2026-05-08

### Feature — Audit-driven `/harness-sync`

Restructures `/harness-sync` so it runs `/harness-audit`'s detection
logic internally via a new shared `harness-audit-engine` skill. The
unified drift table now includes every audit finding tagged `[auto]`
or `[manual]`. Mechanical fixes (convention files, ONBOARDING.md,
snapshot regen via `/harness-health`, HARNESS.md Status section regen
via `/harness-audit`) auto-apply when selected. Judgement-required
fixes (`/harness-upgrade`, `/harness-constrain`) print the suggested
command without writing — preserving the trust boundary.

`/harness-audit` keeps its standalone diagnostic role unchanged. Both
commands now share the same engine; surface coverage evolves in one
place.

### Docs — Lifecycle simplification

Three explanation pages are rewritten to converge on a single
canonical narrative:

- `the-harness-lifecycle` is now the everyday three-state model
  (in sync, drifted, behind upstream) with `/harness-sync`,
  `/harness-upgrade`, and `/harness-constrain` as the everyday entry
  points.
- `the-harness-tuning-loop` refocuses on the signal-capture →
  constraint-promotion sub-flow specifically.
- `self-improving-harness` trims to the conceptual core (why
  iteration matters, the compound-learning principle).

How-to pages for sync-harness and run-a-harness-audit are updated
to reflect the audit-driven flow and the diagnostic-vs-everyday split.
Touch-ups across tutorials, plugin landing, CLAUDE.md (root +
template), and README align command descriptions.

### Internal

- New skill: `harness-audit-engine` documents the shared
  drift-detection contract.

## 0.34.1 — 2026-05-08

### Docs — Migrate site infrastructure from Jekyll/just-the-docs to MkDocs Material

Replaces the Jekyll + just-the-docs docs site infrastructure with
MkDocs Material. The change is plugin-internal only because it
modifies `templates/CLAUDE.md` (the shipped convention text projects
get from `/superpowers-init` now reflects the new theme conventions).

The bulk of the migration touches the `docs/` tree (outside the plugin
directory): a new `mkdocs.yml` and `requirements.txt` at repo root,
the `pages.yml` workflow swapped from `bundle exec jekyll` to
`pip install + mkdocs build`, all 377 Liquid `{% link %}` tags
rewritten to relative markdown paths, all 89 `redirect_from`
frontmatter entries migrated to the `mkdocs-redirects` plugin's
`redirect_maps`, and the Jekyll artifacts (`Gemfile`, `Gemfile.lock`,
`docs/_config.yml`) removed.

The `templates/CLAUDE.md` "Docs Site Review" section is updated to
describe the new theme conventions (MkDocs Material, the
`mkdocs-awesome-pages` plugin for filesystem-derived nav, no more
`has_children: true` or `nav_label` frontmatter required). New
projects running `/superpowers-init` get the corrected guidance.

A one-shot migration script
(`scripts/migrations/jekyll-to-mkdocs.py`) is committed for
reproducibility.

## 0.34.0 — 2026-05-08

### Feature — Diataxis docs reorg (Phase 1: model-cards)

Establishes the project-wide Diataxis folder convention for the docs
site and applies it to the `model-cards` plugin as the reference
implementation. Plugin docs now live at
`docs/plugins/<plugin-name>/<quadrant>/<slug>.md` where `<quadrant>`
is one of `tutorials/`, `how-to/`, `reference/`, or `explanation/`.
URLs are Diataxis-pure; sidebar nav uses friendly labels via
just-the-docs `nav_label` frontmatter.

Ships the convention machinery: a new **Redirect sunset** GC rule
(monthly, deterministic, scans for expired `<!-- redirect-sunset:
YYYY-MM-DD -->` markers), the `scripts/check-redirect-sunsets.sh`
tool that backs it, and the `scripts/migrations/rewrite-docs-links.sh`
one-shot link rewriter. Updates `CLAUDE.md` and
`templates/CLAUDE.md` to document the new layout convention.

The `model-cards` plugin's 7 movable docs pages were moved into
how-to/, reference/, and explanation/ quadrants (no tutorials/ —
no end-to-end walkthrough page exists yet). Every moved page
carries `redirect_from` covering both old URL forms (`/slug/` and
`/slug.html`) plus a 12-month sunset marker (2027-05-08).

`ai-literacy-superpowers` plugin docs migration arrives in Phase 2
as a separate PR (no version bump — outside the plugin directory).

## 0.33.0 — 2026-05-07

### Feature — `/choice-cartograph` command and `choice-cartographer` agent

Adds the second member of the decision-discipline triad: the
`choice-cartographer` agent and its companion `/choice-cartograph`
command.

The choice cartographer's job is decision-record keeping. When the
orchestrator (or a human) invokes `/choice-cartograph`, the
cartographer agent produces a structured YAML+prose choice story at
`docs/superpowers/stories/`. The story captures the decision context,
the options that were on the table, the chosen option, the rationale,
and — crucially — the `disposition:` of each alternative, so the
"road not taken" is preserved alongside the road taken.

- New agent at `agents/choice-cartographer.agent.md`
- New skill at `skills/choice-cartographer/SKILL.md` (the
  cartographer's protocol — phases 1–4, story format, validation
  contract, disposition lifecycle)
- New command at `commands/choice-cartograph.md`
- New `/superpowers-status` Section 8 panel for choice-story health
  (mirrors the Diaboli panel at Section 7)
- Story format reference and schema example at
  `skills/choice-cartographer/references/story-format.md` and
  `skills/choice-cartographer/references/story-schema-example.md`
- Orchestrator updated to dispatch the cartographer after spec
  approval, before the tdd-agent
- TDAD scenarios in `tdad_tests/scenarios/agents/choice-cartographer/`
  covering the four canonical trigger paths and one format-validation
  scenario
- Docs: explanation, how-to, reference pages; README and HARNESS.md
  counts updated

Tracks issue #297.

## 0.32.0 — 2026-04-27

### Feature — `/advocatus-diaboli` command and `advocatus-diaboli` agent

Adds the first member of the decision-discipline triad: the
`advocatus-diaboli` agent and its companion `/advocatus-diaboli`
command (alias `/diaboli`).

The diaboli agent's job is structured adversarial critique of a spec
before implementation starts. When the orchestrator (or a human)
invokes `/advocatus-diaboli <spec-file>`, the agent produces a
structured YAML+prose objection record at `docs/superpowers/objections/`.
Each record captures between 5 and 12 objections; the human author
resolves or defers each one before the orchestrator continues.

- New agent at `agents/advocatus-diaboli.agent.md`
- New skill at `skills/advocatus-diaboli/SKILL.md` (the diaboli
  protocol — phases 1–5, objection format, validation contract,
  disposition lifecycle)
- New command at `commands/advocatus-diaboli.md`
- New `/superpowers-status` Section 7 panel for objection health
  (surfaces pending dispositions per spec, warns when a spec is
  implementation-complete but objections remain open)
- Objection format reference and schema example at
  `skills/advocatus-diaboli/references/objection-format.md` and
  `skills/advocatus-diaboli/references/objection-schema-example.md`
- Orchestrator updated to dispatch the diaboli agent after
  spec-writer, before the tdd-agent
- TDAD scenarios in `tdad_tests/scenarios/agents/advocatus-diaboli/`
  covering the four canonical trigger paths and one format-validation
  scenario
- Docs: tutorial, explanation, how-to, reference pages; README and
  HARNESS.md counts updated

Tracks issue #264.

## 0.31.0 — 2026-04-20

### Feature — TDAD observability and fast-feedback workflows

Adds two GitHub Actions workflows that provide deterministic TDAD
feedback on every PR without requiring any Python environment:

- **`tdad-tests-fast.yml`** — runs the Phase 0 YAML lint and Phase 1
  wiring checks (pure Python stdlib, `<10 s`). Blocks merges if these
  fail.
- **`tdad-scenario-check.yml`** — checks that every new plugin
  component (skill, agent, command) added in a PR has a corresponding
  TDAD scenario file. Blocks merges if the component ships without a
  scenario.

Both are in the STRICT loop; HARNESS.md constraint count moves from
19/20 to 21/22. README mechanism map updated.

### Docs

- New how-to: `run-tdad-tests.md` — step-by-step for the four TDAD
  layers.
- Updated `docs/plugins/ai-literacy-superpowers/explanation/tdad-testing-explained.md`
  to describe the full four-layer picture with the new workflow
  context.

## 0.30.0 — 2026-04-19

### Feature — TDAD testing infrastructure (Layers 0–3)

Ships the four-layer TDAD testing framework for this plugin:

- **Layer 0** (deterministic, bash): three existing scripts
  (`archive-promoted-reflections.sh`, `migrate-reflection-log.sh`,
  `lib/reflection-log-helpers.sh`) and their 11 fixtures.
- **Layer 1** (structural, Python): `test_frontmatter.py` validates
  agent/skill/command YAML frontmatter, `test_command_wiring.py`
  asserts that every `Dispatch the X agent` / `Read the X skill`
  reference in a command body resolves to a real component.
- **Layer 2** (trigger, Python): `test_orchestrator_routing.py` and
  `test_command_dispatch.py` verify that the orchestrator routes to
  the right agent and that each command's declared trigger string
  appears in the right place.
- **Layer 3** (behavioural, YAML scenarios): 20 scenario files across
  `tdad_tests/scenarios/{agents,skills,commands}/` covering the
  canonical trigger paths and format-validation cases for the six
  agents, four skills, and four commands in the plugin.

`pytest.ini` and `conftest.py` wired; CI runs via `tdad-tests-fast.yml`
(Phase 0+1) added in the next PR.

## 0.29.1 — 2026-04-06

### Internal — rebase-only

This version bump marks the resolution of a rebase conflict on the
`orchestrator-tdad-integration` branch. No functional changes from
0.29.0; the rebase brought in the `docs/plugins/` tree from the main
branch (0.28.x series) and the `tdad_tests/scenarios/` directory
landed in 0.29.0 is now on top.

## 0.29.0 — 2026-03-28

### Feature — Governance subsystem

Full governance subsystem: monthly AI usage audit, quarterly literacy
assessment, REFLECTION_LOG.md archiving, and cross-plugin insight
harvesting.

- New agent `governance-auditor` with monthly and quarterly sub-agents
- New command `/governance-audit`
- `/assess` updated to produce structured assessment records with
  gap-tracking sections
- `/harness-health` snapshot format adds a Governance section
- REFLECTION_LOG.md archiving workflow via `archive-promoted-reflections.sh`

Tracks issue #198.

## 0.28.5 — 2026-03-15

### Fix — harness-discoverer trust boundary on harness-init invocation

The harness-discoverer agent's trust-boundary validation logic
incorrectly blocked `harness-init` invocations where the repository
had no existing `HARNESS.md`. The agent now distinguishes first-run
(`harness-init`, no existing file) from update-run (`harness-upgrade`,
existing file present) before applying the trust boundary. Tracked
at issue #187.

## 0.28.4 — 2026-03-14

### Fix — /harness-audit silent-pass on empty constraint list

When a project's HARNESS.md had zero constraints in the Constraints
section (e.g. a brand-new harness from `/harness-init`), the audit
engine reported "0 constraints, 0 passing, 0 failing" — a valid
empty result — as a green pass, which hid the onboarding gap. Now the
audit hard-fails when the constraint count is zero, with a clear
message directing the user to `/harness-constrain`. Tracked at
issue #182.

## 0.28.3 — 2026-03-13

### Fix — /harness-constrain constraint uniqueness check

When adding a new constraint, `/harness-constrain` now checks whether
an equivalent constraint (same `check_type` + `target_pattern`) already
exists before writing. Previously, repeated invocations could append
duplicate constraints without warning. The uniqueness check uses
normalised YAML keys so minor whitespace differences do not create
false negatives. Tracked at issue #178.

## 0.28.2 — 2026-03-12

### Fix — /harness-health snapshot date-stamping

The snapshot filename and frontmatter `date:` field now use the
localtime date of the machine running the command rather than UTC.
This was causing off-by-one-day errors for users in UTC+N timezones
when they ran a health check after 4 PM local. Tracked at issue #173.

## 0.28.1 — 2026-03-11

### Fix — harness-enforcer false positive on multi-line constraint bodies

The constraint-runner regex used by `harness-enforcer` matched only
the first line of a multi-line `check_body:` field, silently passing
constraints whose full body would have failed. Multi-line bodies are
now joined before matching. Tracked at issue #168.

## 0.28.0 — 2026-03-10

### Feature — Harness enforcement CI workflow

Adds `.github/workflows/harness-enforcement.yml`: a GitHub Actions
workflow that runs `harness-enforcer` on every PR and push to main.
The workflow installs no extra dependencies — it uses only the shell
scripts and YAML files already present in the plugin. Status badge
added to README.

Tracks issue #161.

## 0.27.0 — 2026-03-01

### Feature — `/harness-health` command and `harness-observability` skill

Adds longitudinal health snapshots for the harness:

- New command `/harness-health` — generates a dated snapshot file at
  `observability/snapshots/YYYY-MM-DD.md` capturing constraint
  counts, GC rule status, recent audit results, and a pace-of-change
  note.
- New skill `harness-observability` — the detection and generation
  protocol shared by `/harness-health` and the audit engine.
- HARNESS.md gains an `Observability` section (template updated).

Snapshot count moves from 0 to 1 on first invocation; README badge
and HARNESS.md Status section updated.

Tracks issue #149.

## 0.26.0 — 2026-02-14

### Feature — `/harness-upgrade` command

Adds `/harness-upgrade`: compares the project's `HARNESS.md` against
the latest plugin-shipped template, reports semantic drift (new
constraint categories, new GC rules, updated section text), and
offers to apply upstream changes with a conflict-resolution protocol.

- New command at `commands/harness-upgrade.md`
- Template stored at `templates/HARNESS.md`; upgrade logic in the
  `harness-discoverer` skill (Phase 3 branch)

Tracks issue #134.

## 0.25.0 — 2026-02-01

### Feature — Garbage-collection subsystem

Adds the GC subsystem to the harness: structured rules for pruning
stale artefacts, cleaning up obsolete snapshots, and retiring
old constraints that have been superseded.

- HARNESS.md template gains a `Garbage Collection` section with
  5 default GC rules
- New skill `harness-gc` handles rule evaluation and output
- `/harness-audit` now includes a GC pass and surfaces stale-artefact
  findings in the audit report

Tracks issue #121.

## 0.24.0 — 2026-01-25

### Feature — `/harness-constrain` command

Adds the constraint-authoring command: guides the user through
specifying a new harness constraint (type, target, check body,
enforcement mode), validates uniqueness, and appends it to HARNESS.md.

- New command at `commands/harness-constrain.md`
- Constraint schema documented in `skills/harness-audit/references/`

Tracks issue #111.

## 0.23.0 — 2026-01-18

### Feature — `/harness-audit` command

Adds the audit command: runs all harness constraints against the
current repository state, produces a pass/fail report per constraint,
and surfaces actionable fix commands for failures.

- New command at `commands/harness-audit.md`
- New agent `harness-auditor` (runs constraints, formats report)
- New skill `harness-audit-protocol` (the evaluation protocol)

Tracks issue #102.

## 0.22.0 — 2026-01-10

### Feature — `/harness-sync` command (v1)

Adds the first version of the sync command: detects drift between the
project's convention files (CLAUDE.md, AGENTS.md) and the values in
HARNESS.md, and offers to regenerate the convention files from the
harness.

- New command at `commands/harness-sync.md`
- Sync logic in the `harness-discoverer` skill (Phase 2 branch)

Tracks issue #93.

## 0.21.0 — 2026-01-03

### Feature — `/harness-init` command

Adds the harness initialisation command: scaffolds a `HARNESS.md` in
the target repository based on a discovery interview, detects existing
convention files, and seeds the Constraints section with any
constraints the agent detects from the existing CLAUDE.md.

- New command at `commands/harness-init.md`
- New agents `harness-discoverer`, `harness-enforcer`
- New skill `harness-init-protocol`

Tracks issue #81.

## 0.20.0 — 2025-12-21

### Feature — AI Literacy assessment system

Adds the assessment system: a structured progression from L1 to L5,
assessment criteria per level, and the `/assess` command.

- New command `/assess`
- New agent `assessor`
- Assessment rubric at `skills/assessment/references/rubric.md`
- Level progression guide at `skills/assessment/references/levels.md`

Tracks issue #68.

## 0.19.0 — 2025-12-07

### Feature — SessionStart hook and `harness-onboarding` command

Adds automatic context injection at the start of every Claude Code
session:

- New `harness-onboarding` command generates `ONBOARDING.md` from
  `HARNESS.md` + `AGENTS.md` + `REFLECTION_LOG.md`
- `CLAUDE.md` template updated with a `SessionStart:` hook that loads
  `ONBOARDING.md` automatically
- New skill `harness-onboarding-protocol`

Tracks issue #57.

## 0.18.0 — 2025-11-22

### Feature — REFLECTION_LOG.md and reflection workflow

Adds the reflection subsystem:

- `REFLECTION_LOG.md` template with `promoted:`, `archived:`, and
  `raw:` sections
- New command `/capture-reflection` — writes a dated entry to the
  `raw:` section
- New command `/promote-reflection` — moves entries from `raw:` to
  `promoted:` with the human's editorial review
- `migrate-reflection-log.sh` one-shot migration script for projects
  already tracking reflections in plain markdown

Tracks issue #44.

## 0.17.0 — 2025-11-08

### Feature — Plugin marketplace listing

Publishes the plugin to the Claude Code plugin marketplace.

- `CLAUDE.md` metadata block updated with `marketplace: true` and
  `categories: ["AI Literacy", "Agent Harness"]`
- README updated with installation instructions and marketplace badge
- `docs/plugins/ai-literacy-superpowers/` landing page added

## 0.16.0 — 2025-10-25

### Feature — Superpowers status dashboard

Adds `/superpowers-status`: a one-command dashboard that surfaces the
current state of the AI Literacy Superpowers plugin — spec coverage,
constraint health, objection dispositions, choice-story completeness,
and snapshot currency.

- New command at `commands/superpowers-status.md`
- Sections 1–6 cover: plugin version, spec coverage, constraint
  health, GC rule status, snapshot currency, and reflection log
  currency

Tracks issue #31.

## 0.15.0 — 2025-10-11

### Feature — Spec-first CI workflow

Adds `.github/workflows/spec-first-check.yml`: enforces that the
first commit on any feature branch is a spec file in
`docs/superpowers/specs/`. Bug-fix, maintenance, and cross-repo PRs
are exempt via branch prefix or label.

- New workflow file
- HARNESS.md constraint "Spec-first commit ordering" added
- README mechanism map updated

Tracks issue #22.

## 0.14.0 — 2025-09-27

### Feature — `spec-writer` agent

Adds the `spec-writer` agent: given a feature request, produces a
structured spec file at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
with Problem, Goals, Non-goals, Design, and Open Questions sections.

- New agent at `agents/spec-writer.agent.md`
- New skill at `skills/spec-writer/SKILL.md`
- Orchestrator updated to dispatch spec-writer before tdd-agent

Tracks issue #17.

## 0.13.0 — 2025-09-13

### Feature — `tdd-agent`

Adds the `tdd-agent`: given a spec file, produces a RED-phase test
file that fails deterministically, then implements to GREEN.

- New agent at `agents/tdd-agent.agent.md`
- New skill at `skills/tdd/SKILL.md`
- Orchestrator routes feature specs to tdd-agent

Tracks issue #12.

## 0.12.0 — 2025-08-30

### Feature — Orchestrator agent

Adds the `orchestrator` agent: the entry point that routes user
requests to the appropriate specialist agent.

- New agent at `agents/orchestrator.agent.md`
- Routing table covers spec-writer, tdd-agent, harness agents, and
  assessment

Tracks issue #7.

## 0.11.0 — 2025-08-16

### Feature — CLAUDE.md and AGENTS.md templates

Adds the convention-file templates that `/superpowers-init` deposits
into new projects:

- `templates/CLAUDE.md` — project convention file template
- `templates/AGENTS.md` — agent manifest template

Tracks issue #4.

## 0.10.0 — 2025-08-02

### Feature — `/superpowers-init` command

Adds the plugin initialisation command: bootstraps a new project with
`HARNESS.md`, `CLAUDE.md`, `AGENTS.md`, and `REFLECTION_LOG.md` via
an interview-driven setup flow.

- New command at `commands/superpowers-init.md`
- New agent `harness-discoverer` (Phase 1 — initial discovery)

Tracks issue #1.

## 0.9.0 — 2025-07-19

### Initial plugin structure

Establishes the top-level directory layout:

- `ai-literacy-superpowers/` — plugin root
- `agents/`, `skills/`, `commands/` — plugin component directories
- `docs/superpowers/` — plugin documentation tree
- `tdad_tests/` — TDAD test suite root
- `.github/workflows/` — CI workflow directory

## 0.8.0 — 2025-07-05

### Docs — AI Literacy for Software Engineers integration

Adds cross-references from this plugin's documentation to the
`ai-literacy-for-software-engineers` course material. The plugin
docs now link to the relevant course sections for each AI Literacy
level.

## 0.7.0 — 2025-06-21

### Feature — Cost capture workflow

Adds `/cost-capture`: records the token cost and wall-clock time of
the current session to `observability/costs/YYYY-MM.md`. Provides
the longitudinal cost record the governance subsystem later consumes.

- New command at `commands/cost-capture.md`

## 0.6.0 — 2025-06-07

### Feature — Monthly curation workflow

Adds `/monthly-curation`: the monthly operations command that walks
the GC rules, surfaces stale artefacts, and prompts the human to
dispose of or retain each one.

- New command at `commands/monthly-curation.md`

## 0.5.0 — 2025-05-24

### Feature — Harness lifecycle explanation

Adds `docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md`:
the canonical explanation of the three-state harness model (in sync,
drifted, behind upstream) and the three everyday entry points
(`/harness-sync`, `/harness-upgrade`, `/harness-constrain`).

## 0.4.0 — 2025-05-10

### Feature — Harness self-improvement explanation

Adds `docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md`:
the canonical explanation of how the harness improves over time via
the signal-capture → constraint-promotion loop.

## 0.3.0 — 2025-04-26

### Initial documentation scaffold

Adds the docs site scaffold:

- `mkdocs.yml` and `requirements.txt` at repo root
- `docs/` tree with `index.md`, `plugins/` landing pages
- `.github/workflows/pages.yml` for MkDocs build + GitHub Pages deploy

## 0.2.0 — 2025-04-12

### Rename and restructure

- Rename repo from `superpowers-harness` to `ai-literacy-superpowers`
- Move plugin into `ai-literacy-superpowers/` subdirectory for
  marketplace install compatibility
