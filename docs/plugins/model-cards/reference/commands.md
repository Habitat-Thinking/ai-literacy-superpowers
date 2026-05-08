---
title: Commands
---
<!-- redirect-sunset: 2027-05-08 -->

# Commands

The `model-cards` plugin exposes a single slash command, `/model-card`,
with two subcommands today and three more on the roadmap.

---

## /model-card create

```text
/model-card create <model-name> [--provider X] [--out path]
```

Researches a single model and produces a Mitchell-extended card after
a human-in-the-loop review checkpoint.

| Argument | Required | Description |
| -------- | -------- | ----------- |
| `<model-name>` | yes | Model name as published by the provider, e.g. `claude-opus-4-7`, `gpt-5-mini`, `meta-llama/llama-4`. |
| `--provider X` | no | Provider hint — e.g. `anthropic`, `openai`, `google`, `meta`, `mistral`, `xai`, `cohere`, `alibaba`. If omitted, the agent infers from the model name. |
| `--out path` | no | Library directory override. Cards still land beneath this path as `<provider>/<model-name>.md`. Highest-priority path resolver. |

### Path resolution

The resolved target path is `<library-root>/<provider>/<model-name>.md`,
where `<library-root>` is the first of:

1. `--out` flag value (highest priority)
2. `MODEL_CARDS_DIR` environment variable
3. `~/.claude/model-cards/` (default)

### Flow

1. **Parse args** — model name, provider hint, output path.
2. **Resolve target path** using the priority order above.
3. **Existing-card prompt** — if the target exists, ask
   `overwrite / skip / load-existing-as-base`.
4. **Dispatch** the [`model-card-researcher`](agents.md)
   agent. Output is either a markdown card body or a `REFUSED:` string.
5. **Handle REFUSED** — if the agent's output starts with `REFUSED:`,
   surface the refusal verbatim and abort. No file is written.
6. **Show review summary** — sources used per section, sections that
   came up thin, top 3 most-cited claims with URLs, estimated research
   token cost.
7. **Disposition prompt** — `accept / edit / re-run-section <N> / abort`.
8. **Validation checkpoint** (on `accept`) — frontmatter parseable,
   all 10 sections present in canonical order, every `[T<n>.<m>]`
   citation resolves to a frontmatter source, Section 10 fields use
   field-level "Not publicly available" rather than silent omission.
   Deviations are fixed in place; agent is not re-dispatched.
9. **Write the card** to the resolved target path. Print
   `Card written: <full-path>`.

See the [research a model card](../how-to/research-a-model-card.md)
how-to for a step-by-step walkthrough.

### Disposition options

| Choice | Effect |
| ------ | ------ |
| `accept` | Validate, then write the card to the target path. |
| `edit` | Open the draft in `$EDITOR` (or `vi` if unset); on save, the edited content replaces the draft and the disposition prompt re-asks. |
| `re-run-section <N>` | Re-dispatch the agent with a section-specific prompt for template section `N` (1-10). Replaces just that section in the draft, then re-prompts. |
| `abort` | Discard the draft. No file is written. |

### Exit behaviours

- **REFUSED** — model existence not confirmed via tier-1 + tier-2.
  Refusal reason printed; no file written. Exits with status 0.
- **Abort** — user chose `abort` or the existing-card prompt returned
  `skip`. No file written. Exits with status 0.
- **Validation failure** — citation references a missing source index
  in frontmatter. Surfaced to user before write; user is given the
  chance to edit or abort. No file written until validation passes.
- **Success** — card written; full path printed. Exits with status 0.

---

## /model-card seed

```text
/model-card seed [--force]
```

Bulk-populates the library with cards for a shipped list of 14
frontier models.

| Argument | Required | Description |
| -------- | -------- | ----------- |
| `--force` | no | Overwrite existing cards in the library. Without `--force`, existing cards are skipped. |

### Flow

1. **Read the seed list** at `${CLAUDE_PLUGIN_ROOT}/seed/frontier-models.json` —
   format `[{"name": "...", "provider": "..."}, ...]`.
2. **Print the list and total count.**
3. **Single confirmation** — `Research <N> cards into <library-root>? [y/N]`.
   Anything other than `y` aborts.
4. **For each model** (sequential):
   - Resolve target path (same logic as `create`).
   - If card exists at target path AND `--force` is not set, skip with
     a one-line message.
   - Dispatch `model-card-researcher`.
   - If REFUSED, log the skip with reason (one line); continue.
   - Else, write the card and log creation (one line).
5. **Print summary**:

   ```text
   Created: N
   Skipped (existed): N
   Skipped (refused): N
   Failed (other): N
   ```

### Idempotency

`seed` is idempotent for the common-case "ran partially, want to retry"
pattern — the existence check at step 4 skips already-written cards.
To re-research existing cards, either pass `--force` (overwrites all)
or run `/model-card create <name>` per-model (interactive review).

See the [seed your library](../how-to/seed-your-library.md)
tutorial for an end-to-end walkthrough.

---

## Roadmap subcommands

The following subcommands are tracked as GitHub issues but are not yet
implemented:

| Subcommand | Issue | Purpose |
| ---------- | ----- | ------- |
| `/model-card list` | [#233](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/233) | Browse the library — list cards by provider, by date researched, by version. |
| `/model-card compare <a> <b>` | [#234](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/234) | Side-by-side card comparison across the 10-section structure. |
| `/model-card refresh <name>` | [#235](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/235) | Re-research a specific card non-interactively, preserving the existing card as the base. |

These are deliberately deferred — `create` + `seed` cover the bootstrap
flow for v0.1.0. The shape of `list`, `compare`, and `refresh` will
firm up as adoption signal arrives.
