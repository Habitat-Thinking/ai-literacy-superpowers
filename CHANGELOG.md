# Changelog

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

### Feature — Unified surface sync via /harness-sync

Adds `/harness-sync`, a new command that consolidates push-direction
propagation from `HARNESS.md` to all control surfaces (Cursor / Copilot /
Windsurf rule files, `ONBOARDING.md`) under a single human-instigated
entry point.

The command is a multiplexer over the existing primitives
(`/convention-sync`, `/harness-onboarding`) — no new skill, no new
agent. It runs three phases interactively: drift scan with the full
picture (drifted, missing, in sync, managed), multi-select of surfaces
to apply, and apply-with-verification. A pre-commit guard enforces the
trust boundary mechanically: the command never writes to `HARNESS.md`,
`AGENTS.md`, or `REFLECTION_LOG.md`.

Branch enforcement at start-of-run: refuses to apply on `main` and
offers to create a `chore/sync-surfaces-YYYY-MM-DD` branch (the
`chore/` prefix satisfies the spec-first exemption deterministically).
On a feature branch, the command commits in place without opening a
new PR.

`/harness-upgrade` is explicitly out of scope — it is a different
direction (pull from upstream) and stays separate.
`/extract-conventions` is also separate (pulls tacit knowledge from
team into HARNESS.md).

Spec: `docs/superpowers/specs/2026-05-07-harness-sync-design.md`.
Plan: `docs/superpowers/plans/2026-05-07-harness-sync.md`.
Deferred follow-up #256: HARNESS.md template update so existing
harnesses pick up the new command via `/harness-upgrade` after they
upgrade to v0.33.0+.

### Docs — /harness-sync consistency pass across the docs site

Follow-up to the v0.33.0 ship. The initial PR added `/harness-sync` to
the new how-to page, the explanation pages' propagation stages, the
README, and "See also" callouts on the two primitive how-tos — but
older docs pages still referenced `/convention-sync` and
`/harness-onboarding` as canonical propagation commands without
acknowledging `/harness-sync`, and the primitive how-to pages framed
themselves as first-class commands rather than as primitives the
multiplexer composes.

This pass closes both gaps:

- **Lifecycle page internal consistency** — `the-harness-lifecycle.md`
  Stage 5 framing, Stage 5 "How they work together", Stage 6
  enumeration, Stage 6 "Tools at work" table, and Stage 6 "How they
  work together" all updated so `/harness-sync` is the canonical entry
  point and the primitives are named explicitly as its underlying
  components.
- **Subservience framing on the primitive pages** — `sync-conventions.md`
  and `generate-onboarding.md` opening paragraphs rewritten to lead
  with "this command is one of the underlying primitives that
  `/harness-sync` composes" before describing the focused single-surface
  use case.
- **Reference page** — `commands.md` gains a `/harness-sync` entry
  marked as composing the primitives; `/convention-sync` and
  `/harness-onboarding` entries gain a "Primitive of: `/harness-sync`"
  metadata line.
- **Older tutorials and explanation pages** — `first-time-tour.md`
  (both `/convention-sync` and `/harness-onboarding` introductions),
  `harness-md.md` (two passages),
  `run-a-calibration-review.md`, `surfacing-tacit-knowledge.md`, and
  `templates.md` updated to surface `/harness-sync` as the typical
  entry point alongside the primitives.

Closes a consistency gap that would otherwise have surfaced via the
GC `documentation freshness` rule the next time it ran.

No plugin version bump (docs change outside `ai-literacy-superpowers/`).

### Docs — sync-harness how-to + cross-references

New how-to page `docs/plugins/ai-literacy-superpowers/sync-harness.md`
covers the three phases, the on-main vs on-branch distinction, the
refusal cases, and the example output. Existing how-to pages
`sync-conventions.md` and `generate-onboarding.md` updated with
"See also" pointers to the new multi-surface entry. The
`the-harness-tuning-loop.md` and `the-harness-lifecycle.md` Explanation
pages updated to reference `/harness-sync` at their respective
propagation stages. README's Commands count bumped from 24 to 25 and
the new command added to the Commands table.

## 0.32.0 — 2026-05-01

### Chore — Multi-plugin tag conventions

Documents and operationalises the per-plugin tag-naming convention now
that the marketplace ships multiple plugins. The two-plugin convention:

- **`ai-literacy-superpowers`** (primary): continues to use bare
  `vX.Y.Z` tags. 51 historical tags through `v0.32.0` are unchanged;
  new tags follow the same form. CHANGELOG at `CHANGELOG.md` (root).
- **`model-cards`** (sister): uses `model-cards-vX.Y.Z` tags.
  CHANGELOG at `model-cards/CHANGELOG.md`. Backfilled
  `model-cards-v0.1.0` at commit `0053b36` (initial release).

The asymmetry is deliberate — the primary plugin keeps its existing
51-tag history (no migration risk to external links / Releases UI /
subscribers), and sister plugins occupy a clearly-namespaced tier.
Future sister plugins follow the same shape: `<plugin-name>-vX.Y.Z`.

Touched files:

- `.github/workflows/auto-tag-model-cards.yml` — new workflow that
  fires on changes to `model-cards/.claude-plugin/plugin.json` and
  creates `model-cards-vX.Y.Z` tags. Mirrors the existing
  `auto-tag.yml` for ai-literacy-superpowers.
- `.github/workflows/gc.yml` — release-tag-completeness GC rule
  extended into two steps: one scans `CHANGELOG.md` for
  ai-literacy-superpowers `vX.Y.Z`, the other scans
  `model-cards/CHANGELOG.md` for `model-cards-vX.Y.Z`. Both
  auto-create missing tags.
- `HARNESS.md` — `Release traceability` constraint wording updated
  to document the per-plugin convention and the four
  workflows/rules involved.

No plugin version bump (changes are root-level: `.github/`,
`HARNESS.md`, `CHANGELOG.md` only).

### Feature — Reflection log archival (Path 1 + Path 2 + read-side filtering)

Implements the design at
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`.
Three complementary mechanisms keep `REFLECTION_LOG.md` signal-dense
as the project accumulates compound learning over time.

- **Read-side filtering** — agents and commands that read the
  reflection log bound their default intake (last 50 entries OR last
  90 days, whichever is more inclusive). New `bounded_entries` helper
  in `ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh`;
  HARNESS template gets a new `## Read-side filtering` section.
- **Path 1 — auto-archive of promoted entries (deterministic, weekly)**.
  When a curator promotes a reflection to `AGENTS.md` or `HARNESS.md`,
  they add a single `Promoted` line to the source entry. The new
  weekly GC rule (`Reflection log archival of promoted entries`) runs
  `scripts/archive-promoted-reflections.sh`, which verifies the
  Promoted line's right-hand side resolves to actual AGENTS.md /
  HARNESS.md content (pre-archive verification) and moves verified
  entries to `reflections/archive/<YYYY>.md` (annual files,
  file-by-original-year, ordered by archive timestamp). Wired into
  the existing `gc.yml` workflow.
- **Path 2 — agent-augmented aged-out review (monthly, opt-in)**. The
  `harness-gc` agent surfaces entries older than the configured age
  threshold (default 180 days) that lack a `Promoted` line and emits
  per-entry **evidence** (recurrence counts, AGENTS.md/HARNESS.md
  text-overlap matches with quoted excerpts, single-instance signal)
  rather than pre-classified labels. Curator interprets the evidence
  and chooses a disposition. Opt-in via the GC-rule declaration in
  HARNESS.md.
- **Migration helper** — `scripts/migrate-reflection-log.sh`
  pre-cross-references existing entries against AGENTS.md and
  HARNESS.md and produces a proposals file for the curator to confirm.
- **Schema** — one new optional `Promoted: <date> → <rhs>` line per
  entry, formal-grammar parseable, append-only.
- **Graceful degradation** — for adopters who don't engage, the system
  reverts to today's behaviour plus read-side filtering. No archival
  happens, no monthly report is generated, and the active log
  continues as before.

Touched files: 5 agent definitions
(`harness-gc`, `harness-auditor`, `assessor`, `choice-cartographer`,
`integration-agent`); 4 commands
(`reflect`, `superpowers-status`, `harness-health`, `harness-audit`);
templates (`HARNESS.md`, `CLAUDE.md`); skill (`garbage-collection`);
CI workflow (`gc.yml`); plus this repo's live HARNESS.md declaration
of the two new GC rules and the read-side filtering policy.

Adjudication trail:
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`
(spec), `objections/reflection-log-archival-design.md` (12 objections,
8 accepted, 4 rejected), `stories/reflection-log-archival-design.md`
(9 stories, all accepted),
`plans/2026-04-30-reflection-log-archival.md` (32-task plan).

### Docs — Harness tuning loop explainer

Adds a new Explanation page,
`docs/plugins/ai-literacy-superpowers/the-harness-tuning-loop.md`,
that traces a single operational surprise end to end through the six
stages of the tuning loop: capture in `REFLECTION_LOG.md`, detection
by the GC agent's reflection-driven regression rule, promotion via
`/harness-constrain`, verification via `/harness-audit`, propagation
to AGENTS.md / hooks / CI, and the wider quarterly tuning frame.

The page is integrative — it links out to the deep-dive owners of
each slice (`self-improving-harness.md`, `garbage-collection.md`,
`the-loops-that-learn.md`, `three-enforcement-loops.md`) rather than
re-explaining them, and threads a worked example (a CVE-bearing
dependency surprise) through every stage. The pivot insight that
the page makes load-bearing: GC produces reports, not blocks — only
constraints, hooks, and CI block work, which is what makes the loop
safe to run continuously without becoming a punishment surface.

`index.md` updated with the new page in the Explanation deep-dives
section.

No plugin version bump (docs change outside `ai-literacy-superpowers/`).

### Docs — CLAUDE.md spec-first exemptions section

Renames CLAUDE.md's `Cross-Repo Spec-First Discipline` section to
`Spec-First Exemptions` and expands it to list all five exemption
labels (`bug`, `fix`, `chore`, `maintenance`, `cross-repo`) and their
branch-prefix alternatives (`fix/`, `chore/`, `cross-repo/`), each
with one-sentence guidance on the kind of change it applies to.

The previous section only documented the `cross-repo` exemption
explicitly, even though the `Spec-First Check` workflow at
`.github/workflows/spec-first-check.yml` accepts all five labels and
three branch prefixes. The narrow framing made the answer harder to
find than it needed to be — discovered while shipping the docs PRs
for the harness-tuning-loop and harness-lifecycle pages, where the
correct exemption was `chore` but had to be inferred from the
workflow file. See REFLECTION_LOG entry 2026-05-07.

The cross-repo case retains its two sub-options (copy spec into
`docs/superpowers/specs/`, or use the exemption alone) and the
guidance to link to the upstream spec in the PR description.

Closes #250.

No plugin version bump (docs change to root file).

### Docs — Harness lifecycle explainer

Adds a second integrative Explanation page,
`docs/plugins/ai-literacy-superpowers/the-harness-lifecycle.md`,
that traces one harness through six stages over months and years:
Day Zero (Initialisation), First Month (Bootstrapping), Quarter One
(First Steady State), Year One (Maturity), Renewal Years (Upgrades
and Refresh), and When the Harness Has to Change (Adaptation).

Pairs with the harness-tuning-loop page on the orthogonal axis. The
tuning-loop page is the *vertical* cut (one surprise, every surface);
this is the *horizontal* cut (one harness, many months). Together
they answer "how does a harness work?" along both axes.

Each stage has a uniform internal structure: a framing paragraph, a
worked-example beat (a fictional six-engineer team running Python +
TypeScript + Terraform), an "In this plugin's case" sidebar pointing
to a verifiable real event in the plugin's own 5-week-old harness,
the substantive content, and two summary tables — Tools at work
(commands / skills / agents / hooks / CI) and Artefacts evolving here
(`HARNESS.md`, `AGENTS.md`, `REFLECTION_LOG.md`, hook configuration).
The closing reading map organises the rest of the docs site by
lifecycle position so a reader at any stage knows exactly which
deep-dive, tutorial, or how-to to open next.

`REFLECTION_LOG.md` evolution is covered explicitly: append at session,
curation, promotion via the `Promoted` line, Path 1 deterministic
auto-archival (weekly), Path 2 monthly aged-out review, and read-side
filtering (50 entries / 90 days). All cross-linked to the v0.32.0
release notes.

Sister-page issue (#252) opened for "The Portfolio Lifecycle" — the
multi-harness arc, deferred to keep this page focused on the single
harness.

`index.md` updated with the new page immediately after the harness
tuning loop entry.

No plugin version bump (docs change outside `ai-literacy-superpowers/`).

### Chore — pull_request workflows re-evaluate on label changes

Adds `types: [opened, synchronize, reopened, labeled, unlabeled]` to
the `pull_request:` triggers of:

- `.github/workflows/spec-first-check.yml` — branches on the
  `bug | fix | chore | maintenance | cross-repo` exemption labels.
- `.github/workflows/version-check.yml` — branches on the `no-bump`
  exemption label for formatting-only fixes.

Without the explicit `types` list, GitHub Actions defaults to
`opened, synchronize, reopened`, which means adding or removing an
exemption label after a check has run does not re-evaluate the check.
That race condition forced a manual empty-commit re-trigger on
PR #248, when the `chore` label was applied after the spec-first
check had already failed (see REFLECTION_LOG entry 2026-05-07). With the
explicit list, label changes now fire the workflow and the check
re-evaluates against the new label set automatically.

`harness.yml` and `lint-markdown.yml` are unaffected — neither
branches on PR labels, so the trigger change would not add value.

Closes #251.

No plugin version bump (CI config change outside `ai-literacy-superpowers/`).

## 0.31.1 — 2026-04-29

### Docs — README reframed for the marketplace

Updates `README.md` to acknowledge that this repository ships a plugin
**marketplace**, not a single plugin.

- **Top of file**: tagline reframed as a marketplace shipping multiple
  plugins; onboarding pointer also surfaces the docs site URL.
- **Badges**: replaced the single `Plugin v0.31.1` badge with three
  badges — `Marketplace v0.3.0`, `ai-literacy-superpowers v0.31.1`,
  `model-cards v0.1.0` — so plugin versions are visible at a glance.
- **New "Plugins in this marketplace" section** near the top: table
  listing both plugins with version, description, and docs link.
- **Installation reorganised** as "1. Add the marketplace (once)" +
  "2. Install the plugin(s) you want", showing install commands for
  both plugins under both Claude Code and Copilot CLI.
- **Scope note** added before the body of the README: the remaining
  sections document `ai-literacy-superpowers` specifically; for
  `model-cards`, see its README and docs.
- **Quick Start install** updated to show the marketplace add step
  alongside the plugin install (was previously just the install).

The bulk of the README continues to document `ai-literacy-superpowers`
as the flagship in detail (skills, agents, commands, hooks, templates,
enforcement loops, agent pipeline, compound learning, intellectual
foundations). Replicating model-cards content would have created
drift; the table + scope note + per-plugin docs links do the work
without duplication.

### Docs — Marketplace homepage reframe + cross-reference sweep (PR 3 of 3)

Third and final PR in the docs restructure. Closes the loop by
reframing the docs homepage as a marketplace landing and sweeping
remaining old-URL references in repo-root files.

- **`docs/index.md` reframed** as a plugin-marketplace landing rather
  than an `ai-literacy-superpowers`-specific page. The hero tagline
  now positions the repo as a Claude Code / Copilot CLI plugin
  marketplace; both plugins are surfaced equally near the top with
  install instructions and tutorial links; per-plugin "what each
  plugin ships" sections explain the flagship and sister plugins
  side-by-side; a closing "why a marketplace, not a monolith" section
  explains the architectural rationale for incremental adoption.
- **`README.md`** — fixed one stale reference to
  `docs/how-to/update-the-plugin.md` → `docs/plugins/ai-literacy-superpowers/update-the-plugin.md`.
- **`CLAUDE.md`** — rewrote the "Docs Site Review" section to reflect
  the per-plugin Diataxis structure (the four old `docs/<section>/`
  directory references are gone). Plugin docs now land at
  `docs/plugins/<plugin-name>/<slug>.md`.
- **Plugin source files** — confirmed clean (zero references to the
  old `docs/<section>/` paths).

### Docs — Migrate ai-literacy-superpowers docs under per-plugin structure (PR 2 of 3)

Second of three PRs restructuring the docs site to plugin-first
organisation. Moves all 77 ai-literacy-superpowers content pages from
the top-level Diataxis directories into the per-plugin sub-tree
introduced in PR 1, with `redirect_from:` frontmatter on every moved
page so existing bookmarks continue to work.

- **Added `jekyll-redirect-from` plugin.** `Gemfile`, `Gemfile.lock`,
  and `docs/_config.yml` updated to enable `redirect_from:` frontmatter.
- **Moved 77 pages** from `docs/{tutorials,how-to,reference,explanation}/`
  flat into `docs/plugins/ai-literacy-superpowers/`. Each moved page
  has its `parent` rewritten to `ai-literacy-superpowers`,
  `grand_parent: Plugins` added, and a `redirect_from:` block listing
  the old URL (both with and without `.html`) so existing bookmarks
  redirect via meta-refresh.
- **Consolidated four section index pages** (`tutorials/index.md`,
  `how-to/index.md`, `reference/index.md`, `explanation/index.md`)
  into a single `docs/plugins/ai-literacy-superpowers/index.md` with
  Diataxis-organised navigation. The new plugin index also redirects
  the four old section URLs (`/tutorials/`, `/how-to/`, etc.).
- **Rewrote 148 internal `{% link %}` references** across 30 files to
  point at the new paths.
- **Converted 28 broken relative `(../section/...)` markdown links**
  to Jekyll `{% link %}` references (sibling refs after the flat move).
- **Fixed 7 `(../../CHANGELOG.md)` and `(../superpowers/specs/...)` paths**
  that needed an additional `..` segment after the move.
- **Updated `docs/index.md`** — replaced the Diataxis-section table
  with a per-plugin table, and updated the "Get Started" hero button
  to point at the new path.
- **Updated `docs/plugins/index.md`** — added the
  `ai-literacy-superpowers` row and removed the migration-pending
  note from PR 1.
- **Removed empty `docs/{tutorials,how-to,reference,explanation}/`
  directories** after the moves.

PR 3 (optional polish): sweep `README.md` and any deep links in
skills/agents/commands that reference the old docs URLs.

### Docs — Per-plugin docs section + full model-cards documentation (PR 1 of 3)

First of three PRs restructuring the docs site to plugin-first
organisation, motivated by the new sister plugin `model-cards`
shipping in the same marketplace.

- **New top-level docs section: `docs/plugins/`.** Landing page at
  `docs/plugins/index.md` introduces the per-plugin structure and
  lists available plugins.
- **Full model-cards documentation under `docs/plugins/model-cards/`:**
  - `index.md` — landing page with install, quick start, and Diataxis-
    organised navigation.
  - `seed-your-library.md` — tutorial for `/model-card seed`.
  - `research-a-model-card.md` — how-to for `/model-card create`.
  - `commands.md`, `agents.md`, `skills.md`, `card-template.md` —
    reference pages for the command, agent, skill, and template.
  - `mitchell-extended-cards.md` — explanation page covering why the
    cards have ten sections, the citation-tier discipline, the
    existence-check refusal rule, and the read-only-emitter trust
    boundary the agent inherits from `advocatus-diaboli` /
    `choice-cartographer`.
- **`docs/index.md` updated** to surface the new Plugins section in
  the top-level navigation table.
- **No file moves yet.** Existing `ai-literacy-superpowers` docs stay
  at their current paths and URLs continue to work. PR 2 will migrate
  them under `docs/plugins/ai-literacy-superpowers/` with
  `redirect_from:` frontmatter to preserve bookmarks; PR 3 will sweep
  cross-references in `README.md` and skill/agent/command files.

### Chore — Bump HARNESS.md template-version marker to 0.31.1

Ran `/harness-upgrade` against the 0.31.1 template. No new constraints,
GC rules, or sections to adopt — the live `HARNESS.md` is already a
superset of the template, with all template items present (a few
customised with project-specific dates and file references). Only the
`<!-- template-version: -->` marker needed updating, from `0.29.0` to
`0.31.1`, to silence the SessionStart upgrade nudge. The
`.claude/.harness-upgrade-dismissed` marker was also bumped (gitignored,
local-only).

### Docs — Sync Naur as a strand of the Intellectual Foundations

Synced from the upstream framework
(`russmiles/ai-literacy-for-software-engineers` PR #306, which added
Peter Naur (1985) as a sixth, independent strand of the genealogy in
Appendix K alongside Knuth, Gabriel, Beck, Terhorst-North, and the
neuroscience foundation).

- **README — new "Code as Theory" subsection under Intellectual
  Foundations.** Names Naur and his "Programming as Theory Building"
  (1985) and *Computing: A Human Activity* (1992). Frames Naur as
  what habitability protects — the substance of shared understanding
  that the plugin's compound-learning components (REFLECTION_LOG.md,
  AGENTS.md, the convention-extraction and harness-audit skills)
  exist to externalise and sustain.
- **Fixed stale lineage count.** The Intellectual Foundations
  introduction said "three lineages" but already listed six grouped
  subsections (Architecture and Habitability, Code as Literature,
  Harness Engineering, Convention Discovery, Agent Orchestration,
  Specification-Driven Development). Replaced "three lineages" with
  "several lineages" to remove the count statement that had silently
  drifted as the section grew.

The upstream framework also added Determinacy Debt as a fifth debt
type to Theme 16. The plugin's `/governance-audit` and
`/harness-audit` commands already address constraint re-grounding,
which is the discipline that pays down determinacy debt; documenting
the debt typology in this README is deferred until a future change
introduces the full Triple Debt vocabulary into the plugin's
Intellectual Foundations.

## 0.31.0 — 2026-04-28

### Feature — Evidence-base expansion for assessor (Unit B)

Implements Unit B of the workflow signal captured in REFLECTION_LOG.md
(2026-04-28 entry, PR #221). Items 3 and 4 of the user-supplied
feedback decomposed to two complementary additions: parallel-tool
config evidence reading (item 3) and content-shape sophistication
analysis (item 4). This release ships both as a single, conservative
expansion.

- Add
  `skills/ai-literacy-assessment/references/tool-config-evidence.md`
  — single source of truth for reading parallel-tool config surfaces
  as habitat-maturity evidence. Covers `.cursor/rules/`,
  `.github/copilot-instructions.md`, `.windsurf/rules/`, AGENTS.md
  as multi-tool standard, and custom AI tooling locations. Documents
  the path patterns, content markers per surface, what each surface
  signals (L3 context engineering), and what it does NOT signal
  (architectural constraints, compound learning).
- Add
  `skills/ai-literacy-assessment/references/sophistication-markers.md`
  — single source of truth for content-shape analysis. Defines
  simple-vs-sophisticated markers for hooks, scripts, agents, and
  commands; documents how sophistication markers feed level
  determination; requires every applied marker to be cited in the
  assessment document so level shifts are auditable.
- Modify `agents/assessor.agent.md`: Phase 1b adds parallel-tool
  config evidence as a new L3 source class; Phase 3 (Assess the
  level) applies content-shape sophistication analysis before
  assigning the level.
- Modify `skills/ai-literacy-assessment/SKILL.md`: Level 3 indicators
  recognise parallel-tool config evidence as load-bearing for the
  context-engineering discipline (with explicit caveats on what it
  does not signal); Scoring Heuristic gains a Content-shape
  sophistication adjustments subsection that references
  `sophistication-markers.md`.
- Modify `agents/harness-discoverer.agent.md` step 5: applies both
  the habitat-discovery and tool-config-evidence references; the
  discovery report now includes parallel-tool surfaces alongside
  the habitat documents.

The two encoded principles:

1. A project expressing harness control through Cursor, Copilot, or
   Windsurf is at L3 context engineering, not at "no habitat".
   Tool-config evidence is parallel evidence, not weaker evidence.
2. Surface counts (script count, hook count, agent count, command
   count) mislead. A project with one sophisticated state-based
   orchestration script is not at the same maturity as one with ten
   simple bash hooks. Content-shape analysis is the corrective.

Conservative stance on level shifts: sophistication markers are
applied incrementally so previously-assigned levels remain stable
across the v0.30.0 → v0.31.0 boundary unless the cited evidence
genuinely changes the picture. A reflection capturing observed
shifts after the first few re-assessments is the right next step
for tuning.

## 0.30.0 — 2026-04-28

### Feature — Discovery layer for assessor and harness-discoverer (Unit A)

Implements Unit A of the workflow signal captured in REFLECTION_LOG.md
(2026-04-28 entry): the `/assess` discovery is no longer rigid about
default paths and filenames. Items 1, 2, and 5 of the user-supplied
feedback decomposed to a single structural fix; this release ships
that fix.

- Add `skills/ai-literacy-assessment/references/habitat-discovery.md`
  — single source of truth for habitat document discovery covering
  `HARNESS.md`, `AGENTS.md`, and `CLAUDE.md`. Documents alternative
  paths to scan, content markers per document type, the discovery
  report format with citations, and the two failure modes
  (ambiguous discovery surfaces both candidates; genuine absence
  lists every path checked).
- Modify `agents/assessor.agent.md` Phase 1: split into 1a (habitat
  document discovery using the new reference) and 1b (broader
  signal scan). Discovery completes — with auditable absence claims
  — before any maturity calculation.
- Modify `agents/harness-discoverer.agent.md` step 5: convention
  documentation discovery now applies the new reference rather than
  defaulting to `CLAUDE.md` and `CONTRIBUTING.md` only.
- Modify `commands/assess.md`: step 1 split into 1a (discovery
  report as the first output) and 1b (broader scan). Ambiguous
  discovery results halt the flow until the user resolves; silent
  picks are forbidden.
- Modify `skills/ai-literacy-assessment/SKILL.md`: Phase 1
  (Observable Evidence) prefaced with the discovery methodology
  note — habitat documents found at non-conventional paths count
  as *present* for Level 3 indicators.

The principle the discovery layer encodes: **every absence claim
must come from a fully-completed search across known alternatives,
not from "not at the default path"**. Discovery output is auditable
— each finding cites the path matched and the marker confirmed.

Unit B (evidence-base expansion — multi-tool config reading,
content-shape analysis, literacy-improvements gap-to-amendment
mapping update) is a separate follow-up. Issue #222 closes when
Unit A merges; a new issue tracks Unit B.

## 0.29.0 — 2026-04-27

### Docs — Determinacy Calibration explanation and how-to

- Add `docs/explanation/determinacy-calibration.md` — explanation page
  on calibration as a periodic review practice, covering bidirectional
  movement (promotion, demotion, splitting, seam repair, leaving
  unchanged), the four signal classes (change records, temporal
  patterns, reflection-log patterns, seam integrity), recording
  refusals as a first-class output, and the relationship to
  `/harness-audit`, `/harness-gc`, and `/reflect`. Builds on Russ
  Miles' [The Djinn's Determinacy Drift](https://www.softwareenchiridion.com/p/the-djinns-determinacy-drift)
  for the bidirectional-drift framing and the harness-as-habitat
  metaphor.
- Add `docs/how-to/run-a-calibration-review.md` — practical guide
  for running a periodic calibration review: cadence selection,
  signal gathering, candidate movements, decision recording with
  refusals, applying decisions through existing commands, and a
  follow-up audit.
- Cross-links added in `progressive-hardening.md` (the unidirectional
  promotion framing's bidirectional companion) and the explanation
  `index.md` "Deep dives" section.

### Docs — HARNESS.md overview page

- Add `docs/explanation/harness-md.md` — explanation page covering what
  `HARNESS.md` is, how it is operated, and how it compares to
  `AGENTS.md`, CI config, and hooks. Builds on Addy Osmani's
  [Agent Harness Engineering](https://addyosmani.com/blog/agent-harness-engineering/)
  for the model-plus-harness framing alongside the project's
  Boeckeler-derived foundation. Includes the AGENTS.md vs HARNESS.md
  differences-at-a-glance table and addresses the source-code-vs-binary
  metaphor for "do we keep this around" with the single-source-of-truth
  tension.
- Cross-links added in `harness-engineering.md`, `self-improving-harness.md`,
  and the explanation `index.md` "Deep dives" section so the new page
  is discoverable from related entry points.
- Restructured "How HARNESS.md is operated" section to add a Signal
  capture flow that explicitly documents reflections as the primary
  signal source feeding HARNESS.md amendments (alongside audit
  findings and direct human authoring). The original three-flow
  shape elided where amendments come from; the four-flow shape makes
  the reflection-driven ratchet (every preventable mistake becomes a
  rule) load-bearing in the prose.
- Expanded the Signal capture flow from three pathways to seven to
  cover the full set of plugin features that route into
  `HARNESS.md` amendments: reflections, audit/GC findings,
  convention extraction (`/extract-conventions`), assessment-driven
  improvements (`/assess` + `literacy-improvements`), affordance
  discovery and sibling-artefact promotion (`/harness-affordance
  discover` and choice-story `disposition: promoted`), template
  upgrades (`/harness-upgrade`), and direct human authoring. The
  ordering goes from continuous observation through structured
  elicitation to escape hatch.

### Docs — Choice Cartographer integration into docs site

- `docs/reference/agents.md`: add `choice-cartographer` entry alongside
  `advocatus-diaboli` with Routing Rule cross-reference; bump count from
  12 to 13; expand pipeline-agents framing to seven agents with two
  human gates (hard + soft); add row to the Tool Summary table.
- `docs/reference/commands.md`: add `/choice-cartograph` entry under
  Workflow with disposition values and merge-time gate context; bump
  count from 23 to 24.
- `docs/reference/skills.md`: add new "Spec-First Pipeline" section
  containing both `advocatus-diaboli` and `choice-cartographer` skill
  entries; bump count from 28 to 30 (advocatus-diaboli was missing too
  and is now added under the new section).
- `docs/explanation/agent-orchestration.md`: insert Choice Cartographer
  step into the pipeline diagram; expand "Two things matter here" to
  three to cover the soft-gate / hard-gate asymmetry; add cross-link to
  `decision-archaeology.md`.
- `docs/explanation/adversarial-review.md`: add Further Reading links
  to `decision-archaeology.md` and `run-choice-cartograph.md` so the
  paired agents are discoverable from each other.
- `docs/index.md`: bump skills/agents/commands counts to 30/13/24 and
  call out decision-archaeology in the value bullets.

### Feature — Choice Cartographer (decision-archaeology agent)

- Add `agents/choice-cartographer.agent.md` — second chartered read-only
  agent in the spec-first pipeline (Read/Glob/Grep boundary). Runs after
  spec-mode `/diaboli` dispositions are resolved and before plan approval;
  surfaces decisions a spec has made implicitly and emits each as a
  *choice story* (Henney pattern story) for human disposition.
- Add `skills/choice-cartographer/SKILL.md` — six lenses (forces,
  alternatives, defaults, patterns, consequences, coherence), the
  Routing Rule (failure-vs-decision test that partitions findings
  between Cartographer and diaboli), self-imposed selectivity cap (15)
  inside the reasoning protocol, output format, cross-reference
  protocol with deterministic resolution.
- Add `commands/choice-cartograph.md` — `/choice-cartograph <spec-path>`
  with single positional argument (no `--mode` flag this release;
  code-mode tracked at issue #209). Validation checkpoint includes
  cross-reference resolution for `O\d+` and `#\d+` tokens in `Refs`
  fields. Selectivity cap is enforced in the agent's reasoning, so the
  validator never refuses to write — fix-in-place pattern preserved.
- Add `.github/prompts/choice-cartograph.prompt.md` — prompt mirror
  for `/prompts` discovery in Copilot CLI.
- Add `docs/how-to/run-choice-cartograph.md` — task-oriented guide
  covering invocation, output, the Routing Rule, and the disposition
  workflow.
- Add `docs/explanation/decision-archaeology.md` — conceptual page on
  intent debt, cognitive debt, the cartography role frame, the
  Routing Rule, soft-vs-hard gating, and the relationship to ADRs.
- Modify `agents/orchestrator.agent.md` — insert step 1b after
  spec-mode diaboli adjudication and before plan approval; surface
  `cartograph_pending_count: N` as a structured field in the
  plan-approval summary; allow progression with pending dispositions.
- Modify `agents/harness-enforcer.agent.md` — add Choice Story
  Adjudication Review section that mirrors the diaboli adjudication
  check for the new `PRs have adjudicated choice stories` constraint.
- Modify `templates/HARNESS.md` — add `PRs have adjudicated choice
  stories` constraint (agent-enforced via harness-enforcer, scope
  `pr`); bump template-version marker to 0.29.0.
- Modify `HARNESS.md` (this project) — adopt the new constraint
  locally; bump template-version marker to 0.29.0.
- Modify `commands/superpowers-status.md` — add Section 8 (Cartographer
  activity) with `cartograph_pending_count`, fully-resolved rate,
  disposition distribution, and lens distribution; add Cartographer
  line to the dashboard summary.
- Modify `commands/harness-health.md` — add Cartographer to the
  snapshot section list (now 14 sections instead of 13).
- Modify `skills/harness-observability/references/snapshot-format.md`
  — add Cartographer section spec parallel to the Diaboli section,
  with `cartograph_pending_count` documented as the load-bearing
  field tracked by the merge-time HARNESS constraint.
- The Cartographer's plan-approval gate is **soft** by design — it
  surfaces `cartograph_pending_count` and allows progression, while
  the merge-time HARNESS constraint blocks PR merge until every story
  has `disposition != pending`. The asymmetry against the diaboli's
  hard plan-approval gate is deliberate: a `pending` objection is a
  risk that has not been triaged; a `pending` choice story is a
  captured decision waiting for human curation.
- Format vocabulary preserves the Henney pattern-stories lineage —
  each entry is a *choice story* and the format follows POSA Vol. 5;
  the Cartographer name reflects the agent's role (mapping the
  implicit decision terrain) rather than the format's source.
- Spec at `docs/superpowers/specs/2026-04-27-choice-cartographer.md`.
  Adjudicated diaboli objection record at
  `docs/superpowers/objections/choice-cartographer.md` — 12 objections,
  9 accepted, 3 rejected. Follow-up issues: code-mode at #209,
  story-promotion mechanism at #211.

## 0.28.0 — 2026-04-27

### Chore — harness marker bump

- Bump `HARNESS.md` template-version marker from 0.26.0 to 0.28.0 after
  running `/harness-upgrade` (issue #206). No new template content to
  adopt — the plugin's `templates/HARNESS.md` carries internal marker
  0.19.0, and the project HARNESS.md already contains every active rule
  and commented block in the template plus many project-specific
  additions. The bump records that v0.28.0 has been reviewed.

### Feature — `/harness-affordance discover` (sequencing step 2 of harness-affordances)

- Add `commands/harness-affordance.md` — parent command for the
  affordance inventory workflow with three subcommands: `discover`
  (implemented), `add` (planned, sequencing step 3), `review`
  (planned, sequencing step 6). `add` and `review` print a clear
  "not yet implemented" message pointing at the design spec.
- Add `scripts/harness-affordance-discover.sh` — bash discovery
  scanner that reads `.claude/settings.json`,
  `.claude/settings.local.json`, and `.mcp.json`, deriving one draft
  affordance per permission pattern, hook entry, and MCP server.
  Output goes to `<project>/.claude/affordance-discovery-<date>.md`,
  never to `HARNESS.md`. Idempotent — re-running on the same input
  produces the same output modulo the date in the heading.
- Output entries fill machine-derivable fields (Mode, Trigger for
  hooks, Permission) and leave human-owned governance fields
  (Identity, Audit trail, Notes) as `TODO` placeholders.
- Disambiguates colliding derived names by appending numeric
  suffixes (`awk-cli`, `awk-cli-2`, ...).
- Cross-checks `.mcp.json` against permission allowlists and
  warns when an MCP server is declared without a matching
  `mcp__<server>__*` permission entry.
- Add `docs/how-to/discover-affordances.md` — one-page guide
  covering prerequisites (jq), invocation, output structure, and
  the promote-to-HARNESS.md flow.
- Update `.gitignore` to exclude `.claude/affordance-discovery-*.md`
  so drafts never accidentally land in version control.
- Update README Commands count badge from 22 to 23 and Commands
  table to include `/harness-affordance`.
- This is the **backfill path** for existing harness adopters
  promised by sequencing step 2 of the affordances design — running
  the scanner once produces a draft for every existing permission,
  hook, and MCP server in any project that already declared them.

## 0.27.0 — 2026-04-26

### Commands — sync check on /harness-upgrade and PR workflow on /reflect

- Update `commands/harness-upgrade.md` step 1 — fetch `origin/main` and
  warn when the local clone is behind. The marketplace cache reflects
  `origin/main` in near real time, so a stale local clone produces an
  upgrade comparison that suggests content already on main and yields a
  conflicting PR at push time. Best-effort: skipped silently if no
  remote main, detached HEAD, or fetch failure
- Update `commands/reflect.md` step 7 — replace the unconditional
  `git commit` with a branch + labelled-PR workflow when the project
  declares a "Reflections via PR workflow" constraint, and keep direct
  commit as the fallback when no such constraint is declared. The PR
  variant uses `--label chore` on `gh pr create` directly so the
  spec-first and adjudicated-objections gates exempt the reflection
- Both updates trace to a reflection in PR #196 captured during the
  /harness-upgrade run that produced PRs #195 and #196

## 0.26.0 — 2026-04-19

### Harness — bump local template marker and exempt pre-existing specs

- Bump `HARNESS.md` template-version marker `0.25.0` → `0.26.0` to reflect
  the installed plugin version (the constraint and GC rule themselves
  already shipped under this version above)
- Add `diaboli: exempt-pre-existing` frontmatter to all 26 specs in
  `docs/superpowers/specs/` — belt-and-braces alongside the date cutoff
  in the "PRs have adjudicated objections" rule, so the exemption is
  explicit and greppable per file
- Drive-by: add the blank line MD032 wants before a list in
  `docs/superpowers/specs/2026-04-15-observatory-verify-design.md`
- No plugin version bump — `HARNESS.md` and `docs/superpowers/specs/`
  are outside `ai-literacy-superpowers/` (0.26.0 retained)

### Feature — diaboli code-time dispatch point

- Add Dispatch Modes section to `skills/advocatus-diaboli/SKILL.md` documenting
  spec-time weighting (premise, alternatives, scope, specification quality) and
  code-time weighting (risk, implementation); six categories and trust boundary
  unchanged across modes
- Update `agents/advocatus-diaboli.agent.md` to accept `mode: spec|code` input
  (default `spec`); apply mode-appropriate weighting; write to
  `docs/superpowers/objections/<slug>.md` (spec mode) or
  `docs/superpowers/objections/<slug>-code.md` (code mode); add `mode:` field to
  frontmatter
- Update `commands/diaboli.md` and `.github/prompts/diaboli.prompt.md` to accept
  optional `--mode` flag; extend validation checkpoint to verify `mode:` field and
  mode-appropriate required frontmatter fields explicitly
- Update `agents/orchestrator.agent.md` — add code-time dispatch (step 4a) after
  code-reviewer loop exits (PASS or escalation); add Integration Approval gate
  that refuses while any code-mode disposition is `pending`; extend context object
  with `code_diaboli_slug` field
- Rename HARNESS.md constraint from "Spec has adjudicated objections" to "PRs have
  adjudicated objections"; extend rule to require both spec-mode and code-mode
  records; extend "Objection record freshness" GC rule to cover both record types
- Extend `commands/superpowers-status.md` Section 7 Diaboli panel with mode-split
  breakdown (spec-mode and code-mode separately) and overall totals for backward
  compatibility
- Extend `skills/harness-observability/references/snapshot-format.md` Diaboli
  section with mode-split field definitions and computation table
- Update `skills/advocatus-diaboli/references/observability.md` with mode-split
  field definitions and cross-mode interpretation patterns (code-time counts
  trending up/down, distribution divergence)
- Update `MODEL_ROUTING.md` and `templates/MODEL_ROUTING.md` — note code-time
  dispatch routes to most-capable tier; judgment load equivalent across modes
- Update `templates/HARNESS.md` — extended constraint and GC rule for new projects
- Add ARCH_DECISION to `AGENTS.md` — one agent, two dispatches; alternatives
  considered and rejected; conditions for revisit at 20+ PRs
- Update `README.md` — pipeline diagram shows both dispatch points and both gates;
  Agents table row updated; agent count unchanged at 12
- Update `docs/explanation/adversarial-review.md` — intro and three-loops section
  describe both dispatch modes; disposition patterns section notes mode-split stats
- Update `docs/how-to/review-a-spec-adversarially.md` — code mode documented with
  `--mode code` flag, output path, and integration-approval gate

## 0.25.0 — 2026-04-19

### Feature — diaboli observability panel

- Add Diaboli panel to `commands/superpowers-status.md` (Section 7) — surfaces
  in-scope vs exempt spec count, objection records present, in-scope specs without
  a record, fully-resolved record rate, objections total with severity breakdown,
  mean objections per spec, disposition distribution, and median days
  spec-to-disposition; summary uses standard `OK`/`MISSING` tokens; error handling
  for malformed YAML frontmatter
- Add Diaboli section to snapshot format (`skills/harness-observability/references/
  snapshot-format.md`) after Session Quality and before Operational Cadence, with
  field computation table
- Update `commands/harness-health.md` — Diaboli included in required section list;
  step 7 validation updated from 12 to 13 required section headings with Diaboli
  in enumerated list
- Update `skills/harness-observability/SKILL.md` — reference to Diaboli panel added
- Add `skills/advocatus-diaboli/references/observability.md` — metric computation
  definitions, interpretive notes, and watch-for patterns (what each field means
  and what it does NOT mean)
- Fix `commands/diaboli.md` validation checkpoint — category and severity taxonomy
  corrected to match SKILL.md: premise/scope/implementation/risk/alternatives/
  specification quality and critical/high/medium/low
- Add ARCH_DECISION to `AGENTS.md` — observability-before-enforcement principle,
  revisit conditions (10 fully-resolved records or 2026-07-19)
- Update `docs/explanation/adversarial-review.md` — disposition patterns section
  now references Diaboli panel surfaces; three-loops section adds observability loop
- Update `docs/how-to/review-a-spec-adversarially.md` — "What you have now" notes
  that disposition patterns accumulate and are visible in status/health surfaces

## 0.24.0 — 2026-04-19

### Docs and taxonomy — advocatus-diaboli coverage and SKILL.md update

- Add `docs/explanation/adversarial-review.md` — standalone explanation of
  the Promoter Fidei precedent, Popperian falsifiability, the Schopenhauer
  non-goal, the human-cognition gate, and disposition patterns as signals
- Add `docs/how-to/review-a-spec-adversarially.md` — practical guide for
  running `/diaboli`, reading the objection record, and writing dispositions
- Update `docs/reference/commands.md` — add `/diaboli` entry with correct
  taxonomy; count updated to 22
- Update `docs/reference/agents.md` — add `advocatus-diaboli` agent entry;
  count updated to 12; pipeline description updated to six-stage sequence
- Update `docs/explanation/agent-orchestration.md` — pipeline diagram now
  shows advocatus-diaboli and two human gates; "Where This Breaks Down"
  names the structural solution; duplicate link removed from Further Reading
- Update `docs/tutorials/first-time-tour.md` — `/diaboli` section added;
  count updated to twenty-two
- Update `skills/advocatus-diaboli/SKILL.md` — category taxonomy updated
  to premise/scope/implementation/risk/alternatives/specification quality;
  severity updated to critical/high/medium/low (replaces major/minor);
  change driven by spec-first review of the docs work itself via /diaboli

## 0.23.0 — 2026-04-19

### Feature — advocatus-diaboli adversarial spec review

- Add `skills/advocatus-diaboli/SKILL.md` — charter for the adversarial
  spec reviewer: six objection categories (premise, design, threat, failure,
  operational, cost), severity levels (major/minor), 12-objection cap,
  evidence requirement per objection, mandatory "Explicitly not objecting to"
  section; intellectual foundations grounded in the historical Promoter of
  the Faith, Popper on falsifiability, and an explicit anti-Schopenhauer
  framing (no rhetorical tricks, no winning for its own sake)
- Add `agents/advocatus-diaboli.agent.md` — read-only agent (Read/Glob/Grep
  only) that reads a spec and returns objection record content to the
  orchestrator; disposition fields cannot be written by any agent — this
  constraint is the human-cognition gate
- Add `commands/diaboli.md` — `/diaboli <spec-path>` for manual invocation
  and regeneration; includes a 10-point validation checkpoint per the
  output-validation-checkpoints constraint
- Add `.github/prompts/diaboli.prompt.md` — Copilot CLI equivalent
- Update `agents/orchestrator.agent.md` — pipeline is now: spec-writer →
  advocatus-diaboli → GATE (objection adjudication, blocked on `pending`) →
  GATE (plan approval with adjudicated record) → tdd-agent → …
- Update `HARNESS.md` — add "Spec has adjudicated objections" constraint
  (agent-enforced, scope pr) with pre-2026-04-19 exemption; add "Objection
  record freshness" GC rule (deterministic, weekly)
- Update `templates/HARNESS.md` — new projects scaffolded by `/superpowers-init`
  inherit both the constraint and the GC rule
- Update `MODEL_ROUTING.md` — advocatus-diaboli routed to most-capable tier
  (judgment-heavy, not throughput-heavy)
- Update `AGENTS.md` — ARCH_DECISION: diaboli hard-wired as PR constraint
  from the outset; rejected alternatives documented (manual-only, advisory
  gate, deterministic schema check alone)
- Create `docs/superpowers/objections/` — directory for objection records

## 0.22.0 — 2026-04-17

### Docs — first-time tour tutorial

- Add `docs/tutorials/first-time-tour.md` — a single route through
  every plugin capability in the order it is most useful on a first
  run, with the reason each step comes where it does; grouped into
  eight phases (orient, foundation, measure, adjust, learning loop,
  governance, cadence, share and scale) plus two day-to-day
  capabilities (`/worktree`, `/harness-upgrade`)
- Point `docs/tutorials/getting-started.md` "Next Steps" at the new
  tour so first-time users land on it naturally after the
  installation walkthrough
- Docs-only change; no plugin version bump (0.22.0 retained)

### Docs — surfacing-tacit-knowledge tutorial

- Add `docs/tutorials/surfacing-tacit-knowledge.md` — a five-phase
  walkthrough for turning tacit team knowledge into versioned,
  enforceable artefacts: scaffold the habitat with
  `/superpowers-init`, run guided extraction with
  `/extract-conventions`, mine existing code/PRs/wikis with AI,
  introduce lightweight ADRs captured in flow (plus `/reflect` for
  micro-decisions), and generate team-specific onboarding with
  `/harness-onboarding`. Each command is explained in terms of why
  it comes where it does and what it produces, with an ATM
  scheduling-service running example and a closing flywheel that
  turns the one-time exercise into a quarterly habit
- Docs-only change; no plugin version bump (0.22.0 retained)

### CLAUDE.md — CHANGELOG heading format made explicit

- Rewrite the "CHANGELOG" section of `CLAUDE.md` to state the hard
  invariant enforced by the `Check version consistency` CI step:
  every top-level `## ...` heading MUST begin with a semver version
  (`## X.Y.Z — YYYY-MM-DD`). Date-only headings silently parse as the
  first token (for example `2026`) and fail CI with a cryptic
  mismatch error.
- Make the docs-only path explicit: append entries under the most
  recent version's heading; do not create a new top-level heading
  without a version. Closes the recommendation from the 2026-04-16
  reflection that had gone unactioned and caused a repeat CI failure
  on PR #173 (captured in the 2026-04-18 reflection).

### Harness template-version marker bump

- Bump `HARNESS.md` template-version marker 0.21.0 → 0.22.0 after
  running `/harness-upgrade`; no new constraints, GC rules, or sections
  to adopt (template content is unchanged since 0.19.0 — the plugin
  version advanced three releases without template edits)
- Silences the template-currency GC finding until the next plugin
  upgrade introduces new template content

### Marketplace source schema fix

- Fix `source` field in `.claude-plugin/marketplace.json` — bare string
  form (`"ai-literacy-superpowers"`) from #164 is rejected by the
  Claude Code marketplace schema with `plugins.0.source: Invalid input`;
  restore the required `./` prefix (`"./ai-literacy-superpowers"`) so
  `claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers`
  parses again
- Bump listing `version` 0.2.2 → 0.2.3 (source path is a listing
  contract change per CLAUDE.md); `plugin_version` unchanged
- Documented behaviour: marketplace `source` as a plain string must be
  a relative path starting with `./`; the runtime resolves it to the
  plugin directory and loads `.claude-plugin/plugin.json` from there

### Copilot CLI install instructions

- Fix README Copilot CLI install block — add missing
  `copilot plugin marketplace add` step and correct the install
  command to `copilot plugin install ai-literacy-superpowers@ai-literacy-superpowers`
  so users on Copilot CLI can actually install the plugin without
  hitting "plugin not found"
- Mirror the corrected install block in `docs/index.md` Quick Install
  so the docs site and README agree; Claude Code and Copilot CLI
  steps are now shown side-by-side in both places
- Partial fix for #168 (leaves `docs/how-to/install-the-plugin.md`
  how-to page and `docs/tutorials/getting-started.md` tutorial-step
  update for a follow-up)

### Marketplace cache auto-sync

- Add `ai-literacy-superpowers/scripts/sync-marketplace-cache.sh` —
  fast-forwards `~/.claude/plugins/marketplaces/ai-literacy-superpowers`
  when `marketplace.json` on `origin/main` differs from the cached
  copy (any byte difference — covers listing version, `plugin_version`,
  and per-plugin version bumps); no-ops silently when cache missing,
  offline, or already current
- Complements the existing `sync-to-global-cache.sh` (plugin content
  sync); this script handles the marketplace-clone side
- Wire via a `PostToolUse` hook on `Bash(gh pr merge*)` in
  `.claude/settings.local.json` so the cache refreshes the moment a
  marketplace-affecting PR is merged through the CLI
- Document the rule under **Marketplace Cache Auto-Sync** in CLAUDE.md
  so collaborators can opt in by adding the same hook locally

## 0.21.0 — 2026-04-15

### Observatory signal verification

- Add /observatory-verify command — runs the 82-signal checklist
  against the latest output files, reporting PRESENT/PARTIAL/MISSING
  status for each signal the Observatory expects to read
- Add observatory-signals.md reference — the authoritative checklist
  of all signals across 5 sources (snapshot, governance, reflections,
  HARNESS.md, assessments)

## 0.20.0 — 2026-04-15

### Human-readable harness onboarding

- Add /harness-onboarding command — generates ONBOARDING.md from
  HARNESS.md, AGENTS.md, and REFLECTION_LOG.md for new team members
- Add harness-onboarding skill — tone guidelines and section mapping
  for human-readable onboarding document generation
- Add ONBOARDING.md template with 10 section skeleton and placeholder
  markers
- Add onboarding document staleness GC rule (monthly) to both the
  template and the project's own HARNESS.md
- Command includes a validation checkpoint verifying all 10 sections
  are present and no placeholder markers remain
- Generated ONBOARDING.md is linked from the project README

Closes #37.

## 0.19.4 — 2026-04-15

### Output validation checkpoints

- Add validate-and-fix-in-place checkpoint to /harness-health —
  verifies all 12 snapshot sections present, no deprecated YAML block
- Add validation checkpoint to /assess — verifies assessment document
  has required sections and parseable level number for portfolio
  aggregation
- Add validation checkpoint to /reflect — verifies all 8 mandatory
  fields plus 4 session metadata subfields and Signal enum value
- Add validation checkpoint to /cost-capture — verifies cost snapshot
  has fields that /harness-health needs for Cost Indicators section
- Add validation checkpoint to /harness-constrain — verifies
  constraint block has required fields with valid enum values
- Add validation checkpoint to /harness-init — verifies generated
  HARNESS.md has all top-level sections, subsections, and template
  version marker
- Add validation checkpoint to /superpowers-init — verifies all 4
  habitat files (CLAUDE.md, AGENTS.md, MODEL_ROUTING.md,
  REFLECTION_LOG.md) have required sections

## 0.19.3 — 2026-04-15

### Governance Summary validation checkpoint

- Add step 5 to /governance-audit command: validate the Governance
  Summary section after the governance-auditor agent writes the report,
  fixing heading, field count, and value formats in place rather than
  re-dispatching the agent
- Strengthen governance-auditor agent instructions: mark the Governance
  Summary section as a critical format contract, add self-check
  instruction, explicitly forbid 0-based drift stage scale
- Fix existing governance audit report to use the correct
  `## Governance Summary` heading with all nine structured fields

## 0.19.2 — 2026-04-15

### Observatory signal completeness

- Add GC cadence compliance field to snapshot format — reports whether
  GC runs are within declared schedule, not just the last run date
- Add per-activity overdue annotations to Operational Cadence section —
  each activity now shows on-schedule/overdue status with target cadence
- Add `inactive` as third Learning flow state for projects with zero
  reflections, alongside existing `active` and `stalled`
- Add `Cadence compliance` and `Health` fields to Meta section template
  with full computation instructions — previously produced by agents
  but undocumented in the format spec
- Enforce `## Governance Summary` heading in governance-auditor output
  (was `## Summary`) — fixes regex parsing for Observatory consumers
- Require all nine Governance Summary fields to be present even when
  values are zero, with explicit computation instructions for each
- Enforce numeric `N/5` format for Semantic drift stage (was
  qualitative) and add `Frame alignment score` percentage computation

## 0.19.1 — 2026-04-15

### Markdownlint compliance

- Fix all 58 pre-existing markdownlint violations across articles, docs,
  commands, templates, and observability snapshots — MD036 (emphasis as
  heading), MD040 (code fence language), MD033 (inline HTML), MD001
  (heading increment), MD032 (blanks around lists), and others
- Upgrade HARNESS.md to template 0.19.0 with Observability section and
  governance constraint template; correct audit status counts and badge

### Version bump scoping

- Scope version bump requirement to `ai-literacy-superpowers/` plugin
  directory only — changes outside the plugin (articles, docs, CI,
  root config) no longer trigger the CI version bump check
- Add `no-bump` PR label exemption for formatting-only fixes to plugin
  files that don't warrant a version bump
- Update CLAUDE.md convention, HARNESS.md constraint, and
  version-check.yml workflow to reflect the scoped rules

## 0.19.0 — 2026-04-15

### Dev workflow — global plugin sync

- Add sync-to-global-cache.sh script and Stop hook in
  settings.local.json — syncs local plugin to the global Claude Code
  cache at session end so the installed version always reflects the
  working copy

### Harness template — Observability section

- Add `## Observability` section to HARNESS.md template with snapshot
  cadence, operating cadence, health thresholds, and regression
  detection configuration — new harnesses now include self-monitoring
  defaults out of the box

### Harness upgrade — adopt 0.18.1 template content

- Accept all new template items: 2 constraints (Tests must pass,
  Spec conformance), 4 active GC rules (Dependency currency,
  Observability archive, Convention file sync, Reflection-driven
  regression detection), and 7 commented-out GC rules (governance
  and fitness function templates)
- Update template-version marker to 0.19.0

## 0.18.1 — 2026-04-15

### Repo cleanup

- Remove 6 stale root-level directories (agents, commands, hooks,
  skills, scripts, templates) — all content already exists in the
  `ai-literacy-superpowers/` plugin directory
- Move template-currency-check.sh into plugin and wire up as
  SessionStart hook — completes the hook that 0.18.0 described
  but did not ship

## 0.18.0 — 2026-04-15

### Template adoption

- Add `/harness-upgrade` command — structural diff between user's
  HARNESS.md and plugin template, with accept/skip menu for new
  constraints, GC rules, sections, and optional blocks
- Add SessionStart hook for template currency — nudges user when
  plugin template has been updated since their harness was generated
- Add Template currency GC rule to template — weekly persistent
  reminder for un-reviewed template content
- Add `template-version` marker to generated HARNESS.md files for
  upgrade tracking
- Consolidate two diverged template files into single canonical copy
  at `ai-literacy-superpowers/templates/HARNESS.md`

## 0.17.1 — 2026-04-15

### Lint fix

- Fix markdownlint MD060 table separator spacing across 52 files —
  formatting only, no content changes

## 0.17.0 — 2026-04-15

### Release governance

- Add first governance constraint: release traceability — every
  plugin version must have a matching changelog heading and git tag
- Add auto-tag workflow (`.github/workflows/auto-tag.yml`) that
  creates `vX.Y.Z` tags on merge when the version changes
- Add "Release tag completeness" GC rule with auto-fix for missing
  tags
- HARNESS.md Status: 12/12 constraints enforced, 3/8 GC rules active

## 0.16.0 — 2026-04-15

### Observatory rebase: YAML to markdown

- Remove `observatory_metrics` YAML block from snapshot format and
  generation — snapshots now contain only markdown sections that
  agents read natively
- Delete `observatory-metrics-schema.md` — schema versioning is no
  longer needed; format evolution is handled by Claude's natural
  ability to read markdown regardless of structural changes
- Delete `observatory-events.md` and stop appending to
  `observability/events.jsonl` — event tracking is replaced by the
  new "Changes Since Last Snapshot" markdown section in each snapshot
- Remove `observability/violations.jsonl` and all violation logging
  from CI workflows (`harness.yml`, `gc.yml`) and advisory hook — CI
  failure annotations and GC findings already capture this data
- Downgrade CI workflow permissions from `contents: write` to
  `contents: read` (no longer committing violations.jsonl)
- Replace governance YAML block in `governance-auditor` with a
  markdown Governance Summary section containing all expanded metrics
- Remove `observatory_portfolio` YAML block from portfolio assessment
  — habitat aggregates are now a markdown section reading snapshot
  markdown directly
- Add Regression Indicators section to snapshots — stale detection,
  cadence non-compliance counting, consecutive zero-reflection weeks,
  and composite regression flag
- Add Enforcement Loop History section to snapshots — tracks when
  advisory, strict, and investigative loops were first activated
  using git history
- Add Changes Since Last Snapshot section — captures constraint
  lifecycle (added, promoted, removed) and completed assessments and
  audits by diffing against the previous snapshot
- Add Habitat Aggregates section to portfolio assessment template
- Remove event emission instructions from `/reflect`,
  `/harness-constrain`, `/assess`, and governance-auditor commands
- Update governance-observability skill to use markdown format
  instead of YAML for metrics catalogue and snapshot extension

## 0.15.2 — 2026-04-14

### Bug fix

- Fix intermittent YAML block omission in harness-health snapshots —
  split Step 6 into separate markdown generation and YAML block steps
  with mandatory marker and self-verification checkpoint. The trailing
  instruction was unreliable under cognitive load from trend computation.

## 0.15.1 — 2026-04-14

### Bug fix

- Fix `gc-rotate.sh` crash when HARNESS.md has no `## Observability`
  section — `set -euo pipefail` caused the grep pipeline to exit
  non-zero before reaching the default cadence fallback. Added
  `|| true` to let empty results fall through. Fixes #122.

## Marketplace 0.2.1 — 2026-04-14

### GC findings fix

- Fix `marketplace.json` nested `plugins[0].version` stuck at "0.1.0" —
  updated to "0.15.0" to match `plugin.json`
- Align `plugins[0].description` with `plugin.json` description
- Bump marketplace listing version to 0.2.1

## 0.15.0 — 2026-04-14

### Observatory Tier 3: Violation Tracking, Portfolio Metrics, Event Log

- Add violation tracking via `observability/violations.jsonl` — advisory
  hook, CI constraint checks, and GC workflow now log detected violations
  as JSON Lines entries with timestamp, loop, constraint, and context
- Add violation latency metrics to snapshot YAML block —
  `feedback_loops.latency` with per-loop counts and `violations_total`
- Add `observatory_portfolio` YAML block to portfolio assessment reports
  with summary, level distribution, habitat aggregates (mean enforcement
  ratio, learning velocity, GC active ratio, context depth), gaps,
  outliers, and per-project detail
- Add Observatory event log at `observability/events.jsonl` — 10 event
  types tracking state transitions (snapshot creation, assessments,
  governance audits, constraint lifecycle, regression transitions,
  reflections, cadence configuration)
- Add event emission to `/harness-health`, `/reflect`,
  `/harness-constrain`, `/assess`, and `governance-auditor`
- Add `observatory-events.md` reference documenting event log format,
  event types, and emission matrix
- Bump Observatory metrics schema to 1.2.0 (backwards-compatible)

## 0.14.0 — 2026-04-14

### Observatory Tier 2: Regression Detection, Loop Tracking, Session Metadata

- Add `regression_indicators` section to Observatory YAML block —
  `snapshot_stale`, `cadence_non_compliant_count`,
  `consecutive_zero_reflection_weeks`, and composite `regression_flag`
- Expand `feedback_loops` with per-loop `active` and `first_activated`
  date fields, determined via git history lookups with caching
- Add session metadata to reflection entries — duration, model tiers
  used, pipeline stages completed, and agent delegation mode
  (best-effort, "unknown" always valid)
- Standardise governance audit YAML block with `schema_version`,
  `falsifiable_count`, `vague_count`, `drift_stage`, and
  `debt_total_score` fields
- Support configurable snapshot cadence via HARNESS.md Observability
  section — weekly (10d), fortnightly (21d), monthly (30d, default).
  Staleness check scripts and meta-observability checks now respect
  the configured threshold
- Bump Observatory metrics schema to 1.1.0 (backwards-compatible)

## 0.13.0 — 2026-04-14

### Observatory-Ready Metrics

- Add YAML metrics block to harness health snapshots — structured,
  typed `observatory_metrics` block appended after all markdown
  sections, enabling machine consumption without brittle regex parsing
- Add per-context-layer freshness tracking in `context_depth.layers` —
  each of the five context layers reports `present` and `last_modified`
- Add per-constraint enforcement detail in `constraint_maturity.constraints` —
  each constraint listed with name, tier, and enforced status
- Add observatory metrics schema documentation with versioning policy
  (patch/minor/major) and changelog at
  `references/observatory-metrics-schema.md`

## 0.12.0 — 2026-04-13

### Governance Dimension Support

- Add `governance-auditor` agent for deep governance investigation —
  semantic drift analysis, governance debt inventory, constraint
  falsifiability scoring, three-frame alignment checks
- Add `governance-constraint-design` skill with falsifiability test,
  three-frame translation method, anti-patterns gallery, and
  governance constraint template
- Add `governance-audit-practice` skill with five-stage semantic drift
  model, governance debt scoring matrix, and audit methodology
- Add `governance-observability` skill with metrics catalogue, snapshot
  format extension, and HTML dashboard specification
- Add `/governance-audit` command for quarterly deep governance
  investigation
- Add `/governance-constrain` command for guided governance constraint
  authoring with three-frame alignment check
- Add `/governance-health` command for governance health pulse check
  and dashboard generation
- Add governance drift check stop hook — detects governance-related
  file changes and audit staleness at session end
- Extend `harness-enforcer` agent with governance constraint quality
  gate — checks falsifiability, operational meaning, and frame
  alignment for governance constraints
- Extend `assessor` agent with governance dimension in assessment
  output — governance ALCI items, readiness summary, improvement
  recommendations
- Extend `harness-gc` agent with governance GC rules — constraint
  freshness, semantic drift early warning, governance debt cycle check
- Extend HARNESS.md template with governance constraint example and
  governance GC rules

## 0.11.0 — 2026-04-12

### Spec-First Discipline Gate

- Add spec-first commit ordering CI workflow — deterministic gate that
  verifies the first commit on feature branches contains only a spec
  file, with exemptions for bug-fix and maintenance PRs
- Add "Spec-first commit ordering" constraint to HARNESS.md —
  deterministic enforcement via the new CI workflow
- Add "Spec captures intent" constraint to HARNESS.md — agent review
  checking that specs describe problem, approach, and expected outcome
- Extend harness-enforcer agent with spec intent review guidance

## 0.10.0 — 2026-04-11

### Independent Marketplace Listing Versioning

- Add `plugin_version` field to `marketplace.json` — the listing now
  explicitly declares which plugin release it approves
- Add marketplace versioning convention to CLAUDE.md — agents know
  when to bump listing version vs update plugin pointer
- Add marketplace plugin version sync constraint to HARNESS.md —
  CI blocks PRs where `plugin_version` diverges from `plugin.json`
- Add marketplace listing drift GC rule to HARNESS.md — weekly
  check that listing metadata hasn't drifted from plugin metadata
- Extend `version-check.yml` to enforce marketplace sync on every PR
- Add updating guide to README and docs for plugin and marketplace

## 0.9.4 — 2026-04-11

### Documentation Completion

- Complete commands reference page — all 15 commands with skills,
  agents, flags, and modes documented
- Complete agents reference page — all 10 agents with tools, dispatch
  sources, trust boundaries, and design principles
- Complete templates reference page — all 10 templates with purpose,
  key sections, and generation commands
- Add The Loops That Learn explanation page and wire into docs nav
- Add Human Pace how-to guide covering constraint, GC rule, and
  assessment signals
- Fix stale component counts in GitHub Pages design spec (18→24
  skills, 13→15 commands)

## 0.9.3 — 2026-04-11

### Human Pace Template and Assessment Signals

- Add spec-scoped changes constraint to template HARNESS.md — new
  projects get one-concern-per-PR enforcement by default
- Add change cadence drift GC rule to template HARNESS.md — weekly
  monitoring of PR size distribution and cycle time
- Add Human Pace observable evidence signals to assessment skill at
  L2 (TDD-paced diffs), L3 (spec-scoped constraint, cadence drift GC),
  L4 (spec-to-PR mapping), and L5 (cadence metrics as health signal)

## 0.9.2 — 2026-04-10

### Bug Fix

- Fix curation-nudge Stop hook arithmetic error — `grep -c` outputs 0
  to stdout before exiting non-zero under `set -e`, causing the
  `|| echo "0"` fallback to produce `"0\n0"` which breaks arithmetic.
  Fixed both `reflection_count` (line 27) and `promoted_count` (line 42)
  to use `|| var=0` pattern instead.

## 0.9.1 — 2026-04-10

### Article 08: The Loops That Learn

- Add Article 08 — how four recurring practices (/reflect,
  /harness-health, /assess, /cost-capture) create interlocking
  feedback loops at four timescales, connect to the six literacy
  levels, and aggregate into the portfolio view

## 0.9.0 — 2026-04-10

### Cost Tracking

- Add cost-tracking skill — guides quarterly AI cost data capture from
  provider dashboards, records structured cost snapshots, compares
  trends, and updates MODEL_ROUTING.md with observed patterns
- Add /cost-capture command — interactive cost capture with provider
  dashboard guidance, comparison to previous snapshot, budget check
- Expand snapshot format Cost Indicators section with actual fields:
  last capture date, monthly average, budget status, cost trend
- Update /harness-health to read from observability/costs/ directory
- Add "Track AI Costs" how-to guide
- Closes the cost visibility gap identified in the L5 assessment

## 0.8.3 — 2026-04-10

### Reflection-Driven Improvements

- Add how-to template file (`docs/how-to/_template.md`) — explicit
  structure for subagents writing how-to guides, removing style
  inference from examples
- Add CI version consistency check (`version-check.yml`) — verifies
  plugin.json, README badge, and CHANGELOG heading all match, and
  that skill/agent/command changes trigger a version bump
- Add version consistency constraint to HARNESS.md (7/7 enforced)

## 0.8.2 — 2026-04-09

### Complete Tutorial Set

- Fill 2 tutorial stubs: Harness for an Existing Codebase, Creating
  Your First Skill
- Add 3 new tutorials: Your First Assessment, From Assessment to
  Dashboard, The Improvement Cycle
- Total: 6 tutorials covering the full journey from setup through
  measurement, scaling, and improvement

## 0.8.1 — 2026-04-09

### Complete How-To Guides

- Fill 5 stub how-to guides: add a constraint, add fitness functions,
  run a harness audit, set up auto-enforcer, sync conventions
- Add 16 new how-to guides covering all remaining skills: run an
  assessment, extract conventions, set up context engineering, review
  code with CUPID, audit dependencies, audit Docker images, harden
  GitHub Actions, set up garbage collection, write literate code,
  set up verification slots, set up model routing, run portfolio
  assessment, generate improvement plan, orchestrate across repos,
  create team API, understand harness engineering
- Total: 23 how-to guides (was 7, of which 5 were stubs)

## 0.8.0 — 2026-04-09

### Team API Skill

- Add team-api skill — create or update Team Topologies Team API
  documents with AI literacy portfolio assessment data
- Template mode generates a full Team API with AI Literacy section,
  communication preferences, services, dependencies, and ways of
  working
- Update mode adds or refreshes the AI Literacy section in an existing
  Team API document, preserving all other sections
- Includes Team API template in references/team-api-template.md

## 0.7.1 — 2026-04-09

### Agent Harness Enabled Topic Tag

- Add automatic `agent-harness-enabled` GitHub topic tagging to
  /harness-init (after commit) and /assess (at L3+)
- Add Agent Harness Enabled badge (black) to README
- Tag signals to portfolio assessments that a repo has a harness

## 0.7.0 — 2026-04-09

### Portfolio Dashboard Skill

- Add portfolio-dashboard skill — generates a self-contained HTML
  dashboard from portfolio assessment data with level distribution,
  repo table, shared gaps, improvement plan, and trend visualisation
  from multiple quarterly assessments
- Dashboard is single HTML file with inline CSS, no external
  dependencies, works offline, shareable via email or Slack

## 0.6.1 — 2026-04-09

### Documentation

- Add "Build an AI Literacy Portfolio Dashboard" how-to guide —
  step-by-step guide to generating a self-contained HTML dashboard
  from portfolio assessment data with trend visualisation from
  multiple quarterly assessments

## 0.6.0 — 2026-04-09

### Portfolio Assessment

- Add portfolio-assessment skill — aggregates AI literacy assessments
  across multiple repos into an organisational portfolio view with
  level distribution, shared gaps, outliers, and improvement plans
- Three discovery modes: local directories, GitHub org, GitHub topic
  tags — combinable for flexible portfolio scoping
- Lightweight evidence-only scan for repos without prior assessments —
  estimates level from observable signals via GitHub API without
  running a full assessment
- Portfolio improvement plan groups actions by impact scope:
  organisation-wide (50%+ repos), cluster (2-4 repos), individual
- Add /portfolio-assess command with --local, --org, --topic, and
  --no-scan-unassessed flags

## 0.5.0 — 2026-04-09

### Literacy Improvements Skill

- Add literacy-improvements skill — generates prioritised improvement
  plans from assessment gaps, mapping each gap to the specific plugin
  command or skill that closes it
- Includes improvement-mapping reference with level-to-action tables
  for L1→L2, L2→L3, L3→L4, and L4→L5 transitions
- Users choose a target level (next level or higher) and walk through
  improvements interactively with accept/skip/defer
- Integrates with /assess as Phase 5b — invoked automatically after
  workflow recommendations
- Also usable standalone when the user knows their current level

## 0.4.1 — 2026-04-09

### Companion Article

- Add Article 07 (The Assessment Practice) — companion to The
  Environment Hypothesis series covering assessment as a recurring
  quarterly discipline, the six literacy levels as diagnostic positions,
  evidence-based scoring, and how assessment feeds the learning loop

## 0.4.0 — 2026-04-08

### Article Updates

- Update Article 06 (The Learning Loop) with signal classification
  taxonomy and Feedback Flywheel citation — reflections now classify
  their signal type to route learnings during curation

### Model Sovereignty Skill

- Add model-sovereignty skill to the plugin — decision framework for
  model selection, hosting, fine-tuning, and vendor independence with
  three reference files (decision framework, hosting options, technique
  comparison)

### README Component Counts

- Update skills badge and section from 14 to 18 — add secrets-detection,
  auto-enforcer-action, convention-sync, and fitness-functions to the
  skills table
- Update commands badge and section from 12 to 13 — add /convention-sync
  to the commands table

### Feedback Flywheel Integration

- Add signal classification to reflections — each reflection now
  captures a signal type (context, instruction, workflow, failure, none)
  that routes the learning to the right harness component during curation,
  adopting the taxonomy from Birgitta Boeckeler's Feedback Flywheel article
- Add vocabulary mapping section to compound learning docs — maps plugin
  concepts to the Feedback Flywheel article's terminology with direct
  citation and links
- Add Feedback Flywheel article to further reading in compound learning
  and self-improving harness explanation pages
- Add Session Quality section to health snapshot format — tracks signal
  classification metrics (reflections with signal percentage, distribution
  by type, quality trend) derived from the new Signal field
- Update /harness-health command to gather and display Session Quality
  metrics in snapshots and delta summaries

### Organisation Transfer

- Update all references from russmiles to Habitat-Thinking after
  GitHub repo transfer — README badges, docs site config, install
  commands, and getting-started tutorial

### Documentation Fixes

- Fix docs homepage Quick Install section to use the correct two-step
  marketplace install commands matching the getting-started tutorial

### Three-Loop Improvements

- Add markdownlint to CI workflow — closes gap between declared and
  enforced constraints, bringing inner loop enforcement to 100%
- Create AGENTS.md with initial curated entries from REFLECTION_LOG —
  unblocks the compound learning promotion lifecycle
- Add weekly GC GitHub Action running deterministic GC rules (secret
  scanner operational, snapshot staleness, shell syntax, strict mode)
- Add rotating GC Stop hook that checks one rule per session by
  day-of-year rotation — catches entropy between weekly CI runs
- Add curation nudge Stop hook that detects unpromoted reflections
  and nudges curation into AGENTS.md
- Add markdownlint PreToolUse command hook for deterministic .md file
  checking alongside the existing prompt-based constraint evaluation
- Update HARNESS.md status: 6/6 constraints enforced, 2/5 GC active
- Generate health snapshot with trend comparison

### Documentation Alignment

- Update README badges (6/6 enforced, snapshot link to 2026-04-08),
  hook count (5→8), hook list, and mechanism map to reflect new hooks
  and GC execution mechanisms
- Update three-enforcement-loops explanation page: inner loop now
  describes 2 PreToolUse hooks and 7 Stop scripts
- Add "How GC Rules Are Triggered" section to garbage-collection
  explanation page covering weekly CI, rotating Stop hook, and manual
  invocation
- Populate hooks reference page (was "Coming Soon" stub) with full
  catalogue of all 8 hooks including design principles

## 0.3.0 — 2026-04-07

### Selective Harness Init

- Enhance /harness-init with feature selection menu — users choose which
  harness features to configure (context, constraints, GC, CI,
  observability) with all selected by default
- Support additive re-runs — existing configuration is preserved when
  adding new features incrementally
- Gate each conversational step on feature selection so users only
  answer questions for features they chose
- Update Getting Started tutorial with feature selection walkthrough,
  re-run guidance, and per-feature generation notes
- Update homepage with selective init description
- Update harness engineering explanation with incremental adoption paragraph

### Habitat Engineering Documentation

- Add habitat engineering explanation page covering the intellectual
  lineage (Alexander, Gabriel, Knuth, Terhorst-North), the central
  insight that AI failures are environment problems, habitat vs harness
  distinction, the six levels of AI literacy, and links to Software
  Enchiridion articles

### GitHub Pages Build Fix

- Fix Jekyll build by changing color_scheme from "default" to "light" —
  just-the-docs v0.12.0 renamed the default color scheme file from
  default.scss to light.scss, causing "Can't find stylesheet to import"

### Documentation Site

- Add GitHub Pages documentation site using Jekyll + just-the-docs theme
- Organize content using the Diataxis framework (tutorials, how-to,
  reference, explanation)
- Full pages: Getting Started tutorial, Set Up Secret Detection how-to,
  Skills reference catalogue, Harness Engineering explanation
- Stub pages for 17 additional topics ready for future content

### Auto-Constraint from Reflections

- Add auto-constraint proposal step to `/reflect` command — after
  capturing a reflection, the command now detects preventable failures
  in the Surprise and Improvement fields and offers to draft a
  constraint via `/harness-constrain`
- Add optional Constraint field to REFLECTION_LOG.md template — makes
  constraint proposals machine-readable for the regression suite GC rule

### Learnings in Agent Context

- Update orchestrator agent to read the 20 most recent REFLECTION_LOG.md
  entries at pipeline start — past reflections now inform approach decisions
- Update harness-enforcer agent to read the 10 most recent reflections
  before agent-based constraint checks — calibrates scrutiny to known gaps
- Update harness-gc agent to read the 10 most recent reflections when
  running GC rules — entropy signals from reflections guide deeper checks
- Add Learnings section to CLAUDE.md template advising agents to consult
  REFLECTION_LOG.md before starting work

### Regression Suite GC Rule

- Add reflection-driven regression detection GC rule to HARNESS.md
  template — weekly agent check that mines REFLECTION_LOG.md for
  recurring failure patterns not yet covered by constraints
- Add learning-driven GC category to the GC skill and catalogue —
  a new class of GC rules that use compound learning artifacts
  (reflections, assessments) as input rather than scanning code

### Self-Improving Harness (from auto-harness research)

- Add design spec for auto-constraint generation from reflections —
  closes the learning loop by offering to create constraints when
  reflections describe preventable failures
- Add design spec for regression suite GC rule — mines
  REFLECTION_LOG.md for recurring failure patterns and proposes
  constraints for uncovered themes
- Add design spec for feeding learnings into agent context —
  orchestrator, enforcer, and GC agents read recent reflections
  to avoid repeating past mistakes

### Complexity Hotspot Detection

- Expand fitness-functions skill with practical hotspot detection
  guide — churn extraction command, per-ecosystem complexity tools,
  worked Python example, and 3-snapshot threshold rule
- Expand fitness catalogue with complete bash script for churn x
  complexity correlation, annotated example output, and ecosystem
  prerequisites

### Executable Spec Integration

- Add executable spec constraint pattern to constraint-design skill —
  documents how to wire test suites into the harness as a spec
  conformance constraint, including the deterministic + agent
  enforcement pattern and BDD/Cucumber as gold standard
- Add commented-out spec conformance constraint to HARNESS.md template
  for projects using spec-first development

### Dependency Age Budget (libyear)

- Add dependency age (libyear) section to the dependency-vulnerability-audit
  skill — covers what libyear measures, commands per ecosystem (npm, Ruby,
  Python, Go), recommended thresholds, and how to read the output
- Add dependency age budget GC rule to HARNESS.md template as a commented-out
  fitness function for weekly deterministic checking

### Tier 2 Design Proposals

- Add design proposal for complexity hotspot detection — weekly GC rule
  correlating git churn with cognitive complexity to find decay hotspots
- Add design proposal for dependency age budget (libyear) — aggregate
  staleness metric complementing CVE scanning
- Add design proposal for executable spec integration — making specs
  load-bearing by wiring test suites into the constraint system

### Workflow and Conventions

- Add CHANGELOG convention to CLAUDE.md — changelog updates required
  before every PR
- Broaden Bash permission patterns in `.claude/settings.local.json`
  for reliable parallel worktree agent execution

### Tier 1 Feature: Auto-Enforcer GitHub Action

- Add `auto-enforcer-action` skill for setting up automatic PR constraint
  checking via GitHub Actions
- Add `ci-auto-enforcer.yml` CI template — reads HARNESS.md at runtime,
  runs deterministic constraints (blocking) and agent constraints
  (advisory PR comments) on every pull request
- Update `harness-init` to offer auto-enforcer setup when agent PR
  constraints exist

### Tier 1 Feature: Convention Sync Across AI Tools

- Add `convention-sync` skill — reads HARNESS.md and generates convention
  files for Cursor (`.cursor/rules/*.mdc`), Copilot
  (`.github/copilot-instructions.md`), and Windsurf (`.windsurf/rules/`)
- Add `/convention-sync` slash command for direct invocation
- Add "Convention file sync" GC rule to HARNESS.md template for weekly
  drift detection

### Tier 1 Feature: Architectural Fitness Functions

- Add `fitness-functions` skill with catalogue of periodic architectural
  checks (structural, coupling, complexity/hotspot, coverage)
- Add reference catalogue with concrete HARNESS.md GC rule entries and
  tool commands per language ecosystem
- Add fitness functions as sixth category in the GC skill and catalogue
- Add commented-out fitness function examples to HARNESS.md template

### Compound Learning

- Capture reflections on Tier 1 research and parallel implementation
- Diagnose worktree agent permission issue — root cause was user
  permission denials during parallel prompt chaos, not worktree
  isolation itself

## 0.2.0 — 2026-04-06

### Secrets Detection

- Add `secrets-detection` skill for gitleaks-based secret scanning —
  covers installation, scanning, baselining, configuration, CI
  integration, and remediation
- Promote "No secrets in source" constraint to deterministic with
  gitleaks in the HARNESS.md template
- Add `secrets-check.sh` Stop-scope hook script for advisory gitleaks
  scanning at session end
- Wire hook into `hooks.json` and add gitleaks discovery to
  `/harness-init` constraint setup
- Add "Secret scanner operational" GC rule

### Project Harness Initialization

- Initialize HARNESS.md for the plugin itself with 6 constraints and
  5 GC rules
- Add `.github/workflows/harness.yml` CI workflow enforcing gitleaks,
  bash syntax, strict mode, and ShellCheck on every PR
- Fix ShellCheck warnings in `secrets-check.sh`,
  `snapshot-staleness-check.sh`, and `update-health-badge.sh`
- Promote ShellCheck constraint from unverified to deterministic
  (5/6 constraints enforced)
- Add harness enforcement and health badges to README

### Compound Learning

- Initialize REFLECTION_LOG.md with first session reflections
- Generate baseline harness health snapshot

### Plugin Structure

- Move plugin into `ai-literacy-superpowers/` subdirectory for
  marketplace install compatibility
