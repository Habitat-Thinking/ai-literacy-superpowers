# Diagnostic Legibility — sub-S2a `LegibilityElement` schema — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship sub-S2a — the `LegibilityElement` schema artefact for the `diagnostic-legibility` plugin. One markdown file at `diagnostic-legibility/templates/legibility-element.md` describes the schema, the `LegibilityModel` wrapper, validation rules, and worked examples for both architectural and domain dimensions. Plugin version bumps `0.1.0 → 0.2.0`.

**Architecture:** No code added. The artefact is a markdown spec page that future sub-S2b agent prompts will reference by path. The schema is enforced by the agent during construction, not by a runtime validator.

**Tech Stack:** Markdown + JSON. No new dependencies.

**Spec reference:** `docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md`

---

## File structure

```
diagnostic-legibility/
├── .claude-plugin/plugin.json                # MODIFIED: 0.1.0 → 0.2.0
├── CHANGELOG.md                              # MODIFIED: new 0.2.0 entry
└── templates/
    ├── .gitkeep                              # REMOVED
    └── legibility-element.md                 # NEW

.claude-plugin/marketplace.json               # MODIFIED: plugins[].version 0.1.0 → 0.2.0 for diagnostic-legibility
README.md                                     # MODIFIED: badge + table row version bumps
```

Top-level `version` in marketplace.json stays at `0.4.0`. `plugin_version` stays at `0.39.0`. No `ai-literacy-superpowers/` files touched.

---

## Phase 1 — The schema template

### Task 1: Write the schema template

**Files:**
- Create: `diagnostic-legibility/templates/legibility-element.md`
- Delete: `diagnostic-legibility/templates/.gitkeep`

- [ ] **Step 1: Remove the placeholder**

```bash
git rm diagnostic-legibility/templates/.gitkeep
```

- [ ] **Step 2: Write the template**

Write `diagnostic-legibility/templates/legibility-element.md` with EXACTLY this content:

````markdown
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
````

- [ ] **Step 3: Verify the file exists**

```bash
ls -la diagnostic-legibility/templates/legibility-element.md && ! ls diagnostic-legibility/templates/.gitkeep 2>/dev/null
```

Expected: the new file exists; the old `.gitkeep` does not.

- [ ] **Step 4: Commit**

```bash
git add diagnostic-legibility/templates/legibility-element.md diagnostic-legibility/templates/.gitkeep
git commit -m "Diagnostic Legibility — LegibilityElement schema template"
```

(`git add` on the deleted `.gitkeep` records the removal; `git rm` in step 1 already staged it but re-adding via path is harmless.)

---

## Phase 2 — Version bumps

### Task 2: Plugin manifest version bump

**Files:**
- Modify: `diagnostic-legibility/.claude-plugin/plugin.json`

- [ ] **Step 1: Edit the version**

Change `"version": "0.1.0"` to `"version": "0.2.0"` in `diagnostic-legibility/.claude-plugin/plugin.json`.

- [ ] **Step 2: Verify**

```bash
python3 -c "import json; d=json.load(open('diagnostic-legibility/.claude-plugin/plugin.json')); assert d['version']=='0.2.0'; print('OK')"
```

- [ ] **Step 3: Commit**

```bash
git add diagnostic-legibility/.claude-plugin/plugin.json
git commit -m "Diagnostic Legibility — plugin.json bump 0.1.0 -> 0.2.0"
```

### Task 3: CHANGELOG entry

**Files:**
- Modify: `diagnostic-legibility/CHANGELOG.md`

- [ ] **Step 1: Insert a new top-level section**

Insert immediately after `# Changelog` and before the existing `## 0.1.0 — 2026-05-26` heading:

```markdown
## 0.2.0 — 2026-05-26

### LegibilityElement schema

Adds the `LegibilityElement` schema artefact at
`templates/legibility-element.md`. The schema covers both the
architectural and domain dimensions of the diagnostic-legibility
agent (built in sub-S2b, issue #335) under a single flat record type;
the dimensions are typed by the collection wrapper `LegibilityModel`,
not by the record itself. Carries `name`, `description`, `evidence`
(list of `{path, excerpt?}`), `confidence` (low/medium/high), and
`challenge_notes`. Wrapper adds `scope`, `generated_at`,
`generated_by`, and the two collections.

Replaces the `templates/.gitkeep` placeholder from v0.1.0.

Validation is enforced by the agent during construction; no runtime
validator ships at this version.

Sub-S1 of the meta-iteration recorded at
`docs/superpowers/slices/dl-s2-two-model-agent.md`. Tracks parent
issue #331. Sub-S2b (challenge protocol + working agent) is deferred
to issue #335.
```

- [ ] **Step 2: Verify**

```bash
head -10 diagnostic-legibility/CHANGELOG.md
```

Expected: the new section is at the top, immediately after `# Changelog`.

- [ ] **Step 3: Commit**

```bash
git add diagnostic-legibility/CHANGELOG.md
git commit -m "Diagnostic Legibility — CHANGELOG 0.2.0 entry"
```

### Task 4: Marketplace entry version bump

**Files:**
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Edit the diagnostic-legibility entry's version**

Find the `diagnostic-legibility` entry in `plugins[]` and change its `"version": "0.1.0"` to `"version": "0.2.0"`. The top-level `"version": "0.4.0"` and `"plugin_version": "0.39.0"` stay unchanged.

- [ ] **Step 2: Verify**

```bash
python3 -c "
import json
d = json.load(open('.claude-plugin/marketplace.json'))
assert d['version'] == '0.4.0', f'top-level: {d[\"version\"]}'
assert d['plugin_version'] == '0.39.0', f'plugin_version: {d[\"plugin_version\"]}'
dl = next(p for p in d['plugins'] if p['name'] == 'diagnostic-legibility')
assert dl['version'] == '0.2.0', f'dl entry: {dl[\"version\"]}'
print('marketplace.json OK')
"
```

Expected: `marketplace.json OK`.

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Marketplace — diagnostic-legibility entry 0.1.0 -> 0.2.0"
```

### Task 5: Root README badge + table row version bumps

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Bump the per-plugin badge**

Change:
```
[![diagnostic-legibility](https://img.shields.io/badge/diagnostic--legibility-v0.1.0-4682B4?style=flat-square)](diagnostic-legibility/)
```
to:
```
[![diagnostic-legibility](https://img.shields.io/badge/diagnostic--legibility-v0.2.0-4682B4?style=flat-square)](diagnostic-legibility/)
```

- [ ] **Step 2: Bump the table row's version column**

In the marketplace table, find the row that begins:
```
| **`diagnostic-legibility`** | v0.1.0 |
```
and change to:
```
| **`diagnostic-legibility`** | v0.2.0 |
```

- [ ] **Step 3: Verify**

```bash
grep -nE "diagnostic--legibility-v0\.[12]\.0|\\*\\*\`diagnostic-legibility\`\\*\\* \\| v0\\.[12]\\.0" README.md
```

Expected: hits for `v0.2.0` only; no `v0.1.0` for diagnostic-legibility.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "Root README — diagnostic-legibility badge and table row 0.1.0 -> 0.2.0"
```

---

## Phase 3 — Verify and ship

### Task 6: Local CI gate checks

- [ ] **Step 1: Spec-first ordering**

```bash
git log main..HEAD --reverse --oneline | head -1
```

Expected: the first commit is the spec.

- [ ] **Step 2: Per-plugin version sync**

```bash
python3 -c "
import json
m = json.load(open('.claude-plugin/marketplace.json'))
for p in m['plugins']:
    pj = json.load(open(p['source'] + '/.claude-plugin/plugin.json'))
    assert p['version'] == pj['version'], f'{p[\"name\"]}: marketplace={p[\"version\"]} plugin.json={pj[\"version\"]}'
    print(f'{p[\"name\"]}: {pj[\"version\"]} OK')
"
```

Expected: each plugin reports its version followed by `OK`. diagnostic-legibility should now show 0.2.0.

- [ ] **Step 3: ai-literacy-superpowers untouched**

```bash
git diff --name-only main..HEAD -- ai-literacy-superpowers/ | head -1
```

Expected: empty.

- [ ] **Step 4: TDAD + docs-reference parity checks are no-ops**

```bash
git diff --name-only main..HEAD --diff-filter=A | grep -E '^ai-literacy-superpowers/(agents|skills|commands)/' || echo "no component file additions — both checks are no-ops"
```

Expected: `no component file additions — both checks are no-ops`.

### Task 7: Push, PR, CI, merge

- [ ] **Step 1: Push the branch**

```bash
git push -u origin dl-s2-two-model-agent
```

- [ ] **Step 2: Open the PR**

```bash
gh pr create --title "Diagnostic Legibility — LegibilityElement schema (v0.2.0)" --body "$(cat <<'EOF'
## Summary

Sub-S2a of the meta-iteration slicing at \`docs/superpowers/slices/dl-s2-two-model-agent.md\`, which itself slices parent S2 (issue #331) of the diagnostic-legibility roadmap. Ships the \`LegibilityElement\` schema artefact at \`diagnostic-legibility/templates/legibility-element.md\` and bumps the plugin to v0.2.0.

The sub-S1 (this PR) and sub-S2b (issue #335) split came from carpaccio's meta-iteration on issue #331: the schema decision is a branching gate that propagates into every subsequent prompt, the cross-check (issue #332), and the surfacing (issue #333). Splitting it out keeps the schema-revision cost bounded.

Spec: \`docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md\`
Plan: \`docs/superpowers/plans/2026-05-26-dl-s2a-legibility-element-schema.md\`

## What's in the PR

- New schema template at \`diagnostic-legibility/templates/legibility-element.md\` (one record type, \`LegibilityElement\`, used for both architectural and domain dimensions; \`LegibilityModel\` wrapper for the agent's top-level output).
- The \`templates/.gitkeep\` placeholder from v0.1.0 is removed.
- diagnostic-legibility plugin.json and CHANGELOG bump from 0.1.0 → 0.2.0.
- marketplace.json: only the diagnostic-legibility entry's version bumps. Top-level \`version\` (0.4.0) and \`plugin_version\` (0.39.0) are unchanged.
- Root README badge + table row bump for diagnostic-legibility.

## What's NOT in the PR

- No agent file (sub-S2b, #335).
- No challenge-refine protocol (sub-S2b, #335).
- No runtime validator (deferred; validation is enforced by the agent during construction at v0.2.0).
- No machine-readable JSON Schema file (deferred; markdown is the canonical artefact).

## Test plan

- [ ] Spec-first ordering passes (spec is first commit on branch).
- [ ] Per-plugin version sync passes: diagnostic-legibility plugin.json (0.2.0) matches marketplace entry (0.2.0).
- [ ] marketplace.json top-level \`version\` (0.4.0) and \`plugin_version\` (0.39.0) unchanged.
- [ ] TDAD scenario presence check is a no-op (no agents/skills/commands files added).
- [ ] Docs reference parity check is a no-op (no agents/skills/commands files added).
- [ ] Markdown lint passes.
- [ ] Docs build check passes.

Tracks parent issue #331. Does **not** close it — sub-S2b (#335) closes #331 when the agent ships.
EOF
)"
```

- [ ] **Step 3: Watch CI**

```bash
gh pr checks $(gh pr view --json number --jq .number) --watch
```

Wait for all checks green. If anything fails, fetch the failure log (`gh run view <run-id> --log-failed`) and fix at root cause.

- [ ] **Step 4: Merge**

```bash
PR_NUM=$(gh pr view --json number --jq .number)
gh pr merge "$PR_NUM" --squash --delete-branch
```

- [ ] **Step 5: Verify parent issue #331 stays OPEN**

```bash
gh issue view 331 --json state --jq .state
```

Expected: `OPEN`. Closed by sub-S2b (#335), not by this PR.

- [ ] **Step 6: Sync marketplace cache**

```bash
bash ai-literacy-superpowers/scripts/sync-marketplace-cache.sh
CACHE="${HOME}/.claude/plugins/marketplaces/ai-literacy-superpowers"
git -C "${CACHE}" fetch -q origin && git -C "${CACHE}" pull --ff-only origin main 2>&1 | tail -3
```

---

## Out of scope (deferred)

- Agent file under `diagnostic-legibility/agents/` (sub-S2b, #335).
- Challenge-refine protocol design (sub-S2b, #335).
- Runtime validator that checks `LegibilityElement` instances at agent-output time.
- Machine-readable JSON Schema file alongside the markdown template.
- TDAD scenarios (no agent file added; the constraint does not fire).
- Cross-check protocol (parent S3, #332).
- Surfacing interface (parent S4, #333).
