---
component: harness-compile
component_type: command
tier: structural
---

# Scenario: /harness-compile refuses rather than guessing at markers

## Given

Compilation writes only between explicit markers, so every hand-written line in
`HARNESS.md`, `AGENTS.md` and every agent file depends on the marker pair being
unambiguous.

When it is not — an END before a BEGIN, a BEGIN with no END, two pairs in one
file — there is no safe default. Taking the outermost pair swallows everything
between two regions; taking the innermost silently orphans one. Both are how a
generator ends up eating content a person wrote.

The command also has to resist a specific temptation: being used to make a
refusal go away.

## When

`ai-literacy-superpowers/commands/harness-compile.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: harness-compile`, a description stating that it is
idempotent, writes only inside markers, and refuses rather than guessing.

**Body:**

- Names the three things it regenerates: target-artifact regions, the decision
  index, the enforcement report.
- States that it does **not** write into `.github/copilot-instructions.md`,
  `.cursor/rules/` or `.windsurf/rules/`, and gives the reason —
  `/convention-sync` already generates those from `HARNESS.md`, and two
  generators on one file produce the same rule twice in two voices.
- Carries both refusals with their remedies: a missing target artifact, and
  malformed markers.
- **Forbids repairing markers by guessing**, and explains why no default is safe.
- States that a missing governance document is created by a human, not by the
  Registrar.
- Lists `already up to date` as the expected outcome most of the time, and says
  it should not be dressed up as work.

**Validation checkpoint:** M1–M4, including M2 (content outside the markers is
unchanged — *diff it, do not assume*) and M3 (a second run writes nothing, since
a non-idempotent compiler produces permanent drift).

Deviations are reported as defects. Hand-editing a generated region to make it
look right is explicitly ruled out — the next compile overwrites it, and the
check disagrees in the meantime.
