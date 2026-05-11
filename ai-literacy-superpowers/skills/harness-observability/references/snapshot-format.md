# Snapshot Format Reference

Health snapshots are the core artefact of harness observability. Each
snapshot captures the harness's state at a point in time. Trends are
derived by comparing snapshots — no separate database or trend storage.

## Storage

Path: `observability/snapshots/YYYY-MM-DD-snapshot.md`

One file per snapshot. Markdown format — readable by developers and
agents, diffable in git.

## Sections

Every snapshot contains these sections in order. Each section has a
fixed format so agents can parse them reliably.

### Enforcement

```text
## Enforcement
- Constraints: N/M enforced (P%)
- Deterministic: X | Agent: Y | Unverified: Z
- Drift detected: yes/no
```

**Source:** HARNESS.md Status section and constraint definitions.

| Field | How to compute |
| ------- | --------------- |
| N (enforced) | Count constraints with enforcement = deterministic or agent |
| M (total) | Count all constraints |
| P% | (N / M) * 100, rounded to nearest integer |
| Deterministic | Count constraints with enforcement = deterministic |
| Agent | Count constraints with enforcement = agent |
| Unverified | Count constraints with enforcement = unverified |
| Drift | Read HARNESS.md Status section drift field |

### Enforcement Loop History

```text
## Enforcement Loop History

- Advisory (edit-time): active since YYYY-MM-DD
- Strict (merge-time): active since YYYY-MM-DD (or "not active")
- Investigative (scheduled): active since YYYY-MM-DD (or "not active")
```

**Source:** Git history and file existence checks.

| Field | How to compute |
| ------- | --------------- |
| Advisory | Active if hooks exist. First activated = earliest git commit that added hooks configuration (`git log --diff-filter=A --format=%as` on the hooks file). "not active" if no hooks |
| Strict | Active if CI enforcement workflow exists (`.github/workflows/harness.yml` or similar). First activated = earliest commit adding the harness CI workflow. "not active" if no CI enforcement |
| Investigative | Active if GC rules exist in HARNESS.md with enforcement. First activated = earliest commit adding a GC rule. "not active" if no GC rules |

After first computation, subsequent snapshots can read the dates from
the previous snapshot and only re-check if a loop's status changes.

### Garbage Collection

```text
## Garbage Collection
- Rules active: N/M
- Last run: YYYY-MM-DD
- Cadence compliance: on schedule / overdue (N days since last run, threshold T)
- Findings since last snapshot: N
```

**Source:** HARNESS.md GC section and audit history.

| Field | How to compute |
| ------- | --------------- |
| N (active) | Count GC rules with enforcement != none |
| M (total) | Count all GC rules |
| Last run | Date of most recent /harness-gc or /harness-audit |
| Cadence compliance | Compare days since last run against the declared GC cadence. "on schedule" if within threshold, "overdue" if exceeded. Include days since last run and the threshold value for parsability |
| Findings | Count of GC findings since previous snapshot date (from audit reports or commit messages) |

### Mutation Testing

```text
## Mutation Testing
- Go kill rate: N%
- Kotlin kill rate: N%
- Python kill rate: N%
- Trend: stable/improving/declining (±N% from last snapshot)
```

**Source:** Latest mutation testing CI artifacts.

| Field | How to compute |
| ------- | --------------- |
| Kill rate per language | Parse from CI artifact HTML reports or workflow logs |
| Trend | Compare with previous snapshot's kill rates. stable = ±2%, improving = >+2%, declining = <-2% |

If CI artifacts are unavailable, report "not available" rather than
guessing.

### Compound Learning

```text
## Compound Learning
- REFLECTION_LOG entries: N (M new since last snapshot)
- AGENTS.md entries: N (X gotchas, Y arch decisions)
- Promotions since last snapshot: N
```

**Source:** REFLECTION_LOG.md and AGENTS.md.

| Field | How to compute |
| ------- | --------------- |
| REFLECTION_LOG entries | Count entries (each starts with `##` heading with a date) |
| New since last snapshot | Count entries with dates after previous snapshot date |
| AGENTS.md entries | Count `GOTCHA:` and `ARCH_DECISION:` lines |
| Promotions | New AGENTS.md entries since previous snapshot date |

### Session Quality

```text
## Session Quality

- Reflections with signal: N/M (P%)
- Signal distribution: context: X | instruction: Y | workflow: Z | failure: W
- Quality trend: improving/stable/declining (vs previous snapshot)
```

**Source:** REFLECTION_LOG.md Signal fields.

| Field | How to compute |
| ------- | --------------- |
| Reflections with signal | Count reflections where Signal field exists and is not "none", divided by total reflections. Entries predating the Signal field (before 2026-04-08) count as "none". |
| Signal distribution | Count of each signal type across all reflections (cumulative, not just since last snapshot) |
| Quality trend | Compare "reflections with signal" percentage to previous snapshot. stable = ±2%, improving = >+2%, declining = <-2% |

### Diaboli

```text
## Diaboli

Overall:
- In-scope specs: N (specs dated ≥ 2026-04-19)
- Exempt specs (pre-feature): N
- Objection records present: N (spec-mode: A | code-mode: B)
- In-scope specs without any record: N
- Objections total: N (critical: A | high: B | medium: C | low: D)
- Mean objections per record: N.N

Spec-mode:
- Records present: N
- Fully-resolved rate: P% (N of M records fully resolved)
- Disposition distribution: accepted: P% | deferred: P% | rejected: P%
- Mean objections per record: N.N

Code-mode:
- Records present: N
- In-scope specs with spec-mode but no code-mode record: N
- Fully-resolved rate: P% (N of M records fully resolved)
- Disposition distribution: accepted: P% | deferred: P% | rejected: P%
- Mean objections per record: N.N
```

**Source:** `docs/superpowers/specs/` and `docs/superpowers/objections/`.

A spec is **in-scope** if its filename date is on or after `2026-04-19`. A spec
slug is the filename with the `YYYY-MM-DD-` prefix and `.md` extension stripped.

- A **spec-mode record** matches `docs/superpowers/objections/<slug>.md`
- A **code-mode record** matches `docs/superpowers/objections/<slug>-code.md`

| Field | How to compute |
| ------- | --------------- |
| In-scope specs | Count `docs/superpowers/specs/*.md` with filename date ≥ 2026-04-19 |
| Exempt specs (pre-feature) | Count specs with filename date < 2026-04-19 |
| Objection records present | Count all `docs/superpowers/objections/*.md`, excluding `.gitkeep` |
| In-scope specs without any record | In-scope slugs with no matching spec-mode or code-mode file |
| Objections total | Sum of `objections` list lengths across all records |
| Severity breakdown | Count critical/high/medium/low across all `objections` entries |
| Mean objections per record | Total objections / count of all records, rounded to 1 decimal |
| Spec-mode records present | Count `docs/superpowers/objections/<slug>.md` files (no `-code` suffix), excluding `.gitkeep` |
| Fully-resolved rate (spec-mode) | Spec-mode records where every `disposition` is non-`pending` / total spec-mode records |
| Disposition distribution (spec-mode) | Among non-`pending` dispositions in spec-mode records: accepted% / deferred% / rejected% |
| Mean objections per spec-mode record | Sum of spec-mode objection counts / count of spec-mode records, 1 decimal |
| Code-mode records present | Count `docs/superpowers/objections/<slug>-code.md` files |
| Specs with spec-mode but no code-mode | In-scope slugs where `<slug>.md` exists but `<slug>-code.md` does not |
| Fully-resolved rate (code-mode) | Code-mode records where every `disposition` is non-`pending` / total code-mode records |
| Disposition distribution (code-mode) | Among non-`pending` dispositions in code-mode records: accepted% / deferred% / rejected% |
| Mean objections per code-mode record | Sum of code-mode objection counts / count of code-mode records, 1 decimal |

**Error handling:** If a file at `docs/superpowers/objections/` fails YAML parse,
report it by name as "parse error" and exclude it from all metrics.

All fields are descriptive. No pass/fail status, no thresholds defined yet.

### Cartographer

```text
## Cartographer

- In-scope specs: N (specs dated ≥ 2026-04-27)
- Choice-story records present: N
- In-scope specs without a record: N
- Stories total: N
- Mean stories per record: N.N
- cartograph_pending_count: N
- Fully-resolved rate: P% (N of M records fully resolved)
- Disposition distribution: accepted: P% | revisit: P% | promoted: P%
- Lens distribution: forces: N | alternatives: N | defaults: N | patterns: N | consequences: N | coherence: N
```

**Source:** `docs/superpowers/specs/` and `docs/superpowers/stories/`.

A spec is **in-scope** if its filename date is on or after `2026-04-27`.
A spec slug is the filename with the `YYYY-MM-DD-` prefix and `.md`
extension stripped. A choice-story record matches
`docs/superpowers/stories/<slug>.md`.

| Field | How to compute |
| ------- | --------------- |
| In-scope specs | Count `docs/superpowers/specs/*.md` with filename date ≥ 2026-04-27 |
| Choice-story records present | Count `docs/superpowers/stories/*.md`, excluding `.gitkeep` |
| In-scope specs without a record | In-scope slugs with no matching `<slug>.md` file in `docs/superpowers/stories/` |
| Stories total | Sum of `stories` list lengths across all records |
| Mean stories per record | Total stories / count of records, 1 decimal |
| `cartograph_pending_count` | Total count of stories with `disposition: pending` across all records |
| Fully-resolved rate | Records where every `disposition` is non-`pending` / total records |
| Disposition distribution | Among non-`pending` dispositions: accepted% / revisit% / promoted% |
| Lens distribution | Count of stories per lens across all records (a story with multiple lens values counts toward each) |

**Error handling:** If a file at `docs/superpowers/stories/` fails YAML
parse, report it by name as "parse error" and exclude it from all
metrics.

`cartograph_pending_count` is the load-bearing field — it is also the
field surfaced at plan approval by the orchestrator and read by the
merge-time HARNESS constraint `PRs have adjudicated choice stories`.
A non-zero value at snapshot time indicates choice stories awaiting
adjudication; the merge-time constraint will block any affected PR
from merging until the count goes to zero for that spec's record.

### Operational Cadence

```text
## Operational Cadence
- Last /harness-audit: YYYY-MM-DD (N days ago — on schedule / overdue, target T days)
- Last /assess: YYYY-MM-DD (N days ago — on schedule / overdue, target T days)
- Last /reflect: YYYY-MM-DD (N days ago — on schedule / overdue, target T days)
- Outer loop overdue: yes/no
```

**Source:** Git log, assessment files, HARNESS.md Status section.

| Field | How to compute |
| ------- | --------------- |
| Last /harness-audit | HARNESS.md Status section "Last audit" date. Annotate with days ago, `on schedule` or `overdue`, and the cadence target from HARNESS.md Observability section (default 90 days) |
| Last /assess | Most recent file in assessments/ directory. Same annotation format |
| Last /reflect | Most recent date in REFLECTION_LOG.md. Same annotation format (default 30 days) |
| Outer loop overdue | yes if any of the above is overdue relative to its declared cadence |

### Cost Indicators

```text
## Cost Indicators
- Model routing configured: yes/no
- Tier distribution: (from MODEL_ROUTING.md)
- Last cost capture: YYYY-MM-DD (or "never")
- Monthly average: $X,XXX (or "not tracked")
- Budget status: within/over/not set
- Cost trend: increasing/stable/decreasing (vs previous capture)
```

**Source:** MODEL_ROUTING.md existence and content, plus the most
recent file in `observability/costs/` matching `*-costs.md`.

| Field | How to compute |
| ------- | --------------- |
| Model routing configured | Check MODEL_ROUTING.md exists and has routing table |
| Tier distribution | Read Agent Routing table from MODEL_ROUTING.md |
| Last cost capture | Most recent filename date in observability/costs/ |
| Monthly average | Read from the most recent cost snapshot |
| Budget status | Read from the most recent cost snapshot |
| Cost trend | Compare current and previous cost snapshots |

### Sustainable Pace

```text
## Sustainable Pace
- This month's pace: sustainable / at-edge / over-the-edge / unknown
- Note: short free-text note from the snapshot author (optional)
- Trend: holding / drifting toward edge / recovering (vs previous snapshot)
```

**Source:** Snapshot author self-report. Captures the "depletable
collaborator" signal as a longitudinal field so trend lines become
visible across snapshots.

| Field | How to compute |
| ------- | --------------- |
| This month's pace | Self-report from the snapshot author. `sustainable` = no slipping; `at-edge` = cadence held but adding any further pillar would force triage; `over-the-edge` = some streams slipping; `unknown` if no self-report yet |
| Note | Optional one-line free-text annotation explaining what shaped the pace this month |
| Trend | Compare to previous snapshot's pace field. `holding` if same or better; `drifting toward edge` if worsened by one band; `recovering` if improved by one band |

If no self-report was captured, record `unknown` rather than guessing.
Introduced 2026-05-11 per quarterly assessment recommendation.

### Portfolio Adoption

```text
## Portfolio Adoption
- Plugin installs (cumulative): N (or "not tracked")
- /assess invocations from other projects: N (or "not tracked")
- Upstream PRs into ai-literacy-for-software-engineers: N since last snapshot
- agent-harness-enabled tagged repos discovered: N
- Trend: growing / stable / declining (vs previous snapshot)
```

**Source:** GitHub topic-tag search, marketplace install telemetry
(when available), and parent repo PR list.

| Field | How to compute |
| ------- | --------------- |
| Plugin installs | If install telemetry is available, report cumulative. Otherwise `not tracked` |
| /assess invocations from other projects | If telemetry is available, report count since previous snapshot. Otherwise `not tracked` |
| Upstream PRs | Count PRs into `ai-literacy-for-software-engineers` since previous snapshot date (via `gh pr list`) |
| Tagged repos | `gh search repos --topic agent-harness-enabled` count |
| Trend | Compare to previous snapshot. `growing` = any field increased; `stable` = no change; `declining` = any field decreased |

Introduced 2026-05-11 per quarterly assessment recommendation. L5 →
sovereign-across-an-organisation needs adoption telemetry; start
capturing what's available, even when most fields read `not tracked`.

### Meta

```text
## Meta
- Snapshot cadence: on schedule / overdue
- Cadence compliance: N/4 on schedule (audit, assess, reflect, GC)
- Learning flow: active / stalled / inactive
- GC effectiveness: productive / silent
- Trend alerts: none / [list declining metrics]
- Health: Healthy / Attention / Degraded
```

**Source:** Computed from other sections and previous snapshot.

| Field | How to compute |
| ------- | --------------- |
| Snapshot cadence | Compare days since previous snapshot to cadence threshold from HARNESS.md Observability section. "on schedule" if within threshold, "overdue" if exceeded |
| Cadence compliance | Count how many of the four tracked activities (audit, assess, reflect, GC) are on schedule. Report as `N/4 on schedule` |
| Learning flow | `active` if new reflections exist since last snapshot. `stalled` if REFLECTION_LOG has entries but none are recent (> unpromoted reflection age threshold from HARNESS.md). `inactive` if REFLECTION_LOG has zero entries or does not exist |
| GC effectiveness | `productive` if any GC rule produced a finding since the last snapshot. `silent` if all rules reported zero findings |
| Trend alerts | List any metrics that have declined for the configured consecutive-declining-trend threshold (from HARNESS.md Health thresholds). "none" if no alerts |
| Health | `Healthy` if all layers operating and no overdue cadences. `Attention` if one layer degraded or outer loop overdue. `Degraded` if multiple layers degraded or no snapshot in 30+ days. See SKILL.md README Health Indicator for colour mapping |

See `references/meta-observability-checks.md` for additional check
definitions and thresholds.

### Regression Indicators

```text
## Regression Indicators

- Snapshot stale: yes/no (> configured cadence threshold)
- Snapshot age: N days
- Cadence non-compliance: N of 4 activities overdue (audit, assess, reflect, GC)
- Consecutive weeks without reflections: N
- Regression flag: yes/no
```

**Source:** Computed from Operational Cadence and REFLECTION_LOG.md.

| Field | How to compute |
| ------- | --------------- |
| Snapshot stale | Compare previous snapshot date to today. Stale if age exceeds the cadence threshold (10 days for weekly, 21 for fortnightly, 30 for monthly). Read cadence from HARNESS.md Observability section, default monthly |
| Snapshot age | Days between previous snapshot date and today. 0 if this is the first snapshot |
| Cadence non-compliance | Count how many of audit (90-day cadence), assess (90-day), reflect (30-day), and GC (declared cadence) are overdue. Reuse data from Operational Cadence section |
| Consecutive weeks without reflections | Count calendar weeks backwards from today with zero REFLECTION_LOG.md entries. 0 if the most recent entry is this week |
| Regression flag | "yes" if any of: stale = yes, non-compliance >= 2, or consecutive weeks >= 4 |

### Changes Since Last Snapshot

```text
## Changes Since Last Snapshot

- Constraints added: [list or "none"]
- Constraints promoted: [list with old → new tier, or "none"]
- Constraints removed: [list or "none"]
- Assessments completed: [dates and levels, or "none"]
- Governance audits completed: [dates, or "none"]
```

**Source:** Comparison of current HARNESS.md with previous snapshot's
Enforcement section, plus file listings in `assessments/` and
`observability/governance/`.

| Field | How to compute |
| ------- | --------------- |
| Constraints added | Names of constraints in current HARNESS.md not present in the previous snapshot's Enforcement section |
| Constraints promoted | Constraints whose tier changed between snapshots, shown as `name: old tier → new tier` |
| Constraints removed | Constraints present in the previous snapshot but absent from current HARNESS.md |
| Assessments completed | Dates and levels from assessment files in `assessments/` created since the previous snapshot date |
| Governance audits completed | Dates from audit files in `observability/governance/` created since the previous snapshot date |

If no previous snapshot exists, report "first snapshot" for all fields.

This section replaces the separate event log — constraint lifecycle
and assessment events are captured directly in the snapshot.

### Trends

```text
## Trends (vs YYYY-MM-DD)

| Metric | Previous | Current | Change |
| -------- | ---------- | --------- | -------- |
| Enforcement ratio | P% (N/M) | P% (N/M) | ±N% |
| Mutation (Go) | N% | N% | ±N% |
| Mutation (Kotlin) | N% | N% | ±N% |
| Mutation (Python) | N% | N% | ±N% |
| Reflections | N | N | ±N |
| Promotions | N | N | ±N |
| Reflections with signal | P% (N/M) | P% (N/M) | ±N% |
| GC findings | N | N | ±N |
| Cadence status | status | status | changed/unchanged |
```

**Source:** Previous snapshot file. If no previous snapshot exists, omit
this section entirely.

## Parsing Notes for Agents

Agents reading snapshots should:

1. Find the latest file in `observability/snapshots/` by filename date
2. Parse each section by its `##` heading
3. Extract values from the `- Field: Value` format
4. For the Trends table, parse the markdown table rows

The format is deliberately simple and consistent so regex-based parsing
works reliably.
