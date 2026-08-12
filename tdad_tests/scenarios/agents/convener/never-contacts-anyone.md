---
component: convener
component_type: agent
tier: structural
---

# Scenario: the Convener never contacts anyone, and never drafts a message

## Given

The read-only trust boundary already forecloses every **mechanical** path to
contacting someone: the agent holds `Read, Glob, Grep` and no `Bash`, so it
cannot send mail, open an issue, or push a branch.

What remains is **drift** — an agent producing progressively more sendable
questions until one of them is a message. Drift needs a line, not a lock, and
no script can draw it: a matcher for "Hi" would fail on the word appearing
anywhere, and one for a sign-off cannot tell a drafted message from a charter
that names sign-offs in the sentence forbidding them. That is the same
distinction that moved S4's write-surface check from mentions to sources.

The failure is severe and one-directional. An agent that contacts a colleague
on someone's behalf has spent that person's social capital without their
knowledge, in their name, and there is no undo.

## When

`ai-literacy-superpowers/agents/convener.agent.md` is read from the filesystem.

## Then

**Frontmatter:** `name: convener`, non-empty description, `role: sentinel`,
`tools` exactly `Read, Glob, Grep` — no `Write`, no `Edit`, no `Bash`.

**Charter:**

- States that it never contacts anyone: not by email, issue, mention, or a PR
  against another repository, **and not by drafting a message for the human to
  send unedited**.
- States **where the line is** — a question is one sentence a person could
  answer; a message has a salutation, a context paragraph, or a sign-off.
- States the reason the line is severe: social capital spent in someone's name,
  with no undo.
- States that an agent is never a voice, **with the reason** — the record would
  show a conversation that never involved a person, which is the isolation the
  Convener attacks, dressed as its remedy.
- States that a voice is a role or group, never a named individual.
- Caps voices at 8, biasing 3–5, and states the cap is an honesty device aimed
  at the agent rather than an ergonomic concession to the human.
- Carries all three honesty flags — `observed`, `inferred`, `asked` — with
  `asked` meaning the human named the voice.
- States that an absent `## Stakeholders` section is **not an error** and
  produces no warning.
- States that every voice is returned `disposition: pending`, and that the
  agent writes no file — `/convene` persists after the human disposes.
