# Changelog

## 0.66.0 — 2026-07-20

### Feature: the sentinel agent category

Names the sub-family of agents whose object of care is the human's
understanding and judgement rather than an artefact, the pipeline, or
the harness. Categorisation, documentation, and one new enforceable
constraint — no agent renames, no behavioural changes, no new gates.

- **`role: sentinel` frontmatter tag** — added to the five roster agents
  (`reservoir-warden`, `advocatus-diaboli`, `choice-cartographer`,
  `carpaccio`, `cost-estimator`). An enum with a single permitted value;
  absence means "pipeline/harness agent" and changes nothing.
- **Sentinel integrity constraint** — `sentinel-integrity-check.sh`
  fails CI if a `role: sentinel` agent is granted Write/Edit (criterion
  S1), or if any `role:` value falls outside the enum. Runs at PR time
  (`harness.yml`) and weekly (`gc.yml`), and as a Layer-0 test with
  red/green fixtures. This makes the category load-bearing, not
  decorative — mislabel an agent and the build goes red.
- **`sentinel-design` skill** — documents the three-part signature (S1
  read-only, S2 advisory-to-human, S3 explicit honesty rule), the
  near-miss gallery (why code-reviewer and harness-auditor don't
  qualify), the honesty-rule-before-detection-logic discipline, and the
  three anti-patterns.
- **README Sentinels section** — the *Agents (16)* table splits into
  Sentinels (5) and Pipeline & harness agents (11).
- **Docs** — new `explanation/sentinels.md` page; `/superpowers-status`
  now reports sentinel coverage and integrity-constraint state.

### Docs: how to design a sentinel

- Added the [Design a Sentinel Agent](docs/plugins/ai-literacy-superpowers/how-to/design-a-sentinel.md)
  how-to guide — the task-oriented walkthrough for authoring a new
  sentinel (confirm the object of care, write the honesty rule first,
  author the agent, run the integrity check, ship the TDAD scenario and
  reference entry), completing the Diataxis coverage alongside the
  existing concept and reference pages. Cross-linked from the Sentinels
  concept page and the `sentinel-design` reference entry. Docs-only, no
  plugin version bump.

## 0.65.1 — 2026-07-16

### Fix: harness-auditor bounded read-side filtering (#478)

The harness-auditor's "Read-side filtering policy" told the agent to
`bash …/scripts/lib/reflection-log-helpers.sh` and then call
`bounded_entries` — broken two ways: the vendored path does not exist in
a marketplace-cache install (the #475 class of failure), and
`reflection-log-helpers.sh` is a *sourced* function library, so running
it with `bash` in a subshell never defines the function for the caller.

Fixing the invocation surfaced a third, latent defect: `bounded_entries`
itself returned empty entry bodies. It wrote each multi-line entry into a
tmpfile with real newlines, so the line-based `sort`/`awk` that follow
shattered every record — only the first physical line kept its tab, and
the rest read back blank. The existing tests missed it because they
counted `---ENTRY---` markers only, never the bodies.

- **`scripts/lib/reflection-log-helpers.sh`** — `bounded_entries` now
  encodes each entry body as a single physical line (newlines → literal
  `\n`) before the sort, which the downstream `awk` already decodes.
  Entry bodies are preserved.
- **New `bin/reflection-log-bounded` shim** — sources the helper library
  (resolved from its own location) and calls `bounded_entries` with the
  caller's arguments, so it works vendored or cache-installed and via
  PATH as a bare command.
- **`agents/harness-auditor.agent.md`** — the read-side-filtering
  instruction now runs `reflection-log-bounded REFLECTION_LOG.md 50 90`.
- **Test** — added `test_bounded_entries_preserves_entry_bodies`
  (asserts bodies == markers); it fails against the pre-fix function.

## 0.65.0 — 2026-07-04

### Fix: plugin-script references resolve in cache installs via bin/ shims (#475)

Commands, agents, and GC-rule `Tool:` fields referenced plugin scripts by
path — either `ai-literacy-superpowers/scripts/<name>.sh` (only valid when
the plugin is vendored in-repo) or `${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh`.
In the default (non-vendored) install the plugin runs from the versioned
marketplace cache, and **`${CLAUDE_PLUGIN_ROOT}` is defined only for hooks**
— it is UNSET in slash-command, main-agent, and subagent Bash contexts
(verified empirically on Claude Code 2.1.200, in both `--plugin-dir` and
real marketplace-cache installs). So every such reference silently failed
to resolve outside a vendored checkout — most importantly the **active,
deterministic** "Reflection log archival of promoted entries" GC rule,
which ships enabled with no caveat.

The one thing that IS on PATH in every context, including the harness-gc
subagent, is the plugin's `bin/` directory.

- **New `ai-literacy-superpowers/bin/` shims** — `archive-promoted-reflections`,
  `harness-affordance-check`, `harness-affordance-staleness`,
  `harness-affordance-invocations`, `harness-affordance-discover`,
  `update-badge`, `update-health-badge`, and `regenerate-reflection-log`.
  Each resolves the plugin root from its own location and `exec`s the
  corresponding `scripts/<name>.sh`, preserving the caller's working
  directory.
- **`templates/HARNESS.md`** — the reflection-archival and affordance
  `Tool:` fields are now **bare commands** (e.g. `archive-promoted-reflections`)
  that resolve via `bin/` on PATH regardless of vendored-vs-cache install
  and survive plugin upgrades. Added a Garbage Collection section note
  explaining the mechanism, and reworded the affordance caveat (no more
  "adjust to your install location"). The `sync-to-global-cache` hook
  example now shows `${CLAUDE_PLUGIN_ROOT}` (hooks resolve it; GC-rule
  Tool fields do not).
- **Commands / agents / skills** — badge, discovery, and reflection-log
  regeneration instructions now invoke the bare `bin/` commands instead of
  `${CLAUDE_PLUGIN_ROOT}` or vendored paths: `commands/harness-health.md`,
  `commands/harness-init.md`, `commands/harness-affordance.md`,
  `commands/reflect.md`, `agents/harness-gc.agent.md`,
  `agents/harness-auditor.agent.md`, `agents/integration-agent.agent.md`,
  and `skills/ai-literacy-assessment/SKILL.md`.

Known remaining edge (not addressed here): the read-side-filtering
instruction in `agents/harness-auditor.agent.md` sources the
`reflection-log-helpers.sh` function library rather than executing a
top-level script, so a `bin/` shim does not map to it cleanly — it needs
its own treatment.

## 0.64.1 — 2026-07-03

### Fix: gc-rotate strict-mode check false positives (#362)

- **`hooks/scripts/gc-rotate.sh` rule 3 (shell strict mode)** now scans
  the whole file for any start-of-line `set` that enables
  errexit/nounset/pipefail, instead of matching the exact literal
  `set -euo pipefail` in the first 15 lines only. The old check produced
  false positives on two legitimate patterns: strict-mode lines that sit
  below a documented header comment block (past line 15), and deliberate
  fail-open subsets such as `set -uo pipefail` (hooks that must not abort
  mid-run) and `set -u` (telemetry/CI scripts). The `[euo]` anchor still
  rejects `set -- "$@"` and still flags scripts with no strict mode at
  all. (Defect 1 from the issue — whole-tree `*.sh` scan — was already
  fixed by the `git ls-files` scoping in `list_owned_shell_scripts`.)

## 0.64.0 — 2026-06-23

### Docs: curated agentic-engineering video library (#456)

- **New explanation page** `docs/plugins/ai-literacy-superpowers/explanation/agentic-engineering-videos.md`
  — a "watch this to understand X" companion that maps authoritative
  talks (Böckeler, Anthropic, Osmani, North, Adzic, Knuth, Fairbanks,
  Meadows, Boyd/OODA) onto the plugin's own capabilities and lineage.
  Grouped by repo theme, each entry cites the capability or foundation
  it illuminates, carries a start-here → deeper sequence hint, and was
  link-verified live on 2026-06-24. Includes a suggested viewing path
  and an honest list of foundations with no verified primary-source
  video. Linked from the plugin docs index. Docs-only, no version bump.

### dynamic-workflows: docs, Copilot contract, epic finale (S7, #444)

The final slice of the Dynamic Workflows Alignment epic (D1–D9 now all
delivered across S1–S7).

- **README gains a "Dynamic Workflows" section** — the new ephemeral substrate,
  the six patterns, the opt-in election discipline, INV-1/INV-2, and the
  Claude-Code-only/guidance-everywhere boundary. The `Skills-36` badge is
  deliberately unchanged (the count was reconciled in S1).
- **Copilot CLI degradation contract resolved (open question 4 → Option A):** the
  `dynamic-workflows` skill **ships to both** the Claude Code and Copilot CLI
  trees and is **never omitted**. Where the workflow runtime is absent it is
  guidance-only — readable knowledge with each workflow-mode degrading to its
  static fallback, never erroring. Documented in the README and the skill's
  `governance.md`. This is documentation of already-shipped behaviour — no agent
  behaviour changes.
- **`CLAUDE.md` (root) and `templates/CLAUDE.md`** gain a pointer: when a task
  looks long-running, massively parallel, highly structured, or adversarial,
  consult the `dynamic-workflows` skill before reaching for a workflow.
- The optional advisory `Stop` hook from D9 was **deliberately deferred** (a Stop
  hook cannot reliably know a task's shape; the election discipline already lives
  in the skill and the orchestrator's classifier).
- All four §7 open questions are now resolved: Q1 fan-out threshold = 8 (S3); Q2
  routing opt-in (S5); Q3 staging = `REFLECTION_STAGING.md` (S6); Q4 Copilot =
  Option A (here). Deterministic structural checks
  (`test_s7_docs_hook_copilot_structural.py`) gate the declared contract.

## 0.63.0 — 2026-06-23

### dynamic-workflows: reflection-mining curation workflow (S6, #443)

Raises the *proposal* quality of the compound-learning loop without touching the
human-curates principle.

- **`/reflect` gains an optional `--mine` mode**: it adapts
  `reflection-mining.workflow.js` to cluster the reflection corpus, adversarially
  pre-filter each candidate rule ("would this rule have prevented a real past
  mistake?"), and emit a vetted **shortlist** of promotion candidates. The
  default `/reflect` capture behaviour is unchanged.
- **New `REFLECTION_STAGING.md`** (gitignored, regenerated each run) is the sole
  write target — each candidate carries the proposed rule, its source reflection
  fragment(s), and the adversarial verdict/evidence. Mining writes **only** there
  and **never** to `AGENTS.md` (byte-for-byte unchanged); a **human still
  promotes** from staging via the existing `Promoted:` flow (INV-1: agents
  propose, humans curate).
- **`integration-agent`** notes that mining **augments, never replaces** human
  curation — the `Promoted:`-line gate stays the only path into AGENTS.md/HARNESS.md.
- `--mine` requires the Claude Code runtime; without it it degrades to
  guidance-only and never errors. Deterministic structural checks
  (`test_s6_reflection_mining_structural.py`) gate the declared contract.

## 0.62.0 — 2026-06-23

### dynamic-workflows: orchestrator classify-and-act routing (S5, #442)

The largest behavioural slice — deliberately conservative. A classifier front
runs before the pipeline and routes by task type, but only when explicitly
opted in.

- **`orchestrator` gains a "Task classification" step** before the pipeline.
  Non-static routing is **opt-in** via an optional `orchestrator-routing` field
  in HARNESS.md (**default off**); when off — and for ordinary coding tasks and
  any ambiguous classification — the existing **static pipeline runs unchanged
  with no extra compute**. Treat drift toward "everything is a workflow" as a
  regression.
- **Four routes** when enabled: static (ordinary coding), tournament
  (design/naming/taste, rubric-bearing judge), root-cause (debugging/incident,
  ≥3 hypotheses from disjoint evidence + verifier/refuter panel), and triage
  (large backlogs under INV-2 quarantine — untrusted content read by
  low-privilege agents, trusted agents act). Each adapts the relevant
  `*.workflow.js` template.
- **The Plan Approval GATE and `MAX_REVIEW_CYCLES=3` GUARDRAIL hold on every
  route** — routing changes which pipeline runs, never the human-cognition gates.
  Claude-Code-only with a non-erroring static fallback; every route is
  propose-only (INV-1).
- **`/superpowers-status`** surfaces routing posture (opt-in/off-by-default vs
  enabled) and the last route taken when traceable, else `unavailable`.
- Deterministic structural checks (`test_s5_orchestrator_routing_structural.py`)
  gate the declared contract.

## 0.61.0 — 2026-06-22

### dynamic-workflows: adversarial review + deep-research workflows (S4, #441)

Reuses the proven S3 pattern across the four agents most exposed to
self-preferential bias and agentic laziness.

- **`code-reviewer` gains separate-context adversarial review** (D5): for
  non-trivial diffs (default `> 2 files`, configurable via the HARNESS.md
  `fan-out-threshold` field) it adapts `adversarial-review.workflow.js` so the
  reviewer works in a context window distinct from the implementer's, each
  CUPID + literate property checked by a dedicated verifier and findings
  synthesised, not collapsed. `MAX_REVIEW_CYCLES=3` still holds.
  **`advocatus-diaboli`** declares its role as the rubric-bearing adversary,
  read-only trust boundary unchanged.
- **`assessor` and `harness-auditor` gain deep-research mode** (D7): above a
  repo file-count threshold (`> 300`, configurable via the HARNESS.md field)
  they adapt `deep-assessment.workflow.js` to fan out by area, verify each
  finding in a separate agent, and synthesise a cited report. The auditor adds
  a **self-preference guard** — at least one verifier is adversarial to the
  framework's own assumptions, so it cannot grade its own homework. Output stays
  a timestamped artefact in the existing location/format.
- All four are Claude-Code-only with a non-erroring single-context fallback;
  INV-1 precision preserved (the ephemeral workflow proposes; the assessor/
  auditor still write their own report artefacts, which are not the four durable
  curated files). `commands/assess.md` and `commands/harness-audit.md` document
  the large-repo workflow path. Deterministic structural checks
  (`test_s4_adversarial_deepresearch_structural.py`) gate the declared contract.

## 0.60.0 — 2026-06-22

### dynamic-workflows: harness-enforcer fan-out mode (S3, #440)

The highest-leverage slice of the epic — defeats the enforcer's "35 of 50
constraints checked" lazy stop.

- **`harness-enforcer` gains a "Workflow mode" section**: when the enforceable-
  constraint count exceeds a threshold (**default 8, configurable per project
  via an optional `fan-out-threshold` field in HARNESS.md**; strict `>`
  trigger), the enforcer adapts `enforcer-fanout.workflow.js` to spawn **one
  verifier subagent per rule** plus a **skeptic** persona, reconciled at a
  **synthesis barrier** that waits for all N. At or below the threshold the
  single-context path runs unchanged — no workflow, no extra compute.
- **Count-equality guarantee (no silent drop)**: when it reports "all
  constraints checked", verifier results equal the enforceable count (`unverified`
  excluded). The first run records the skeptic's false-positive-reduction
  observation in REFLECTION_LOG.md for human curation — an observation, never a
  CI-verified metric.
- **`verification-slots` SKILL.md** documents the **fan-out slot** as a
  first-class agent-backed slot (one verifier per rule + skeptic + synthesis
  barrier) producing the same pass/fail + `{file, line, message}` contract.
- Workflow mode requires the Claude Code runtime; where it is absent the
  enforcer falls back to single-context behaviour and never errors. Read-only /
  propose-only — never writes a durable artefact (INV-1).
- Deterministic structural checks (`test_s3_enforcer_fanout_structural.py`) gate
  the declared workflow-mode contract in CI.

## 0.59.0 — 2026-06-22

### dynamic-workflows: template library + INV-1/INV-2 firewall (S2, #439)

The runnable substrate for the epic, plus the deterministic teeth that keep it
governed.

- **Four workflow templates** under `skills/dynamic-workflows/workflows/` —
  `enforcer-fanout`, `adversarial-review`, `reflection-mining`, and
  `deep-assessment`. Each is a template to **adapt, never run verbatim**, with a
  literate preamble naming its pattern, token budget, per-role model tiers, the
  INV-1 boundary it respects, and the Claude-Code-only runtime scope. A
  `workflows/package.json` (`type: module`) lets the `export const meta` +
  top-level-await DSL parse as the runtime expects.
- **INV-1/INV-2 firewall** (`scripts/inv-firewall.sh`) — one POSIX-portable
  matcher, invoked two ways: a PR-time gate
  (`.github/workflows/dynamic-workflows-firewall.yml`) and a Layer-0
  deterministic test with red/green fixtures. INV-1 strips comments then fails on
  any durable filename (`HARNESS.md` / `AGENTS.md` / `CLAUDE.md` /
  `MODEL_ROUTING.md`) appearing in executable code — so a literate preamble that
  merely *names* one passes, but a write fails. INV-2 fails if a declared
  `@untrusted-reader` agent's `@tools` names a high-privilege tool (write, edit,
  bash, commit, push). A consequence templates respect: durable artefacts are
  reached only through harness indirection, never spelled in code.
- **`SKILL.md`** flips the template library from "forthcoming (S2)" to shipped,
  referencing all four templates by resolving relative path; the how-to guide
  names them. The S1 markdownlint scenario that forbade template links is
  reconciled to assert the links now resolve.

## 0.58.1 — 2026-06-22

### dynamic-workflows: state the Claude-Code-only runtime scope in the skill

- **`skills/dynamic-workflows/SKILL.md`** gains a "Runtime scope — Claude Code
  only" section: dynamic workflows are a Claude Code runtime capability, **not
  transferable** to GitHub Copilot CLI or other coding agents. The skill is
  knowledge everywhere, runtime only on Claude Code; on a tree without the
  workflow runtime it is guidance only — readable, but no workflow can be
  spawned, and an agent there falls back to its static behaviour rather than
  erroring. Brought forward from S7 so the boundary is clear in the artefact
  agents actually read; the precise Copilot degradation *contract* (guidance-only
  vs omit) remains S7's open question.
- The `dynamic-workflows` how-to guide carries the same runtime-scope note.

## 0.58.0 — 2026-06-22

### dynamic-workflows: foundational skill + election discipline (S1, #438)

First slice of the Dynamic Workflows Alignment epic — the conceptual model the
rest of the epic references.

- **New `dynamic-workflows` skill** (`ai-literacy-superpowers/skills/dynamic-workflows/`):
  `SKILL.md` plus `references/{patterns,when-not-to-use,governance}.md`. Knowledge
  agents read, not a script they run — sibling to `harness-engineering` and
  `context-engineering`. Names the six composable patterns (classify-and-act,
  fan-out-and-synthesize, adversarial verification, generate-and-filter,
  tournament, loop-until-done), each with a worked micro-example.
- **Compute-discipline election rubric** (`references/when-not-to-use.md`): the
  four-question test — long-running, massively parallel, highly structured, or
  adversarial — with the default "if none apply, use the static pipeline", so
  workflows are elected, not reflexive. Advisory guidance, not a CI gate.
- **Governance invariants** (`references/governance.md`): INV-1 (ephemeral
  proposes, durable curates — workflows never write `HARNESS.md` / `AGENTS.md` /
  `CLAUDE.md` / `MODEL_ROUTING.md` directly) and INV-2 (quarantine
  untrusted-content readers from high-privilege tools), restated for agents.
- **`templates/MODEL_ROUTING.md`** gains a *workflow election* section: a
  per-workflow token-budget convention and a model-routing-classifier idea
  (Haiku/Sonnet/Opus tiering).
- **Docs**: new how-to guide and `### dynamic-workflows` reference entry; skill
  count reconciled to 36 (badge, plugin table, tree). Workflow *templates* and
  the INV-1 CI firewall are deferred to S2 (#439); SKILL.md only forward-references
  them.

## 0.57.0 — 2026-06-17

### planning: dynamic-workflows-alignment epic spec + carpaccio slicing (#438–#444)

Saved the Dynamic Workflows Alignment design (D1–D9) as the umbrella spec
(`docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`) and
sliced it into seven independently-shippable pieces via carpaccio rather than
landing it as one big change. Recorded human dispositions (all accepted) and
resolved three of four open questions (D3 threshold = 8; D4 routes opt-in for
v1; D6 staging = new `REFLECTION_STAGING.md`); Copilot degradation deferred to
the S7 build. Filed issues #438–#444, one per slice, in §6 dependency order.
Docs/planning only — no plugin change.

### harness: declare a cross-OS Layer 0 constraint (reflection follow-up)

Reflection from the affordances epic surfaced a recurring BSD-vs-GNU shell
portability trap in deterministic check scripts (`grep '\|'` is BSD-literal and
masked locally by the harness's `grep`→`ugrep` alias; `date -u -j -f` does not
pin UTC midnight on BSD). Declared a new `unverified` HARNESS.md constraint —
**Layer 0 bash tests run on macOS and Linux** — whose promotion to
`deterministic` is adding a `macos-latest` leg to the TDAD fast-suite matrix.
(Repo HARNESS.md only — no plugin change.)

### affordances: runtime invocation recorder + dead-inventory analyzer (#203)

Sequencing step 7 — the affordance section's runtime backbone.

- **`hooks/scripts/affordance-invocation-recorder.sh`** — a PostToolUse hook
  (registered in `hooks.json`) appending one minimal NDJSON tuple per `Bash` /
  `mcp__*` call to the gitignored `observability/affordance-invocations.json`.
  Built-in file tools are not recorded. **Privacy is enforced, not just
  declared**: the Bash `program` field strips env-var prefixes (`GH_TOKEN=…
  gh` → `gh`), `basename`s paths (`/a/b/deploy.sh` → `deploy.sh`), and accepts
  only a clean `^[A-Za-z0-9._-]+$` shape — no arguments, paths, secrets, or
  user identity. Uses grep/sed (no jq), never blocks, self-trims to 5000 lines.
- **`scripts/harness-affordance-invocations.sh`** — a report-only analyzer:
  `--check=freshness` (is the recorder operating?) and `--check=dead-inventory`
  (each declared, non-example, **non-hook** affordance observed within N days?).
  Bash matching is program-coarse and **conservative** (an observed program
  marks every Bash affordance sharing it as observed — a false-alive, never a
  false-dead); MCP/named matching is exact. Hermetic via `--today`; tolerates
  any malformed NDJSON line.
- **Local, per-machine.** The data file is gitignored (the user-confirmed
  answer to cross-machine merge), so the two GC rules and the checks are
  **local observability via `/harness-gc`, not CI governance** — stated
  honestly. A reference page documents the stable tuple format.
- Spec-mode `/diaboli` raised 12 objections (6 high), all adjudicated before
  implementation: keep the `.json` filename (the existing reference), sanitise
  the Bash program token so the no-secrets guarantee is real, recorder uses
  grep/sed (no jq silent-no-op trap), exclude hooks from dead-inventory, and
  frame the gitignored consequence honestly.

## 0.56.0 — 2026-06-16

### affordances: review subcommand + staleness GC rule (#202)

Sequencing step 6 of the harness-affordances epic — the per-affordance
staleness loop.

- **`/harness-affordance review <name>`** — interactive re-validation that
  bumps `Last reviewed` to today **only if all three checks pass** (Identity,
  Audit trail, Permission), each with an explicit `yes / no / needs-edit`
  prompt. A bump after any edit requires re-answering all three; a failing
  check leaves the date and records a single idempotent `[review-gap: <check>]`
  Notes line. Inline edits follow the same human-dictates/command-transcribes
  discipline as `add`.
- **`scripts/harness-affordance-staleness.sh`** — a deterministic, report-only
  scanner that flags non-example affordances (hooks **included**) whose
  `Last reviewed` is older than the threshold, or undated. UTC-normalised age
  (`--today` makes it hermetic). Threshold precedence: `--max-age-days` flag >
  a human-owned `<!-- affordance-review-threshold-days: N -->` marker the
  scanner reads from HARNESS.md > default 180.
- **Weekly GC**: a `gc.yml` step runs the scanner, prints findings to the step
  summary, and emits a `::warning::` when any exist (self-skips with no
  `## Affordances` section) — so the rule genuinely runs on the cron, not only
  via `/harness-gc`. A matching template GC rule (commented opt-in) covers the
  on-demand agent path.
- **Layer 0 tests** over the scanner (stale/fresh/undated, hook inclusion,
  example skip, threshold override, marker read, UTC determinism).
- Spec-mode `/diaboli` raised 10 objections (3 high), all adjudicated before
  implementation — the load-bearing fix wired the rule into `gc.yml` (a
  template GC rule alone is never run by the hardcoded cron) and made the
  scanner read the threshold from HARNESS.md rather than only a CLI flag.

## 0.55.0 — 2026-06-16

### affordances: chained constraints — declaration-vs-enforcement loop (#201)

Sequencing steps 4+5 of the harness-affordances epic: the asymmetric
constraint pair that checks the `## Affordances` section against the
permissions allowlist.

- **`scripts/harness-affordance-check.sh`** — one deterministic `shell + jq`
  script, two directions: `--direction=blocking` (affordance-without-
  permission, exits 1 on a gap) and `--direction=advisory` (permission-
  without-affordance, warns, always exits 0). Matching is **string equality**
  on the permission pattern.
- **Two-condition gate.** The check is `unverified` (exit 0, no-op) unless
  the section has a real (non-example) affordance **and** a project
  permissions allowlist is readable — so it never fires on un-migrated
  adopters or in CI without a committed allowlist. Example entries (marked
  `<!-- affordance-example -->`) and hook-mode affordances are skipped.
- **Two constraint entries** in the HARNESS.md template's `## Constraints`
  (commented opt-in, `Scope: pr`); adopters pick them up via
  `/harness-upgrade`. The step-3 example entries gain the per-entry marker.
- **Layer 0 tests** exercise all acceptance scenarios against hermetic
  fixture directories (the check takes a project-dir argument).
- Spec-mode `/diaboli` raised 12 objections (1 critical, 4 high); all
  adjudicated before implementation — the critical caught that hook
  affordances would false-fire the blocking check (now skipped), and the
  enforcement model (pr scope, honest self-gating) was user-confirmed.

## 0.54.0 — 2026-06-16

### affordances: HARNESS.md section + guided `/harness-affordance add` (#200)

Sequencing step 3 of the harness-affordances epic makes the discovery
scanner's inventory a first-class part of the harness.

- **`templates/HARNESS.md` `## Affordances` section** — a top-level section
  (after Garbage Collection, before Status) carrying the field schema in
  comments, a reference to `observability/affordance-invocations.json`, and
  four worked example entries (cli, central-mcp, current-user cli, hook).
- **`/harness-affordance add <name>`** — replaces the stub with a guided
  flow: seed from the newest discovery draft (matched by permission pattern),
  prompt for the governance fields (Identity with five-value framing, Audit
  trail with "none is fine" guidance), auto-date `Last reviewed`, validate
  (required fields, Mode/Trigger pairing, permission existence across project
  **and** user settings — warn, not block), and write idempotently. Re-runs
  edit in place keyed on the **permission pattern**, not the heading name, so
  a rename never duplicates an entry.
- **`/harness-init`** gains Affordances as a sixth, opt-in (default off)
  feature; **`/harness-status`** counts declared affordances.
- **Docs** — new explanation (the contractor scenario, identity as the
  load-bearing field, the source-of-truth split) and reference (field-by-
  field schema) pages; the discover how-to updated for `add`.
- **Tests** — a Layer 0 test validates the template's example entries against
  the schema (required fields, Mode/Trigger pairing, date format).
- Spec-mode `/diaboli` raised 12 objections (3 high); all adjudicated before
  implementation (idempotency keys on permission pattern; `add` reads user
  settings; concrete init integration; direct-write confirmed).

## 0.53.3 — 2026-06-16

### docs: exploration findings for microsoft/AI-Engineering-Coach (#340)

Investigation-only findings doc at
`docs/superpowers/explorations/2026-06-16-ai-engineering-coach-findings.md`
mapping the MS project's concepts to our surfaces. Key framing: MS coaches
from *behavioural* session-log evidence, we assess from *habitat* artifacts —
so most features have a mature analog here and the additive ideas are the
behavioural ones. Recommends five follow-ups (R1 behavioural lens, privacy-
gated; R2 mine their rule taxonomy; R3 agentic-readiness checklist; R4
skill-finder angle; R5 decline gamification) and flags MIT attribution rules.

### compound learning: promote three dispositioned findings (#339, #347, #348)

Curation pass landing three choice-cartographer findings that the human had
already dispositioned `promoted`, turning recurring lessons into standing
guardrails (no plugin version bump — convention files only).

- **#339** → `CLAUDE.md` Marketplace Versioning: a cross-PR coordination rule
  for `marketplace.json`'s `plugin_version` (owned by `ai-literacy-superpowers`
  PRs; non-owning PRs take main's value verbatim). Specs can now reference the
  convention instead of restating the merge-time rule per spec.
- **#347** → `AGENTS.md` ARCH_DECISIONS: "schema evolution routes by fact
  granularity" — per-element facts use a per-element field with a string
  prefix; model-level facts earn an additive wrapper field; audit entries keep
  a single writer.
- **#348** → `AGENTS.md` ARCH_DECISIONS: "dispatcher-first error contracts for
  agent output" — structured output for programmatic consumers must spec a
  single-line, pattern-matchable refusal shape emitted instead of the success
  block, with no silent fallback (third-occurrence promotion).

### auto-enforcer: record deterministic results without source interpolation (#424)

The `Run deterministic constraints` step in `templates/ci-auto-enforcer.yml`
built a `python3 -c "…"` body by shell-interpolating each tool's stdout into
a triple-quoted Python literal. Any tool that printed `'''` (or other quote
characters) terminated the literal early and raised a `SyntaxError`, failing
the whole step — so a tool that **passed** could still break the run, and the
interpolation was a latent injection vector.

- The step now uses the same safe heredoc-argv pattern as the agent and
  comment steps: a single-quoted heredoc (no shell expansion) with the
  results file, name, status, and tool output passed via `sys.argv` *after*
  the source is parsed, so no character in tool output can corrupt the script.
- Layer 0 coverage added: tool stdout containing `'''`, `"`, `"""`, and
  shell-like `$(…)` text is recorded verbatim; a PASS result records `--`.
  Verified to SyntaxError against the pre-fix interpolation form (RED→GREEN).

## 0.53.2 — 2026-06-15

### auto-enforcer: four PR-enforcement bug fixes (#322, #323, #324, #325)

Four defects in `templates/ci-auto-enforcer.yml` quietly degraded PR-time
constraint enforcement for every adopter of the GitHub Action.

- **#325 — duplicate constraint rows.** The constraint parser appended
  the final block at section exit **and** again at the EOF flush, so any
  `HARNESS.md` with a `##` section after `## Constraints` ran (and listed)
  its last constraint twice. The section-exit path now resets state and the
  trailing flush is gated on still being inside the section.
- **#324 — truncated multi-line rules.** `parse_field` returned only the
  first physical line of a `Rule:`, so multi-paragraph agent constraints
  reached the model half-stated (the agent even reported the rule as
  "incomplete"). It now folds continuation lines until the next list item.
- **#323 — COMMENT_MODE never applied.** `comment_mode = "${COMMENT_MODE}"`
  inside a single-quoted heredoc was a literal string, so `findings-only`
  never suppressed all-PASS comments. The value is now passed as a
  positional argv. `SKIP` also counts as a finding so a silently-disabled
  gate still surfaces a comment.
- **#322 — no retry on transient overload.** A single `urlopen` with a
  broad `except` turned an Anthropic `429`/`529` into a `SKIP`pped
  enforcement gate. Agent calls now retry transient overloads with backoff
  (2s, 4s), retry one network error, and fail fast on non-transient HTTP
  errors; a half-second pace between agent calls flattens the burst.
- **Tests.** New Layer 0 suite (`test-auto-enforcer.sh`) extracts the real
  embedded Python from the template and exercises all four fixes — nine
  cases, verified to fail against the pre-fix template (RED→GREEN).

## 0.53.1 — 2026-06-15

### reflections: verify_rhs recognises CLAUDE.md + .claude/HARNESS.md promotions (#319, #320)

`verify_rhs` (the Path 1 archival pre-check) rejected valid, documented
promotion forms, so `archive-promoted-reflections.sh` kept those entries
in the active set forever.

- **#320 — HARNESS path resolution.** The check hard-coded `HARNESS.md`
  at the repo root, but the plugin's own `/superpowers-init` scaffolds to
  `.claude/HARNESS.md`. A canonical `Promoted: → HARNESS.md: <constraint>`
  line therefore never verified in projects that follow the recommended
  layout. A new `resolve_file` helper now resolves the constraint heading
  against the repo root **or** the `.claude/` scaffold; `propose_for_entry`
  uses the same resolution.
- **#319 — CLAUDE.md and explicit .claude paths.** Promotions to
  `CLAUDE.md` (root or per-component `<subdir>/CLAUDE.md`) and the explicit
  `.claude/HARNESS.md: <constraint>` form fell through to a rejection.
  `verify_rhs` now models a `CLAUDE_FORM` (verifies the quoted excerpt in
  the named CLAUDE.md) and accepts the `.claude/HARNESS.md:` alias. The
  formal grammar in the archival spec and the RHS-form lists in `/reflect`
  and the integration-agent are updated to match.
- Layer 0 coverage added: eight `verify_rhs` unit cases plus an end-to-end
  archival case proving a `.claude/HARNESS.md`-only project archives.

## 0.53.0 — 2026-06-15

### reflections: one-file-per-entry storage + union-merge default (#398)

`REFLECTION_LOG.md` was a single, shared, append-only file. Every
reflection PR appended at the same EOF location, so any two PRs cut from
the same base conflicted at the same spot — and when that conflict was
resolved against an already-merged block, a committed reflection was
**silently dropped** (the PR merged green and the entry simply wasn't on
`main`). This was an emergent property of the storage design, observed
downstream, not a one-off mistake.

- **Source of truth is now per-entry fragments.** `/reflect`, the
  integration-agent, and the assessment skill write each reflection as
  its own file under `reflections/active/<YYYY-MM-DD>-<slug>.md` (body
  only, no leading `---`). Two reflections authored concurrently never
  touch the same path, so the append-contention — and the silent-drop
  failure — disappears at the source.
- **`REFLECTION_LOG.md` becomes a generated aggregate.** It stays
  committed (like a lockfile) and is deterministically regenerated from
  the fragments in Date order by the new
  `scripts/regenerate-reflection-log.sh`, so all existing readers
  (agents, GC rules, health/status commands, observability) keep working
  unchanged. A messy interim union merge self-heals on the next
  regeneration because the fragments are canonical.
- **Union-merge default shipped.** A root `.gitattributes` (and a
  `templates/gitattributes` scaffolded by `/superpowers-init`) applies
  git's built-in `merge=union` driver to `REFLECTION_LOG.md` and
  `reflections/archive/*.md`, so even an un-migrated monolith or two
  concurrent GC runs can never drop content.
- **Archival preserved on fragments.** `archive-promoted-reflections.sh`
  now moves promoted fragments to `reflections/archive/<YYYY>.md`,
  deletes them, and regenerates the aggregate; the Promoted-line grammar
  and archive format are unchanged. The weekly GC workflow counts and
  commits fragments instead of monolith entries.
- **One-time migration.** New `scripts/split-reflection-log.sh`
  (idempotent) splits an existing monolith into fragments and
  regenerates the aggregate, preserving Promoted lines and the existing
  archive. This repo's own 49-entry log was migrated as part of this
  change (verified lossless: all 591 content lines preserved).

## 0.52.1 — 2026-06-15

### gc-rotate: scope shell-script GC rules to project-owned files (#361)

The rotating GC check's shell-syntax (rule 2) and strict-mode (rule 3)
rules scanned **every** `*.sh` under the project, excluding only
`*/.git/*`. In non-trivial projects this pulled in vendored, generated,
and untracked scripts and flooded the session-end banner with
false positives — `bash -n` choking on `zsh` snapshots written under
`CLAUDE_CONFIG_DIR`, `node_modules` scripts, and nested worktrees that
were never meant to follow this plugin's conventions.

- **Scope to tracked files.** Both rules now enumerate scripts via a new
  `list_owned_shell_scripts` helper that uses `git ls-files -z -- '*.sh'`,
  which skips `node_modules`, nested worktrees, `CLAUDE_CONFIG_DIR`
  snapshots, and build output for free. Paths are re-anchored to
  `PROJECT_DIR` and the loops read NUL-delimited entries so paths with
  spaces survive.
- **Graceful fallback.** Outside a git repo the helper falls back to the
  previous `find` walk, so non-git projects are unaffected.

## 0.52.0 — 2026-06-15

### cost-estimation: single-source the family stem table + deterministic drift guard (#414)

Keeps the v0.50.0 tier→model family stems (`claude-opus-4`,
`claude-sonnet-4`) **singly-sourced and internally consistent** as model
generations roll over.

- **Declared canonical source.** The binding table in
  `skills/cost-estimation/references/estimate-record-format.md` now carries
  an authoritative, parseable `canonical-estimating-tier-family-stems`
  block — the single source the other cost files reference.
- **Add-and-retire maintenance note** (not replace-in-place): a new
  generation **adds** a stem (both coexist while transition snapshots may
  carry either — consistent with cross-generation family aggregation); a
  stem is **retired** only when no snapshot in the retention window carries
  its family; never silently replaced (which would regress a
  transition-quarter snapshot to omission).
- **Deterministic drift guard.** A CI-gated Layer-1 structural test
  (`tdad_tests/tests/test_layer1_structural.py`,
  `TestCostEstimationStemConsistency`) asserts that no consumer cost file
  references an estimating-tier family stem absent from the canonical set
  (every `claude-opus-*`/`claude-sonnet-*` family token must resolve, by
  the delimiter-bounded stem rule, to a declared stem; documented
  delimiter counter-examples like `claude-opus-40` are exempt). A future
  stem bump that desyncs the files fails CI loudly.

**Design pivot (spec-mode diaboli).** The slice originally proposed a
periodic GC staleness rule reading the latest snapshot; the diaboli refuted
it (false-positive every cheap-tier-only month; false-negative on a
*staggered* rollover; the agent has no stem logic; only the rule's
existence was testable) and noted external staleness is already covered by
the loud disclosed omission/proxy of #412 and #413's capture-time
advisory. The human disposed the design to **drop the GC rule** and ship
the deterministic
mention-consistency check + canonical source instead. Option 2 (derive
stems from `MODEL_ROUTING.md`) was rejected — its only family names are
illustrative HTML-comment examples; routing uses abstract tiers.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-15-cost-estimation-stem-table-maintenance-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/cost-estimation-stem-table-maintenance-design.md`
(12 objections — 5 high — all accepted). Closes #414.

## 0.51.0 — 2026-06-15

### cost-capture: capture-time binding-gap advisory (#413)

`/cost-capture` now tells the human, **at capture time**, whether the
prospective `cost-estimation` sibling will be able to ground a dollar
figure against the snapshot just written — closing the binding-gap
feedback loop one step earlier than the per-estimate discovery #411
suffered.

- **Informational, never a gate.** A new advisory step (after structural
  validation, before commit) emits no pass/fail token, never alters the
  snapshot's cost data, and runs regardless of the validation result. A
  thin snapshot remains a perfectly valid cost snapshot.
- **A thin family-presence check, not a pricing re-run.** It applies the
  `cost-estimation` binding table's family-stem + delimiter rule **by
  reference** to detect which estimating-tier families (`claude-opus-4` /
  `claude-sonnet-4`) are present — it does **not** re-implement
  aggregation, rate derivation, or proxy selection (those stay
  estimator-only, so there is no second copy of the pricing logic).
- **A structured, checkable artefact.** The outcome is recorded as a
  `Cost-estimate grounding:` line in the snapshot's `## Observations`
  (and echoed in the capture summary): `grounds` / `proxied (<absent
  tiers>)` / `omitted (no estimating-tier family)` / `omitted (no
  per-model breakdown)` — so the advisory is falsifiable and a consumer
  can corroborate it.
- **Conditional, honest wording.** Proxy advisories are conditioned on a
  future target *exercising* the absent tier; the no-estimating-family
  case is the unconditional "will omit". The advisory distinguishes
  *thin because data wasn't recorded* (actionable) from *thin because the
  period genuinely used only some tiers* (not a defect) and **never**
  nudges fabricating a model row for spend that did not occur.

Touches `commands/cost-capture.md` and `skills/cost-tracking/SKILL.md`
(the snapshot format gains the `Cost-estimate grounding:` Observations
line and an estimating-tier-coverage pointer). Pure consumer of the
v0.50.0 family-stem rule — no binding, proxy, or format-field change.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-15-cost-capture-binding-gap-warning-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/cost-capture-binding-gap-warning-design.md`
(10 objections — 3 high — all accepted; the highs reshaped it to a thin
presence check writing a structured, falsifiable line). Closes #413; the
stem-table-maintenance sibling is #414.

## 0.50.0 — 2026-06-15

### cost-estimation: tier→model family matching + disclosed cross-tier proxy (#411)

Fixes the silent cost-omission #411 surfaced: the cost-estimation binding
matched representative model keys **literally** (`claude-opus-4`,
`claude-sonnet-4`), but real snapshots key their Model Breakdown by the
**actual** model ids (`claude-opus-4-8`, …), so every estimate omitted
cost even when a snapshot existed to ground it.

- **Family matching (the core fix).** A snapshot key now resolves to a
  tier's representative **by family stem** — it matches iff it starts with
  the stem (`claude-opus-4` / `claude-sonnet-4`) **and** the next character
  is `-` or end-of-string (so `claude-opus-4-8` → Most capable;
  `claude-opus-40` does **not** match). Multiple rows in one family
  aggregate into one blended rate, disclosed when >1. Only
  `claude-opus-4` / `claude-sonnet-4` are estimating-tier families; haiku
  and others bind to no tier. The stems are a maintained table (bumped per
  model generation); a renamed family is a *signalled* miss (omission),
  never a silent wrong rate.
- **Disclosed cross-tier proxy (Option B′).** When an exercised tier's
  family is **absent** but ≥1 estimating-tier family resolves, the missing
  tier is **priced by a proxy** at the dearest present family's rate rather
  than omitted — but as a **distinctly-typed, disclosed** figure: a new
  additive `cost_basis` value **`snapshot-actuals-proxied`** (machine-
  distinguishable from direct `snapshot-actuals`), with
  `failure_direction: likely-overrun` and `confidence.cost: low` forced and
  every proxied tier named. The proxy uses only observed snapshot rates —
  never a vendor list price (the no-list-price-fallback rule is intact).
- **Validator changes.** The `cost_basis` enum gains
  `snapshot-actuals-proxied`; the "Split-tier spread" check exempts a
  proxied (`snapshot-actuals-proxied`) split-tier band from the strict
  `low < high` requirement (a cross-tier proxy legitimately collapses it);
  the cost-pairing check requires a proxied record to carry the forced
  overrun/low-confidence/disclosure trio. The three grounding states /
  closed omission set are restated under family resolution.

Touches the format reference (`skills/cost-estimation/references/estimate-record-format.md`),
the skill (`skills/cost-estimation/SKILL.md`), and the `cost-estimator`
agent in lockstep.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-15-cost-estimation-family-matching-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/cost-estimation-family-matching-design.md`
(12 objections — 2 critical, 4 high — all accepted; the two criticals
broke the naïve proxy and drove the engineered Option B′). Closes #411.

## 0.49.0 — 2026-06-14

### cost-estimator: populate per-stage cost_usd bands on cost-present records

- **Per-stage `cost_usd` bands (#380).** Now that the repo has a usable cost
  snapshot (`observability/costs/2026-06-13-costs.md`), the cost-estimator
  emitter honours the #377 §4.3.1 SHOULD obligation: on a **cost-present**
  record it populates a `tokens_by_stage[].cost_usd` `{ low, high }` band on
  every exercised stage (stage `tokens` × tier `$/token`), with split-tier
  stages priced cheaper-at-low / dearer-at-high so the spread is strictly
  positive (`low < high`). Cost-omitted records are unchanged (no per-stage
  band; the one-directional coupling forbids a band without the whole-record
  `cost_usd`). The pricing convention is referenced from the format spec, not
  redefined; no format change and no new validation-rejection rule. Behaviour
  change to a shipped agent — minor bump. Spec:
  `docs/superpowers/specs/2026-06-14-per-stage-cost-bands-emitter-design.md`.

## 0.48.1 — 2026-06-14

### cost-estimator: normalise the split-tier model_tier literal

- **Consistent `Standard/Capable` literal (#381).** The cost-estimator agent
  charter referred to the split tier as `Standard / Capable` (spaced) in its
  Split-tier widening note while the format reference binding table records the
  literal as `Standard/Capable` (unspaced). Normalised the charter to the
  unspaced form so an exact-string consumer of `model_tier` sees one emitted
  shape. The whitespace-insensitive comparison note (which deliberately shows
  both forms are equivalent) is unchanged. Doc-only; patch bump.

## 0.48.0 — 2026-06-14

### Reservoir warden — watching the verifier the harness cannot verify

The framework's first observability surface aimed at the **human verifier**
rather than the session output. Every other enforcement mechanism checks what
an agentic session produced; none checked the state of the human who approves
it. This adds a read-only, advisory watch — opt-in per project, never a gate.
New skill + agent + command + hook — minor bump.

- **`cognitive-reservoir` skill (new).** The shared grounding: four observable
  proxies (session span, decision volume, context switches, wall-clock hour),
  the `observed`/`inferred`/`asked` confidence discipline, disjunctive default
  thresholds (span 180 min, decision volume 8, context switches 4, window 8 h),
  the one firm principle, six-level scaling, and the honesty rule that keeps
  contested science (ego depletion, the hungry-judges study) out of the
  mechanism's assertions while standing on the robust basis (vigilance
  decrement, task-switching cost).
- **`reservoir-warden` agent (new).** Read-only on the human (tools: Read,
  Glob, Grep, Bash — no Write, no Edit). Counts the proxies via `git`/`date`,
  reports each with a confidence flag, and offers the single
  decide-your-stop-first recommendation when a threshold is crossed. Persists no
  record of the human's state; produces no combined fatigue score. Routed to an
  inexpensive tier in `MODEL_ROUTING.md`.
- **`/reservoir` command (new) + Copilot prompt.** Read mode dispatches the
  agent for a fuller read; Tune mode helps you edit the HARNESS.md block
  (thresholds and an optional `chronotype`), proposing edits to confirm.
- **`reservoir-check.sh` Stop hook (new).** Self-gates on an active
  `## Cognitive reservoir` heading and a git repo, computes the proxies over the
  recent window, and emits at most one `{"systemMessage": ...}` advisory.
  Advisory-only: never blocks, never exits non-zero, never asserts ego depletion
  or the hungry-judges figure.
- **HARNESS template (updated).** Ships an optional, commented `Cognitive
  reservoir` block (inert until uncommented) with the `chronotype` field and a
  not-a-constraint note.
- **AGENTS.md ARCH_DECISION (new).** Records that the verifier-watch is
  advisory-only and must never be promoted into a CI gate or a single fatigue
  score, so a future contributor does not "improve" it into one.
- **Docs + TDAD.** New explanation and how-to pages, reference entries for the
  new skill/agent/command/hook, and four TDAD scenarios (read-only boundary,
  fires-on-long-session, silent-when-quiet, silent-when-not-opted-in); the test
  runner gains hook-component discovery.

## 0.47.0 — 2026-06-12

### Calibration loop — per-PR actuals capture (S6 of the cost-estimator pipeline)

Closes the calibration seam S1 deliberately left open: the estimator now learns
from **this repo's own history** instead of only the generic `MODEL_ROUTING.md`
budgets. The final slice of the cost-estimator pipeline. New integration-agent
responsibility + new actuals format + calibration ingestion — minor bump.

- **Per-PR actuals format (new).** A single-task, structural sibling of the
  quarterly provider snapshot, owned by the `cost-tracking` skill
  (`references/per-pr-actuals-format.md`) and stored under
  `observability/costs/per-pr/`. Captures which stages ran, review cycles, files
  and languages touched, plus token/cost figures **when a human supplies them**.
- **Integration-agent capture (new Step 1a).** At integration time — after the
  CHANGELOG, before the commit, so the record **ships in the PR** and never
  commits to `main` — the integration-agent auto-captures the structural facts and
  records human-supplied `/cost` figures, marking them `unavailable` otherwise.
  **Non-blocking and never fabricates a figure**: a subagent can't read per-PR
  tokens programmatically, and the repo's no-fabrication rule forbids inventing
  them, so `unavailable` is explicit and is never `0`.
- **Calibration ingestion — token ranges only.** The `cost-estimation` methodology
  and the `cost-estimator` agent now read accumulated per-PR records as a
  `kind: calibration` grounding source to **narrow the per-stage token ranges**
  (and may raise the `tokens` confidence) against repo history, disclosed in
  `Confidence rationale`. The `$/token` ground stays the snapshot
  (`cost_basis: snapshot-actuals`) — calibration refines tokens only.
- **No estimate-record format change.** True to the S1 seam, calibration ships as
  the already-permitted `kind: calibration` `grounding_sources[]` entry plus a
  disclosure — no field added, removed, or retyped. Zero history degrades cleanly
  to the pre-S6 generic-budget behaviour.
- **Docs** — the prospective-cost-estimation concept page gains a calibration-loop
  section; the cost-tracking skill documents its two actuals records (quarterly
  snapshot + per-PR).

## 0.46.0 — 2026-06-12

### Orchestrator T0 pre-carpaccio ballpark (S5 of the cost-estimator pipeline)

Adds the earliest, weakest insertion point: a coarse whole-task cost **ballpark**
from raw task text only, surfaced **before carpaccio** as a non-blocking go/no-go
sniff-test. Completes the T0/T1/T2 insertion picture (T1/T2 shipped in 0.45.0).
Behavioural change to the orchestrator agent — minor bump.

- **T0 (new Step 3 of "Before dispatching carpaccio").** After branch and issue
  creation and immediately before carpaccio, the orchestrator dispatches the
  `cost-estimator` **once** against the issue body as an inline `task-text` target
  (the `low` confidence ceiling) and surfaces a **loud low-confidence** ballpark
  framed as a "sniff-test, not an estimate to plan against".
- **Inline-only and ephemeral — a deliberate asymmetry with T1/T2.** T0 writes
  **no file** and runs **no checkpoint**, and is **not** threaded into the context
  object. The gate-folded T1/T2 estimates persist (decision-support with audit
  value); the earliest, least-accurate sniff-test stays ephemeral so a
  low-confidence raw-text number never reads as an authoritative artefact — the
  structural answer to the anchoring risk the slice flags.
- **Non-blocking, no gate, no verdict.** T0 adds no pause, no keypress, and no
  go/no-go prompt; the orchestrator proceeds to carpaccio regardless. A `REFUSED:`
  string or a dispatch error surfaces "T0 ballpark unavailable" and the run
  continues exactly as today.
- **Pure consumer of S1/S2.** No change to the estimate-record format, the
  `cost-estimator` agent, or the `/cost-estimate` command.
- **Docs** — the prospective-cost-estimation concept page now describes the full
  T0/T1/T2 picture with the inline-only-vs-persisted asymmetry; the
  agent-orchestration page notes the pre-pipeline ballpark.

## 0.45.0 — 2026-06-12

### Orchestrator cost fold-in at T1 and T2 (S4 of the cost-estimator pipeline)

Wires the read-only `cost-estimator` agent into the orchestrator's **existing**
human-disposition gates as **informational fields, never a new gate**. The
highest-value insertion the carpaccio slicing record names — cost surfaces at the
moment it most changes a choice. Behavioural change to the orchestrator agent —
minor bump.

- **T1 — Slice Adjudication gate (new Step 2a).** After carpaccio's record is
  validated and before it is surfaced, the orchestrator dispatches the
  `cost-estimator` **once per slice in parallel** (explicit `target_kind: slice`),
  persists each returned record under `cost-estimates/<date>-<task-slug>-<slice-id>-estimate.md`,
  runs the S3 Output Validation Checkpoint on each, and appends a **compact
  one-line-per-slice** cost summary (tokens, cost-or-"not grounded", confidence,
  failure direction) to that slice's block — so the human sees cost while choosing
  which slice to progress.
- **T2 — Plan Approval gate (new Step 6a).** After the choice-story soft gate and
  before the Plan Approval prompt, the orchestrator dispatches the estimator
  **once** against the progressed slice's spec (explicit `target_kind: spec`, the
  pipeline's highest confidence ceiling), persists + validates it, and surfaces a
  fuller cost block (tokens, agent-compute time, cost, **verbatim `human_gate_time`
  caveat**, excluded pointer) alongside `cartograph_pending_count`.
- **Informational, never a decision point.** Both fold-ins mirror the existing
  `cartograph_pending_count` treatment: no block, no extra keypress, no agent
  writes dispositions. The estimate carries no recommendation or verdict; the
  human reads the ranges and disclosures and makes the **existing** slice /
  plan-approval choice.
- **The gate never degrades.** A `REFUSED:` string, a dispatch error, or a
  checkpoint abort reduces the affected target's estimate to "unavailable" and the
  existing gate proceeds exactly as today — the estimate is purely additive.
- **Pure consumer of S1/S2/S3.** No change to the estimate-record format, the
  `cost-estimator` agent, or the `/cost-estimate` command. The orchestrator owns
  the write (the agent stays read-only) and reuses the S3 persistence + checkpoint
  discipline by reference. New context-object fields (`t1_estimate_slugs`,
  `t1_estimate_refused_count`, `t2_estimate_slug`, `t2_estimate_grounded`) make the
  estimate state readable by observability tooling.
- **Docs** — the prospective-cost-estimation concept page's "future orchestrator
  fold-in" forward-reference is now present-tense; the agent-orchestration
  explanation page notes the fold-in at both gates.

## 0.44.0 — 2026-06-12

### New command — `/cost-estimate` (S3 of the cost-estimator pipeline)

Ships the standalone manual dispatcher for the read-only `cost-estimator` agent —
the **prospective** sibling of the retrospective `/cost-capture`. New command —
minor bump.

- **`/cost-estimate <target> [--kind <target-kind>] [--out <dir>]`** — point it at
  a slice, a spec, a slicing record, or pasted task text and it estimates the
  target's tokens, agent-compute time, and (only when a cost snapshot grounds it)
  cost, then writes the estimate record to disk. One target per invocation
  (matching the agent's one-target-per-dispatch contract); path vs inline text
  resolved by filesystem lookup; `--kind` forwards an explicit `target_kind` to the
  agent; the `--near` sketch is dropped. The command is a **pure consumer** of the
  S2 agent and the S1 format reference — it redefines neither.
- **Dispose-then-write ordering** — the command owns the single `Write`; the agent
  stays read-only. The human disposition (`accept` / `edit` / `re-run` / `abort` —
  the full vocabulary) **precedes** the write. On `REFUSED:` the refusal is
  surfaced verbatim with no checkpoint and no file.
- **Output Validation Checkpoint** — reads the returned record back and checks it
  against every line of `estimate-record-format.md`'s validation checklist
  (including the #377 per-stage cost coupling and split-tier strict-spread checks),
  **fixing only structural-only deviations in place** (routinely just deleting a
  stray verdict field) and **aborting — never authoring — on any derived-value
  defect**. The review summary surfaces a change-list of exactly what was altered,
  flags a human-asserted `--kind` as asserted-not-inferred, and honours the
  grounding-path trailing-slash sentinel in its own summary consumption. The `edit`
  path is validate-and-report, never silently reverting a human edit.
- **Output home** — default `cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md`,
  a new top-level directory **outside** `observability/` (predictions are not
  telemetry); `--out` overrides the directory; same-day collisions are
  disambiguated under both, never silently overwritten. `cost-estimates/` is added
  to `.gitignore` as a derived, regenerable artefact.
- **Docs and discipline** — `/cost-estimate` joins the CLAUDE.md Output Validation
  Checkpoints list; a how-to guide and a reference-page entry ship in the same PR.
- **Code-mode adversarial hardening** — eight `advocatus-diaboli` code-mode
  objections closed executor-latitude seams in the command prose: the
  `<target-slug>` is sanitised to a single `[a-z0-9-]` path segment
  (write-target-injection closed); `REFUSED:` detection is anchored to the
  untrimmed first line; a pre-classification test routes a *stray verdict field*
  to FIX and a *prose verdict* to ABORT (so the checkpoint never edits the agent's
  judgment); the change-list is a diff of the retained original, not a narration;
  the checkpoint takes an explicit `fix-in-place | validate-and-report` mode; and
  the same-day collision is re-checked at write time (TOCTOU gap closed).

## 0.43.0 — 2026-06-11

### Format revision — per-stage `cost_usd`, `generated_by` grammar, grounding-path sentinel

Ships the format-revision slice (#377): a backward-compatible revision of the
`cost-estimation` skill's estimate-record format reference, resolving three
deferred residues from the S1/S2 reviews. Format/schema change to a plugin
reference file — minor bump. No new skill, agent, or command.

- **Per-stage `cost_usd` sub-field** — `references/estimate-record-format.md`
  gains an optional `tokens_by_stage[].cost_usd` `{ low, high }` range,
  **one-directionally coupled** to top-level `cost_usd` (sub-field present ⟹
  top-level present is enforced; top-level present ⟹ bands SHOULD be populated
  is an emitter obligation, not a rejection rule — **not** an `iff`, so S1-era
  cost-present records without bands stay valid). Makes a split-tier band's
  non-collapsed (strictly-spread) shape record-internally checkable.
- **Two new validation-checklist lines** — *Per-stage cost coupling* (forbids
  the incoherent inverse: a per-stage band with no whole-record cost) and
  *Split-tier spread* (a present split-tier band, identified by the closed
  `model_tier` contains-`/` rule, must have a strict `low < high`). A §4.4.1
  CAN/CANNOT note states the honest floor: the validator can assert
  presence/coupling, `low ≤ high`, and strict spread, but cannot assert the
  band spans two tiers or equals the absolute snapshot rates — that
  absolute-rate check defers to S3.
- **Example 2 re-derived** from two fixed per-tier rates (sonnet `4.0e-6`, opus
  `2.0e-5` $/token): spec-writer `{1.00, 2.00}`, tdd-agent `{0.20, 0.60}`,
  implementer `{0.40, 5.00}`, summing to the whole-record `{1.60, 7.60}`.
  Example 1 (cost-omitted) carries no per-stage band.
- **`generated_by` grammar widened** — the field description admits a
  `tier:<tier>` routing-tier label alongside a concrete model id, with `tier:`
  defined as a reserved provenance prefix (a concrete model id never begins with
  `tier:`) so consumers can distinguish the two forms with no rejecting check.
  Makes the merged S2 agent's `tier:Standard` output documentation-conformant.
- **Grounding-path sentinel documented** — the trailing-slash directory
  `observability/costs/` is the defined cost-omitted sentinel; the reference
  names that this entrenches an overloaded `path` meaning (file = grounded;
  directory = looked-and-found-nothing) and carries the consumer special-case
  (an aggregator must not count a trailing-slash path as a grounding), noted as
  advisory/unenforced.

## 0.42.0 — 2026-06-11

### New agent — `cost-estimator` (read-only prospective-cost emitter)

Ships S2 of the cost-estimator capability: the read-only agent that *produces*
an estimate record. S1 (0.41.0) shipped the methodology and the format
contract; this slice ships the emitter that consumes them. No command or
orchestrator wiring ships here (S3/S4, out of scope).

- **`agents/cost-estimator.agent.md`** — a `Read, Glob, Grep`-only emitter
  (`model: inherit`). Given a target (raw task text, slicing record, slice, or
  spec), it reads `MODEL_ROUTING.md` and the latest `observability/costs/`
  snapshot, applies the `cost-estimation` skill, and **returns the
  estimate-record content as a string** for a dispatcher to persist after a
  human disposes — the next instance of the AGENTS.md agent-emit +
  dispatcher-persist + human-disposes pattern and its dispose-then-write
  ordering invariant. It never writes, validates, or decides go/no-go.
- **Target classification** drives the S1 confidence ceiling; any inferred
  `target_kind` discloses its inference basis (`classified as <kind> by
  <signal>`) so a confident mis-read is human-catchable, and ambiguous targets
  resolve to the lower-grounding candidate with disclosure.
- **Mechanical cost-omission**: omits `cost_usd` (with disclosure) whenever any
  exercised stage tier is unmapped by the binding table — after the S1 join-key
  normalisation — or a named model key is missing, with no salience judgment.
- **Refusal discipline**: a machine-greppable `REFUSED:` string on an
  unreadable/unclassifiable target or an absent/tableless `MODEL_ROUTING.md`;
  an empty `observability/costs/` is a cost-omitted record, **not** a refusal.
- **Provenance**: `generated_by` carries the dispatcher's resolved model id when
  supplied, else the honest routing-tier label `tier:Standard` — never a guessed
  model string.
- `MODEL_ROUTING.md` gains an Agent Routing row for `cost-estimator` at the
  **Standard** tier (read-and-author, like `tdd-agent`).
- Docs: a reference entry in
  `docs/plugins/ai-literacy-superpowers/reference/agents.md` and an emitter
  section added to the `prospective-cost-estimation.md` explanation page.

## 0.41.1 — 2026-06-11

### Fix — reconcile advocatus-diaboli objection taxonomy

- Completed the abandoned 2026-04-19 taxonomy migration: the SKILL.md and
  the `/diaboli` command were migrated to the canonical six-category set
  (`premise`/`scope`/`implementation`/`risk`/`alternatives`/`specification
  quality` + `critical`/`high`/`medium`/`low`), but `advocatus-diaboli.agent.md`
  and the orchestrator's spec-mode validation kept the retired
  `design`/`threat`/`failure`/`operational`/`cost` + `major`/`minor` set.
  Reconciled both to the canonical set (one set for both modes; only per-mode
  weighting differs). Surfaced by REFLECTION_LOG 2026-06-11.
- Remapped the objection records that had drifted to the retired taxonomy
  (`cost-estimation-skill-design.md`; one stray `operational` in
  `dl-s2b-challenge-protocol-design-code.md`) back to canonical.
- Added a deterministic guard — `scripts/check-objection-taxonomy.py` +
  `objection-taxonomy-check.yml` workflow + the HARNESS constraint
  "Objection records use the canonical taxonomy" — so the retired vocabulary
  cannot reappear. Records dated on or before the 2026-04-19 migration are
  grandfathered.

## 0.41.0 — 2026-06-11

### New skill — `cost-estimation` (prospective cost/token/time estimation)

Ships S1 of the cost-estimator capability: the methodology and the format
contract every later slice (the S2 agent, the S3 command, the S4
orchestrator fold-in) consumes. No agent, command, or orchestrator wiring
ships here.

- **`skills/cost-estimation/SKILL.md`** — the prospective sibling of
  `cost-tracking`. Describes how MODEL_ROUTING.md grounds token and
  agent-compute-time ranges today, how an `observability/costs/` snapshot
  adds a dollar figure only when it supplies a usable $/token rate (three
  grounding states, no list-price fallback), the split-tier widening for
  the implementer stage, the two-layer no-verdict guarantee, the
  agent-compute / human-gate time split, and the calibration seam left
  open for S6.
- **`skills/cost-estimation/references/estimate-record-format.md`** — the
  stable estimate-record field set (with `cost_usd`/`cost_basis`
  conditional and `confidence` per-axis), the tier→model→$/token binding
  table, the four-part disclosure body, the validation checklist
  (including the positive-content no-verdict scan), and two worked
  examples (cost-omitted and cost-present). This is the artefact a
  downstream command's Output Validation Checkpoint parses.

## 0.40.0 — 2026-06-01

### `/assess` — ALCI Part D operational axes + Habitat Build Gap

Brings `/assess` into line with the framework's latest ALCI, which was
extended upstream with **Part D — four operational axes** and the
**Habitat Build Gap** diagnostic (driving change:
`ai-literacy-for-software-engineers` commits `f13d388`/#327 and
`542f325`/#330). Parts A–C (the cognitive level placement) are
unchanged; Part D is additive.

- **Four operational axes** — Composition, Testing, Observability,
  Governance — each placed L1–L5, measuring what the team's *habitat
  actually delivers* alongside the cognitive level.
- **Habitat Build Gap** — `cognitive level − operational axes mean`,
  with three interpretation regimes (Coherent / Ambition outpaces
  enablement / Inherited habitat). The signal is coherence, not the
  size of the level.
- **Hybrid administration** — evidence-first placement by default
  (from the repo scan), with an opt-in 40-statement ALCI Part D survey
  for teams wanting the rigorous per-axis score.
- **Self-contained** — all axis definitions, the full L1–L5 marker
  statements, the evidence map, the gap formula, and the regimes are
  embedded in the plugin (new reference
  `skills/ai-literacy-assessment/references/operational-axes.md`).
  `/assess` reads no external repository at runtime; upstream refs are
  provenance/re-sync pointers only.
- **Governance** — the existing standalone Governance Dimension
  deep-dive is retained; the new Governance operational axis is its
  one-line operational summary. The two are cross-referenced and must
  report a consistent level (enforced by the document validation
  checkpoint).
- Updated: the `ai-literacy-assessment` SKILL, the `assessor` agent,
  the assessment template, the `/assess` command (document step +
  validation checkpoint), the two evidence references, and the
  `run-an-assessment` how-to. Structural tests added.

Spec: `docs/superpowers/specs/2026-06-01-assess-operational-axes-design.md`.

### Maintenance

- `/harness-upgrade`: advanced the root `HARNESS.md` template-version
  marker from 0.39.1 to 0.40.0 after confirming the dogfood harness
  already contains all current template content (no new constraints,
  GC rules, or sections to adopt).

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
