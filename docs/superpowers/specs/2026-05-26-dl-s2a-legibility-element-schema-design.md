# Diagnostic Legibility — sub-S2a — `LegibilityElement` schema — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-26 |
| Status | Draft |
| Author | claude-opus-4-7[1m] (interactive session with russmiles) |
| Slice | sub-S1 of the meta-iteration record at `docs/superpowers/slices/dl-s2-two-model-agent.md` (which is itself S2 of the parent record `docs/superpowers/slices/diagnostic-legibility-plugin.md`) |
| Parent issue | #331 (Diagnostic Legibility S2) |
| Deferred sibling issue | #335 (sub-S2b: challenge protocol + working agent) |
| Plugin version target | `diagnostic-legibility` v0.1.0 → v0.2.0 |
| Marketplace listing | Unchanged at v0.4.0; `plugin_version` unchanged at v0.39.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Related work | S1 of parent (PR #334 merged, scaffold shipped); sibling slicing of `model-cards/templates/` as a pattern anchor |

---

## 1. Premise

Issue #331 commissions the two-model agent for the diagnostic-legibility
plugin. Carpaccio's meta-iteration on that issue (recorded at
`docs/superpowers/slices/dl-s2-two-model-agent.md`) surfaced a sub-gate
the parent slicing did not show: the schema-shape decision for the two
models is a branching gate that should be settled before any agent
code is written. The wrong answer propagates into every prompt the
agent sends, into the cross-check (parent S3 / issue #332), and into
the surfacing format (parent S4 / issue #333).

This spec covers sub-S1 of that meta-iteration only: the
`LegibilityElement` schema artefact. The agent implementation,
challenge protocol, and refined-output mechanics live in the deferred
sibling issue #335 (sub-S2b).

## 2. The schema decision

The chosen shape (settled in brainstorming above this spec): **same
flat schema for both dimensions** — `LegibilityElement`. The
architectural-model and domain-model instances are typed by their
*collection*, not by their *record*. Dimension-specific framing
(boundaries, collaborators, ubiquitous language, aliases) collapses
into the free-text `description` field.

This is the simplest path. Three consequences worth naming:

- **Prompting**: one prompt template targets both dimensions, with
  the dimension passed as a parameter and the target description
  varying accordingly. Sub-S2b designs the prompt's structure.
- **Cross-check (parent S3, #332)**: comparing two collections of
  the same record type is mechanically simpler than comparing
  records of different types. The cross-check protocol can iterate
  the two lists symmetrically.
- **Surfacing (parent S4, #333)**: the human-facing presentation
  can use the same row template for both lists, with section headings
  distinguishing the dimensions.

The trade-off accepted: the schema does not carry
dimension-specific affordances. Whether an architectural element
has explicit `responsibility` and `boundary` fields, or whether a
domain concept has explicit `ubiquitous_language_canonical` and
`aliases` fields, those concerns live inside the free-text
`description` field. A later iteration may revisit this if it
turns out the descriptions become a junk drawer.

## 3. `LegibilityElement` schema

### 3.1 Fields

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `name` | string | yes | Short identifier for the element. For architectural: a component, service, or module name. For domain: a concept term. |
| `description` | string | yes | Free-text explanation. Carries dimension-specific framing: for architectural, what the element does and how it is bounded; for domain, what the term means and how it is used. Multi-paragraph is fine. |
| `evidence` | list of objects | yes | Citations grounding the element. Each entry has `path` (string) and optional `excerpt` (string). At least one entry per element when confidence is `medium` or `high`. |
| `confidence` | enum | yes | One of `low`, `medium`, `high`. Indicates the agent's confidence in the element. `low` means "candidate, included for completeness"; `high` means "well-evidenced and challenged". |
| `challenge_notes` | list of strings | yes | What the challenge-refine step surfaced and how it was resolved. Empty list permitted only when challenge protocol is not yet run (sub-S2b will populate this). |

### 3.2 Type definition

The schema is described in prose with a field table in the template
file (per §4); no machine-readable schema file (JSON Schema or
similar) ships at this version. The agent reads the template as
prose and embeds it into its system prompt.

Equivalent type signature in pseudocode (for documentation only,
not committed as code):

```
LegibilityElement = {
  name: string,
  description: string,
  evidence: [{ path: string, excerpt?: string }],
  confidence: "low" | "medium" | "high",
  challenge_notes: [string]
}
```

### 3.3 Validation rules

- `name` must be non-empty.
- `description` must be non-empty.
- `evidence` must have at least one entry when `confidence` is
  `medium` or `high`. `low`-confidence elements may have empty
  evidence (the agent flagged a candidate without ground).
- `confidence` must be one of the three enum values.
- `challenge_notes` may be empty (sub-S2b's agent will not always
  populate it; the cross-check in parent S3 may).

The validation rules are enforced *by the agent*, not by a runtime
validator. Sub-S2b's agent file references this template and applies
the rules as part of its construction protocol. A later slice may
ship a deterministic validator if it earns its keep.

## 4. `LegibilityModel` collection wrapper

The two dimensions are gathered into a `LegibilityModel` wrapper
that the agent emits as its top-level output.

### 4.1 Fields

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `scope` | string | yes | A path or description of what was modelled (e.g. `"./src/auth/"` or `"the checkout flow across services A and B"`). |
| `generated_at` | string (ISO 8601) | yes | Timestamp the model pair was produced. |
| `generated_by` | string | yes | Agent name + model identifier (e.g. `"diagnostic-legibility-agent / claude-sonnet-4-6"`). |
| `architectural` | list of `LegibilityElement` | yes | The architectural-dimension elements. May be empty if scope yielded no architecture-level findings. |
| `domain` | list of `LegibilityElement` | yes | The domain-dimension elements. May be empty if scope yielded no domain concepts. |

### 4.2 Validation rules

- At least one of `architectural` or `domain` must be non-empty.
  An empty pair on both sides is a degenerate output and the agent
  should surface a `low`-confidence placeholder rather than emit
  two empty lists.
- The two lists may have different lengths; symmetric size is not
  required.

## 5. The schema artefact

### 5.1 Path

`diagnostic-legibility/templates/legibility-element.md`

Same `templates/` directory pattern that `model-cards/templates/`
uses. The template is referenced by sub-S2b's agent file via its
relative path.

### 5.2 Format

A single markdown file. Sections:

- `# LegibilityElement` — heading and one-paragraph charter.
- `## Fields` — the field table from §3.1.
- `## Validation rules` — from §3.3.
- `## LegibilityModel` — the wrapper from §4.
- `## Examples` — two worked examples, one architectural and one
  domain, each as a YAML block showing a `LegibilityElement`
  instance. The examples are illustrative; they ground the agent's
  prompt in concrete shape.
- `## Why this schema` — short pointer to this spec (§2) so a
  reader landing on the template file can find the design
  rationale.

### 5.3 Worked examples (content for the template)

The architectural example shows an element naming a service:

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

The domain example shows an element naming a concept:

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

## 6. User stories and acceptance scenarios

### 6.1 Story — sub-S2b can build the agent against the schema

**As** a developer implementing sub-S2b (the two-model agent and its
challenge protocol)
**I want** to find the `LegibilityElement` schema as a committed
template in the plugin
**So that** my agent's prompts can reference it by path and embed
its prose directly into the system message.

```gherkin
Given the merged main on this PR
When I look at diagnostic-legibility/templates/legibility-element.md
Then the file exists
And it contains a field table for LegibilityElement
And it contains the LegibilityModel wrapper definition
And it contains at least one architectural example and one domain example
And it contains a link back to this spec for the design rationale
```

### 6.2 Story — the schema is human-readable as documentation

**As** a future reader trying to understand what the diagnostic
legibility plugin produces
**I want** to read the schema as documentation without running any
agent
**So that** I can see the contract the agent emits before deciding
whether to use it.

```gherkin
Given diagnostic-legibility/templates/legibility-element.md
When I read it without any prior context
Then I understand what LegibilityElement is
And I understand how architectural and domain instances differ in
    practice (despite sharing a schema)
And I see worked examples that show the validation rules in concrete
    form
```

### 6.3 Story — the plugin version reflects the new template

**As** the marketplace consumer
**I want** the diagnostic-legibility plugin version to bump when
content is added
**So that** caches and version checks know the plugin has changed.

```gherkin
Given the merged main on this PR
When I read diagnostic-legibility/.claude-plugin/plugin.json
Then the version is "0.2.0"
And the entry in .claude-plugin/marketplace.json for diagnostic-legibility
    also shows version "0.2.0"
And the top-level marketplace `version` is unchanged at "0.4.0"
And the `plugin_version` field is unchanged at "0.39.0"
And diagnostic-legibility/CHANGELOG.md has a new entry for 0.2.0
```

## 7. Files to add and modify

### 7.1 New files

| Path | Purpose |
| --- | --- |
| `diagnostic-legibility/templates/legibility-element.md` | The schema artefact (§5). Replaces the `.gitkeep` placeholder in `templates/`. |

### 7.2 Removed files

| Path | Reason |
| --- | --- |
| `diagnostic-legibility/templates/.gitkeep` | Replaced by the new template file. The directory no longer needs a placeholder. |

### 7.3 Modified files

| Path | Change |
| --- | --- |
| `diagnostic-legibility/.claude-plugin/plugin.json` | Bump `version` `0.1.0` → `0.2.0`. |
| `diagnostic-legibility/CHANGELOG.md` | New `## 0.2.0 — 2026-05-26` entry naming the template addition and the sub-S1 disposition that produced it. |
| `.claude-plugin/marketplace.json` | Bump the `diagnostic-legibility` entry in `plugins[]` from `version: "0.1.0"` to `"0.2.0"`. Top-level `version` and `plugin_version` unchanged. |
| `README.md` (repo root) | Update the `diagnostic-legibility` badge from `v0.1.0` to `v0.2.0` and the marketplace table row's Version column from `v0.1.0` to `v0.2.0`. |

## 8. Out of scope

The slice narrowing keeps the following out of scope. They are listed
so the spec is honest about what is *not* shipping in this PR:

- **Any agent file under `diagnostic-legibility/agents/`.** Reserved
  for sub-S2b (#335). The `agents/.gitkeep` placeholder stays in
  place.
- **The challenge-refine protocol design.** Reserved for sub-S2b.
- **The cross-check protocol (parent S3, #332).**
- **The surfacing interface (parent S4, #333).**
- **A machine-readable JSON Schema file.** §3.2 explicitly defers
  this. The markdown template is the canonical artefact at v0.2.0.
- **A runtime validator that checks `LegibilityElement` instances at
  agent-output time.** Validation is enforced by the agent during
  construction (§3.3) until a later slice earns the validator.
- **TDAD scenarios.** No agent, skill, or command file is added; the
  TDAD-scenario-presence constraint and docs-reference-parity
  constraint are both no-ops on this PR.

## 9. Compatibility and rollout

- **Backwards compatibility:** the diagnostic-legibility plugin was
  shipped in v0.1.0 as a scaffold-only plugin. Adding a template file
  does not break any consumer because no consumer exists yet.
- **Cache behaviour:** `sync-marketplace-cache.sh` fires when
  `.claude-plugin/marketplace.json` differs from `origin/main` —
  this PR triggers it because the per-plugin version bumps.
  `sync-to-global-cache.sh` rsyncs the new template into the
  versioned plugin cache.
- **CI gates:** all existing gates apply. Spec-first is satisfied
  by this spec being the first commit on the branch. Version
  consistency is satisfied: diagnostic-legibility's plugin.json
  (0.2.0) matches its marketplace entry (0.2.0). TDAD and
  docs-reference-parity are no-ops.

## 10. Open questions resolved during brainstorming

| Question | Decision |
| --- | --- |
| Same schema vs. distinct schemas | Same flat schema (`LegibilityElement`) |
| Schema artefact location and format | Markdown spec at `diagnostic-legibility/templates/legibility-element.md` |
| Field set | `name`, `description`, `evidence` (list of {path, excerpt}), `confidence` (low/medium/high), `challenge_notes` |
| Collection wrapper | `LegibilityModel` with `scope`, `generated_at`, `generated_by`, `architectural[]`, `domain[]` |
| Per-version bump | diagnostic-legibility 0.1.0 → 0.2.0 (minor: new content); marketplace listing unchanged at 0.4.0 |

## 11. References

- Issue #331 — parent S2 commission.
- Issue #335 — deferred sub-S2b sibling (challenge protocol + agent).
- Sub-slicing record: `docs/superpowers/slices/dl-s2-two-model-agent.md`.
- Parent slicing record: `docs/superpowers/slices/diagnostic-legibility-plugin.md`.
- S1 (parent) spec: `docs/superpowers/specs/2026-05-26-diagnostic-legibility-plugin-scaffold-design.md`.
- Sibling pattern: `model-cards/templates/` for the templates/ convention.
- `CLAUDE.md` — Semantic Versioning and Marketplace Versioning sections.
