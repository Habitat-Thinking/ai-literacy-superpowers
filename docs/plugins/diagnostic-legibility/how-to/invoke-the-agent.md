# How to invoke the diagnostic-legibility agent

This guide covers the **v0.3.0** invocation surface for the
`diagnostic-legibility` agent. The agent produces two refined models
of a codebase scope — *architectural moving parts* and *domain
concepts* — and emits them as a `LegibilityModel` YAML block.

> **Note on the invocation surface.** At v0.3.0 there is no
> `/diagnose` slash-command. The agent is dispatched directly via the
> Task tool. A wrapping `/diagnose` command is the deliverable of
> parent S4, tracked at
> [issue #333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333).
> When that ships, this how-to will be updated.

## Inputs

The agent takes one required input:

- **`scope`** — what to model. Three accepted forms:
  - Directory path — `./src/auth/`
  - File list — `src/checkout/cart.py, src/checkout/order.py`
  - Free-text description — `"the checkout flow across services A and B"`

Use whichever form fits the question you are asking. The free-text form
is acceptable when the scope is conceptual rather than directory-bounded.

## Dispatch (bare Task-tool pattern)

From an orchestrator, command, or interactive Claude Code session,
invoke the Task tool with:

- `subagent_type`: `diagnostic-legibility`
- `description`: a short imperative — e.g. `"Model the auth module"`
- `prompt`: a free-text body whose first line is an optional mode
  marker; if absent, mode is `full`.

### Mode `full` (default — Phase A + B + C)

The minimum prompt shape:

```text
scope: ./src/auth/
```

Or with the explicit marker:

```text
mode: full
scope: ./src/auth/
```

The agent constructs both collections (Phase A), runs the
five-question self-challenge on every element (Phase B), then
cross-checks the two collections against each other (Phase C).
Each element's `challenge_notes[]` carries both `Q<N>` and
(when Phase C ran cleanly with both collections populated) `CC<N>`
entries in canonical order. The wrapper carries
`cross_check_status: completed` or `skipped_asymmetric` depending
on whether both collections were populated.

Add a second paragraph for any additional context (e.g. *"focus on
the public API surface only; treat the integration tests as evidence
but not as in-scope elements"*).

### Mode `cross-check-only` (Phase C only, against supplied YAML)

When you already have a v0.3.0-or-later `LegibilityModel` and want
to layer cross-check onto it:

````text
mode: cross-check-only
```yaml
scope: "./src/auth/"
generated_at: "2026-05-28T14:00:00Z"
generated_by: "diagnostic-legibility / claude-sonnet-4-6"
architectural:
  - name: AuthenticationService
    description: |
      ...
    evidence:
      - path: src/auth/service.py
    confidence: high
    challenge_notes:
      - "Q1 (boundary): ..."
domain:
  - name: Credential
    description: |
      ...
    evidence:
      - path: src/auth/models.py
    confidence: high
    challenge_notes:
      - "Challenge applied; no questions surfaced changes"
```
````

The YAML payload must be inside a fenced code block; unfenced or
prose-surrounded YAML triggers a refusal. Every element must have a
populated `challenge_notes[]` (Phase B must have run). The agent
runs Phase C against the payload and emits the cross-checked YAML
in its response.

Before resubmitting your own previous output for cross-check, **be
sure to substitute the `<DISPATCHER: ...>` placeholders** in
`generated_at` and `generated_by` with real values. The
cross-check-only mode refuses on unsubstituted placeholders.

### Refusal contract

When the agent refuses, it emits a single line and no YAML block:

```text
diagnostic-legibility refusal: <single-sentence reason>.
```

Programmatic dispatchers pattern-match on "no YAML block + presence
of `diagnostic-legibility refusal:`" to route to error handling.
Refusals fire on: unrecognised mode value, missing required fields
in cross-check-only payload, unfenced or multiple YAML blocks,
unrevised input (any element with empty `challenge_notes[]` in
cross-check-only), or unsubstituted dispatcher placeholders.

## What you get back

A single markdown response containing one YAML block. The block
conforms to the `LegibilityModel` schema at
`diagnostic-legibility/templates/legibility-element.md`.

A truncated example:

```yaml
scope: "./src/auth/"
generated_at: "<DISPATCHER: ISO 8601 timestamp>"
generated_by: "diagnostic-legibility / <DISPATCHER: active model identifier>"
architectural:
  - name: AuthenticationService
    description: |
      The HTTP-level entry point for credential validation...
    evidence:
      - path: src/auth/service.py
        excerpt: "class AuthenticationService:"
    confidence: high
    challenge_notes:
      - "Q1 (boundary): initially smeared AuthenticationService and SessionStore into one element; revised to keep them separate because the session-store boundary is in a different module."
domain:
  - name: Credential
    description: |
      A username + password pair presented at login. Distinct from
      `Session`, which is the authenticated artefact returned after
      successful credential validation.
    evidence:
      - path: src/auth/models.py
        excerpt: "@dataclass\nclass Credential:"
    confidence: high
    challenge_notes:
      - "Challenge applied; no questions surfaced changes"
```

Every element carries `challenge_notes[]` — either one or more
`Q<N> (question name):` entries (when a challenge question surfaced a
change) or the single sentinel `Challenge applied; no questions
surfaced changes` (when all five questions ran cleanly).

## Persisting the output

The agent does **not** write files. Your dispatcher is responsible
for persisting the YAML to whatever path you choose. A common
convention:

```
diagnostic-legibility/output/<YYYY-MM-DD>-<scope-slug>.legibility.yaml
```

The dispatcher (a command, an orchestrator step, or a human pasting
into a file) writes the block; the agent stays read-only.

### Substitute the dispatcher placeholders

The agent emits two fields as literal placeholders because it has no
reliable clock and no introspection of the active model identifier:

```yaml
generated_at: "<DISPATCHER: ISO 8601 timestamp>"
generated_by: "diagnostic-legibility / <DISPATCHER: active model identifier>"
```

Before persisting, substitute both with real values — the current ISO
8601 timestamp and the active Claude Code model identifier (e.g.
`claude-sonnet-4-6`, `claude-opus-4-7[1m]`). If you skip the
substitution, the persisted YAML carries the placeholder strings
verbatim, which is fine for a draft but breaks any consumer that
parses these fields as data.

## Empty-scope handling

If your scope yields no architectural or domain elements (an empty
directory, generated-only files, a free-text description that doesn't
resolve), the agent returns a single placeholder element under
`architectural[]` with the literal name `(empty scope)`:

```yaml
architectural:
  - name: "(empty scope)"
    description: "Scope ./src/foo/ was inspected and yielded no architectural moving parts or domain concepts..."
    evidence: []
    confidence: low
    challenge_notes:
      - "Challenge applied; no questions surfaced changes"
domain: []
```

Pattern-match exactly on `name == "(empty scope)"` to distinguish
this from "I flagged an evidence-less candidate" — the two failure
modes that would otherwise be indistinguishable.

## Further reading

- [Challenge-refine protocol](../explanation/challenge-refine-protocol.md)
  — what the five Phase B questions catch and why the agent uses a
  retained-challenge single-pass cycle.
- [Cross-check protocol](../explanation/cross-check-protocol.md) —
  what Phase C does, the five cross-check questions, the
  direction-flavoured weighting, the subject-only audit trail, the
  `cross_check_status` wrapper field, and the mode-marker contract.
- `diagnostic-legibility/templates/legibility-element.md` (in the
  repository) — the contract every emitted element follows,
  including the v0.4.0 additive `cross_check_status` wrapper field.
