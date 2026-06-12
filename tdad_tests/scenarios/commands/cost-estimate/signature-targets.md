---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-signature-targets
---

# Scenario: path-vs-inline routing, --kind forwarding, and --out override with collision disambiguation (runnable-today)

## Given

A fixture repository with: a valid, readable **spec** target file; a quoted
**inline task-text** target that does not resolve to a readable file; a readable
`MODEL_ROUTING.md` whose tables parse; an empty `observability/costs/`; and a
scratch `<dir>` used for `--out`. For the collision arm, a **same-day,
same-target** estimate already exists beneath `<dir>`.

This scenario exercises the signature semantics: path vs inline resolution,
`--kind` forwarding, `--out` directory override, and same-day collision
disambiguation (spec §10.6, §10.6c; FR-3, FR-4, FR-11, FR-11a).

**Runnable-today** — exercised by real grounding reads against today's empty
`observability/costs/` (cost-omitted records).

## When

The command is run across the following arms:

1. A positional target that **resolves to a readable file**.
2. A positional target that **does not resolve** to a readable file.
3. `--kind spec` supplied.
4. `--out <dir>` supplied, human responds `accept`.
5. `--out <dir>` supplied while a same-day same-target estimate already exists
   beneath `<dir>`, human responds `accept`.

## Then

The **path-vs-inline routing**, **file-at-overridden-dir**, and
**collision-disambiguation** oracles assert:

- **Arm 1 (resolvable)** — the target is treated as a **path** and passed to the
  agent as a path.
- **Arm 2 (non-resolvable)** — the target is treated as **inline task text** and
  passed to the agent as an inline string.
- **Arm 3 (`--kind spec`)** — `spec` is **forwarded to the agent as the explicit
  dispatch-stated kind** (the command does not itself re-classify).
- **Arm 4 (`--out <dir>`)** — **exactly one file** is written **beneath `<dir>`**
  with the derived `<YYYY-MM-DD>-<target-slug>-estimate.md` filename (the
  directory is overridden, the derived filename preserved), and the full path is
  confirmed.
- **Arm 5 (`--out` collision)** — the command **appends a short disambiguator**
  to the derived filename, **notes the disambiguation in the confirm-before-write
  summary**, and the **pre-existing estimate is NOT overwritten** (a second file
  appears; the original is intact).

## Rubric

Layer 3 behavioural, graded by the **path-vs-inline routing oracle** (how the
target reaches the agent), the **file-at-overridden-dir oracle** (one file
beneath `<dir>` with the derived filename), and the **collision-disambiguation
oracle** (a disambiguated second file, original preserved, never a silent
overwrite), per spec §9. Targets, `--kind`, and `--out` are fixture-pinned. The
oracle never asserts the exact disambiguator string — only that the original
file survives and a distinct second file is written.

## Cleanup

Remove the temporary fixture repository (including any written estimate
directories).

## Implementation note

The runner drives each arm against the fixture: it inspects how the target is
passed to the agent (path vs inline), confirms `--kind` is forwarded as the
explicit kind, asserts the `--out` arm writes one file beneath `<dir>` with the
derived filename, and asserts the collision arm writes a disambiguated second
file while leaving the pre-existing estimate untouched.
