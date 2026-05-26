# Slicing-record validation checks

Reference for the validation checkpoint applied to slicing records at
`docs/superpowers/slices/<task-slug>.md`. Both `/carpaccio` and the
orchestrator's step 0 import this list as the single source of truth —
do not inline these checks into the command or the orchestrator.
Reference the file by path.

When a check fails, apply the **fix-recipe** in place. Do not
re-dispatch the agent. The 9-slice cap is enforced inside the agent's
reasoning protocol; the validator never receives a cap-overshoot in
normal operation, but F4 catches it if it ever does.

## Frontmatter checks

### F1. YAML frontmatter parseable

The file must open with `---`, contain valid YAML up to a closing
`---`, and the closing line must be reachable.

**Fix-recipe:** none. If the frontmatter is unparseable, fail loudly
with the YAML error message.

### F2. Required top-level fields present

The frontmatter must have all of: `task`, `task_slug`, `date`,
`carpaccio_model`, `inseparable`, `progressed_slice`, `slices`.

**Fix-recipe:** if any scalar field is missing, fail loudly. If
`slices` is missing or empty, fail loudly.

### F3. Top-level field types

- `inseparable` must be a boolean.
- `progressed_slice` must be `null` or a string matching one of the
  slice ids in `slices[].id`.

**Fix-recipe:** if `inseparable` is missing or non-boolean, fail
loudly. If `progressed_slice` does not match an id, fail loudly.

### F4. Slice count

`slices` must have at least 1 entry and at most 9.

**Fix-recipe:** if count > 9, surface a warning and truncate to the
first 9 slices by lens priority (decision-boundary first, then
acceptance-criterion, then end-to-end, then independence, then
inseparability). Document the truncation in the prose body's
`## Explicitly not slicing on` section.

### F5. Each slice has required fields

Every entry must have: `id`, `title`, `scope`, `decision_focus`,
`lens_used`, `disposition`, `disposition_rationale`, `file_as_issue`,
`issue_url`, `merged_into`.

**Fix-recipe:** insert missing scalar fields with default values
(`disposition: pending`, `disposition_rationale: null`,
`file_as_issue: pending`, `issue_url: null`, `merged_into: null`).
Do not invent `id`, `title`, `scope`, or `decision_focus` — fail
loudly if missing.

### F6. lens_used vocabulary

`lens_used` must be one of: `decision-boundary`,
`acceptance-criterion`, `end-to-end`, `independence`,
`inseparability`.

**Fix-recipe:** if an unknown lens is present, fail loudly. The
vocabulary is closed.

### F7. Initial-state contract

Every slice must ship with `disposition: pending`,
`disposition_rationale: null`, `file_as_issue: pending`,
`issue_url: null`, `merged_into: null`. The agent never pre-fills
these. The orchestrator sets `issue_url` *after* the gate clears.

**Fix-recipe:** if any of these is non-default on agent output,
reset to default and surface a warning. The agent should never
pre-fill, but the validator self-heals.

### F8. Inseparability shape

When `inseparable: true`, `slices` must have exactly 1 entry, and
that slice's `lens_used` must be `inseparability`.

**Fix-recipe:** if `inseparable: true` and slice count ≠ 1, fail
loudly. If `inseparable: true` and the single slice's `lens_used`
is not `inseparability`, fail loudly.

## Prose-body checks

### P1. One ## S<N> heading per frontmatter slice

Each frontmatter slice must have a matching `## S<N> — <title> — <lens>`
heading in the prose body. The id, title, and lens must match.

**Fix-recipe:** if a frontmatter slice has no matching heading, fail
loudly. If a heading exists but title or lens disagrees with the
frontmatter, fail loudly.

### P2. Required subsections per slice

Each `## S<N>` section must contain four subsections: **Context**,
**Decision content**, **Dependencies**, **Rationale**. They may use
any heading depth (e.g., `### Context` or `**Context**` bold-emphasis
prose lead).

**Fix-recipe:** if any subsection is missing, fail loudly. Do not
invent content.

### P3. Sequencing recommendation present

A `## Sequencing recommendation` section must be present, even if its
body is just "Any order — slices are independent."

**Fix-recipe:** if missing, append the section with body "Any order
— slices are independent." and surface a warning.

### P4. Explicitly not slicing on present with ≥ 3 entries

A `## Explicitly not slicing on` section must be present and contain
at least three discrete entries (bullets or short paragraphs).

**Fix-recipe:** if the section is missing or has < 3 entries, fail
loudly. This forces the agent to surface what it considered.

### P5. Inseparability rationale when applicable

When frontmatter has `inseparable: true`, the prose body must
contain a `## Inseparability rationale` section with substantive
content (≥ 3 sentences).

**Fix-recipe:** if missing or insubstantial when `inseparable: true`,
fail loudly.
