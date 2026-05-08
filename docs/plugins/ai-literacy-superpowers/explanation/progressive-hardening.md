---
title: Progressive Hardening
---
# Progressive Hardening

Progressive hardening is the constraint promotion ladder: constraints begin as unverified declarations in `HARNESS.md`, are promoted to agent-based review once you have a prompt that catches violations reliably, and are promoted again to deterministic enforcement once the constraint is understood precisely enough to express as a script or linter rule. Movement is always toward deterministic. Patterns of repeated agent catches are the signal that a constraint is ready to be promoted.

---

## The Three Maturity Levels

Every constraint in `HARNESS.md` sits at one of three enforcement levels. The levels are not arbitrary categories. They reflect the team's understanding of the constraint: how precisely they can state it, how reliably they can check it, and how much they trust the checking mechanism.

### Level 1: Unverified (Declared)

An unverified constraint is a written commitment. The team has identified a rule, agreed that it matters, and documented it in `HARNESS.md`. No automated mechanism checks it. Enforcement depends entirely on human memory and discipline.

This state is not a failure. It is honest accounting. Most teams have dozens of implicit conventions that nobody has written down. An unverified constraint is better than an unwritten convention, because it is visible, version-controlled, and shows up when `/harness-status` reports on enforcement coverage. It creates an explicit target: this rule matters enough to declare, and it deserves enforcement investment when the team is ready.

**When it is appropriate:**

- The team has just identified a new convention and the wording is still evolving
- No deterministic tool exists for this kind of rule
- The team wants to observe violations manually before investing in automation
- The constraint is experimental and may be revised or removed

**What verification looks like:**

Nothing automated. The constraint appears in `HARNESS.md` with `enforcement: unverified` and `tool: none yet`. The `/harness-status` command reports it as an unverified entry. The harness auditor flags it as an opportunity to improve enforcement coverage.

**Example:**

```markdown
### Error handling consistency

- **Rule**: All public API functions must return structured error types,
  not raw strings or nil error values
- **Enforcement**: unverified
- **Tool**: none yet
- **Scope**: pr
```

The team knows this matters. They have written it precisely. They have not yet built a check for it. That is a valid state, and recognising it as such prevents two bad outcomes: pretending the constraint is enforced when it is not, and not declaring the constraint at all because no tooling exists yet.

### Level 2: Agent-Backed (Verified by AI)

An agent-backed constraint is checked by the `harness-enforcer` agent. The agent reads the constraint's prose rule from `HARNESS.md`, reads the code under review, and makes a judgment about whether the code complies. The output is a pass or fail with file-and-line findings, identical in format to deterministic results.

Agent-backed enforcement occupies a middle ground that did not exist before large language models. It lets teams enforce constraints that are too nuanced for mechanical checking but too important to leave unenforced. An agent can read a function and judge whether its error handling is consistent with the project's conventions. No linter can do that. But a linter that checks whether functions return `error` types can handle the mechanical subset of the same constraint.

**When it is appropriate:**

- The rule involves intent, semantics, or quality judgments that resist mechanical expression
- The team wants enforcement now but is not ready to invest in custom tooling
- A deterministic tool covers part of the constraint but not all of it
- The constraint is well-worded enough for an LLM to apply consistently

**What verification looks like:**

The `harness-enforcer` agent reads the constraint's rule text, reviews the relevant files, and produces findings. The findings are structured identically to deterministic tool output: pass or fail, with a list of `{file, line, message}` entries. This uniformity means the rest of the system does not care whether a human, an agent, or a script produced the result.

Agent-based checks are flexible and nuance-aware, but they are also non-deterministic, token-intensive, and slower than tooling. The same code reviewed twice may produce slightly different findings. This is acceptable for constraints where judgment is inherently involved. It is a reason to promote when a deterministic alternative becomes available.

**Example:**

```markdown
### Documentation quality

- **Rule**: Doc comments on exported functions must explain reasoning
  and design intent, not restate the function signature
- **Enforcement**: agent
- **Tool**: harness-enforcer
- **Scope**: pr
```

A linter can check whether doc comments exist. It cannot check whether they are useful. The agent can, because "explains reasoning rather than restating the signature" is a judgment that language models handle well.

### Level 3: Deterministic (Tool-Enforced)

A deterministic constraint is checked by a specific tool: a linter rule, a formatter in check mode, a structural test, a secret scanner, or a custom script. The tool produces the same result every time for the same input. There is no interpretation, no judgment, no variability.

Deterministic enforcement is the strongest level. A constraint at this level is a law of physics in your codebase. The CI pipeline will not let you violate it. The check runs in milliseconds, costs nothing in LLM inference, and is completely trustworthy within its specification.

It is also the most dangerous level. A bad deterministic rule does not just annoy developers -- it blocks them. A constraint promoted to deterministic before its edge cases are understood will generate false positives, which generate workarounds, which erode trust in the entire constraint system. One bad linter rule that forces `// nolint` annotations trains the team to suppress warnings without reading them.

**When it is appropriate:**

- A tool exists (or can be written) that checks the rule accurately
- The constraint has been stable, with no wording changes across multiple audit cycles
- The team has observed the agent-backed version long enough to understand edge cases
- False positives are rare enough that the rule will not be routinely overridden

**What verification looks like:**

The `harness-enforcer` reads the constraint from `HARNESS.md`, sees `enforcement: deterministic`, and executes the command in the `tool` field. Exit code 0 means pass. Non-zero means fail. The tool's output is parsed into the standard findings format.

**Example:**

```markdown
### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys may appear
  in committed source files
- **Enforcement**: deterministic
- **Tool**: gitleaks detect --source . --no-banner --exit-code 1
- **Scope**: commit
```

Secret detection is a textbook candidate for deterministic enforcement. The rule is precise, the tool is mature, and false negatives are more dangerous than false positives. There is no judgment involved in detecting a private key in source code.

---

## Verification Slots

The verification slot is the abstraction that makes progressive hardening mechanical rather than conceptual. Every constraint occupies a slot. The slot defines a uniform contract: what goes in, what comes out, and how the result is consumed. The enforcement mechanism behind the slot -- agent or tool -- is an implementation detail that can change without affecting anything upstream.

### The Contract

**Input:**

- Constraint definition: the rule text, enforcement type, and tool command from `HARNESS.md`
- Scope: when the check runs (`commit`, `pr`, `weekly`, `manual`)
- File set: which files to check (changed files for PR scope, all files for scheduled scope)

**Output:**

- Result: `pass` or `fail`
- Findings: a list of `{file, line, message}` entries (empty on pass)

This contract is the same regardless of whether the slot is filled by `eslint`, `gitleaks`, a custom bash script, or the `harness-enforcer` agent reading prose. The uniformity is the point. It means that promoting a constraint from agent to deterministic requires changing two fields in `HARNESS.md` (enforcement type and tool command) and nothing else. No hooks change. No CI configuration changes. The slot interface absorbs the transition.

### How a Constraint Declares Its Verification

A constraint in `HARNESS.md` declares its verification mechanism through the `enforcement` and `tool` fields:

| Enforcement value | What the enforcer does |
| --- | --- |
| `unverified` | Skips the constraint; logs it as unchecked |
| `agent` | Reads the rule text, reviews files, produces findings |
| `deterministic` | Executes the tool command, interprets exit code and output |
| `deterministic + agent` | Runs both, merges findings from each |

The `deterministic + agent` option handles constraints where a tool covers the mechanical subset and an agent covers the semantic remainder. For example, a linter checks that doc comments exist on all exported functions (deterministic presence check) while the agent reviews whether those comments explain reasoning rather than restating signatures (quality check). Both produce findings in the same format. The enforcer merges them.

### Why the Uniform Interface Matters

The uniform interface means the harness does not accumulate integration complexity as constraints mature. A team with three unverified constraints, five agent-backed constraints, and two deterministic constraints runs the same enforcement pipeline for all ten. Adding a new tool or retiring an agent prompt is a configuration change in `HARNESS.md`, not a workflow change.

This also means that demotion -- moving a constraint backward from deterministic to agent because the tool was removed or is no longer maintained -- is equally straightforward. Change the enforcement field, and the enforcer falls back to agent review automatically.

---

## The Promotion Process

Promotion is not a scheduled event. It is a response to evidence. The harness generates that evidence through its normal operation: audit reports, violation logs, enforcement statistics. The team reads the evidence and decides when a constraint is ready to move.

### Signals That Indicate Readiness

| Signal | Indicates |
| --- | --- |
| Unverified constraint violated in a PR review | The constraint is real and actively relevant; promote to agent |
| Agent constraint catches real violations consistently | The rule wording is effective; the agent understands it |
| Agent constraint produces the same class of finding repeatedly | The pattern is well-understood enough to automate |
| A deterministic tool exists that covers the constraint | Promotion to deterministic is mechanically possible |
| Constraint wording has not changed in three or more audit cycles | The team's understanding has stabilised |
| Agent gives inconsistent results on similar code | The rule may need rewriting before promotion, or a tool that eliminates interpretation |

The strongest promotion signal is repetition. When the agent catches the same kind of violation across multiple PRs, that repetition proves two things: the constraint matters (violations keep happening) and the pattern is understood (the agent describes it consistently). At that point, writing a script or linter rule to catch the same pattern is usually straightforward.

### How to Recognise When an Agent Constraint Is Ready for Deterministic Enforcement

Ask three questions:

1. **Can you describe the violation mechanically?** If you can write a sentence of the form "a violation occurs when file X contains pattern Y," a script can check it. If you need words like "appropriate," "reasonable," or "consistent with the spirit of," the constraint resists deterministic expression.

2. **Are the edge cases understood?** The agent may have been handling edge cases through judgment. Before promoting, enumerate the edge cases and confirm the deterministic tool handles them correctly. A tool that produces false positives on legitimate code will be overridden and ignored.

3. **Is the tool trustworthy?** A mature, well-maintained linter rule is worth promoting to. A fragile custom script that breaks on unusual input is not. Promotion to deterministic is a commitment to maintain the tool.

### The Steps to Promote

1. **Identify or write the tool.** Find an existing linter rule, formatter check, or structural test that covers the constraint. If none exists, write a script that follows the verification slot contract: exit 0 for pass, non-zero for fail, structured output for findings.

2. **Test the tool against known violations.** Run the tool against code that the agent has previously flagged. Confirm the tool catches the same violations. Run it against code that the agent passed. Confirm no false positives.

3. **Update `HARNESS.md`.** Change `enforcement` from `agent` to `deterministic`. Set `tool` to the exact command. Keep the rule text unchanged -- it remains documentation even when a tool does the checking.

4. **Run `/harness-audit`.** The auditor confirms the tool executes successfully in the harness context and the constraint is now enforced deterministically.

5. **Monitor the first few cycles.** Watch for false positives, missed violations the agent would have caught, and developer complaints. If the tool is not working well, demoting back to agent is a single field change.

---

## When NOT to Promote

The promotion ladder has a direction -- toward deterministic -- but it does not have a mandate. Some constraints belong at agent level permanently. Forcing them into deterministic enforcement produces worse outcomes than leaving them where they are.

### Judgment-Based Rules

Some constraints require judgment that no tool can replicate:

- "Functions should be small enough to understand in one pass." A line-count limit is a poor proxy. A 60-line function that reads as a single clear sequence is better than three 20-line functions that force the reader to jump between files. An agent can make this distinction. A linter cannot.

- "Variable names should come from the problem domain, not the implementation domain." An agent can read `calculateMonthlyRevenue` and recognise it as domain language, and read `processDataList` and flag it as implementation jargon. A naming linter would need a domain dictionary that does not exist.

- "Error messages should be actionable." The difference between "Error: invalid input" and "Error: expected ISO-8601 date format, got '2024-13-01'" is a judgment about what helps the user. An agent can evaluate this. A tool cannot.

### Semantic Constraints That Resist Deterministic Expression

Some constraints are about meaning, not syntax:

- "Documentation should explain why, not what." A tool can check that comments exist. It cannot check that they are illuminating rather than redundant.

- "Test names should describe the behaviour being tested, not the implementation being exercised." An agent can read `test_returns_error_when_user_not_found` and distinguish it from `test_getUserById_null`. A tool would need to understand the relationship between test names and test bodies.

- "API responses should be consistent in structure across endpoints." An agent can compare response shapes and flag inconsistencies. A schema validator can check individual responses but not cross-endpoint consistency patterns that emerge from convention rather than specification.

### The Cost of Bad Deterministic Rules

A deterministic rule that produces false positives is actively harmful. Developers learn to suppress warnings rather than fix code. The suppression becomes a habit, applied without thought. The constraint system loses credibility. Future legitimate constraints are treated with suspicion.

The agent level is the right permanent home for any constraint where the cost of false positives from a deterministic rule exceeds the cost of occasional false negatives from agent review.

---

## Constraint Design Principles

A constraint is only as good as its statement. A vague constraint cannot be enforced at any level. A precise constraint can start unverified and still provide value, because it tells developers exactly what is expected even before automation exists.

### Precision

State what compliant code looks like. State what violating code looks like. If a reviewer -- human or agent -- cannot determine compliance without asking clarifying questions, the constraint is too vague.

**Vague:** "Code must be clean."
**Precise:** "All public API functions must return structured error types, not raw strings."

**Vague:** "Tests must be good."
**Precise:** "Every exported function must have at least one test that exercises the success path and one that exercises an error path."

Precision is not the same as rigidity. A precise constraint can still involve judgment ("doc comments must explain reasoning") as long as the judgment is scoped narrowly enough for consistent application.

### Testability

A good constraint can be tested before it is enforced. Write an example of compliant code and an example of violating code. Show them to a colleague (or an agent) and ask: "Does this violate the rule?" If the answer is ambiguous, the rule needs rewriting.

This is the same principle that makes good test assertions: if you cannot write a failing test, you do not understand the requirement.

### Rationale

Every constraint should state why it exists. The rationale is not decoration. It serves three purposes:

1. **It helps agents apply the constraint correctly.** An agent that knows "we require structured error types because our error-handling middleware depends on the type field for routing" will make better judgments about edge cases than one that only knows the mechanical rule.

2. **It helps developers accept the constraint.** A rule with a visible reason is followed willingly. A rule without one is followed resentfully, then quietly abandoned.

3. **It helps future maintainers decide whether the constraint is still relevant.** If the rationale references a system that no longer exists, the constraint may be a candidate for removal.

---

## HARNESS.md Format

Constraints are declared in the `## Constraints` section of `HARNESS.md`. Each constraint is a level-three heading followed by four fields in a consistent format.

### The Four Fields

```markdown
### Constraint name

- **Rule**: What must be true, stated precisely enough for objective verification
- **Enforcement**: unverified | agent | deterministic | deterministic + agent
- **Tool**: The exact command to run (or "none yet" for unverified, "harness-enforcer" for agent)
- **Scope**: commit | pr | weekly | manual
```

**Rule** is the most important field. It is the constraint itself -- the statement of what must be true. It should be specific enough that a reviewer can check compliance without interpretation.

**Enforcement** declares the current maturity level. This field is what the `harness-enforcer` reads to decide how to verify the constraint. It is also what `/harness-status` reads to calculate enforcement coverage.

**Tool** names the verification mechanism. For deterministic constraints, this is the exact shell command that the enforcer will execute. For agent-backed constraints, it is `harness-enforcer` (the agent itself). For unverified constraints, it is `none yet`.

**Scope** declares when the check runs. `commit` scope runs in the inner loop (advisory, at edit time). `pr` scope runs in the middle loop (strict, at merge time). `weekly` scope runs in the outer loop (investigative, on a schedule). `manual` scope runs only when explicitly triggered by `/harness-audit`.

### Examples in Practice

A constraint at each level, showing how the fields change as the constraint is promoted:

**Unverified:**

```markdown
### Consistent error handling

- **Rule**: All public API functions must return structured error types
  with a machine-readable code field and a human-readable message field
- **Enforcement**: unverified
- **Tool**: none yet
- **Scope**: pr
```

**Promoted to agent:**

```markdown
### Consistent error handling

- **Rule**: All public API functions must return structured error types
  with a machine-readable code field and a human-readable message field
- **Enforcement**: agent
- **Tool**: harness-enforcer
- **Scope**: pr
```

**Promoted to deterministic:**

```markdown
### Consistent error handling

- **Rule**: All public API functions must return structured error types
  with a machine-readable code field and a human-readable message field
- **Enforcement**: deterministic
- **Tool**: ./scripts/check-error-types.sh
- **Scope**: pr
```

The rule text stays the same across all three promotions. The enforcement type and tool change. Everything else remains constant. This is the mechanical simplicity that the verification slot abstraction provides.

---

## Further Reading

- [Constraints and Enforcement](constraints-and-enforcement.md) -- introductory concepts of constraint maturity and the promotion ladder
- [Determinacy Calibration](determinacy-calibration.md) -- the bidirectional companion to this page; calibration as a periodic review activity covering promotion, demotion, splitting, seam repair, and refusal as legitimate outputs
- [Harness Engineering](harness-engineering.md) -- the three components (context, constraints, garbage collection) and how they interact
- [The Three Enforcement Loops](three-enforcement-loops.md) -- inner, middle, and outer loop timing
- [Context Engineering](context-engineering.md) -- what context declares before constraints enforce
- [Codebase Entropy](codebase-entropy.md) -- the slow drift that constraints alone cannot catch
