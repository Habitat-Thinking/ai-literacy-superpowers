---
title: Skills
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 1
redirect_from:
  - /reference/skills/
  - /reference/skills.html
---

# Skills

The plugin ships 30 skills. Each skill is a focused unit of domain knowledge that Claude can invoke during a session. They are grouped below by category.

---

## Harness Core

### harness-engineering

The conceptual foundation of the harness framework. Covers what a harness is, why deterministic tooling surrounds AI generation, and how the enforcement loops relate to each other.

### context-engineering

Writing enforceable conventions for the Context section of HARNESS.md. Covers how to express rules that Claude will honour consistently rather than treat as advisory suggestions.

### constraint-design

Designing and promoting constraints. Covers the lifecycle of a constraint from informal team agreement through to a checked, versioned rule enforced in CI.

### verification-slots

Integrating deterministic tools into verification slots. Covers how to attach linters, scanners, and test runners to the pre-commit, pre-merge, and scheduled enforcement loops.

### garbage-collection

Entropy-fighting periodic checks. Covers how to define GC rules that detect drift, dead code, and stale configuration before they compound into larger problems.

### harness-observability

Harness health snapshots and observability. Covers how to read a health snapshot, interpret enforcement scores, and set up alerting when the harness degrades.

### harness-onboarding

Generating human-readable onboarding documentation from harness state. Covers the three-source synthesis (HARNESS.md, AGENTS.md, REFLECTION_LOG.md), tone guidelines for writing for new contributors, section-by-section content mapping, and the validation checkpoint that verifies structural completeness.

---

## Security

### secrets-detection

Gitleaks-based secret scanning. Covers configuration, baseline management, and integrating the scan into pre-commit and CI verification slots.

### dependency-vulnerability-audit

Go/Maven dependency CVE scanning. Covers running audits, triaging findings by severity, and deciding when to suppress versus remediate a vulnerability.

### docker-scout-audit

Docker image CVE scanning. Covers running Docker Scout against local and registry images, interpreting the report, and acting on critical findings.

### github-actions-supply-chain

CI pipeline security hardening. Covers pinning Actions to commit SHAs, reviewing third-party action permissions, and detecting supply-chain risks in workflow files.

---

## Code Quality

### cupid-code-review

CUPID properties for code review. Covers applying the CUPID principles (Composable, Unix philosophy, Predictable, Idiomatic, Domain-based) when reviewing or refactoring a pull request.

### literate-programming

Code structured for humans to read first. Covers writing source files where narrative explanation and code are interleaved so that intent is always visible alongside implementation.

---

## Architecture

### fitness-functions

Periodic architectural health checks. Covers defining fitness functions that measure whether the system still satisfies its architectural properties, and running them on a schedule.

### convention-extraction

Surfacing tacit team knowledge. Covers guided sessions that turn unwritten team norms into explicit, versioned conventions that can be enforced by the harness.

### convention-sync

Syncing conventions to Cursor, Copilot, and Windsurf. Covers translating HARNESS.md conventions into the rule formats understood by each editor AI so enforcement is consistent across tools.

### cross-repo-orchestration

Coordinating changes across repos. Covers patterns for planning, sequencing, and verifying a change that touches more than one repository without breaking consumers.

### model-sovereignty

Model selection, hosting, and vendor independence. Covers the decision hierarchy (prompting → RAG → fine-tuning → distillation → local hosting), data classification for routing, cost break-even analysis, and maintenance awareness for custom models.

---

## Workflow

### ai-literacy-assessment

ALCI assessment instrument. Covers scanning for observable evidence, asking clarifying questions, producing a timestamped assessment with level rationale, applying immediate habitat fixes, recommending workflow changes, and invoking the `literacy-improvements` skill for prioritised improvement plans targeting the next literacy level or higher.

### literacy-improvements

Prioritised improvement plans from assessment gaps. Covers mapping each gap to the specific plugin command or skill that closes it, grouped by target level, with interactive accept/skip/defer for each item.

### portfolio-assessment

Multi-repo assessment aggregation.

### portfolio-dashboard

Self-contained HTML dashboard from portfolio assessment data.

### team-api

Team Topologies Team API document generation and update. Covers creating a new Team API from a template or updating an existing one with AI literacy portfolio data — repo levels, discipline scores, shared gaps, and improvement priorities. Bridges portfolio assessment into organisational communication artifacts. Covers generating a shareable dashboard with level distribution, repo table, shared gaps, improvement plan, and trend visualisation from multiple quarterly assessments. Output is a single HTML file with no external dependencies. Covers discovering repos from local paths, GitHub orgs, or topic tags, reading or estimating individual assessment levels, aggregating into a portfolio view with level distribution, shared gaps, and outliers, and generating improvement plans grouped by organisational impact.

### cost-tracking

Quarterly AI cost capture and tracking. Covers guiding users through provider billing dashboards, recording spend and token usage in a structured format, comparing to previous snapshots for trend analysis, and updating MODEL_ROUTING.md with observed cost patterns.

### auto-enforcer-action

Automatic PR constraint checking via GitHub Actions. Covers installing and configuring the GitHub Action that runs harness constraint checks on every pull request without manual intervention.

---

## Governance

### governance-constraint-design

Falsifiable governance constraint authoring. Covers the falsifiability test (what to verify, what counts as evidence, what happens on failure), the three-frame translation step (engineering, compliance, AI system perspectives), an anti-patterns gallery with falsifiable rewrites, and the governance constraint template for HARNESS.md. Referenced by `/governance-constrain` and the harness-enforcer agent.

### governance-audit-practice

Governance audit methodology. Covers the seven-step audit process, the five-stage semantic drift model with detection heuristics, governance debt scoring (severity × blast radius matrix), three-frame alignment assessment, four-debt cycle reinforcement detection, and audit report format. Referenced by the governance-auditor agent.

### governance-observability

Governance metrics and dashboard specification. Covers the seven governance metrics (constraint count, falsifiability ratio, drift score, debt inventory size, frame alignment score, last audit date, drift velocity), the snapshot format extension, staleness thresholds, audit report format, HTML dashboard section specifications, and portfolio integration. Referenced by the governance-auditor agent and `/governance-health`.

---

## Spec-First Pipeline

Two paired read-only agents that run between spec-writer and plan
approval. The diaboli challenges; the cartographer maps. Both have
read-only trust boundaries that enforce a human-cognition gate on
dispositions. They share a deterministic Routing Rule that partitions
findings between them.

### advocatus-diaboli

Adversarial spec review. Covers the six objection categories
(premise, scope, implementation, risk, alternatives, specification
quality), severity levels (critical, high, medium, low), evidence
requirements grounded in the spec text, the 12-objection cap, the
"Explicitly not objecting to" discipline, dispatch-mode category
weighting (spec-time vs. code-time), and the Routing Rule that
partitions findings with the choice-cartographer. Referenced by
`/diaboli` and the advocatus-diaboli agent.

### choice-cartographer

Decision archaeology. Covers the six lenses (forces, alternatives,
unspoken, defaults inherited, patterns unnamed, consequences accepted,
story coherence), the Routing Rule (failure-vs-decision test that
partitions findings with the diaboli), the selectivity protocol
(5–8 stories per spec target with a self-imposed 15-cap inside the
agent's reasoning), the cross-reference protocol (deterministic
resolution of `O\d+` and `#N` tokens in `Refs` fields), and the
output format. Referenced by `/choice-cartograph` and the
choice-cartographer agent.
