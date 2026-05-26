# Carpaccio slicing lenses

Reference for the lenses the carpaccio agent applies. SKILL.md cites
this file; the agent reads both at dispatch time. Lenses are applied
in priority order: each candidate slice is tested against the lenses
top-down, and the first lens that legitimately fits is recorded as
`lens_used`.

When no lens fits, the candidate is dropped. Padding to meet a count
is forbidden — selectivity is the value, per the SKILL.md non-goals.

## decision-boundary (primary)

A slice falls under this lens when it contains exactly one material
*decision* the human will need to engage with. A decision is material
when an alternative would produce visibly different downstream work —
not a choice between equivalent implementations.

Apply this lens first. If the task surfaces three decisions, three
slices typically result.

*Example:* a task describing "add OAuth login" surfaces decisions about
(a) provider (Google? GitHub? both?), (b) account-linking semantics,
(c) session storage. Three slices under decision-boundary.

## acceptance-criterion (fallback)

A slice falls under this lens when the task does not surface clear
decisions but does surface testable behaviours. One slice per
testable Given/When/Then equivalent.

Fall back to this lens only when decision-boundary cannot legitimately
fit. The agent records the fallback in its reasoning, not via a hidden
flag.

*Example:* a task to "improve the install instructions" has no decision
content but has acceptance criteria (the page renders on mobile, the
install command is copyable, the prerequisites are listed). Each
becomes a slice.

## end-to-end

A modifier lens applied to candidates that have already passed the
primary or fallback test: does this slice ship something observable?
End-to-end here means *from the system's edge to the system's edge for
this slice's scope* — not necessarily user-visible in production.

Reject candidates that are only internal milestones with no observable
output. This is the lens Cockburn's original exercise emphasises.

## independence

A modifier lens applied when multiple slices are present: can any
slice land without blocking any other? When the answer is yes, record
`lens_used: independence` on the slice that exemplifies the property
and surface ordering in `## Sequencing recommendation`.

When slices have dependencies, the `sequencing_note` field captures
ordering and the recommendation section explains it.

## inseparability

The terminal lens. A slice falls under this when slicing further would
harm correctness — atomic migrations, security patches, single-
coherent refactors. When this lens fits, the agent emits exactly one
slice and writes a defended `## Inseparability rationale` section.

The inseparability claim must be argued, not asserted. A rationale of
"this is atomic" is a contract break — the agent must explain *why*
slicing would harm correctness.

## Application order

1. Try **decision-boundary** for each candidate.
2. For candidates that don't fit decision-boundary, try **acceptance-criterion**.
3. Apply **end-to-end** as a filter — drop candidates that are not
   observably complete.
4. Apply **independence** to surface ordering when slices are mixed.
5. If the whole task fails every other lens, apply **inseparability**
   with a defended rationale.

## Anti-patterns

- **Slicing on files.** "One slice per file" is a code-organisation
  cut, not a decision cut.
- **Slicing on layers.** "One slice for the backend, one for the
  frontend" leaves the human with a slice that ships nothing observable.
- **Slicing on commits.** A commit boundary is an implementation
  artefact, not a decision boundary.
- **Slicing on PR reviewability.** "Each slice ≤ 200 LOC" is a
  reviewer-budget heuristic, not a cognitive-budget one.

Record these (and any task-specific anti-patterns) in `## Explicitly
not slicing on`.
