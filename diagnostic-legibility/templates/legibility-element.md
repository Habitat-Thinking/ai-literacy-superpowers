# LegibilityElement

The unit of legibility produced by the diagnostic-legibility agent. A
single record type used for both architectural and domain dimensions —
the two collections (`architectural[]` and `domain[]` inside the
`LegibilityModel` wrapper) carry the type distinction; the record
itself is uniform.

Dimension-specific framing (e.g. architectural boundaries and
collaborators, or domain ubiquitous-language and aliases) lives in the
free-text `description` field rather than in dedicated fields. This
keeps prompt construction symmetric across dimensions and makes the
cross-check (issue #332) and surfacing (issue #333) work mechanically
simpler.

## Fields

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `name` | string | yes | Short identifier for the element. For architectural: a component, service, or module name. For domain: a concept term. |
| `description` | string | yes | Free-text explanation. Carries dimension-specific framing: for architectural, what the element does and how it is bounded; for domain, what the term means and how it is used. Multi-paragraph is fine. |
| `evidence` | list of objects | yes | Citations grounding the element. Each entry has `path` (string) and optional `excerpt` (string). At least one entry per element when confidence is `medium` or `high`. |
| `confidence` | enum | yes | One of `low`, `medium`, `high`. Indicates the agent's confidence in the element. `low` means "candidate, included for completeness"; `high` means "well-evidenced and challenged". |
| `challenge_notes` | list of strings | yes | What the challenge-refine step surfaced and how it was resolved. May be empty when the challenge protocol has not yet run. |

Equivalent type signature (for documentation only — not a committed type):

```
LegibilityElement = {
  name: string,
  description: string,
  evidence: [{ path: string, excerpt?: string }],
  confidence: "low" | "medium" | "high",
  challenge_notes: [string]
}
```

## Validation rules

The agent enforces these rules during construction (no runtime
validator ships at v0.2.0):

- `name` must be non-empty.
- `description` must be non-empty.
- `evidence` must have at least one entry when `confidence` is
  `medium` or `high`. `low`-confidence elements may have empty
  evidence (the agent flagged a candidate without ground).
- `confidence` must be one of the three enum values.
- `challenge_notes` may be empty.

## LegibilityModel

The top-level structure the agent emits. Wraps two collections of
`LegibilityElement`.

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `scope` | string | yes | A path or description of what was modelled (e.g. `"./src/auth/"` or `"the checkout flow across services A and B"`). |
| `generated_at` | string (ISO 8601) | yes | Timestamp the model pair was produced. |
| `generated_by` | string | yes | Agent name + model identifier (e.g. `"diagnostic-legibility-agent / claude-sonnet-4-6"`). |
| `architectural` | list of `LegibilityElement` | yes | The architectural-dimension elements. May be empty if scope yielded no architecture-level findings. |
| `domain` | list of `LegibilityElement` | yes | The domain-dimension elements. May be empty if scope yielded no domain concepts. |

### LegibilityModel validation rules

- At least one of `architectural` or `domain` must be non-empty. An
  empty pair on both sides is a degenerate output and the agent should
  surface a `low`-confidence placeholder rather than emit two empty
  lists.
- The two lists may have different lengths; symmetric size is not
  required.

## Examples

### Architectural example

```yaml
name: AuthenticationService
description: |
  The HTTP-level entry point for credential validation. Bounded by
  the login endpoint and the session-issuance endpoint. Collaborates
  with the credentials store (read-only) and the session-token issuer
  (write). The service owns the credential-validation policy but not
  the storage of credentials themselves.
evidence:
  - path: src/auth/service.py
    excerpt: "class AuthenticationService:\n    def authenticate(self, credentials):"
  - path: src/auth/README.md
    excerpt: "AuthenticationService is the only entry point that writes session tokens."
confidence: high
challenge_notes:
  - "Initial draft included session storage as a responsibility; challenge clarified the service issues but does not store, and the description was revised."
```

### Domain example

```yaml
name: Order
description: |
  In this codebase, "Order" is a finalised purchase intent that has
  cleared cart and inventory checks but has not yet been fulfilled.
  Distinct from "Cart" (mutable, pre-checkout) and from "Shipment"
  (post-fulfilment). The ubiquitous-language canonical term is "Order";
  the codebase uses "PurchaseOrder" in some legacy modules as an alias.
evidence:
  - path: src/domain/order.py
    excerpt: "class Order:  # canonical name; PurchaseOrder is deprecated"
  - path: docs/glossary.md
    excerpt: "Order: a finalised purchase intent..."
confidence: high
challenge_notes:
  - "Initial draft conflated Order with Cart; challenge surfaced the cart→order transition as the boundary and the description was refined."
```

## Why this schema

The design rationale lives in the spec at
[`docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md`](../../docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md).
The short version: a single flat schema is the simplest path that
keeps prompting, cross-checking (issue #332), and surfacing
(issue #333) mechanically uniform. The trade-off accepted is that
dimension-specific affordances (boundaries, ubiquitous-language
canonicals, etc.) live in the free-text `description` field rather
than dedicated columns.
