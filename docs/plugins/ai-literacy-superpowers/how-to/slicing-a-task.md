# Slicing a task with `/carpaccio`

Use `/carpaccio` to slice a task into thin end-to-end-complete pieces
before any spec ceremony begins. The agent produces a slicing record;
the human dispositions each slice; the orchestrator drives downstream
issue creation.

## When you do not need to invoke it manually

If you start work via the orchestrator (e.g., by handing the
orchestrator agent a task description), it dispatches carpaccio
automatically at step 0. Skip this how-to and just talk to the
orchestrator.

## When you do need to invoke it manually

- You are running the pipeline by hand and want to slice before
  spec-writer.
- You are exploring whether to start a task at all — `/carpaccio`
  lets you see the slicing without committing to the pipeline.
- A task description was substantively edited after the orchestrator
  already produced a slicing record, and you want a fresh slicing
  before proceeding.

## Invocation

Pass either an issue reference or a free-text task description:

```bash
/carpaccio #326
/carpaccio "Add a search feature to the docs site with index, UI, and ranking."
```

The command:

1. Resolves the task description (fetches the issue body if an
   issue reference was passed).
2. Derives a slug.
3. Dispatches the carpaccio agent.
4. Writes the slicing record to `docs/superpowers/slices/<task-slug>.md`.
5. Runs the validation checkpoint.
6. Surfaces the record to you.

## Filling dispositions

Open the slicing record and fill the per-slice fields:

- **`disposition`** — one of `accepted | merged | dropped | revised`.
- **`disposition_rationale`** — required when `disposition` is not
  `accepted`. Free-text.
- **`file_as_issue`** — for `accepted` slices you are not
  progressing now, set `true` (orchestrator will file a GitHub
  issue) or `false` (you will track it elsewhere).
- **`merged_into`** — required when `disposition: merged`. The
  other slice's id.

At the top of the frontmatter, set:

- **`progressed_slice`** — the slice id you will work on in this
  iteration.

## What happens after dispositions are filled

If you invoked `/carpaccio` manually, the orchestrator does not
auto-pick up. You can then:

1. Hand the orchestrator the slicing record path — it reads the
   dispositions and proceeds from step 1 (spec-writer) against
   the progressed slice's scope.
2. Run `/spec-writer` directly with the progressed slice's scope
   as the task description.

In either case, `accepted` slices marked `file_as_issue: true`
can be filed by running:

```bash
gh issue create --title "<slice.title>" \
                --body "<slice.scope>\n\n<slice.decision_focus>\n\nSliced from parent #<N>"
```

The orchestrator does this automatically when running the full
pipeline; manual invocations require the manual `gh issue create`
step.

## Re-slicing

If you mark any slice's `disposition` as `revised`, run `/carpaccio`
again. The command:

- Reads your prior slicing record (specifically the
  `disposition_rationale` strings on `revised` slices).
- Re-dispatches the agent with the rationale as context.
- Overwrites the prior record.

Prior dispositions are lost on re-dispatch. This is intentional —
the new slicing may not preserve the prior slice structure.

## Inseparability case

If carpaccio judges the task inseparable, the record has:

- `inseparable: true` in the frontmatter
- Exactly one slice with `lens_used: inseparability`
- A `## Inseparability rationale` prose section

You still need to disposition the single slice (typically
`accepted`) and set `progressed_slice:` to it. The orchestrator
will then proceed to spec-writer against the full task scope.

## Anti-patterns to avoid

- **Skipping disposition for `accepted` slices.** The gate is
  hard; the orchestrator will refuse to advance.
- **Setting `progressed_slice` to a `dropped` or `merged` slice.**
  The validation contract rejects this.
- **Accepting more than one `progressed_slice`.** The field is
  scalar — one slice per iteration.

## See also

- Concepts: `decision-discipline-triad.md` — how carpaccio fits with
  diaboli and cartographer.
- Spec: `docs/superpowers/specs/2026-05-26-carpaccio-cadence-governor-design.md`.
- Reference: `ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md`.
