---
title: Sync Harness Surfaces
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 7
redirect_from:
  - /how-to/sync-harness/
  - /how-to/sync-harness.html
---

# Sync Harness Surfaces

Run `/harness-sync` to detect drift across all push-direction control surfaces
and bring them back in line with `HARNESS.md` in a single pass. For
single-surface deep dives, see
[Sync Conventions](sync-conventions.md)
(convention and constraint files) and
[Generate an Onboarding Guide](generate-onboarding.md)
(`ONBOARDING.md`).

---

## Prerequisites

- `HARNESS.md` exists in the project root (created by `/harness-init`).
- The working tree is clean — `/harness-sync` refuses to run on a dirty tree.
  Stash or commit your work-in-progress first.
- `gh` CLI is authenticated (needed for PR creation on a fresh `chore/` branch).

---

## 1. Phase 1 — Drift scan

```text
/harness-sync
```

The command checks the current branch and working-tree state, then scans every
push-direction surface and prints a status table:

```text
Surface                                              Status      Action on apply
───────────────────────────────────────────────────  ──────────  ─────────────────────────
.cursor/rules/                                       drifted     /convention-sync
.github/copilot-instructions.md                      in sync     —
.windsurf/rules/                                     missing     /convention-sync (create)
ONBOARDING.md                                        drifted     /harness-onboarding
CI / CD (constraint scope)                           managed     handled at runtime
─────────────────────────────────────────────────────────────────────────────────────────
5 surfaces tracked · 2 drifted · 1 missing · 1 in sync · 1 managed at runtime
```

State vocabulary:

| State | Meaning |
| ----- | ------- |
| `drifted` | File exists but diverges from `HARNESS.md` |
| `missing` | File is absent; would be created on apply |
| `in sync` | File matches `HARNESS.md` |
| `managed` | Runtime-managed by `harness-enforcer`; surfaced for completeness only |

If all surfaces are `in sync` or `managed`, the command exits cleanly — nothing
to do.

Pass `--check` to run the scan without applying anything (useful from CI or as
the deep-scan step inside `/harness-health --deep`). The flag exits after
printing the table, non-zero if any surface is `drifted` or `missing`.

---

## 2. Phase 2 — Selection

After the scan, `/harness-sync` presents a multi-select prompt listing each
`drifted` or `missing` surface. All drifted/missing surfaces are selected by
default. Deselect anything you want to handle separately.

The `managed` row (CI / CD) never appears as a selectable option — it is status,
not an action.

An "Apply nothing — exit without changes" option is always present to make the
no-op path an explicit choice.

---

## 3. Phase 3 — Apply with verification

For each selected surface, the command invokes the corresponding primitive in
series:

- `.cursor/rules/` _and_ `.windsurf/rules/` → `/convention-sync`
- `ONBOARDING.md` → `/harness-onboarding`

After applying, it re-runs the drift scan as a verification pass and prints a
delta table:

```text
Apply complete — verification scan:

Surface                                              Before      After
───────────────────────────────────────────────────  ──────────  ──────────
.cursor/rules/                                       drifted     in sync ✓
.windsurf/rules/                                     missing     in sync ✓
ONBOARDING.md                                        drifted     in sync ✓
```

If a surface fails to come into sync it is marked `still drifted (error)`, the
command exits non-zero, and nothing is committed. Fix the underlying primitive
and re-run.

---

## 4. Branch and PR discipline

### Running on `main`

`/harness-sync` refuses to apply changes directly to `main`. It offers to
create a `chore/sync-surfaces-YYYY-MM-DD` branch (you can supply a custom name
instead). Once you confirm, it switches to the new branch and proceeds. After
the verification pass it:

1. Stages only the surface files (`.cursor/rules/`, `.github/copilot-instructions.md`,
   `.windsurf/rules/`, `ONBOARDING.md`).
2. Commits with a parameterised message: `chore: sync convention files and ONBOARDING.md to HARNESS.md`.
3. Pushes the branch and opens a PR with `--label chore`.
4. Reports the PR URL and the verification delta.

The `chore/` prefix satisfies the spec-first-check branch-prefix exemption —
no spec document is required for this type of maintenance PR.

### Running on a feature branch

If you are already on a feature branch, `/harness-sync` takes a lighter path:
apply, verify, stage, commit. _No push, no PR._ The commit joins your existing
branch and you push when ready.

---

## 5. Refusal cases

| Situation | What happens |
| --------- | ------------ |
| Uncommitted changes on the working tree | Refuses to run; lists dirty paths; suggests `git stash` or commit-first |
| Underlying primitive errors for one surface | Continues with remaining surfaces; marks the errored surface `still drifted (error)`; exits non-zero |
| Verification scan still shows drift after apply | Exits non-zero; reports failed surfaces; does not commit |
| User declines all surfaces in Phase 2 | Exits cleanly with no changes |
| Pre-commit guard finds a path outside the allow-list | Refuses to commit; reports the unexpected path as a bug in the underlying primitive |

---

## 6. Trust boundary

`/harness-sync` _never_ writes to `HARNESS.md`, `AGENTS.md`, or
`REFLECTION_LOG.md`. These are the harness source of truth; the command only
writes to the generated surfaces derived from them (`.cursor/rules/`,
`.github/copilot-instructions.md`, `.windsurf/rules/`, `ONBOARDING.md`).

A pre-commit guard verifies every staged path against that allow-list before
committing. Any path outside it is treated as a bug in the underlying
primitive — the command refuses to commit and reports the offending path.

This boundary mirrors the trust model used by `harness-gc` and
`governance-auditor`: read the harness, write to the surfaces, never write to
the harness itself.

---

## See also

- [Sync Conventions](sync-conventions.md)
  — single-surface deep dive for convention and constraint files
- [Generate an Onboarding Guide](generate-onboarding.md)
  — single-surface deep dive for `ONBOARDING.md`
- [The Harness Tuning Loop](../explanation/the-harness-tuning-loop.md)
  — the Propagate stage (Stage 5) that `/harness-sync` serves
- [The Harness Lifecycle](../explanation/the-harness-lifecycle.md)
  — the Renewal stage where surface synchronisation fits
