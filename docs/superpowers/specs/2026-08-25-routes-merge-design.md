# Routing table merge semantics — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #559
**Provenance:** found while fixing #551, documented in
`harness-decision-records.md` and PR #552, never fixed.
**Scope:** `effective_routes` in `check-harness-decisions.py`.
**Out of scope:** #557, #558.

## 1. Problem statement

```python
def effective_routes(root: str) -> dict[str, str]:
    """The routing table in force, defaults included."""
    ...
    routes = doc.get("routes")
    if not isinstance(routes, dict) or not routes:
        return dict(DEFAULT_ROUTES)
    return {k: v for k, v in routes.items() if isinstance(v, str) and v.strip()}
```

The last line returns **only** the project's routes. The docstring says "defaults
included" and is false in exactly the branch it describes — the one where a
project has declared routes.

A project that declares one custom route silently loses every default, including
`harness-loop: HARNESS.md`. Those classifications then have no route, and
`compile_plan` refuses at acceptance:

```text
FAIL: <record>: classification 'harness-loop' has no route and the HDR names no 'target'.
```

Loud when it bites, but late: on a record someone has already read, argued and
written a cost for, and the cause is a line in `surfaces.yaml` that reads as
additive.

### Observed

This repository declared two routes. Adding `script-validator` to
`DEFAULT_ROUTES` in #552 therefore had no local effect until the route was also
written into `harness/surfaces.yaml`:

```text
resolved routes: {'harness-loop': 'HARNESS.md', 'turn-instructions': 'AGENTS.md'}
```

That is the upgrade problem in miniature, and the same shape as #547: a default
the plugin ships cannot reach any project that has customised the thing it lives
in.

## 2. Decision — merge, with an explicit way to suppress

`effective_routes` returns `DEFAULT_ROUTES` overlaid with the project's routes.
The docstring becomes true, and a route added in a future release reaches
projects that have customised their table.

**A default can be suppressed by mapping it to an empty value:**

```yaml
routes:
  turn-instructions:      # suppressed: this project has no AGENTS.md
  script-validator: HARNESS.md
```

### Why the escape hatch is not optional

A plain merge has a failure case. `target_of` prefers the route over any `target`
the record names:

```python
routed = routes.get(str(record.classification))
if routed:
    return routed
```

So for a project with no `AGENTS.md`, restoring `turn-instructions: AGENTS.md`
means a record of that classification routes to a file that does not exist,
`compile_plan` refuses, and **nothing can redirect it** — the record cannot name
its own target, because the route wins.

Today such a project omits the route and names targets explicitly. A merge
without suppression would take that away and leave no alternative. Three lines
buys back the case, so the case is bought back.

Suppression is by empty value rather than a separate key because the existing
filter already drops non-string and blank values; this makes that behaviour
meaningful instead of incidental.

## 3. Adopter impact, stated plainly

A project that today declares a partial `routes:` block will find the omitted
defaults **back in force** after upgrading.

This is a fix rather than a change of mind: the documented contract was always
"defaults included", so those projects were getting behaviour that contradicted
the documentation. Restoring the documented behaviour is the correction.

Where a project relied on the undocumented behaviour, one blank line per
suppressed route restores it, and the refusal that would otherwise appear names
the classification, so the remedy is discoverable.

## 4. Acceptance criteria

- **A1** — with no `surfaces.yaml`, the defaults are returned. Unchanged.
- **A2** — with no `routes:` block, the defaults are returned. Unchanged.
- **A3** — a partial `routes:` block yields the defaults **plus** the project's
  entries.
- **A4** — a project entry overrides a default of the same name.
- **A5** — a default mapped to an empty value is **absent** from the result.
- **A6** — a suppressed classification behaves as unrouted: a record of that
  classification must name its own `target`, and one that does is accepted.
- **A7** — the docstring matches the behaviour.
- **A8** — this repository's corpus is unaffected; `/harness-check` passes and the
  enforcement report is byte-identical.
- **A9** — Layer 0 coverage for each of the above, so the trap cannot reopen.

## 5. Version

Behaviour change to plugin files: minor bump, `0.84.0` → `0.85.0`.
