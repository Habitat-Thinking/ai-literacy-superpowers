---
title: The Harness Lifecycle
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 19
redirect_from:
  - /explanation/the-harness-lifecycle/
  - /explanation/the-harness-lifecycle.html
---

# The Harness Lifecycle

A harness has a life. It is born when `/harness-init` runs for the first time and writes a skeletal `HARNESS.md` from a template. It takes its first steps as reflections accumulate, conventions are extracted, and the first hand-authored constraints get promoted. It reaches maturity when the tuning loop runs continuously and the four operational cadences (`/reflect`, `/harness-health`, `/assess`, `/cost-capture`) anchor the team's rhythm. It renews itself when template upgrades arrive through `/harness-upgrade`. It is forced to rebuild when the team, the codebase, or the platform underneath it changes. This page walks one harness through that arc.

[The Harness Tuning Loop](the-harness-tuning-loop.md) cuts the harness on the *vertical* axis — one operational surprise, every enforcement surface, traced in a single turn of the loop. This page cuts the same harness on the *horizontal* axis — one harness, six stages, over months and years. Together the two pages answer the question "how does a harness work?" along both axes. The previous page is the propagation cut; this is the temporal cut.

The page threads a fictional six-engineer team through their first twelve months. Their stack is deliberately polyglot — a Python backend service (`ruff`, `mypy`, `pytest`), a TypeScript frontend (`eslint`, `tsc`, `vitest`), and Terraform infrastructure-as-code (`tflint`, `terraform fmt`) — so the artefact tables show realistic multi-stack behaviour rather than a monoculture. No single team member is fluent in all three stacks. Each stage also carries one *In this plugin's case* sidebar that points to a verifiable real event in this plugin's own harness, so the temporal arc is rooted in something that actually happened, not invented to fit the narrative.

---

## The shape of one full lifecycle

Six stages. The first five are the per-harness arc; the sixth applies whenever change forces a rebuild, regardless of where on the arc the harness sits.

| Stage | Defining artefact at the end | Dominant cadence |
| --- | --- | --- |
| 1. Day Zero — Initialisation | A skeletal `HARNESS.md` with the Status section unverified | One-shot |
| 2. First Month — Bootstrapping | First hand-authored constraints; first promoted `AGENTS.md` entries | Per-session |
| 3. Quarter One — First Steady State | First `/harness-audit` complete; first `/harness-health` snapshot | Weekly + monthly |
| 4. Year One — Maturity | Tuning loop in continuous operation; archival rules running | Daily + monthly + quarterly |
| 5. Renewal Years — Upgrades and Refresh | At least one `/harness-upgrade` accepted; convention files in sync | Quarterly + on plugin release |
| 6. When the Harness Has to Change | Rebuilt artefacts after team / codebase / platform shift | Triggered by change |

Each stage below has the same internal structure: a framing paragraph, a worked-example beat for the fictional team, a real-plugin sidebar, the substantive content, two summary tables (tools and artefacts), and a connective paragraph that ties them together.

---

## Stage 1 — Day Zero — Initialisation

The cold-start. The team has decided to put a harness around its AI-assisted work, but has nothing yet — no `HARNESS.md`, no `AGENTS.md`, no `REFLECTION_LOG.md`, no hooks. The defining artefact at the end of this stage is a complete-but-unverified `HARNESS.md` that describes what the team thinks it cares about, with the actual enforcement still mostly to be wired up.

The fictional team runs `/harness-init` from a clean checkout. The `harness-discoverer` agent reads `pyproject.toml`, `package.json`, the Terraform configs, and the existing GitHub Actions workflow. It surfaces what is already true: `ruff` and `mypy` and `pytest` running on the Python service; `eslint` and `tsc` and `vitest` on the TypeScript frontend; `tflint` and `terraform fmt` on the IaC. It proposes a starting `HARNESS.md` with three deterministic constraints already wired (one per stack), three unverified placeholder constraints describing things the team should enforce but currently does not, and a Status section showing 3/6 verified. Each inference is presented for confirmation; nothing is auto-accepted. They commit the file and push.

> *In this plugin's case:* the very first `/harness-init` ran on the plugin's own codebase on 2026-04-06 (commit `8b30ea3` "Initialize project harness with HARNESS.md"). The discoverer found `markdownlint`, `gitleaks`, and `shellcheck` already in CI. Six constraints were declared and five reached deterministic enforcement on the first run, because the codebase is markdown and bash — projects with application code typically start with more unverified or agent-level constraints. See [`REFLECTION_LOG.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/REFLECTION_LOG.md) entry 2026-04-06.

The output of Day Zero is not a finished harness. It is a *starting line that is honest about what is real today*. The Status section showing 3/6 verified is the truthful claim. The three unverified placeholders are not failures; they are declared intent that has not yet been wired to enforcement. The whole point of the stages that follow is to turn declared intent into verified enforcement, one constraint at a time.

### Tools at work

| Surface | Name | Role |
| --- | --- | --- |
| Command | `/harness-init` | Cold-start setup; orchestrates discovery, generates `HARNESS.md`, scaffolds `AGENTS.md` and `REFLECTION_LOG.md`, configures hooks |
| Skill | [`harness-engineering`](harness-engineering.md) | Provides the conceptual framework that `/harness-init` operates within |
| Agent | `harness-discoverer` | Read-only scanner that infers stack, linters, CI checks, and existing convention documentation |
| Hook | `SessionStart` + rotating `Stop` | Installed and declared in `.claude/settings.local.json`; ready to fire from the next session onward |

### Artefacts evolving here

| Artefact | State at this stage | What changed since the previous stage |
| --- | --- | --- |
| `HARNESS.md` | Skeleton with three deterministic and three unverified constraints; Status 3/6 | Created from the plugin's `HARNESS.md` template |
| `AGENTS.md` | Five empty section headers (STYLE, GOTCHAS, ARCH_DECISIONS, TEST_STRATEGY, DESIGN_DECISIONS) | Created from template |
| `REFLECTION_LOG.md` | Header comment block; no entries | Created from template |
| Hook configuration | `SessionStart` + rotating `Stop` declared in `.claude/settings.local.json` | Configured at `/harness-init` time |

**How they work together:** `/harness-init` is the single command that brings every other surface into existence. The `harness-discoverer` agent does the reading work that would otherwise require the team to recall every convention from memory; the [`harness-engineering`](harness-engineering.md) skill provides the conceptual scaffolding the agent operates against. The four artefacts created in this stage are all in their starting state — the skeleton from which everything else accretes. The hooks are the only thing that becomes operationally active immediately; the rest of the artefacts will not start changing until the team works in this codebase again. For the deep mechanics of the bootstrap process, see [Harness Engineering](harness-engineering.md#bootstrapping) and the tutorial [Harness for an Existing Codebase](harness-from-scratch.md).

---

## Stage 2 — First Month — Bootstrapping

The harness is alive but largely empty. Reflections start appearing as the team uses AI assistants in earnest. Conventions that lived in scattered places — Slack pins, `CONTRIBUTING.md` excerpts, comments in `pyproject.toml` — start being surfaced explicitly. The first hand-authored constraints land in `HARNESS.md`. The first promoted entries appear in `AGENTS.md`. The defining property of this stage is *accretion under human curation*.

The fictional team has eight reflection entries by the end of week two. One captures an agent committing a SQL query that bypassed the team's repository abstraction, going straight to `cursor.execute()`. `/reflect` flags this as a `failure` signal during the entry capture and proposes an agent-enforced constraint there and then. The team accepts; `/harness-constrain` writes the constraint into `HARNESS.md` (with `agent` enforcement, `scope: pr`, tool `code-reviewer agent`). A week later, after the same kind of surprise hasn't recurred, a developer reads through recent reflections during a curation session and promotes the gotcha into `AGENTS.md`'s GOTCHAS section: "always route DB writes through `repositories/` — agents tend to inline `cursor.execute()`." Separately, the team runs `/extract-conventions` in a thirty-minute structured session that surfaces three more tacit conventions worth promoting.

> *In this plugin's case:* by 2026-04-08, the auto-constraint proposal pipeline was firing on reflections and the `Signal` field had been added to the entry template (see `REFLECTION_LOG.md` 2026-04-08, the first signal-classified entries). The integration agent began appending reflections automatically at the end of pipeline runs, and the assessment skill stack started taking shape iteratively across PRs #79–#90 as documented in the 2026-04-09 reflection.

The work of First Month is mostly conversational — `/reflect` after sessions, `/extract-conventions` once or twice, occasional `/harness-constrain` calls to lock in a real pattern. The artefacts are accreting slowly. By the end of the month, the team typically has five to ten reflection entries, three to five new constraints in `HARNESS.md` (some still unverified), and a handful of GOTCHAS and ARCH_DECISIONS in `AGENTS.md`. The Status section's verified ratio has not necessarily improved much; verification slots take real engineering work to wire, and First Month is mostly about declared intent.

### Tools at work

| Surface | Name | Role |
| --- | --- | --- |
| Command | `/reflect` | Captures a reflection at session end; proposes a constraint when the surprise looks preventable |
| Command | `/extract-conventions` | Structured discovery session that surfaces tacit team knowledge |
| Skill | [`convention-extraction`](extract-conventions.md) | Supports `/extract-conventions` with the question framework |
| Command | `/harness-constrain` | Interactive promotion of a proposal into `HARNESS.md`; configures the verification slot when deterministic |
| Skill | [`constraint-design`](constraints-and-enforcement.md) + [`verification-slots`](set-up-verification-slots.md) | Support `/harness-constrain` |

### Artefacts evolving here

| Artefact | State at this stage | What changed since the previous stage |
| --- | --- | --- |
| `HARNESS.md` | 6–10 constraints; some hand-authored, some still unverified | New constraints appended via `/harness-constrain`; Status section unchanged |
| `AGENTS.md` | First entries in GOTCHAS and ARCH_DECISIONS; STYLE has a few items from `/extract-conventions` | First promoted entries from `REFLECTION_LOG.md` and from extraction session |
| `REFLECTION_LOG.md` | 5–10 entries, mostly `failure` and `workflow` signals | First entries appended from sessions; first auto-constraint proposals fired |
| Hook configuration | Unchanged from Day Zero | None |

**How they work together:** The flow at this stage is: a session happens, the developer or agent runs `/reflect`, the entry lands in `REFLECTION_LOG.md`, sometimes `/reflect` proposes a constraint inline and the developer accepts, `/harness-constrain` writes it into `HARNESS.md`. Separately, on a slower cadence (weekly or fortnightly), the developer reviews recent reflections and promotes recurring patterns into `AGENTS.md`. `/extract-conventions` runs as a one-shot bootstrap — the team only needs to do it once or twice early on to capture the conventions that already exist. The deep mechanics of how reflections become constraints and how `AGENTS.md` curation works are covered in [Compound Learning](compound-learning.md) and [The Self-Improving Harness](self-improving-harness.md).

---

## Stage 3 — Quarter One — First Steady State

The harness has stopped being purely declarative and has started doing work the team can feel. The first `/harness-audit` runs and reveals what the Status section actually means. The first `/harness-health` snapshot lands and gives the team a baseline to compare against. The rotating `Stop` hook has cycled through every deterministic GC rule at least once. The defining property of this stage is *observability of the harness's own state* — the team can now see whether their harness is doing what they thought it was doing.

The fictional team runs their first `/harness-audit` six weeks in. The `harness-auditor` agent compares declared constraints in `HARNESS.md` against the enforcement actually present in the codebase and CI. Two findings: the unverified constraint about TypeScript bundle size has no tool wired anywhere, and the deterministic Terraform constraint references a `tflint` config that no longer exists in the repo (someone moved it). The team writes a verification slot for the bundle-size constraint and updates the path reference for the `tflint` one. The auditor updates the Status section: 5/6 verified. Separately, `/harness-health` produces the team's baseline snapshot — enforcement ratio 0.6, learning velocity nominal, no regression flags.

> *In this plugin's case:* the baseline `harness-health` snapshot was generated on 2026-04-06 alongside the gitleaks integration (see `REFLECTION_LOG.md` 2026-04-06, second entry — "Initialized the project's own harness... and generated the baseline health snapshot"). The reflection notes the unusual deterministic-enforcement ratio of 5/6 on first init, which is specific to a markdown-and-bash codebase; an application codebase will typically start lower and climb across Quarter One.

By the end of Quarter One the team has roughly 15–25 reflection entries, the first two or three constraints have been promoted from unverified to verified-deterministic, the rotating Stop hook is producing sub-five-second advisory findings every session, and the weekly `gc.yml` workflow has run a dozen times. The team can now answer "is our harness healthy?" with evidence — a snapshot, an enforcement ratio, a count of GC findings. They could not answer it with evidence in First Month.

### Tools at work

| Surface | Name | Role |
| --- | --- | --- |
| Command | `/harness-audit` | Full meta-verification; updates Status section in `HARNESS.md` |
| Agent | `harness-discoverer` + `harness-auditor` | Read-only scan + read-write Status update |
| Command | `/harness-status` (lighter) and `/harness-health --deep` (heavier alternative) | Faster spot-checks of the same thing |
| Command | `/harness-health` | Generates a snapshot of enforcement ratio, learning velocity, regression flags |
| Hook | rotating `Stop` | Picks one deterministic GC rule per session by day-of-year, runs it as a sub-5s advisory |
| CI workflow | `gc.yml` | Runs all deterministic GC rules every Monday 09:00 UTC |

### Artefacts evolving here

| Artefact | State at this stage | What changed since the previous stage |
| --- | --- | --- |
| `HARNESS.md` | 8–12 constraints; Status section maintained by audits; promotion ladder visible | Status updated by `harness-auditor`; verification slots added; some `unverified` → `verified-agent` or `verified-deterministic` |
| `AGENTS.md` | Steady accretion of curated entries every 2–4 weeks | New entries from `REFLECTION_LOG.md` curation |
| `REFLECTION_LOG.md` | 15–25 entries; signal-tagging is routine; first reflection-driven regression detection runs | Continues to accumulate; GC rule scans it weekly |
| Hook configuration | Unchanged; rotation has now hit every declared deterministic GC rule | None |
| `observability/snapshots/` | First snapshot file present | Created by first `/harness-health` run |

**How they work together:** `/harness-audit` and `/harness-health` are the two observability commands that turn the harness from a silent infrastructure into something the team can reason about. The auditor writes the Status section; the health command writes snapshots. The rotating Stop hook and the `gc.yml` workflow form the [Three Enforcement Loops](three-enforcement-loops.md)' outer (scheduled, investigative) loop — they catch entropy that no single change introduces. By the end of Quarter One the harness has stopped being something the team built and has started being something the team operates. The lighter command `/harness-status` is what most teams reach for between full audits; deep mechanics are in [Run a Harness Audit](run-a-harness-audit.md).

---

## Stage 4 — Year One — Maturity

The tuning loop runs continuously. Reflections come in, GC notices recurring patterns and files issues, the team promotes proposals into constraints, audits keep the Status section honest, propagation pushes new policies out to the convention files and CI workflows. The four operational cadences (`/reflect` per session, `/harness-health` monthly, `/assess` quarterly, `/cost-capture` quarterly) are anchoring the team's rhythm. The `REFLECTION_LOG.md` archival rules — Path 1 deterministic auto-archive of `Promoted`-tagged entries, Path 2 monthly aged-out review — start mattering as the log crosses 50 entries. The defining property of this stage is *the harness operates the team as much as the team operates the harness*.

The fictional team is nine months in. GC's reflection-driven regression detection rule has filed three issues over the past two quarters, two of which have become constraints. The promotion ladder has moved one constraint from `agent` enforcement to `deterministic` after the team built the right verification tool. Quarterly `/assess` shows movement from Level 2 to Level 3. `REFLECTION_LOG.md` has crossed 60 entries. The first weekly archival sweep moves seven entries with `Promoted` lines into `reflections/archive/2026.md`; the agent verifies each entry's `Promoted` line resolves to actual `AGENTS.md` or `HARNESS.md` content before moving it. Read-side filtering caps every agent's intake at 50 entries / 90 days, so the working set stays bounded even as the archive grows.

> *In this plugin's case:* the plugin is too young to have a real Year One artefact yet — it is five weeks old as this page is written. The closest real evidence is the bootstrap-circularity moment: `REFLECTION_LOG.md` 2026-05-01 captures the design and shipping of v0.32.0's archival rules, and the very entry that captures the lessons is now the first entry the system will be asked to manage. The Path 1 GC rule will scan that entry for a `Promoted` line; if a curator promotes a learning from it, the rule will archive the entry by its own logic. The mechanism is recursively self-applying from day zero.

Year One is when the asymmetry that makes the whole system work becomes visible: the parts of the harness that *block* (constraints, hooks, CI) catch most surprises before they recur, while the parts that *report* (`/harness-gc`, `/harness-audit`) describe drift the blocking surfaces missed. Reports nudge; constraints stop. The two are now operating together at full cadence, each catching what the other cannot.

### Tools at work

| Surface | Name | Role |
| --- | --- | --- |
| Command | `/harness-gc` | Weekly entropy detection; reads recent reflections; files issues for findings |
| Skill | [`garbage-collection`](garbage-collection.md) | Supports `/harness-gc` with the rule taxonomy |
| Agent | `harness-gc` | Read-write within bounds; cannot modify `HARNESS.md` itself (trust boundary) |
| Command | `/assess` | Quarterly literacy assessment; surfaces gaps and produces an improvement plan |
| Skill | `ai-literacy-assessment` | Supports `/assess` |
| Agent | `assessor` | Scans the repo; scores across disciplines; writes the assessment document |
| Command | `/governance-audit` | Quarterly semantic-drift detection on governance constraints |
| Agent | `governance-auditor` | Reports never-modifies-`HARNESS.md` (mirrors `harness-gc` trust boundary) |
| Command | `/cost-capture` | Quarterly snapshot of provider spend, tokens, model mix |
| CI workflow | `gc.yml` (weekly), `harness-audit.yml` (where configured), per-PR constraint workflows | Continuous enforcement and entropy detection |

### Artefacts evolving here

| Artefact | State at this stage | What changed since the previous stage |
| --- | --- | --- |
| `HARNESS.md` | Mature constraint set (15–25); governance constraints declared with falsifiability rules; Status section stable; promotion ladder has moved several constraints up | Constraints tightened; some promoted; governance section populated |
| `AGENTS.md` | Stable entry base; new entries are subtle (the obvious patterns were caught in earlier stages) | Slow accretion of nuanced learnings |
| `REFLECTION_LOG.md` + archive | 50+ entries in the live log; first entries moved to `reflections/archive/<YYYY>.md` by the Path 1 weekly auto-archive rule; Path 2 aged-out review running monthly for entries >180 days without `Promoted` | Archival mechanism active; read-side filtering caps intake |
| `observability/snapshots/` | Multiple snapshots; trends visible; archive directory accumulating monthly snapshots older than 6 months | New snapshot per `/harness-health`; archival per the `Observability archive` GC rule |
| Cost data | `MODEL_ROUTING.md` updated quarterly with observed routing patterns | New cost snapshots from `/cost-capture`; routing decisions adjusted on evidence |

**How they work together:** The deep description of how all of this fits is in [The Harness Tuning Loop](the-harness-tuning-loop.md) (one full turn of the per-surprise loop) and [The Loops That Learn](the-loops-that-learn.md) (the four cadences interlocking). At the Year One scale, the most important thing happening is *the loops are interlocking*: reflections feed GC, GC produces issues, the team promotes proposals into constraints, audits confirm the constraints are real, snapshots prove they are working, assessments validate the team has moved up the literacy ladder, cost data informs the routing the team uses. Each loop's output is another loop's input; the whole system is cybernetic. The archival mechanism described in the v0.32.0 release notes ([CHANGELOG](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/CHANGELOG.md#0320--2026-05-01)) is what keeps the working set bounded over multiple years.

---

## Stage 5 — Renewal Years — Upgrades and Refresh

The plugin ships new template content. New GC rules, new template-shipped constraints, new skills, refined agent prompts. None of this propagates automatically; the SessionStart hook surfaces a `/harness-upgrade` prompt when the installed plugin version moves ahead of the `<!-- template-version: -->` marker in `HARNESS.md`. The team reviews the diff and accepts what fits. The push-direction surfaces — convention files (`.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`) and `ONBOARDING.md` — get re-generated together via `/harness-sync`, the unified multi-surface entry point that composes the underlying primitives (`/convention-sync` for the rule files; `/harness-onboarding` for the onboarding document) into one interactive pass. The defining property of this stage is *the harness adopts upstream improvements without losing the team's own accumulated tuning*.

The fictional team is in their second year. Plugin v0.36 ships. Their next session opens with the SessionStart hook surfacing a `/harness-upgrade` prompt: "three new GC rules, one new template-shipped constraint, two refined skill descriptions." They review each item against their own context. The new constraint about CVE-bearing dependencies maps onto a real concern; they accept it and `/harness-upgrade` adds it to `HARNESS.md` with the verification slot pre-wired. Two of the three new GC rules fit; the third assumes a Java codebase, so they decline it. They run `/harness-sync` — the unified multi-surface entry point — which scans for drift across the convention files and `ONBOARDING.md` together; the team selects all three drifted surfaces and `/harness-sync` applies the underlying primitives (`/convention-sync` for the rule files; `/harness-onboarding` for `ONBOARDING.md`, since a new engineer is joining the team next week) in one pass.

> *In this plugin's case:* the plugin's harness has not yet had a substantial Renewal moment because the plugin is the source of the upgrades, not a downstream consumer. What is real and verifiable is the propagation half: the rotating Stop hook ran the new "Reflection log archival of promoted entries" GC rule the same day v0.32.0 shipped (see `REFLECTION_LOG.md` 2026-05-01). The convention-sync mechanics are exercised continuously across the marketplace's plugins; per-plugin tag conventions stabilised in v0.32.0 (see CHANGELOG 0.32.0 chore section).

Renewal is not a one-shot event; it is an ongoing rhythm punctuated by plugin releases. Most months, no renewal happens. When the plugin ships, the team has a small triage decision: which of the new items match our context, which do not, what would we keep regardless. The `/harness-upgrade` machinery does not auto-apply anything; it shows the diff and waits.

### Tools at work

| Surface | Name | Role |
| --- | --- | --- |
| Hook | `SessionStart` | Surfaces `/harness-upgrade` prompts when template versions move |
| Command | `/harness-upgrade` | Diffs current `HARNESS.md` against the latest template; presents new items for accept/reject |
| Command | [`/harness-sync`](sync-harness.md) | Multi-surface entry point: detects drift, multi-selects, applies via the underlying primitives in one pass |
| Command | `/convention-sync` | Re-generates `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/` from `HARNESS.md` |
| Skill | [`convention-sync`](sync-conventions.md) | Supports `/convention-sync` |
| Command | `/harness-onboarding` | Regenerates `ONBOARDING.md` from `HARNESS.md` + `AGENTS.md` + `REFLECTION_LOG.md` |
| Skill | [`harness-onboarding`](generate-onboarding.md) | Supports `/harness-onboarding` |

### Artefacts evolving here

| Artefact | State at this stage | What changed since the previous stage |
| --- | --- | --- |
| `HARNESS.md` | New template-shipped constraints accepted; `<!-- template-version: -->` marker bumped to current | Diff applied via `/harness-upgrade`; Status section reflects new verified slots |
| `AGENTS.md` | Largely unchanged; `/harness-upgrade` rarely modifies hand-curated learnings | Untouched by upgrade unless a structural reorganisation is part of the new template |
| `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/` | Re-generated to match current `HARNESS.md` | Re-generated by `/convention-sync` |
| `ONBOARDING.md` | Regenerated when new members join | Regenerated by `/harness-onboarding` |
| `REFLECTION_LOG.md` | Continues to accumulate; older entries move to archive | Path 1 archival continues; Path 2 aged-out review continues |

**How they work together:** The upgrade pipeline is deliberately serial: `SessionStart` hook surfaces the prompt → `/harness-upgrade` shows the diff → human accepts or rejects each item → `HARNESS.md` is updated → `/harness-sync` re-evaluates drift across all push-direction surfaces and applies the underlying primitives (`/convention-sync` for the convention files; `/harness-onboarding` for the onboarding document) in one interactive pass. No agent in this pipeline has the authority to write to `HARNESS.md` without confirmation. The propagation step closes the loop the same way the propagation half of [The Harness Tuning Loop](the-harness-tuning-loop.md#stage-5--propagate-the-change-to-the-enforcement-surfaces) closes it for newly-promoted constraints. For the deep mechanics of how `/harness-upgrade` parses templates and produces a diff, see [Upgrade Your Harness](upgrade-your-harness.md); for `/harness-sync` itself, see [Sync Harness Surfaces](sync-harness.md).

---

## Stage 6 — When the Harness Has to Change

This stage is not bound to the temporal arc. A team change in month three needs the same response as a team change in year three. A codebase split in week six needs the same response as one in year two. The stage is placed last for narrative reasons — it is the disruption that resets parts of the lifecycle — but it can apply at any point in the harness's life. The defining property of this stage is *the harness must absorb a change underneath it that breaks one of its assumptions*.

Three forces typically trigger this stage:

**Team change.** People leave; people join. Tacit knowledge departs; tacit knowledge has to be re-extracted. The fictional team loses two engineers and gains three. The departing engineers held conventions about error handling and logging that lived nowhere except in their heads and in code reviews. A `/extract-conventions` session — run as soon as possible after the announcement, ideally before the engineers actually leave — surfaces what they knew. New STYLE and ARCH_DECISIONS entries land in `AGENTS.md`. The new engineers are onboarded via `/harness-onboarding`'s output.

**Codebase change.** A new subsystem in a new language, a major refactor, a service split. The fictional team carves out a new Go data-pipeline service for high-throughput work. They re-run `/harness-init` scoped to `data-pipeline/**`; the discoverer finds `govulncheck` and `staticcheck`. Two new constraints land, each scoped to the new directory. The existing constraints stay scoped to where they were. The `MODEL_ROUTING.md` document picks up a note that the data-pipeline service has different latency characteristics and may benefit from a different routing policy.

**Platform change.** New AI tooling, new model tier, new CI provider, new package manager. `/cost-capture` typically detects this first — a quarterly snapshot shows model spend has shifted, and the routing assumptions need updating. `MODEL_ROUTING.md` is rewritten. If the change is large enough, `/superpowers-init` may need to re-run to reconfigure the broader habitat (model routing, observability cadences, the badge in the README).

> *In this plugin's case:* the model-cards plugin shipped as a sister plugin in the same marketplace on 2026-04-29. That triggered a real change-driven moment: a new repo (`Habitat-Thinking/model-card-library`) was created and seeded; per-plugin tag conventions were introduced (CHANGELOG v0.32.0); a multi-repo scheduled agent was set up to walk both repos quarterly; the marketplace listing's `version` was decoupled from `plugin_version` to handle two plugins with independent release rhythms. The reflections of 2026-04-30 and 2026-05-01 capture both the surprises and the rebuilding moves.

The common thread across all three forces: the rebuild moves are not new mechanism. They are the same `/extract-conventions`, `/harness-init`, `/cost-capture`, and `/harness-sync` commands the team already uses (with `/convention-sync` and `/harness-onboarding` continuing to serve as `/harness-sync`'s underlying primitives when the team wants focused single-surface work), applied in a different sequence and with a different focus. The harness does not need to invent special change-handling mechanism; it needs to apply its existing mechanism intentionally.

### Tools at work

| Surface | Name | Role |
| --- | --- | --- |
| Command | `/extract-conventions` | Re-run when team composition changes; surfaces the conventions the departing members held |
| Command | `/harness-init` | Re-run scoped to a new subsystem; the discoverer finds the new stack |
| Command | `/cost-capture` | Detects platform-level cost shifts that suggest routing assumptions need updating |
| Command | `/superpowers-init` | Re-runs broader habitat configuration when the platform shifts substantially |
| Command | [`/harness-sync`](sync-harness.md) | Multi-surface entry point: propagates the rebuilt artefacts to the convention files and onboarding document by composing `/convention-sync` and `/harness-onboarding` in one pass |
| Skill | [`cross-repo-orchestration`](orchestrate-across-repos.md) | Guides multi-repo coordination when the change spans repositories |

### Artefacts evolving here

| Artefact | State at this stage | What changed since the previous stage |
| --- | --- | --- |
| `HARNESS.md` | New constraints scoped to new subsystems; existing scope preserved | New entries from re-run `/harness-init`; re-scoped from `/harness-constrain` |
| `AGENTS.md` | New STYLE / ARCH_DECISIONS entries from `/extract-conventions`; departing-member conventions made explicit | Entries from extraction sessions; existing entries audited for relevance |
| `MODEL_ROUTING.md` | Updated with new platform realities | Re-evaluated against `/cost-capture` data |
| `ONBOARDING.md` | Regenerated to reflect new state | `/harness-onboarding` re-run |
| `REFLECTION_LOG.md` | Continues to accumulate; pre-change reflections may be promoted before they are archived | Curators promote departing-member reflections to `AGENTS.md` deliberately |

**How they work together:** The change-driven sequence is intentional but not heavyweight: notice the change → run the right extraction or init command → write what surfaces into the right artefact → propagate via `/harness-sync`, which composes `/convention-sync` and `/harness-onboarding` into one interactive pass against the rebuilt state. The trust boundary that protects `HARNESS.md` (only `/harness-constrain` writes constraints; only `harness-auditor` writes the Status section) holds across change events too — no agent gets to rewrite the harness because the team changed. The depth of how cross-repo coordination works during a change event is in [Orchestrate Across Repos](orchestrate-across-repos.md). [Habitat Engineering](habitat-engineering.md) is the broader frame for thinking about the harness's environment when forces underneath it shift.

---

## What the lifecycle earns

A team that has run a harness through all six stages has something different from what they had at Day Zero. The `HARNESS.md` is no longer a record of what they thought was important when they started. It is a record of what their operational experience has taught them is worth enforcing — evidence-backed, audited, propagated, and re-applied through every change the team has been through.

A team that has not run the lifecycle has the same `HARNESS.md` they had on day one. The reflections they did not capture do not exist. The patterns they did not promote do not block recurring surprises. The upgrades they did not adopt mean their harness is years behind the upstream. The harness still appears to operate, but it has stopped tuning, stopped renewing, and stopped adapting.

The infrastructure is not the product. The lifecycle is the product. Every component on this page exists to make the next stage of the arc possible without imposing a cost the team cannot pay — two minutes for `/reflect`, weekly automated GC, an interactive `/harness-constrain` when a real pattern emerges, an annual triage when the plugin ships, and the existing extraction and init commands re-applied when the team or codebase or platform changes underneath the harness.

---

## Where are you on this arc? — A reading map

The map below organises the rest of the docs site by lifecycle position. A reader who is at *First Month* should be able to look at this map and know exactly which next pages to open.

| Stage | Where you are — observable signals | Read deeper | Try it |
| --- | --- | --- | --- |
| **Day Zero** | No `HARNESS.md` yet, or one only just created from template | [Harness Engineering](harness-engineering.md) · [Habitat Engineering](habitat-engineering.md) | [Getting Started](getting-started.md) · [Harness From Scratch](harness-from-scratch.md) (tutorial) |
| **First Month** | `HARNESS.md` has fewer than 5 hand-authored constraints; `AGENTS.md` mostly template-default; first reflections appearing | [Compound Learning](compound-learning.md) · [The Self-Improving Harness](self-improving-harness.md) | [Surfacing Tacit Knowledge](surfacing-tacit-knowledge.md) (tutorial) · [Add a Constraint](add-a-constraint.md) · [Extract Conventions](extract-conventions.md) |
| **Quarter One** | First `/harness-audit` has run; first `/harness-health` snapshot exists; rotating Stop hook visible in session logs | [Three Enforcement Loops](three-enforcement-loops.md) · [Codebase Entropy](codebase-entropy.md) · [Constraints and Enforcement](constraints-and-enforcement.md) | [Run a Harness Audit](run-a-harness-audit.md) · [Run a Calibration Review](run-a-calibration-review.md) |
| **Year One** | 50+ reflections; tuning loop running on its own; quarterly assessments cycling; first archival sweep has happened | [The Harness Tuning Loop](the-harness-tuning-loop.md) · [The Loops That Learn](the-loops-that-learn.md) · [Garbage Collection](garbage-collection.md) · [Regression Detection](regression-detection.md) | [Run an Assessment](run-an-assessment.md) · [Run a Governance Audit](run-a-governance-audit.md) · [Track AI Costs](track-ai-costs.md) |
| **Renewal Years** | At least one `/harness-upgrade` accepted; convention files in sync with `HARNESS.md`; `ONBOARDING.md` regenerated at least once | [Progressive Hardening](progressive-hardening.md) · [Governance as Meaning Alignment](governance-as-meaning-alignment.md) · [Determinacy Calibration](determinacy-calibration.md) | [Upgrade Your Harness](upgrade-your-harness.md) · [Sync Conventions](sync-conventions.md) · [Generate Onboarding](generate-onboarding.md) |
| **Change-driven** | Team composition just shifted, codebase just split, or platform just changed | [Decision Archaeology](decision-archaeology.md) · [Adversarial Review](adversarial-review.md) | [Extract Conventions](extract-conventions.md) (re-run) · [Orchestrate Across Repos](orchestrate-across-repos.md) |

If you can't tell which stage you're in, the fastest tell is your `HARNESS.md`. A skeleton template with an unverified Status section means you are at Day Zero or early First Month. A Status section being maintained by audits means Quarter One has happened. Hand-authored governance constraints with falsifiability declarations mean Year One is well underway. A `<!-- template-version: -->` marker that lags the installed plugin version means the next move is `/harness-upgrade`. A team or codebase or platform shift you have not yet absorbed means the change-driven stage applies whatever your position on the linear arc.

---

## Further reading

Pages on the orthogonal axis or one level out:

- [The Harness Tuning Loop](the-harness-tuning-loop.md) — the propagation cut: one surprise, every surface, in a single turn of the loop. Read alongside this page for both axes of harness operation.
- [The Loops That Learn](the-loops-that-learn.md) — the four operational cadences (`/reflect`, `/harness-health`, `/assess`, `/cost-capture`) that drive the per-stage rhythm.
- [The Three Enforcement Loops](three-enforcement-loops.md) — the timescale cut: inner (edit-time, advisory), middle (PR-time, blocking), outer (scheduled, investigative).
- [Habitat Engineering](habitat-engineering.md) — the broader environment in which the harness lives.
- [`HARNESS.md`, the Document](harness-md.md) — the reference for the central artefact whose evolution this page traces.
