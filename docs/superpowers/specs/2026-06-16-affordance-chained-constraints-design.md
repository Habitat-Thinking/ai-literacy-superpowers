# Spec: Affordance chained constraints (sequencing steps 4 + 5)

**Date**: 2026-06-16
**Author**: Russ Miles + assistant
**Parent design**: `docs/superpowers/specs/2026-04-26-harness-affordances-design.md`
(Chained Constraints; O5, O8, O9 dispositions)
**Builds on**: step 3 (`2026-06-16-affordances-section-and-add-design.md`, PR #433)
**Driving issue**: #201
**Status**: design — awaiting spec-mode `/diaboli` and user review

## Problem

Step 3 made the affordance inventory a first-class `## Affordances` section,
but nothing yet *checks* it against reality. The whole point of pairing
affordances with permissions is the governance loop:

- **Affordances declare** what tools the agent should have access to.
- **Permissions enforce** what the agent actually has access to.

Without a constraint reasoning across both, the two drift: a permission gets
removed without reviewing the affordance (the agent declares a tool it can no
longer invoke), or a permission gets granted without a governing affordance
(an ungoverned capability). Steps 4 and 5 close that loop with the
**asymmetric pair** designed in the parent spec's O9.

## Scope

Sequencing steps 4 and 5, shipped together (they share one check script):

1. **Affordance-without-permission (blocking).** Every affordance's
   `Permission` pattern must appear in the permissions allowlist. A missing
   permission is a real safety concern. Deterministic, **blocking**.
2. **Permission-without-affordance (advisory).** Every allowlist entry
   should have a matching affordance. A missing affordance is paperwork debt.
   Deterministic, **advisory** (warns, never fails).
3. One deterministic check script (`shell + jq`) backing both directions.
4. Both constraints in `templates/HARNESS.md` under `## Constraints`;
   adopters pick them up via `/harness-upgrade`.
5. Layer 0 tests over the check script.
6. Minor version bump.

**Out of scope**: `/harness-affordance review` + the staleness GC rule
(step 6), the runtime tuple recorder (step 7), CI discovery automation
(step 8), and the further exemplar constraints (identity-confusion,
auditless-pre-tool-hook) the parent spec lists as motivating but unbuilt.

## Matching algorithm (per O5)

**String equality on the permission pattern.** An affordance whose
`Permission` field is `` `Bash(gh pr *)` `` matches the allowlist entry
`Bash(gh pr *)` and no other. No subset reasoning, no wildcard expansion —
broader patterns subsume narrower invocations rather than producing separate
entries, which is exactly the "one affordance per permission pattern"
granularity rule step 3 already enforces. This keeps the check trivially
deterministic.

The affordance's pattern is the backticked token in
`- **Permission**: \`<pattern>\` (...)`. The allowlist patterns are the
strings in `.permissions.allow[]` of the settings files.

## Gating: stay `unverified` until comparable (resolves the #201 open question)

The parent spec's O8 warns: if the constraint fires before a project has
affordances, it fires *universally* on day one (everyone has permissions, no
one has affordances). Two independent conditions must both hold before the
check enforces; if either fails, the check is **`unverified`** — it exits 0
with a one-line "skipped (unverified): <reason>" and never fails or warns.

1. **Affordances are populated.** The `## Affordances` section exists and no
   longer carries the **examples sentinel**. Step 3 ships the section with
   four example entries; this spec adds a machine-readable sentinel comment
   to that block:

   ```text
   <!-- affordance-examples-present: the affordance chained constraints stay
        unverified until you replace these examples with real entries and
        delete this line -->
   ```

   While the sentinel is present (or the section is absent, or holds only the
   "Not yet configured" placeholder), the check is unverified. Deleting the
   sentinel is the human's explicit "these are real affordances now" signal —
   no separate marker file, no fragile example-name heuristic.

2. **The allowlist is readable.** At least one of `.claude/settings.json`,
   `.claude/settings.local.json`, or `~/.claude/settings.json` exists and
   parses. This matters because `.claude/settings.local.json` and the user
   layer are commonly gitignored/per-machine, so a CI runner may have no
   readable allowlist. Rather than report every affordance as
   permission-less (the O8 universal-fire failure mode, transplanted to CI),
   the check stays unverified when it cannot see an allowlist to compare
   against. The settings files actually read are named in the output so the
   verdict is honest about what it could see.

This makes the **blocking** direction safe everywhere: it enforces only on a
machine that has both real affordances *and* a readable allowlist (the
human's working tree at commit time), and self-skips in CI or on an
un-migrated adopter. It satisfies the acceptance criterion "ships
`unverified` for projects without an `## Affordances` section; graduates to
`deterministic` once the section is populated" — graduation is automatic and
data-driven, not a manual edit.

## The check script

`scripts/harness-affordance-check.sh [--direction=blocking|advisory] [project-dir]`

1. Resolve `HARNESS.md` (project root or `.claude/HARNESS.md`). Absent → exit
   0, unverified.
2. Extract the `## Affordances` section. Absent, placeholder-only, or
   examples-sentinel present → exit 0, unverified.
3. Collect affordance `Permission` patterns (backticked token per entry).
4. Collect allowlist patterns via `jq -r '.permissions.allow[]?'` over each
   readable settings file (project `.claude/settings.json`,
   `.claude/settings.local.json`, user `~/.claude/settings.json`),
   de-duplicated. No readable file → exit 0, unverified.
5. **`--direction=blocking`**: for each affordance pattern not in the
   allowlist set, print `FAIL: affordance '<name>' declares Permission
   <pattern> with no matching allowlist entry`. Any failure → exit 1.
   Otherwise exit 0.
6. **`--direction=advisory`**: for each allowlist pattern not in any
   affordance's `Permission`, print `ADVISORY: permission <pattern> has no
   declared affordance`. Always exit 0 (advisory never fails); the warnings
   are the signal.

`set -euo pipefail`; `jq` required (clear install hint if absent, exit 0
unverified — missing tooling must not block). Deterministic: same inputs →
byte-identical output; patterns sorted `LC_ALL=C` before reporting.

## Constraint entries (templates/HARNESS.md `## Constraints`)

```text
### Affordances have matching permissions
- **Rule**: Every affordance declared in the ## Affordances section must
  have a Permission pattern that appears verbatim in the permissions
  allowlist (.claude/settings.json, .claude/settings.local.json, or
  ~/.claude/settings.json). An affordance without a permission is a tool the
  agent has declared but cannot invoke.
- **Enforcement**: deterministic
- **Tool**: ai-literacy-superpowers/scripts/harness-affordance-check.sh --direction=blocking
- **Scope**: commit

### Permissions have declared affordances
- **Rule**: Every entry in the permissions allowlist should have a matching
  affordance in the ## Affordances section. An ungoverned permission is
  paperwork debt, not a safety violation — flag, do not block.
- **Enforcement**: deterministic
- **Tool**: ai-literacy-superpowers/scripts/harness-affordance-check.sh --direction=advisory
- **Scope**: commit
```

Scope is `commit` (the human's machine has the settings files the check
needs). The check self-gates to `unverified` wherever the data is not
present, so it is also safe if a project wires it into `pr`/CI.

## Acceptance scenarios

1. **Un-migrated adopter** (no `## Affordances`): both directions exit 0,
   unverified.
2. **Examples not yet replaced** (sentinel present): both directions exit 0,
   unverified — no universal fire.
3. **No readable allowlist** (CI without settings files): exit 0, unverified.
4. **Real affordance missing its permission**: blocking exits 1 naming the
   affordance; advisory still exits 0.
5. **Allowlist entry with no affordance**: advisory prints the warning and
   exits 0; blocking exits 0 (that direction does not care).
6. **Fully paired** (every affordance has a permission and vice versa): both
   exit 0, no findings.
7. **Matching is string equality**: `Bash(gh *)` in the allowlist does **not**
   satisfy an affordance declaring `Bash(gh pr *)`; they are distinct.

## Functional requirements

- **FR1** A deterministic `harness-affordance-check.sh` backs both
  directions via `--direction`, using string-equality matching.
- **FR2** Blocking direction exits non-zero on an affordance whose
  `Permission` is absent from the allowlist; advisory direction warns and
  always exits 0.
- **FR3** The check is `unverified` (exit 0, no finding) unless **both** the
  affordances are populated (examples sentinel removed) and an allowlist is
  readable.
- **FR4** Both constraints ship in `templates/HARNESS.md` under
  `## Constraints`, scope `commit`, with the matching algorithm documented in
  the Rule text.
- **FR5** Step 3's example block gains the machine-readable examples
  sentinel that the gate keys on.
- **FR6** Layer 0 tests cover the seven acceptance scenarios.

## Risks and mitigations

- **Universal fire on day one (O8).** Mitigated by the two-condition gate
  (FR3): no real affordances or no readable allowlist → unverified.
- **CI has no `.claude/settings.local.json` (gitignored).** Mitigated by the
  allowlist-readable condition — the check skips rather than failing every
  affordance.
- **Pattern-extraction brittleness** (multi-pattern Permission fields). Step
  3's reference already mandates one pattern per `Permission` field; the
  check extracts the single backticked token and treats a malformed
  multi-pattern field as a non-match (surfaced by the blocking direction as a
  finding the human resolves by splitting the entry).
