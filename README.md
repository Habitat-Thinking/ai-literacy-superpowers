# ai-literacy-superpowers

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Lint Markdown](https://github.com/Habitat-Thinking/ai-literacy-superpowers/actions/workflows/lint-markdown.yml/badge.svg)](https://github.com/Habitat-Thinking/ai-literacy-superpowers/actions/workflows/lint-markdown.yml)
[![Marketplace](https://img.shields.io/badge/Marketplace-v0.3.0-4682B4?style=flat-square)](.claude-plugin/marketplace.json)
[![ai-literacy-superpowers](https://img.shields.io/badge/ai--literacy--superpowers-v0.35.5-4682B4?style=flat-square)](ai-literacy-superpowers/)
[![model-cards](https://img.shields.io/badge/model--cards-v0.1.0-4682B4?style=flat-square)](model-cards/)
[![Skills](https://img.shields.io/badge/Skills-30-2E8B57?style=flat-square)](#skills-30)
[![Agents](https://img.shields.io/badge/Agents-13-2E8B57?style=flat-square)](#agents-13)
[![Commands](https://img.shields.io/badge/Commands-25-2E8B57?style=flat-square)](#commands-25)
[![Harness](https://img.shields.io/badge/Harness-19%2F20_enforced-4682B4?style=flat-square)](HARNESS.md)
[![Harness Health](https://img.shields.io/badge/Harness_Health-Healthy-2E8B57?style=flat-square)](observability/snapshots/2026-05-08-snapshot.md)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-D97757?style=flat-square&logo=anthropic&logoColor=white)](https://claude.ai/claude-code)
[![Copilot CLI](https://img.shields.io/badge/Copilot_CLI-Plugin-000000?style=flat-square&logo=githubcopilot&logoColor=white)](https://github.com/features/copilot)
[![Agent Harness Enabled](https://img.shields.io/badge/Agent_Harness-Enabled-000000?style=flat-square)](HARNESS.md)
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_5-DAA520?style=flat-square)](assessments/2026-04-28-assessment.md)

A plugin marketplace for [Claude Code](https://claude.ai/claude-code) and [GitHub Copilot CLI](https://github.com/features/copilot) shipping opinionated tools for the AI Literacy framework — harness engineering, agent orchestration, decision archaeology, governance, and model evaluation.

Add the marketplace, install the plugin(s) you want, and you have a fully operational habitat for AI-assisted development.

New to the project? Start with [ONBOARDING.md](ONBOARDING.md) or browse the [docs site](https://habitat-thinking.github.io/ai-literacy-superpowers/).

---

## Plugins in this marketplace

| Plugin | Version | What it does | Docs |
| ------ | ------- | ------------ | ---- |
| **`ai-literacy-superpowers`** | v0.35.1 | The flagship. Harness engineering, agent orchestration, literate programming, CUPID code review, compound learning, and the three enforcement loops. **30 skills, 13 agents, 25 commands.** | [docs](docs/plugins/ai-literacy-superpowers/index.md) |
| **`model-cards`** | v0.1.0 | Researches and authors Mitchell-extended model cards from a model name. Tiered source strategy (provider docs → HuggingFace → arXiv → web), refusal-on-unconfirmed-existence honesty rule. | [docs](docs/plugins/model-cards/index.md) |

The bulk of this README documents the **`ai-literacy-superpowers`** plugin specifically — its skills, agents, commands, hooks, templates, enforcement loops, and pipelines. For `model-cards`, see [its README](model-cards/README.md) and [its docs](docs/plugins/model-cards/index.md). Future sister plugins will land in this marketplace under `<plugin-name>/` with their own docs at `docs/plugins/<plugin-name>/`.

---

## Installation

### 1. Add the marketplace (once)

```bash
# Claude Code
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers

# GitHub Copilot CLI
copilot plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
```

### 2. Install the plugin(s) you want

```bash
# Claude Code
claude plugin install ai-literacy-superpowers     # the flagship
claude plugin install model-cards                  # the sister

# GitHub Copilot CLI
copilot plugin install ai-literacy-superpowers@ai-literacy-superpowers
copilot plugin install model-cards@ai-literacy-superpowers
```

You can install one, the other, or both. Once installed, each plugin's skills, agents, hooks, and commands (or prompts) are available in any session within your project.

> Commands are available as `/command-name` in Claude Code and as `/prompt-name` in Copilot CLI.

### Updating

#### Check if an update is available

Three signals surface new versions without manual polling:

- **SessionStart hook** — if your project has a HARNESS.md, the hook compares
  its `template-version` marker against the installed plugin version and emits
  a nudge if they differ. This fires once per upgrade and goes silent after you
  run `/harness-upgrade`.
- **Weekly GC rule** — the `Template currency` rule checks the same marker on
  its weekly schedule and includes any mismatch in the `/harness-health` report.
- **Manual check** — compare installed vs latest at any time:

```bash
claude plugin list
```

#### Update the plugin

When a new version is released, update your local installation:

```bash
# Claude Code
claude plugin update ai-literacy-superpowers@ai-literacy-superpowers

# Copilot CLI
/plugin update ai-literacy-superpowers
```

Check the [CHANGELOG](CHANGELOG.md) for what changed between versions.

After updating, run `/harness-upgrade` to review and adopt any new template
content (constraints, GC rules, optional blocks) into your HARNESS.md.

#### Update the marketplace listing

If you maintain your own marketplace that includes this plugin, refresh
the index so new versions are discoverable:

```bash
claude plugin marketplace update Habitat-Thinking/ai-literacy-superpowers
```

This pulls the latest `plugin.json` metadata (version, description,
keywords) into the marketplace index. Users who have already installed
the plugin still need to run `claude plugin update` separately.

See [How to Update the Plugin](docs/plugins/ai-literacy-superpowers/update-the-plugin.md) for
the full guide.

### Quick start

After installation, run these commands to set up your project:

```bash
# Full habitat setup (recommended for new projects)
/superpowers-init

# Harness-only setup (if you want constraints without the agent pipeline)
/harness-init

# Check the status of your harness
/harness-status

# Run a health check
/harness-health

# Run an AI literacy assessment
/assess
```

**`/superpowers-init`** sets up the complete habitat: CLAUDE.md, HARNESS.md, AGENTS.md, MODEL_ROUTING.md, REFLECTION_LOG.md, the full agent team, skills, hooks, and CI workflow templates. Use this for new projects.

**`/harness-init`** sets up only the harness: HARNESS.md with starter constraints and GC rules. Use this if you want the constraint and enforcement machinery without the full agent pipeline.

### Tool Compatibility

This plugin works with both Claude Code and GitHub Copilot CLI from the same repository. The formats have converged:

| Component | Claude Code | Copilot CLI | Shared? |
| --------- | ----------- | ----------- | ------- |
| Skills | `skills/*/SKILL.md` | `skills/*/SKILL.md` | Identical |
| Agents | `agents/*.agent.md` | `agents/*.agent.md` | Identical |
| Hooks | `hooks/hooks.json` | `hooks/hooks.json` | Identical |
| Commands | `commands/*.md` | `.github/prompts/*.prompt.md` | Translated |
| Instructions | Via `templates/CLAUDE.md` | `.github/copilot-instructions.md` | Adapted |

---

## `ai-literacy-superpowers` — what it ships

The remaining sections of this README document the **`ai-literacy-superpowers`** plugin in detail. For `model-cards`, see [its README](model-cards/README.md) and [its docs](docs/plugins/model-cards/index.md).

### Skills (30)

Code quality, harness engineering, and governance knowledge that agents read when working in your codebase.

| Skill | What it provides |
| ----- | ---------------- |
| literate-programming | Knuth's five rules — code as literature, reader-first |
| cupid-code-review | Terhorst-North's five properties — composable, unix, predictable, idiomatic, domain-based |
| github-actions-supply-chain | CI hardening checklist — SHA pinning, permissions, dependabot |
| dependency-vulnerability-audit | Go and Maven CVE scanning procedures |
| docker-scout-audit | Docker image CVE triage and remediation |
| harness-engineering | Foundational concepts — the three components, promotion ladder, enforcement timing |
| context-engineering | Writing conventions precise enough for humans and LLMs to enforce |
| constraint-design | Designing enforceable constraints with the verification slot model |
| garbage-collection | Entropy-fighting patterns and the auto-fix safety rubric |
| verification-slots | The unified interface for deterministic and agent-based checks |
| ai-literacy-assessment | Assessment instrument — scan repo, ask questions, produce timestamped assessment with prioritised improvement plans |
| harness-observability | Four-layer observability guidance — snapshot format, telemetry export, meta-observability checks |
| convention-extraction | Five extraction questions, artefact mapping, four-element anatomy — surfaces tacit team conventions |
| cross-repo-orchestration | Git-mediated (L4) and specification-mediated (L5) patterns for syncing artefacts and governing portfolios |
| secrets-detection | Gitleaks-based secret scanning — configuration, baselining, and CI integration |
| auto-enforcer-action | Automatic PR constraint checking via GitHub Actions |
| convention-sync | Syncing HARNESS.md conventions to Cursor, Copilot, and Windsurf convention files |
| fitness-functions | Architectural fitness functions as GC rules — periodic checks for layer boundaries, coupling, and complexity |
| model-sovereignty | Decision framework for model selection, hosting, fine-tuning, and vendor independence |
| literacy-improvements | Prioritised improvement plan mapping assessment gaps to plugin commands and skills |
| portfolio-assessment | Multi-repo assessment aggregation — level distribution, shared gaps, and portfolio improvement plans |
| portfolio-dashboard | Generate a self-contained HTML dashboard from portfolio assessment data with trend visualisation |
| team-api | Create or update a Team Topologies Team API document with AI literacy portfolio data |
| cost-tracking | Quarterly AI cost capture — record spend, compare trends, inform model routing |
| governance-constraint-design | Falsifiable governance constraint authoring — three-frame translation, anti-patterns gallery, governance constraint template |
| governance-audit-practice | Governance audit methodology — five-stage semantic drift model, debt scoring matrix, frame alignment review |
| governance-observability | Governance metrics catalogue, snapshot format extension, and HTML dashboard specification |
| advocatus-diaboli | Adversarial spec review — six-category objection framework, evidence requirements, steel-manned challenge before plan approval |
| choice-cartographer | Decision archaeology — six-lens map of implicit choices a spec has made (forces, alternatives, defaults, patterns, consequences, coherence); routing rule partitions findings between the Cartographer and the diaboli |

### Agents (13)

A coordinated team that handles the full development lifecycle.

| Agent | Role | Trust boundary |
| ----- | ---- | -------------- |
| orchestrator | Pipeline coordinator — dispatches agents in sequence | Full access |
| spec-writer | Updates specs and plans before any code is written | No Bash |
| tdd-agent | Writes failing tests from spec scenarios | Can execute tests |
| code-reviewer | Reviews code through CUPID and literate programming lenses | No Write |
| integration-agent | CHANGELOG, commit, PR, CI, merge, cleanup, reflection | Full git access |
| harness-discoverer | Read-only project scanner | Read only |
| harness-enforcer | Unified verification engine for all constraint types | Read + Bash |
| harness-gc | Periodic entropy fighter | Read + Write |
| harness-auditor | Meta-agent — checks whether the harness matches reality | Write to Status only |
| assessor | AI literacy assessment — scans repo, asks questions, applies fixes, recommends workflow changes | Read + Write |
| governance-auditor | Governance specialist — semantic drift analysis, debt inventory, three-frame alignment | Read + limited Write |
| advocatus-diaboli | Adversarial reviewer — spec-time (premise/design focus, before plan approval) and code-time (risk/implementation focus, before integration); six-category objection record, read-only trust boundary, human-cognition gate on dispositions at both gates | Read only |
| choice-cartographer | Decision-archaeology mapper — runs after spec-mode diaboli dispositions are resolved; emits choice stories (Henney pattern stories) for each material implicit decision; soft gate at plan approval, merge-time HARNESS constraint enforces resolution | Read only |

### Commands (25)

| Command | What it does |
| ------- | ------------ |
| `/superpowers-init` | Guided setup — scaffolds the full habitat |
| `/superpowers-status` | Health dashboard — harness, agents, learning, CI |
| `/harness-init` | Harness-specific init |
| `/harness-status` | Quick harness health read |
| `/harness-constrain` | Add or promote a constraint |
| `/harness-gc` | Manage and run garbage collection rules |
| `/harness-audit` | Read-only diagnostic. Same engine as `/harness-sync` but prints findings without prompting to fix. Use for inspection-without-commitment, CI scripts, or the quarterly cadence anchor. |
| `/reflect` | Capture a post-task reflection |
| `/worktree` | Git worktree lifecycle — spin, merge, clean |
| `/assess` | AI literacy assessment with immediate fixes, workflow recommendations, and prioritised improvement plans |
| `/harness-health` | Harness health snapshot — enforcement ratio, trends, meta-observability checks |
| `/extract-conventions` | Guided session — surfaces tacit team conventions and maps them to CLAUDE.md and HARNESS.md |
| `/harness-sync` | Everyday lifecycle entry. Runs the shared audit-engine to detect drift across every surface (convention files, snapshot, Status section accuracy, ONBOARDING.md staleness, template, constraint regressions, recurring reflection patterns), presents a unified drift table tagged `[auto]`/`[manual]`, and applies the fixes you select. Mechanical fixes (convention files, snapshot, Status) auto-apply via existing primitives; judgement-required fixes (ONBOARDING regen, template upgrade, constraint authoring) print suggested commands. |
| `/convention-sync` | Sync HARNESS.md conventions to Cursor, Copilot, and Windsurf convention files |
| `/portfolio-assess` | Multi-repo AI literacy assessment — aggregate across local repos, GitHub orgs, or topic tags |
| `/cost-capture` | Capture AI tool cost data — record spend, compare to previous snapshot, update model routing |
| `/governance-constrain` | Guided governance constraint authoring with three-frame alignment check |
| `/governance-audit` | Deep governance investigation — semantic drift, debt inventory, frame alignment |
| `/governance-health` | Governance health pulse check and dashboard generation |
| `/harness-upgrade` | Discover and adopt new template content after a plugin upgrade |
| `/harness-onboarding` | Generate a human-readable onboarding guide from harness state |
| `/observatory-verify` | Verify all Observatory signal contracts against latest output files |
| `/diaboli` | Run the adversarial spec reviewer — produces objection record at `docs/superpowers/objections/<slug>.md` |
| `/choice-cartograph` | Run the Choice Cartographer — produces choice-story record at `docs/superpowers/stories/<slug>.md` after spec-mode diaboli dispositions are resolved |
| `/harness-affordance` | Manage the project's affordance inventory — `discover` scans config to produce a draft inventory; `add` and `review` planned |

### Templates (11)

Opinionated defaults scaffolded by `/superpowers-init`:

- **CLAUDE.md** — framework-aligned conventions (literate programming, CUPID, spec-first, TDD)
- **HARNESS.md** — living harness with starter constraints and enforcement timing
- **AGENTS.md** — compound learning memory (human-curated, agent-proposed)
- **MODEL_ROUTING.md** — model-tier guidance and token budget thresholds (see below)
- **REFLECTION_LOG.md** — append-only agent reflection log
- **ci-github-actions.yml** — CI enforcement template for GitHub Actions
- **ci-auto-enforcer.yml** — GitHub Actions workflow for agent-based PR constraint enforcement
- **ci-mutation-testing.yml** — weekly mutation testing template
- **ci-generic.sh** — fallback CI script for non-GitHub systems
- **ONBOARDING.md** — human-readable onboarding guide skeleton for new team members
- **harness-health-icon.svg** — monochrome shield icon for the README health badge

**MODEL_ROUTING.md** guides cost-conscious model selection. It maps each agent to a model tier (most capable, standard, fast) based on the judgment required. The orchestrator consults it when dispatching agents — spec-writers and code-reviewers get the most capable model; implementers and integration agents get standard models. Token budget guidance prevents runaway costs.

### Hooks (11)

All hooks are registered in `hooks/hooks.json` and active in every Claude Code session.

- **PreToolUse constraint gate** — reads HARNESS.md, warns on violations during edits (prompt-based, advisory)
- **PreToolUse markdownlint check** — runs markdownlint on `.md` files being written or edited (deterministic, advisory)
- **Stop drift check** — detects when CI, linter, or dependency configs change, nudges `/harness-audit`
- **Stop snapshot staleness check** — detects when the harness snapshot is stale (> 30 days), nudges `/harness-health`
- **Stop reflection prompt** — detects commits during the session, nudges `/reflect` to capture learnings
- **Stop framework-change prompt** — detects `framework.md` modifications, nudges `/reflect` + `/sync-repos` + downstream README checks
- **Stop secrets check** — scans for accidentally committed secrets or credentials using gitleaks
- **Stop rotating GC check** — runs one deterministic GC rule per session (rotating by day), catching entropy between weekly CI runs
- **Stop curation nudge** — detects unpromoted reflections in `REFLECTION_LOG.md` and nudges curation into `AGENTS.md`
- **Stop governance drift check** — detects governance-related file changes and audit staleness, nudges `/governance-audit`
- **SessionStart template currency check** — detects when the HARNESS.md template version is behind the installed plugin version, nudges `/harness-upgrade`

---

## Quick Start

### Install

See the [Installation](#installation) section above for the full marketplace + plugin install. In short:

```bash
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
claude plugin install ai-literacy-superpowers
```

### Initialize

```bash
cd your-project
```

Then in Claude Code:

```text
/superpowers-init
```

The init command will:

1. Scan your project to discover the stack, existing linters, CI, and test frameworks
2. Ask about your conventions (one topic at a time)
3. Ask which constraints to enforce and how
4. Offer the full agent pipeline or a subset
5. Generate CLAUDE.md, HARNESS.md, AGENTS.md, MODEL_ROUTING.md, REFLECTION_LOG.md, CI workflows, and a README badge
6. Commit everything

### Check Health

```text
/superpowers-status
```

Shows harness enforcement ratio, agent team configuration, compound learning state, model routing, and CI summary.

---

## How to Extend

### Adding a language-specific implementer

The plugin provides the agent pipeline pattern but does not ship language-specific implementers — these are created per project for each language in the stack. To create one:

1. Copy the pattern from any existing implementer (e.g. the exemplar's `go-implementer.md`)
2. Adapt the tool permissions, file scope, and build commands for your language
3. Save to `.claude/agents/<language>-implementer.md` in your project
4. The orchestrator will discover and dispatch it automatically

### Adding a new skill

1. Create a directory: `skills/<skill-name>/`
2. Add `SKILL.md` with YAML frontmatter (`name`, `description` with trigger conditions)
3. Optionally add a `references/` subdirectory for supporting material
4. The plugin auto-discovers skills by directory structure

### Adding a new command

1. Create `commands/<command-name>.md` with YAML frontmatter (`name`, `description`)
2. Define the process steps the command should follow
3. The command becomes available as `/<command-name>` in Claude Code sessions

### Adding a new hook

1. Create a script in `hooks/scripts/<script-name>.sh`
2. Add an entry to `hooks/hooks.json` under the appropriate event (`PreToolUse`, `PostToolUse`, or `Stop`)
3. Hook scripts receive context via environment variables (`CLAUDE_PROJECT_DIR`, etc.)
4. Always make hooks advisory (warn, don't block) unless enforcement is critical

---

## The Three Enforcement Loops

Every mechanism in the plugin operates at one of three timescales:

| Loop | Trigger | Strictness | Purpose |
| ---- | ------- | ---------- | ------- |
| Advisory | PreToolUse hook | Warn | Catch issues while context is fresh |
| Strict | CI on PR | Fail | Prevent violations from reaching main |
| Investigative | Scheduled GC + audit | Report | Fight slow entropy that gates miss |

### Mechanism Map

```text
ADVISORY LOOP (edit time — warn, do not block)
│
├── Hooks
│   ├── PreToolUse constraint gate     Reads HARNESS.md commit-scoped constraints,
│   │                                  warns on violations during Write/Edit
│   ├── PreToolUse markdownlint check  Runs markdownlint on .md files being
│   │                                   written or edited (deterministic)
│   ├── Stop drift check               Detects CI/linter/dependency changes at
│   │                                   session end, nudges /harness-audit
│   ├── Stop snapshot staleness check  Detects stale harness snapshot (> 30 days),
│   │                                   nudges /harness-health
│   ├── Stop reflection prompt          Detects commits during session,
│   │                                    nudges /reflect to capture learnings
│   ├── Stop framework-change prompt   Detects framework.md modifications,
│   │                                    nudges /reflect + /sync-repos +
│   │                                    downstream README checks
│   ├── Stop secrets check             Scans for committed secrets using gitleaks
│   ├── Stop rotating GC check         Runs one deterministic GC rule per session,
│   │                                    rotating by day-of-year
│   ├── Stop curation nudge            Detects unpromoted reflections, nudges
│   │                                    curation into AGENTS.md
│   ├── Stop governance drift check    Detects governance file changes, nudges
│   │                                    /governance-audit
│   └── SessionStart template currency Detects HARNESS.md template-version drift,
│                                        nudges /harness-upgrade
├── Context (read by agents at session start)
│   ├── CLAUDE.md                       Workflow rules, conventions, disciplines
│   ├── AGENTS.md                       Compound learning memory (human-curated)
│   ├── MODEL_ROUTING.md                Model-tier guidance + token budgets
│   └── Skills (30)                     Domain knowledge for agents
│
└── Commands
    ├── /reflect                        Capture post-task learnings
    └── /worktree spin|merge|clean      Parallel agent isolation


STRICT LOOP (merge time — block until green)
│
├── CI Workflows (generated from templates)
│   ├── ci-github-actions.yml           PR-scoped constraint enforcement
│   │                                    (markdownlint, gitleaks, shell checks)
│   ├── gc.yml                           Weekly GC for deterministic rules
│   └── ci-mutation-testing.yml         Language-specific mutation testing
│
├── Agent Pipeline
│   ├── orchestrator                    Coordinates full pipeline
│   │   ├── GATE: objection adjudication User resolves objections before proceeding
│   │   ├── GATE: plan approval         User reviews spec + adjudicated objections
│   │   └── GUARDRAIL: MAX_REVIEW_CYCLES=3
│   ├── spec-writer                     Spec + plan updates (no Bash)
│   ├── advocatus-diaboli               Adversarial spec review (read-only)
│   ├── tdd-agent                       Failing tests from spec scenarios
│   ├── implementer(s)                  Makes tests green — user-created per
│   │                                   language, not shipped by the plugin
│   ├── code-reviewer                   CUPID + LP review (no Write)
│   └── integration-agent               CHANGELOG, PR, CI, merge, reflection
│
└── Harness Constraints (HARNESS.md)
    ├── Deterministic                   Backed by CI tools
    ├── Agent-backed                    Backed by harness-enforcer
    └── Unverified                      Declared intent, not yet automated


INVESTIGATIVE LOOP (scheduled — sweep for entropy)
│
├── Garbage Collection Rules (HARNESS.md)
│   ├── Weekly CI workflow (gc.yml)      Deterministic rules: secret scanner,
│   │                                    snapshot staleness, shell checks
│   ├── Rotating Stop hook               One deterministic GC rule per session
│   └── Agent-scoped rules               Documentation freshness, command-prompt
│                                         sync, plugin manifest currency
├── Compound Learning
│   ├── REFLECTION_LOG.md               Agent reflections (append-only)
│   └── AGENTS.md                       Human-curated from reflections
│
├── Harness Commands
│   ├── /harness-audit                  Full meta-verification
│   ├── /harness-health                 Snapshot with trends and meta-observability checks
│   ├── /harness-status                 Quick health read
│   └── /harness-gc                     Run GC checks on demand
│
└── Governance Commands
    ├── /governance-constrain           Guided governance constraint authoring
    ├── /governance-audit               Deep governance investigation
    └── /governance-health              Governance pulse check and dashboard
```

### Observability as the Enabling Layer

The three enforcement loops generate signals that, when collected, make the entire habitat observable. The plugin's mechanisms produce the data; observability tools (OpenTelemetry, Claude Code analytics, Grafana) make it visible.

| Panel | What it shows | Sources |
| ----- | ------------- | ------- |
| **Cost** | Spend trend, model-tier distribution, cost per PR | Provider API, MODEL_ROUTING.md compliance |
| **Quality** | Coverage trend, mutation score trend, change failure rate | CI artifacts, mutation testing workflow |
| **Adoption** | Active AI users, sessions per developer, acceptance rate | Provider analytics |
| **Habitat health** | Harness enforcement ratio, compound learning growth, ALCI progression | /harness-status, REFLECTION_LOG.md, ALCI surveys |

Without observability, cost discipline is aspirational, mutation testing is a one-time experiment, and the harness is a document that may or may not match reality. With it, every mechanism gains an evidence layer.

---

## Harness Observability

The plugin includes a four-layer observability model for monitoring harness health over time:

| Layer | Question | How |
| ----- | -------- | --- |
| Operational cadence | Is the harness running? | `/harness-health` generates snapshots; a Stop hook nudges when the last snapshot is older than 30 days |
| Trend visibility | How has the harness changed? | Snapshots are diffed to show deltas; `--trends` produces multi-period views |
| Telemetry export | Can I visualise this externally? | Snapshot data can be exported as OpenTelemetry metrics to any OTLP-compatible backend |
| Meta-observability | Is the observability itself working? | Five self-checks: snapshot currency, cadence compliance, learning flow, GC effectiveness, trend direction |

### Health snapshots

`/harness-health` generates structured markdown snapshots stored in `observability/snapshots/`. Each snapshot captures:

- Enforcement ratios (deterministic / agent / unverified breakdown)
- Garbage collection rule status and findings
- Mutation testing kill rates per language
- Compound learning velocity (reflections and promotions)
- Operational cadence compliance
- Meta-observability results

Trends are derived by diffing consecutive snapshots — no external tooling required.

### README health badge

`/harness-health` maintains a shields.io badge in the project README:

- **Healthy** (green) — all layers operating, no overdue cadences
- **Attention** (amber) — one layer degraded or outer loop overdue
- **Degraded** (red) — multiple layers degraded or no snapshot in 30+ days

### Telemetry export

For teams that want external dashboards, the `references/telemetry-export.md` reference documents OTel metric names and a reference export script. The file-based approach (snapshots in git) is the default — telemetry export is optional.

### Related plugin components

- Skill: `skills/harness-observability/SKILL.md`
- Command: `commands/harness-health.md`
- Meta-checks: `skills/harness-observability/references/meta-observability-checks.md`
- Snapshot format: `skills/harness-observability/references/snapshot-format.md`
- Telemetry export: `skills/harness-observability/references/telemetry-export.md`
- Hook: snapshot staleness check in `hooks/hooks.json`
- Script: `scripts/update-health-badge.sh`

---

## The Agent Pipeline

When you use the orchestrator agent, it runs this pipeline:

```text
orchestrator
  → spec-writer
  → advocatus-diaboli (spec mode — read-only, produces spec objection record)
  → GATE: objection adjudication — spec mode (user writes dispositions; gate blocked while any is `pending`)
  → GATE: plan approval (user reviews plan + adjudicated spec objection record)
  → tdd-agent
  → implementer(s) (parallel, one per language — user-created per project)
  → code-reviewer
  → GUARDRAIL: MAX_REVIEW_CYCLES=3 (escalate after 3 loops)
  → advocatus-diaboli (code mode — read-only, produces code objection record; runs once after loop exits)
  → GATE: integration approval — code mode (user writes dispositions; gate blocked while any is `pending`)
  → integration-agent (includes reflection step)
```

The spec objection adjudication gate raises premise-level challenges before any tests or code exist — the cheapest moment to change course. The plan approval gate catches bad plans before they become bad code. The loop guardrail prevents unbounded reviewer cycles. The code objection adjudication gate surfaces threat-model, failure-mode, and operational concerns visible in the implementation before merge.

The plugin ships the orchestrator, spec-writer, tdd-agent, code-reviewer, and integration-agent. Language-specific implementers are not included — each project creates its own based on the stack. See [How to Extend](#how-to-extend) for instructions.

---

## Compound Learning

Agents learn across sessions through curated documentation:

```text
Agent completes work
  → integration-agent appends to REFLECTION_LOG.md
  → Human reviews periodically
  → Worthy entries promoted to AGENTS.md
  → All agents read AGENTS.md at next session start
```

Research shows LLM-generated documentation files reduce success rates. Human-curated files provide modest but real improvement. The rule: agents propose; humans curate.

### Compound learning flow

The plugin implements a three-stage learning cycle:

1. **Capture** — the integration-agent appends a structured reflection to `REFLECTION_LOG.md` after each task (date, agent, task, surprise, proposal, improvement)
2. **Curate** — during the quarterly operating cadence, humans review reflections and promote worthy entries to `AGENTS.md` as GOTCHA or ARCH_DECISION entries
3. **Benefit** — all agents read `AGENTS.md` at session start, incorporating prior learnings into their decision-making

The GC rule "Stale AGENTS.md" flags reflections older than 30 days that haven't been reviewed for promotion. This prevents the common failure mode where reflections are captured but nobody reads them.

---

## Intellectual Foundations

This plugin packages the practical workflow from the AI Literacy for Software Engineers framework. The design draws on several lineages — architecture, theory, craft, and engineering practice — that converge on a single idea: the environment matters as much as the code.

### Architecture and Habitability

- **Christopher Alexander** — *A Pattern Language* (1977); *The Timeless Way of Building* (1979). The "quality without a name" — design for inhabitants, not spectators. Alexander's insight that environments shape the behaviour of their occupants is the conceptual root of habitat engineering.
- **Richard P. Gabriel** — *Patterns of Software* (1996). Habitability: code as a place to live in. Gabriel extended Alexander's architectural philosophy to software, arguing that code should be welcoming to the people who maintain it.

### Code as Tacit Practice

- **Michael Polanyi** — *Personal Knowledge* (1958); *The Tacit Dimension* (1966). *We can know more than we can tell.* Tacit knowing — the practical understanding built up through engaged work, much of which resists articulation — is the ground on which all explicit knowledge stands. Polanyi gives the cognitive-science epistemology that Naur's theory-building applies to software: the substance of "theory" is Polanyi's tacit knowing. Polanyi grounds why the plugin's pedagogical commitments matter — the framework's cognitive gym (Theme #7), no-vibe coding (Theme #2), and the creator-to-verifier shift (Theme #15) are all defences against the tacit-knowledge attrition that AI generation tends to produce. Frank Ginac's "Cognitive Atrophy and Systemic Collapse in AI-Dependent Software Engineering" (2026, arxiv:2604.26855) gives the contemporary application.

### Code as Theory

- **Peter Naur** — "Programming as Theory Building" (1985); *Computing: A Human Activity* (1992). The essential product of programming is not the code but the theory the programmers hold about how the system works — Polanyi's tacit knowing applied to software. Loss of theory is loss of system: code can be preserved while the understanding that made it changeable is not. Naur is what habitability protects — the substance of shared understanding that the plugin's compound-learning components (REFLECTION_LOG.md, AGENTS.md, the convention-extraction and harness-audit skills) exist to externalise and sustain.

### Code as Literature

- **Donald Knuth** — "Literate Programming" (1984); *TeX: The Program* (1986). Code is written for humans to read, and only incidentally for machines to execute. The literate-programming skill applies Knuth's discipline: narrative preambles, reasoning-based documentation, presentation ordered by understanding.
- **Daniel Terhorst-North** — "CUPID — for joyful coding" (2022). Five properties that good code tends toward: Composable, Unix philosophy, Predictable, Idiomatic, Domain-based. The cupid-code-review skill uses these as a review and refactoring lens.

### Harness Engineering

- **Birgitta Boeckeler** — ["Harness Engineering"](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html) (2026). *Exploring Gen AI*, martinfowler.com. The three components of a complete harness: context engineering, architectural constraints, and garbage collection. The theoretical foundation for the plugin's three enforcement loops.
- **Mitchell Hashimoto** — "AI Harness" (2025). Blog post referenced by Boeckeler as a possible origin of the harness terminology.
- **Chad Fowler** — "Relocating Rigor." Essay on how rigor moves from writing code to designing the systems that generate and verify code. Frames the shift from manual discipline to environmental enforcement.

### Convention Discovery

- **Rahul Garg** — ["Encoding Team Standards"](https://martinfowler.com/articles/reduce-friction-ai/encoding-team-standards.html) (2026). *Patterns for Reducing Friction in AI-Assisted Development*, martinfowler.com. Treats AI instructions as infrastructure, not individual craft. Structured extraction interviews surface tacit team knowledge. Informed the convention-extraction skill and `/extract-conventions` command.

### Agent Orchestration

- **Addy Osmani** — ["The Code Agent Orchestra"](https://addyosmani.com/blog/code-agent-orchestra/) (2026). addyosmani.com. Subagent delegation, quality gates, compound learning, and the orchestrator pattern. Informed the agent pipeline design, worktree isolation, and the review loop guardrail.

### Specification-Driven Development

- **Gojko Adzic** — *Specification by Example: How Successful Teams Deliver the Right Software*. Manning. Concrete examples as tests; specifications as the shared language between intent and implementation. Informed the spec-first workflow and the spec-writer agent.

### Verification and Quality

- **Dave Farley** — Controlled study of 150 participants comparing AI-generated and human-written code across creation and maintenance phases. Evidence for AI as an amplifier of existing discipline — the core argument for why harnesses matter.
- **2025 DORA Report** — DevOps Research and Assessment. Findings on AI as an amplifier of existing engineering discipline: teams with strong practices benefit; teams without them are harmed.

### Cognitive Science (Framework Foundation)

The plugin implements practical workflows, but the framework's design decisions are grounded in cognitive science research on how human and artificial intelligence differ:

- **Andy Clark** — *Surfing Uncertainty* (2015). Predictive processing and the embodied mind.
- **George Lakoff & Mark Johnson** — *Metaphors We Live By* (1980). Embodied cognition and conceptual metaphor.
- **Edwin Hutchins** — *Cognition in the Wild* (1995). Distributed cognition — intelligence as a property of systems, not individuals.
- **Lucy Suchman** — *Plans and Situated Actions* (1987). The gap between plans and situated human action.
- **James J. Gibson** — *The Ecological Approach to Visual Perception* (1979). Affordances — the environment offers possibilities for action.
- **John Boyd** — The OODA Loop. Observe-Orient-Decide-Act as a cognitive cycle — the basis for the harness's replanning-after-each-action pattern.
- **Donella Meadows** — *Thinking in Systems* (2008). Systems thinking, leverage points, and feedback loops — the conceptual model for the three enforcement loops.

The mission: building habitats where human and AI intelligence thrive together.

---

## See It in Action

For a complete worked example of this plugin applied to a real project, see the [ai-literacy-exemplar](https://github.com/russmiles/ai-literacy-exemplar) repository — a Go CLI tool built using the full agent pipeline, with authentic git history showing the framework workflow.

---

## License

[Apache License 2.0](LICENSE)
