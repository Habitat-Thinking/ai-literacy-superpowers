# Validator binding — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #553
**Provenance:** found while checking whether the #551 fix removed the ability to
enforce rules on scripts. It did not — `render_region` only ever emitted prose,
so governance has never edited code, which makes the `validator` field the
*entire* link between a written rule and the code enforcing it. Evidence table
reproduced against this repository at commit 91cd510 and recorded in #553.
**Scope:** `has_validator`, the enforcement-report reason strings, and the
`validator` field's contract.
**Out of scope:** #555, #556, #557, #558, #559.

## 1. Problem statement

```python
def has_validator(record: Record, root: str) -> bool:
    """A validator counts only if the file it names actually exists."""
    value = record.fm.get("validator")
    if not value:
        return False
    items = value if isinstance(value, list) else [value]
    return any(os.path.exists(os.path.join(root, str(item))) for item in items)
```

Existence is the whole test, and `any` means a list passes when one entry
resolves. Observed against this repository:

| `validator:` | `has_validator` |
| --- | --- |
| `README.md` | **True** |
| `CHANGELOG.md` | **True** |
| `.gitignore` | **True** |
| `["docs/index.md", "nope/missing.py"]` | **True** |
| an unrelated real script | **True** |
| `scripts/does-not-exist.py` | False |

`achieved_for` gates the top of the enforcement ladder on this single boolean, so
`validator: README.md` is the difference between a rule reporting `advisory`
(honest: written down, nothing enforces it) and `validated` or `blocked` (a claim
that something refuses violations).

The failure is silent and it flatters. Nothing corrupts and no check goes red —
the report simply asserts enforcement that does not exist, which is the one thing
`harness/enforcement-report.md` was built to prevent.

## 2. What must be true for `validated` to mean what it says

1. The named path exists.
2. It is plausibly runnable.
3. Something invokes it.
4. It checks **this** rule.

Only (1) is checked today, and weakly.

### Why (3) is not in this change

"Referenced by a workflow or hook" looks like the natural test for invocation and
is close to worthless here. `README.md` is referenced by
`.github/workflows/version-check.yml` and `tdad-scenario-check.yml`, which grep
its contents — so the archetypal bad validator satisfies the invocation test.

Worse, it carries a real false-negative cost: a validator invoked from inside
another script reads as uninvoked, and a genuinely enforced rule would silently
drop to `advisory`. A test that passes the worst case and fails good ones is not
worth having.

## 3. Decision — resolve, runnable, and bound to the rule

`has_validator` requires all three:

- **Every** listed path resolves. `all`, not `any`. A list whose real checker is
  missing must not pass because a doc beside it exists.
- **Each path looks runnable**: the executable bit is set, or the suffix is one of
  `.py`, `.sh`, `.bash`, `.js`, `.rb`. This is a shape test, not a guarantee — it
  exists to exclude documents, which is the observed failure, not to prove
  executability.
- **At least one listed path names the record it enforces** — the HDR `id`
  appears in the file's text.

The third is the one that makes the claim falsifiable. A runnable, invoked script
that checks something else is still not enforcement of *this* rule, and nothing
short of a binding can tell the difference.

The binding is deliberately one-directional and cheap: the validator mentions the
record. A comment is enough. That also makes the validator self-describing, which
is worth having on its own — a checker that says which governance rule it exists
for is easier to keep honest than one that does not.

### The adopter cost, stated plainly

Any existing record declaring a validator that does not name it will drop from
`validated` to `advisory` on the next compile. That is a **downgrade toward
honesty**: the report stops claiming enforcement it cannot demonstrate. It is
still a change adopters will see, and the reason string has to say exactly why so
nobody has to read this spec to understand their report.

This repository's corpus declares no validators, so nothing here changes.

## 4. Decision — the report distinguishes the states

`achieved_for` currently collapses everything into one reason:

```text
no validator declared or resolvable
```

That sentence covers four different situations and tells an adopter nothing about
which one they are in. Replace it with a specific reason per state:

| State | Reason |
| --- | --- |
| No `validator` field | `no validator declared` |
| A listed path does not exist | `validator not found: <path>` |
| A listed path is not runnable | `validator is not runnable: <path>` |
| No listed path names the record | `validator does not name <hdr-id>, so it cannot be shown to enforce this rule` |

The distinction is the point of the report. "Nobody declared one" and "one was
declared and it is missing" are different failures with different remedies, and
collapsing them is the same class of defect as the one being fixed.

## 5. Acceptance criteria

- **A1** — a `validator` naming a document (`README.md`, `CHANGELOG.md`,
  `.gitignore`) does not reach `validated`.
- **A2** — a list passes only when **every** entry resolves.
- **A3** — a runnable script that does not name the record does not reach
  `validated`.
- **A4** — a runnable script that names the record **does** reach `validated`.
- **A5** — the executable bit qualifies a path with no recognised suffix.
- **A6** — each state produces its own reason string in the enforcement report.
- **A7** — a record with no `validator` still reports `advisory`, unchanged.
- **A8** — the existing corpus is unaffected: `/harness-check` passes and the
  enforcement report is byte-identical before and after.
- **A9** — Layer 0 coverage using the #553 evidence table as fixtures, so the
  loophole cannot return.

## 6. Version

Behaviour change to plugin files: minor bump, `0.81.0` → `0.82.0`, across the
five CI-checked locations named in `CLAUDE.md`.
