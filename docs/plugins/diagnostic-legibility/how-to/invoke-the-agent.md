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
- `prompt`: a free-text body whose first line names the scope.

The minimum prompt shape:

```text
scope: ./src/auth/
```

Add a second paragraph for any additional context (e.g. *"focus on
the public API surface only; treat the integration tests as evidence
but not as in-scope elements"*).

## What you get back

A single markdown response containing one YAML block. The block
conforms to the `LegibilityModel` schema at
[`diagnostic-legibility/templates/legibility-element.md`](../../../../diagnostic-legibility/templates/legibility-element.md).

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
  — what the five questions catch and why the agent uses a
  retained-challenge single-pass cycle.
- [LegibilityElement schema](../../../../diagnostic-legibility/templates/legibility-element.md)
  — the contract every emitted element follows.
