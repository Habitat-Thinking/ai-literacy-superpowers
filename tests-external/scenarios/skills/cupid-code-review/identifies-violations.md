---
component: cupid-code-review
component_type: skill
tier: behavioural
fixture: cupid-violations/user_repository.py
---

# Scenario: cupid-code-review identifies violations in fixture code

## Given

A Python file `fixtures/cupid-violations/user_repository.py`
containing a `UserManager` class with deliberate CUPID violations:

- **Composable** failure: the class instantiates a database
  connection, an SMTP client, and a logger directly inside its
  constructor — there is no way to use it without dragging the entire
  ecosystem in with it.
- **Unix philosophy** failure: the class does authentication, email
  delivery, audit logging, password hashing, and analytics in one
  surface — the antithesis of "do one thing completely and well".
- **Predictable** failure: methods named `get_user` perform side
  effects (writing audit logs, updating last-seen timestamps) that
  the name does not reveal.
- **Idiomatic** failure: the class uses `camelCase` for method names
  in a Python file that otherwise follows PEP 8.
- **Domain-based** failure: methods are named for plumbing
  (`runSqlQuery`, `flushBuffer`) rather than for the domain
  (`recordLogin`, `expireSession`).

The session has the `cupid-code-review` skill loaded.

## When

The user prompt is: *"Please apply the CUPID lens to this file and
identify the most significant violations of each property."*

The fixture file content is provided as context.

## Then

The skill output should:

- Identify all five CUPID properties by name in its review
- Flag at least the **Predictable** violation (side-effects in
  getters) — this is the most obvious one and a miss here suggests
  the skill has stopped engaging with the actual code
- Flag at least the **Domain-based** violation (plumbing names) —
  the second most obvious
- Suggest at least one concrete refactor (extract dependency,
  rename method, split class) — not just a critique

The skill is *not* required to find every violation. The purpose of
this test is to verify the skill engages with real code rather than
producing a generic CUPID summary detached from what was reviewed.

## Rubric

LLM-as-judge with these criteria, each pass/fail independently:

1. *Specificity*: does the review reference at least three named
   methods or attributes from the fixture? Generic prose without
   specific references means the skill answered without reading.
2. *Coverage*: does the review name at least four of the five
   properties (C, U, P, I, D)?
3. *Refactor suggestion*: is there at least one concrete
   refactoring proposal grounded in the code (not "consider applying
   SOLID")?

A pass requires 3 of 3 criteria; 2 of 3 is amber (worth investigating
but not a regression); 1 of 3 or fewer is a fail.

## Implementation note

The runner that fulfils this scenario should:

1. Load the skill into an SDK session
2. Send the user prompt with the fixture file appended
3. Capture the response
4. Dispatch a separate "judge" inference with the rubric above
5. Assert the structured pass/fail-per-criterion output meets the
   pass threshold
