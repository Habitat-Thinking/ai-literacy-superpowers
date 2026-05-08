# Project Conventions

<!-- INSTRUCTIONS: Replace every placeholder marked with <!-- ... --> with
     project-specific content. Delete placeholder comments once filled in.
     Keep this file focused and high-signal — every rule here costs a token
     budget on every call. Remove rules that do not apply. -->

## Literate Programming

All code written in this project follows Don Knuth's literate programming principles.
The full skill is at `.claude/skills/literate-programming/SKILL.md`.

When creating a new source file or significantly rewriting an existing one, read
`.claude/skills/literate-programming/SKILL.md` and apply it before writing any code.

The five rules in brief:

1. Every file opens with a narrative preamble — why it exists, key design decisions,
   what it deliberately does NOT do
2. Documentation explains reasoning, not signatures — WHY the design is this way,
   not what the function returns
3. Order of presentation follows logical understanding — orchestration before detail,
   concept before mechanism
4. Each file has one clearly stated concern — named in the first sentence of the preamble
5. Inline comments explain WHY, not WHAT — the code already shows what happens

## CUPID Code Review

When reviewing or refactoring code, apply the CUPID lens documented at
`.claude/skills/cupid-code-review/SKILL.md`.

The five properties in brief:

1. **Composable** — can it be used independently without hidden dependencies?
2. **Unix philosophy** — does it do one thing completely and well?
3. **Predictable** — does it behave as its name suggests, with no hidden side effects?
4. **Idiomatic** — does it follow the grain of the language and project conventions?
5. **Domain-based** — do its names come from the problem domain, not the technical implementation?

## Workflow

### Spec-First Change Discipline

Any change to application behaviour must flow through the spec before touching
implementation code:

1. Update the spec — add or revise user stories, acceptance scenarios, and FRs
2. Update the implementation plan — reflect new or changed FRs
3. Write failing tests from the spec — confirm red before writing implementation
4. Update the implementation — until failing tests turn green
5. Refactor — clean up while keeping all tests green

### Test-Driven Development

Follow red-green-refactor strictly:

1. RED — write a failing test that describes the desired behaviour
2. GREEN — write the minimal production code needed to make the test pass
3. REFACTOR — clean up while keeping all tests green

No production code without a failing test first.

### Branch Discipline

Never commit directly to `main`. At the start of any task:

1. Create a GitHub issue describing the task
2. Create a branch: `git checkout -b <short-descriptive-name>`
   (lowercase, hyphen-separated, e.g. `add-search`, `fix-renderer-wrapping`)

### Commit Messages

Write concise commit messages that describe what changed and why. No postamble,
no attribution lines. The message ends when the description ends.

### CHANGELOG

Before every PR, update CHANGELOG.md:

- Add a dated section at the top if today's date is not already present
- Group entries under a short theme heading
- One bullet per change: what changed and why it matters

### PR Health Check

After every push and PR creation:

1. Run `gh pr checks <number> --watch`
2. If any check fails, fetch the log: `gh run view <run-id> --log-failed`
3. Fix every error, then commit (never amend) and push
4. Repeat until all checks are green

<!-- LANGUAGE-SPECIFIC CONVENTIONS -->
<!-- Add the commands for your project's language(s) below. Examples: -->

## Build and Test

<!-- Replace with actual commands for this project -->

    # Build
    # <fill in build command>

    # Test
    # <fill in test command>

    # Lint
    # <fill in lint command>

    # Format
    # <fill in format command>

<!-- PROJECT-SPECIFIC CONSTRAINTS -->
<!-- Add constraints specific to this project below.
     Each constraint should answer: what is the rule, and why does it exist?
     Remove this section if there are no project-specific constraints. -->

## Learnings

REFLECTION_LOG.md contains past session learnings — surprises,
failures, and improvement proposals. Agents should read recent
entries before starting work to avoid repeating past mistakes.

## Reflection Log Curation

Reflections are appended to `REFLECTION_LOG.md` via `/reflect`. The
log is **a working file**, not the permanent record. The permanent
record lives in `reflections/archive/<YYYY>.md`, populated by the
weekly Path 1 GC rule from entries the curator has tagged with a
`Promoted` line.

### Promoted-line schema

When promoting an entry's content to `AGENTS.md` or `HARNESS.md`, add
a single line to the source reflection entry **in the same commit**
as the AGENTS.md / HARNESS.md edit:

    - **Promoted**: YYYY-MM-DD → <RHS>

`<RHS>` must match one of the documented forms (see
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`,
Schema change → Formal grammar). Path 1's weekly GC rule auto-archives
entries with verified Promoted lines.

### Aged-out review

Optionally enable the Path 2 GC rule (`Reflection log aged-out review`)
in HARNESS.md to receive a monthly report of unpromoted entries older
than the threshold, with evidence (recurrence, overlap matches) for
the curator to interpret.

If neither rule is engaged, the system reverts to today's behaviour
plus read-side filtering: agents and commands still bound their
intake by default, but the log itself accumulates entries until the
curator manually intervenes.

## Docs Site Review

The `docs/` directory is the project's documentation site, organised
**per plugin** under `docs/plugins/<plugin-name>/`. When presenting a
plan or opening a PR, always check whether any docs pages need to be
created or updated.

For each plugin, content is organised into Diataxis quadrant folders:

- `tutorials/` — nav label "Getting Started" — end-to-end walkthroughs
- `how-to/` — nav label "How-to Guides" — task-oriented (one guide per
  command or workflow)
- `reference/` — nav label "Reference" — API/schema reference material
- `explanation/` — nav label "Concepts" — conceptual background

Pages live at `docs/plugins/<plugin-name>/<quadrant>/<slug>.md`. The
plugin's root `index.md` is a landing page that links to each quadrant;
each quadrant has its own `index.md` so MkDocs Material renders the
section as a navigable group. The site uses the `mkdocs-awesome-pages`
plugin to derive nav from the filesystem — folder structure is the
source of truth, no manual `nav:` listing required. The `_template.md`
file stays at the plugin root with header guidance for each quadrant.
A quadrant folder is created only when the plugin has at least one
page in that quadrant — empty quadrants are not scaffolded.

For the `ai-literacy-superpowers` plugin, pages live at
`docs/plugins/ai-literacy-superpowers/<quadrant>/<slug>.md`. For sister
plugins, under `docs/plugins/<plugin-name>/<quadrant>/<slug>.md`.

**When a feature adds a new command, skill, or agent**: check for an existing
how-to guide and create one if missing.

**When a feature changes behaviour**: check whether explanation pages reference
the old behaviour and update them.

**When a feature changes a format or schema**: check whether reference pages
are current.

Include docs changes in the same PR as the implementation, not as a follow-up.

## Monthly Operations

Light-touch health check (every 30 days, between quarterly anchor weeks):

1. `/governance-health` — governance constraint health snapshot
2. Reflection review — scan `REFLECTION_LOG.md` for new entries worth
   promoting to `AGENTS.md`
3. `/harness-sync` — bring every push-direction surface into alignment
   with HARNESS.md (convention files, ONBOARDING.md, snapshot, Status
   section). Surfaces template drift and recurring reflection patterns
   as `[manual]` items for follow-up.

## Project Constraints

<!-- Example:
- All database queries must go through the repository layer — direct DB access
  from handlers bypasses the audit log middleware.
- API responses must use the envelope format {data, error, meta} — clients
  depend on this structure for error handling.
-->
