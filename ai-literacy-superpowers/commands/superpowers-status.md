---
name: superpowers-status
description: Show the complete health of the project's AI Literacy habitat — harness enforcement, agent team, compound learning, model routing, and CI status
---

# /superpowers-status

Display a health dashboard for the project's AI Literacy habitat. Run this any
time to verify that the framework is correctly configured and that compound
learning is accumulating as expected.

## What this command checks

Work through each section below in order. For each check, report status as
one of: OK, WARNING, or MISSING. Collect all results and print the full
dashboard at the end — do not stop early if a check fails.

### Section 1: Habitat files

Check that the core habitat files exist:

| File | Expected location | Status |
| ------ | ------------------ | -------- |
| CLAUDE.md | project root | OK / MISSING |
| AGENTS.md | project root | OK / MISSING |
| MODEL_ROUTING.md | project root | OK / MISSING |
| REFLECTION_LOG.md | project root | OK / MISSING |

For each file that exists, check that it is non-empty and contains the
expected section headings (STYLE, GOTCHAS, ARCH_DECISIONS for AGENTS.md;
agent routing table for MODEL_ROUTING.md).

### Section 2: Harness health

Check for the presence and validity of the harness:

- Does `.claude/settings.json` exist?
- Are hooks configured? Check for the drift-check hook or equivalent.
- Does `.claude/HARNESS.md` exist and describe the harness?
- Are the hook scripts executable?

Use the harness-engineering skill to evaluate what is found.

### Section 3: Agent team

Check that the agent team is present and consistent:

- List all `.claude/agents/*.md` files
- For each agent, confirm it has frontmatter with `name`, `description`,
  and `tools` fields
- Confirm the orchestrator, spec-writer, tdd-agent, code-reviewer, and
  integration-agent are all present

Report any agents that are present in `.claude/agents/` but not referenced
in MODEL_ROUTING.md (potential routing gap).

### Section 3a: Workflow routing

Surface the orchestrator's task-routing posture (the opt-in classify-and-act
routing):

- **Posture.** Read the optional `orchestrator-routing` field in HARNESS.md.
  Report `routing: enabled` when it is set to `enabled`, otherwise
  `routing: opt-in, off by default` (the conservative default when the field is
  absent). This is descriptive only — off-by-default is the intended posture, not
  a warning.
- **Last route taken.** When a durable trace of the most recent orchestrator run
  exists, report which of the four routes it selected — `static`, `tournament`,
  `root-cause`, or `triage`. When no such trace exists (the dashboard is a file
  snapshot, not a live event stream), report the last route as `unavailable`
  rather than inventing one.

### Section 3b: Sentinel coverage

Surface the health of the [sentinel](../skills/sentinel-design/SKILL.md)
agent family — the agents whose object of care is the human's understanding
and judgement (`carpaccio`, `advocatus-diaboli`, `choice-cartographer`,
`reservoir-warden`, `cost-estimator` in the flagship, plus any downstream
additions):

- **Count.** Count `.claude/agents/*.md` files whose frontmatter declares
  `role: sentinel`. Report `N sentinels active`. A count of zero is **not a
  warning** — a downstream project may legitimately ship none; report it as
  descriptive (`0 sentinels active`).
- **Integrity constraint.** Report the state of the Sentinel integrity
  constraint. When the plugin's `sentinel-integrity-check.sh` script is
  available, run it against the agents directory:
  `bash ai-literacy-superpowers/scripts/sentinel-integrity-check.sh <agents-dir>`.
  Report `integrity constraint green` on exit 0, or `integrity constraint
  WARNING` naming the offending agent(s) on a non-zero exit. When the script
  is not available (e.g. a bare-harness install without the plugin cache),
  report `integrity constraint unavailable` rather than inventing a verdict.

Combined line, e.g. `Sentinels: 5 active, integrity constraint green`.

### Section 4: Compound learning

Evaluate the state of AGENTS.md:

- When was it last modified? (`git log -1 --format="%ar" AGENTS.md`)
- How many entries are in GOTCHAS?
- How many entries are in ARCH_DECISIONS?
- How many reflection entries are in REFLECTION_LOG.md?
- Is the content growing (healthy) or static (potentially stale)?

Report: "Compound learning is active" if AGENTS.md or REFLECTION_LOG.md has
been modified in the last 30 days. Report "WARNING: no recent updates" if
neither has been touched in over 30 days.

### Section 5: Model routing

Check MODEL_ROUTING.md:

- Does it contain a routing table?
- Does it reference all agents present in `.claude/agents/`?
- Are token budget guidelines present?

### Section 6: CI status

Check for CI configuration:

- Does `.github/workflows/` contain any AI Literacy workflow files?
- Is `scripts/ai-literacy-check.sh` present and executable?
- If on a branch with an open PR, show the PR check status:
  `gh pr checks --json name,status,conclusion 2>/dev/null || echo "No open PR"`

### Disposition counting (shared algorithm for Sections 7 and 8)

`disposition:` and `disposition: pending` appear in objection and choice-story
records in **two distinct places** and only one of them is a real disposition:

1. **YAML frontmatter list items** — each entry under `objections:` or
   `stories:` carries a `disposition:` field indented exactly four spaces.
   These are the only values that count.
2. **Prose / evidence text** — `evidence:`, `claim:`, body sections, and
   quoted examples routinely contain the literal string `disposition: pending`
   when an objection critiques disposition handling. **These must not be
   counted.**

A naive `grep -c "disposition: pending"` over the whole file produces false
positives: in 2026-05 the `choice-cartographer.md` record reported as having
3 pending dispositions when every entry was in fact resolved — the three
matches were all inside O9's `evidence:` field quoting the spec.

**Counting rule (use this exact awk recipe, or an equivalent YAML-aware
parser):**

```bash
# Count entries with disposition: pending in YAML frontmatter only.
# Matches lines with exactly 4 leading spaces, scoped to the file's first
# `---`…`---` block, so prose occurrences are ignored.
count_pending() {
  awk '
    /^---$/                                          { fm++; next }
    fm == 1 && /^    disposition: pending([[:space:]]|$)/ { c++ }
    END                                              { print c+0 }
  ' "$1"
}

# Count total entries (objection IDs or story IDs) the same way.
count_entries() {
  awk '
    /^---$/             { fm++; next }
    fm == 1 && /^  - id:/ { c++ }
    END                 { print c+0 }
  ' "$1"
}
```

Why this works: every list-item field in these records is indented exactly
four spaces; list-item starts (`  - id:`) are indented two. Multi-line YAML
block scalars (if introduced later) would indent content **deeper** than four
spaces, so they cannot collide. Quoted-string lines start with the field's
own key (`    evidence:`, `    claim:`) — the `disposition:` token inside
those strings is therefore not at column 0–4.

Apply this rule consistently when computing:

- Section 7 spec-mode and code-mode `pending` counts and fully-resolved rates.
- Section 8 `cartograph_pending_count` and fully-resolved rate.
- Disposition distributions in both sections.

If a YAML-aware parser (`yq`, `python -c "import yaml; ..."`) is available,
prefer it — semantics match, parsing is structurally correct.

### Section 7: Diaboli activity

Check `docs/superpowers/specs/` and `docs/superpowers/objections/`.

A spec is **in-scope** if its filename date is on or after `2026-04-19`. Specs with
earlier dates are **exempt**. A spec slug is the filename with the `YYYY-MM-DD-` date
prefix and `.md` extension stripped.

- A **spec-mode record** matches `docs/superpowers/objections/<slug>.md`
- A **code-mode record** matches `docs/superpowers/objections/<slug>-code.md`

**Error handling**: if any file at `docs/superpowers/objections/` fails YAML parse,
report it by name as "parse error" and exclude it from all metrics.

**Counting**: use the shared algorithm in "Disposition counting" above for
all `disposition: pending` and total-objection counts. Do not grep the whole
file — only the YAML frontmatter list items count.

#### Overall totals (all records, both modes)

- **In-scope specs**: count of `docs/superpowers/specs/*.md` with filename date ≥ 2026-04-19
- **Exempt specs (pre-feature)**: count of specs with filename date < 2026-04-19
- **Objection records present**: count of all `docs/superpowers/objections/*.md`,
  excluding `.gitkeep`
- **In-scope specs without any record**: in-scope spec slugs with no matching spec-mode
  or code-mode file
- **Objections total**: sum of `objections` list lengths across all records
- **Mean objections per record**: total objections / count of records (1 decimal)

#### Spec-mode breakdown

- **Spec-mode records present**: count of `docs/superpowers/objections/<slug>.md` files
  (no `-code` suffix), excluding `.gitkeep`
- **Fully-resolved rate (spec-mode)**: records where every `disposition` is non-`pending`
  / total spec-mode records (record-level ratio)
- **Disposition distribution (spec-mode)**: among non-`pending` dispositions —
  accepted% / deferred% / rejected%
- **Mean objections per spec-mode record**: (1 decimal)

#### Code-mode breakdown

- **Code-mode records present**: count of `docs/superpowers/objections/<slug>-code.md`
  files
- **In-scope specs with spec-mode record but no code-mode record**: slugs where
  `<slug>.md` exists but `<slug>-code.md` does not
- **Fully-resolved rate (code-mode)**: records where every `disposition` is non-`pending`
  / total code-mode records (record-level ratio)
- **Disposition distribution (code-mode)**: among non-`pending` dispositions —
  accepted% / deferred% / rejected%
- **Mean objections per code-mode record**: (1 decimal)

Summary line: `Diaboli [OK]` when at least one in-scope spec-mode record is present;
`Diaboli [MISSING]` when none exist. No `WARNING` state — no threshold is defined yet.

### Section 8: Cartographer activity

Check `docs/superpowers/specs/` and `docs/superpowers/stories/`.

A spec is **in-scope** if its filename date is on or after `2026-04-27`. Specs
with earlier dates are **exempt**. A spec slug is the filename with the
`YYYY-MM-DD-` date prefix and `.md` extension stripped.

A **choice-story record** matches `docs/superpowers/stories/<slug>.md`.

**Error handling**: if any file at `docs/superpowers/stories/` fails YAML parse,
report it by name as "parse error" and exclude it from all metrics.

**Counting**: use the shared algorithm in "Disposition counting" above for
all `disposition: pending` and total-story counts. The same prose-vs-frontmatter
trap that bit Diaboli also applies here — count YAML list items only.

#### Totals

- **In-scope specs**: count of `docs/superpowers/specs/*.md` with filename
  date ≥ 2026-04-27
- **Choice-story records present**: count of
  `docs/superpowers/stories/*.md`, excluding `.gitkeep`
- **In-scope specs without a choice-story record**: in-scope spec slugs with
  no matching `<slug>.md` file
- **Stories total**: sum of `stories` list lengths across all records
- **Mean stories per record**: total stories / count of records (1 decimal)

#### Disposition state

- **`cartograph_pending_count`**: total count of stories with
  `disposition: pending` across all in-scope records. This is the field
  surfaced at plan approval and tracked by harness-health snapshots.
- **Fully-resolved rate**: records where every `disposition` is
  non-`pending` / total records (record-level ratio)
- **Disposition distribution**: among non-`pending` dispositions —
  accepted% / revisit% / promoted%

#### Lens activity

- **Lens distribution**: count of stories per lens across all records,
  reported as the six-lens histogram (forces / alternatives / defaults /
  patterns / consequences / coherence). Each story may count toward
  multiple lenses if its `lens` field has multiple values.

Summary line: `Cartographer [OK]` when at least one in-scope choice-story
record is present and `cartograph_pending_count` is 0; `Cartographer
[WARNING]` when records exist but `cartograph_pending_count > 0`;
`Cartographer [MISSING]` when no in-scope record exists. The WARNING
state surfaces unadjudicated stories — the merge-time HARNESS constraint
will block the PR until they are resolved, so `WARNING` is an early-look
signal, not a steady state.

## Output format

Print the dashboard as a structured report:

```text
AI Literacy Habitat Status
==========================

Habitat files    [OK / WARNING / MISSING]
Harness          [OK / WARNING / MISSING]
Agent team       [OK / WARNING / MISSING]
Sentinels        [N active, integrity constraint green / WARNING / unavailable]
Compound learning [OK / WARNING / MISSING]
Model routing    [OK / WARNING / MISSING]
CI               [OK / WARNING / MISSING]
Diaboli          [OK / MISSING]
Cartographer     [OK / WARNING / MISSING]

--- Details ---

[Section-by-section findings, flagging anything that is WARNING or MISSING;
 Diaboli and Cartographer sections always shown as descriptive stats —
 Cartographer's WARNING state means cartograph_pending_count > 0,
 surfaced as an early-look signal before the merge-time HARNESS gate
 fires]

--- Recommendations ---

[Prioritised list of actions to reach full green, if any]
```

If all sections are OK and Diaboli has at least one record, end with:
"Habitat is healthy. All checks passed."

## Reflection log + archive reporting

Include a `Reflection log` section that reports counts separately for
the active log, the archive, and the curation-debt metric (unpromoted
entries older than 180 days):

```bash
active=$(grep -c '^---$' REFLECTION_LOG.md 2>/dev/null || echo 0)
archive=$(grep -c '^---$' reflections/archive/*.md 2>/dev/null \
          | awk -F: '{s+=$2} END {print s+0}')
debt=$(awk '/^- \*\*Date\*\*: / {date=$3} /^- \*\*Promoted\*\*: / {p=1} /^---$/ {if (date && !p) {
              # entry boundary; check age vs 180d cutoff
            } date=""; p=0}' REFLECTION_LOG.md | wc -l)
```

Report these as a section in the status output:

```text
Reflection log:
  Active entries: <active>
  Archived entries: <archive>
  Curation debt (unpromoted >180d): <debt>
```
