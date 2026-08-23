---
title: Add a Constraint
---
# Add a Constraint

Add or promote a constraint in HARNESS.md using `/harness-constrain` to capture the rule,
its enforcement state, and the verification command.

> **Use this for the first draft, not for evolution**
>
> `/harness-constrain` writes a rule straight into `HARNESS.md`. That is the
> right thing when you are **authoring a harness that does not exist yet**.
>
> For changing a harness that already exists, use the governed path —
> [Record a Governance Change](record-a-governance-change.md). It records the
> evidence that justified the rule, the cost the approver wrote, the
> enforcement each surface actually achieves, and an expiry that CI enforces.
>
> The difference matters after about a year, when a harness written by hand
> has a dozen rules and nobody can say why any of them are there or what it
> would cost to remove one.
>
> A constraint added this way can be brought under governance later by
> importing it as a grandfathered decision record.

---

## 1. Open a guided session

Run the command in Claude Code:

```text
/harness-constrain
```

The agent will ask you to describe what must be true. Write the rule precisely enough that
a reviewer — human or agent — could check it without ambiguity.

---

## 2. Choose an enforcement type

When prompted, select one of three enforcement types:

| Type | When to use |
| ------ | ------------- |
| `deterministic` | A tool exists that produces a clear pass/fail result |
| `agent` | The rule requires judgement but is precise enough for consistent LLM review |
| `unverified` | No tool yet; constraint is declared but not mechanically checked |

Start with `unverified` if you are unsure. Promote later when tooling is ready.

---

## 3. Set the scope

| Scope | When it runs | Use for |
| ------- | ------------- | ------- |
| `commit` | PreToolUse hook (advisory) | Fast checks — formatting, naming |
| `pr` | CI pipeline (strict) | Thorough checks — tests, secrets |
| `weekly` | Scheduled GC run | Slow checks — dependency audits |
| `manual` | `/harness-audit` only | New rules being calibrated |

Use `pr` for most constraints. Move to `commit` only for checks that run in under a second.

---

## 4. Confirm the HARNESS.md entry

After the guided session, verify the new constraint appears in `HARNESS.md`:

```markdown
## No direct database calls from controllers

- **Rule**: Controller classes may not import repository or ORM packages directly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Scope**: pr
```

If the entry looks wrong, edit `HARNESS.md` directly — the format is plain markdown.

---

## 5. Promote an existing constraint

To move a constraint from `unverified` to `deterministic`:

1. Add the tool command to the constraint's `Tool` field in `HARNESS.md`
2. Change the `Enforcement` field from `unverified` to `deterministic`
3. Run the tool command manually to confirm it exits non-zero on a real violation:

   ```bash
   # Example: run the tool against the current codebase
   npx dependency-cruiser --validate .dependency-cruiser.js src/
   ```

4. Wire the command into CI (see [Set Up Auto-Enforcer](set-up-auto-enforcer.md))

The promotion ladder is: `unverified` → `agent` → `deterministic`.

The ladder is one axis. **Reach** — whether a constraint is required on every PR or [complete-if-present](../explanation/progressive-hardening.md#rung-and-reach-are-different-axes) — is a second, and the `Enforcement` field does not record it.

You can skip steps
if tooling is immediately available.

---

## 6. Verify with `/harness-status`

```text
/harness-status
```

The output lists all constraints grouped by enforcement type. Confirm your new constraint
appears in the correct tier. If it shows as `unverified` when you expect `deterministic`,
check that the `Enforcement` field in `HARNESS.md` is spelled correctly.
