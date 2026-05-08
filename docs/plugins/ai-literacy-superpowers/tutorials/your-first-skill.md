---
title: Creating Your First Skill
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 2
redirect_from:
  - /tutorials/your-first-skill/
  - /tutorials/your-first-skill.html
---

# Creating Your First Skill

A skill is a Markdown file that agents read when working. It encodes
knowledge your team has — domain rules, recurring corrections, project
patterns — in a form that any Claude Code agent can act on. Skills are
the difference between an agent that writes code that looks reasonable
and one that writes code that fits your project.

This tutorial walks you through creating a custom project-local skill,
from identifying what to encode to writing the file and verifying the
skill is active. It takes about twenty minutes.

---

## Prerequisites

You need:

- Claude Code installed with the ai-literacy-superpowers plugin (see
  [Getting Started](getting-started) if you haven't done this yet)
- A project with at least a `.claude/` directory — run `/superpowers-init`
  if you don't have one

You do not need any special knowledge of the skill format. The tutorial
covers it from scratch.

---

## Step 1: What Is a Skill?

Skills are files that agents read when the user's request matches the
skill's description. When you start a session and ask Claude Code to
review some code, it checks the available skills for descriptions that
match the task. If a skill says "use when reviewing code," the agent
reads it before proceeding.

The content of a skill is the knowledge you want available. That can be:

- **Domain rules** — what a concept means in your business, how it
  differs from a generic implementation
- **Recurring corrections** — patterns that AI keeps getting wrong in
  your project, stated as what to do instead
- **Project conventions** — how your team names things, structures code,
  handles errors
- **Review lenses** — a checklist or framework to apply when assessing
  code quality

Skills do not run code. They are read and applied — the agent uses the
knowledge, judgment, and patterns to inform whatever it is doing.

Look at the plugin's built-in skills as examples. The `cupid-code-review`
skill encodes the CUPID framework as a set of review questions and
signals. The `harness-engineering` skill explains the harness framework so
any agent can understand the conceptual foundation. Both are between 100
and 200 lines — specific enough to be useful, short enough to be read
completely.

---

## Step 2: Identify What to Encode

The best skills encode something that:

1. **Recurs** — you find yourself correcting or explaining it repeatedly
2. **Is specific** — it applies to this project, not to projects in general
3. **Matters** — getting it wrong causes problems (review comments,
   rework, bugs)

Good starting points:

- The conventions you most often fix in AI-generated code (also the
  answer to extraction question 2)
- Domain terms that AI consistently conflates with their generic meaning
  (`Order` means purchase order, not sort order)
- A review framework you apply consistently
- A security pattern that must be applied in a specific way

For this tutorial, imagine you work on a billing system where the concept
of a `Customer` is very specific — it is always a paying account, never
a trial, and it always has a billing contact. AI keeps generating code
that uses `Customer` loosely. That is a good candidate for a skill.

---

## Step 3: Create the Directory Structure

Project-local skills live in `.claude/skills/` at your project root.
Each skill gets its own directory named after it.

```bash
mkdir -p .claude/skills/billing-domain/references
```

The structure will be:

```text
.claude/
  skills/
    billing-domain/
      SKILL.md
      references/        ← optional, for supplementary material
```

The `references/` directory is optional. Use it for lookup tables,
examples, or extended material that is too long to put in the main file
but that agents might need to consult.

---

## Step 4: Write the Frontmatter

Create `.claude/skills/billing-domain/SKILL.md` and start with the
frontmatter block:

```markdown
---
name: billing-domain
description: Use when generating, reviewing, or refactoring code that
  involves customers, invoices, billing contacts, or payment processing —
  encodes the domain model and the boundaries that must be respected
---
```

The frontmatter has two required fields:

**`name`** — must match the directory name. This is how the skill is
identified.

**`description`** — this is the most important field. Agents read the
description to decide whether this skill is relevant to their current
task. Write it as a natural sentence that includes the trigger phrases
a person would use. Ask yourself: what words would appear in a task
where this skill matters?

Include:

- The action verbs that should trigger the skill: `Use when generating`,
  `Use when reviewing`, `Use when refactoring`
- The nouns that signal relevance: the entities, concepts, or topics
  the skill covers
- A brief statement of what the skill provides

Do not include implementation instructions in the description — save
those for the skill body.

---

## Step 5: Write the Skill Content

Below the frontmatter, write the skill itself. A skill has three parts:
when to use it, the knowledge, and examples.

### When to Use

Start with a short paragraph that situates the skill. What is the
context? What problem does it solve?

```markdown
# Billing Domain

This project's billing domain has specific meanings that differ from
generic usage. Agents working in this codebase need to respect these
boundaries — conflating billing concepts with their generic counterparts
causes subtle bugs that do not surface until billing runs.
```

### The Knowledge

This is the main content. Write it as structured, specific guidance —
not aspirations, but observable facts and rules.

```markdown
## Core Entities

### Customer

A `Customer` is always a paying account. In this system:

- A Customer always has exactly one BillingContact
- A Customer is never in trial status — trial accounts use the
  `Prospect` type
- A Customer.ID is a UUID that matches the Stripe customer ID
- Do not use `Customer` to mean "user" or "person" — use `User`
  for generic user operations

### Invoice

An `Invoice` is always associated with a Customer, never a Prospect.
Invoices have a status lifecycle: `draft → issued → paid | void`.
Do not skip lifecycle steps in code — always use the `Invoice.Transition`
method.

### BillingContact

A BillingContact is a person, not an account. There is always exactly
one per Customer. BillingContact.Email is validated at creation and
must not be changed without going through `BillingContact.UpdateEmail`,
which triggers notification.

## Boundaries

- Never pass raw Stripe objects beyond the `billing/stripe/` package.
  Translate to domain types at the boundary.
- Do not store payment method details anywhere outside the
  `billing/payment/` package.
- `billing/domain/` must not import from `billing/api/` or
  `billing/storage/` — dependency goes inward only.
```

### Examples

Where the rule is non-obvious, show an example of the violation and
the correction. This is especially helpful for naming rules.

For the billing domain skill, the examples section might look like this.

**Using Customer where User is correct:**

```go
// Wrong — this is a generic user operation
func GetCustomerByEmail(email string) (*Customer, error)

// Right — GetCustomerByEmail implies a billing context that may not exist
func GetUserByEmail(email string) (*User, error)
```

**Skipping the lifecycle transition:**

```go
// Wrong — sets status directly, bypassing notifications and validation
invoice.Status = "paid"

// Right — use the transition method
err := invoice.Transition("paid")
```

Keep the examples short. One or two for each important rule is enough —
agents read the examples to understand the pattern, then apply judgment
from there.

---

## Step 6: Add Reference Files (Optional)

If your skill has lookup tables, longer examples, or supplementary
material that is too long for the main file, add it to the `references/`
directory.

For the billing domain skill, you might add a file with the full status
lifecycle for each entity:

```bash
touch .claude/skills/billing-domain/references/lifecycle-diagrams.md
```

Reference the file in SKILL.md:

```markdown
## Additional Resources

For the complete status lifecycle of each entity, consult
`references/lifecycle-diagrams.md`.
```

Agents will read the main SKILL.md first. They will only consult
reference files if the SKILL.md directs them to, or if the task
requires it. Keep SKILL.md complete enough to stand alone — references
are for depth, not for essential knowledge.

---

## Step 7: Test the Skill

Start a new Claude Code session in the project:

```bash
claude
```

Ask it to do something that should trigger the skill:

```text
Write a function that finds all invoices for a given customer email address.
```

The agent should pick up the billing-domain skill because the task
involves invoices and customers. You can confirm by checking whether the
agent:

- Uses `User` (not `Customer`) when the context is generic
- Uses `Invoice.Transition` instead of direct status assignment
- Respects the package boundary rules

If the agent misses the skill, check two things:

1. **The description** — does it include words that appear in the task?
   "invoice" and "customer" should be in the description if that is what
   the task uses.
2. **The directory** — is SKILL.md at `.claude/skills/billing-domain/SKILL.md`?
   The path must be exact.

You can also ask the agent directly:

```text
What skills do you have available?
```

A well-formed skill should appear in the list.

---

## What You Have Now

After completing this tutorial you have:

- A project-local skill at `.claude/skills/billing-domain/SKILL.md` that
  agents will read when working with your domain's entities
- A clear structure you can copy for any future skills — frontmatter with
  trigger-phrase description, when-to-use intro, specific knowledge,
  and examples
- An understanding of how to test that skills are being applied

The skill is a living document. Update it when you discover new recurring
corrections — after a code review where AI got something wrong is a good
trigger. Add it to your HARNESS.md garbage collection rules to check
for freshness periodically.

---

## Next Steps

- [Harness for an Existing Codebase](harness-from-scratch) — encode more
  of your conventions in HARNESS.md and promote them to enforcement
- [Reference: Commands](../reference/commands.md) — `/harness-gc` for
  managing skill freshness over time
- [How-to Guides](../index.md) — specific tasks like adding a constraint
  or running an audit
