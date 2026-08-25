# Habitat document discovery

Reference for the discovery methodology used by `/assess`, the
`assessor` agent, and the `harness-discoverer` agent before any
maturity claim or absence finding.

The methodology has one rule: **every absence claim must come from a
fully-completed search across known alternatives, not from "not at the
default path"**. Discovery output is auditable — each finding cites
the path matched and the content marker that confirmed the match, so
the user can verify rather than trust.

This reference covers three habitat documents — `HARNESS.md`,
`AGENTS.md`, and `CLAUDE.md`. Other artefacts (specs, objections,
stories, snapshots, reflections) follow in a later iteration.

## What's in scope (this iteration)

The three core habitat documents:

| Document | Role |
| --- | --- |
| `HARNESS.md` | Declared specification of the surrounding harness; constraints, GC rules, status |
| `AGENTS.md` | Compound-learning memory the agent reads on every dispatch; STYLE, ARCH_DECISIONS, past gotchas |
| `CLAUDE.md` | Project conventions in the agent's context window |

Discovery answers, for each of the three: present at the conventional
location, present at an alternative location, or genuinely absent
across all the alternatives we checked.

## Alternative paths to scan

For each habitat document, scan the conventional location *and* the
following alternatives. The list isn't exhaustive — it is the union
of paths observed across real projects. New alternatives go here as
they are discovered.

### HARNESS.md alternatives

```text
HARNESS.md                          # Conventional
docs/HARNESS.md
.ai/HARNESS.md
.agents/HARNESS.md
conventions/HARNESS.md
governance/HARNESS.md
CONVENTIONS.md                      # Renamed equivalent
STANDARDS.md                        # Renamed equivalent
docs/conventions.md
docs/standards.md
```

### AGENTS.md alternatives

```text
AGENTS.md                           # Conventional
.agents/AGENTS.md
docs/AGENTS.md
.claude/AGENTS.md
.cursor/AGENTS.md                   # Some projects place it under tool dirs
```

### CLAUDE.md alternatives

```text
CLAUDE.md                           # Conventional
.claude/CLAUDE.md
docs/CLAUDE.md
.ai/CLAUDE.md
```

A path-only match is a *candidate*, not a *match*. Confirm with
content markers below.

## Content markers

A habitat document at an alternative path is only a real match if its
content contains the marker patterns associated with that document
type. Path matching narrows the search; content-marker matching
confirms the match.

### HARNESS.md content markers

Match if **at least two** of the following are present:

- `^## Constraints` heading (with constraint blocks following)
- `^### Status` or `^## Status` heading with last-audit-date or
  enforcement-ratio fields
- `^## Garbage Collection` heading
- `^## Context` heading with stack/conventions sub-headings
- A constraint block with the four-field shape:
  `**Rule**:`, `**Enforcement**:`, `**Tool**:`, `**Scope**:`
- The string `template-version:` in an HTML comment near the top
  <!-- redirect-sunset: 2027-02-25 — retained reader for the retired
       template-version marker (spec 2026-08-25-template-currency-measure-content-design
       §2.2). The marker is no longer written; this stays only while
       consuming projects still carry one. Remove at the sunset date. -->
- A YAML frontmatter `name:` field with a harness-shaped value

The four-field constraint block is the strongest single marker — a
file containing two or more such blocks is almost certainly a
HARNESS.md equivalent regardless of filename or path.

### AGENTS.md content markers

Match if **at least two** of the following are present:

- `ARCH_DECISION` headings or sections
- `^## Style` heading with conventions-style content
- A "past learnings" / "gotchas" / "patterns observed" section
- References to `REFLECTION_LOG.md` or to specific past reflection
  dates
- Compound-learning vocabulary: "promotions from reflections", "what
  agents should know"

### CLAUDE.md content markers

Match if **at least two** of the following are present:

- Direct address to an AI: "You are…", "Do not…", "Always…", "Never…"
- A conventions block with naming, file structure, error handling, or
  documentation style sub-sections
- References to specific agent commands (`/spec-writer`,
  `/diaboli`, `/choice-cartograph`, etc.) as part of workflow
  instructions
- Workflow rules describing branching, commit messages, PR flow

## Discovery report format

The discovery report is the first artefact produced by `/assess` and
the harness-discoverer, before any maturity claim. The format is
auditable — every finding cites the path matched and the markers
confirmed.

```markdown
## Habitat document discovery

### HARNESS.md

- **Status**: <found at conventional path | found at alternative path | not found>
- **Path**: `<path>` (or `—` if not found)
- **Markers matched**: <list of marker patterns, with line citations>
  - `## Constraints` heading at line N
  - 4-field constraint block at lines M–P
  - `template-version: 0.29.0` in HTML comment at line K
- **Notes**: <free text — e.g. "embedded inside CLAUDE.md as a
  Constraints section rather than as a separate file" or "two
  candidates found, see Ambiguities below">

### AGENTS.md

- **Status**: …
- **Path**: …
- **Markers matched**: …
- **Notes**: …

### CLAUDE.md

- **Status**: …
- **Path**: …
- **Markers matched**: …
- **Notes**: …

### Ambiguities

<empty if discovery was unambiguous; populated when multiple
candidates were found for the same document type>

- HARNESS.md: two candidates
  - `HARNESS.md` (4-field constraint blocks at lines 50–80, no
    Status block)
  - `docs/STANDARDS.md` (Status block at line 200, no constraint
    blocks)
  - **Resolution**: ambiguous — user must confirm which is the
    canonical record. Discovery does not pick silently.

### Paths checked but not matched

<every path scanned that did not match — even at conventional
locations — so the user can verify the search was complete>

- `HARNESS.md` — file does not exist
- `docs/HARNESS.md` — file does not exist
- `.ai/HARNESS.md` — file does not exist
- `CONVENTIONS.md` — exists but does not contain any HARNESS markers
- … (the full list of alternative paths from this reference)
```

The `Paths checked but not matched` section is what makes absence
claims auditable. A user reading the report can see exactly which
locations were scanned and which markers were checked. "Not found
anywhere I checked" with the list of paths is a different claim
than "not at the default path", and the report distinguishes them.

## Failure modes

Two cases the discovery layer must handle deliberately rather than
silently.

### Ambiguous discovery

Two or more files match content markers for the same document type
across the scanned paths. The discovery layer **fails loudly** — it
lists every candidate with its path and matched markers, places them
under an `Ambiguities` section, and asks the user to confirm which
file is the canonical record. The discovery layer does not pick one
silently; silent picks produce confidently-wrong assessments.

Concrete example: a project has both `HARNESS.md` (with constraint
blocks but no Status section) and `docs/CONVENTIONS.md` (with a
Status section but no constraint blocks). Both partially match.
Discovery reports both, the user resolves.

### Genuine absence

No path matches and no content marker is satisfied across any scanned
path. The discovery layer reports `Status: not found`, lists every
path checked under `Paths checked but not matched`, and continues to
the next document. Downstream tooling (the assessor's maturity
calculation, the harness-discoverer's report) treats genuine absence
differently from "found at alternative path" — but both have to be
distinguishable in the report.

## Where this reference is consumed

- `agents/assessor.agent.md` Phase 1 (Scan the repository) — consumes
  this reference to perform habitat document discovery before the
  rest of the scan.
- `agents/harness-discoverer.agent.md` step 5 (Convention
  documentation) — consumes this reference to find embedded habitat
  patterns regardless of filename.
- `commands/assess.md` — surfaces the discovery report as the first
  output, before any maturity claim.
- `skills/ai-literacy-assessment/SKILL.md` — references this file as
  the methodology for habitat document discovery.

Inline duplication of these paths or markers across the four
consumers is forbidden. Edits to discovery contract live in this
file so the consumers stay in sync.

## What's deferred

Out of scope for this iteration; tracked for follow-up:

- Specs, objections, stories, snapshots, reflections paths
- Reading parallel-tool configurations (`.cursor/rules/`,
  `.github/copilot-instructions.md`, `.windsurf/rules/`) as
  evidence sources — that's evidence-base expansion (Unit B), not
  discovery
- Content-shape analysis to distinguish state-based orchestration
  from accumulated bash — also Unit B
