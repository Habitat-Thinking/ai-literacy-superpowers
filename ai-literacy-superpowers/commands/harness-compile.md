---
name: harness-compile
description: Idempotent repair — regenerates every generated region, the decision index, and the enforcement report from HARNESS.md, AGENTS.md and the accepted decision records; writes only inside markers, refuses rather than guessing when they are ambiguous, and never touches hand-written content
---

# /harness-compile

Regenerate everything derived from the accepted Harness Decision Records.

You should rarely need this. Acceptance compiles as part of its own transaction,
so the two occasions that call for it are a hand-edit to a generated region and a
merge that combined two branches.

## When to use

- Once, at setup, to establish the generated regions. Nothing should change
  except the appearance of the markers
- After `/harness-check` reports drift
- After a merge that touched a generated region
- Never as a way to make a refusal go away

## What it regenerates

1. The generated region of every **target artifact** named by an accepted record
2. `harness/decisions/index.md`
3. `harness/enforcement-report.md`

Classification decides where a rule's text goes; `surfaces` decides who is told
about it. That split matters here: compilation does **not** write into
`.github/copilot-instructions.md`, `.cursor/rules/` or `.windsurf/rules/`,
because `/convention-sync` already generates those from `HARNESS.md`. Two
generators on one file produce the same rule twice, in two voices, with each
mechanism believing it owned the outcome.

## Process

### 1. Run it

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py compile
```

### 2. Report what changed

List the files written. If nothing was written, say `already up to date` — that
is the expected result most of the time and should not be dressed up as work.

### 3. Read the refusals, if any

Compilation refuses, writing **nothing at all**, in two cases:

| Refusal | What it means | What to do |
| --- | --- | --- |
| Target artifact does not exist | A record routes to a file that is not there | Create the artifact, or correct the record's `target` — the Registrar writes records, not governance documents |
| Malformed generated markers | A file has an END before a BEGIN, a BEGIN with no END, or two pairs | A human repairs the markers |

**Never repair markers by guessing.** Working out which BEGIN belongs to which
END is exactly how a generator eats hand-written content, and there is no safe
default: taking the outermost pair swallows everything between two regions,
taking the innermost silently orphans one. Show the human the file and let them
decide.

### 4. Validation checkpoint

- **M1** — every file written has exactly one `BEGIN`/`END` marker pair
- **M2** — content outside the markers is unchanged. Diff it; do not assume
- **M3** — running compile a second time writes nothing. If it does, the
  compiler is not idempotent and `/harness-check` will report permanent drift
- **M4** — `harness/enforcement-report.md` exists and its gap count matches the
  rows in it

Report a deviation as a defect. Do not edit a generated region by hand to make
it look right — the next compile will overwrite it, and `/harness-check` will
disagree with you in the meantime.

## What it never does

- Touch anything outside the markers
- Create a governance document that does not exist
- Change an HDR. Compilation reads the corpus; it never writes to it
- Commit or push
