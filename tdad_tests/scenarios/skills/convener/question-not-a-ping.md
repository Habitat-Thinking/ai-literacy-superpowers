---
component: convener
component_type: skill
tier: structural
---

# Scenario: the skill draws the question/message line and the prune-and-add loop

## Given

Two failures this skill exists to prevent are invisible to any matcher.

**The vague question.** "Sync with support" converts a real gap into a
scheduled meeting, and the meeting is what makes people stop doing this. S2
built a lexical anchor check for exactly this shape and then demoted it from
judge to trigger, because lexical form does not measure specificity. So the
skill teaches the property and shows worked examples rather than shipping a
matcher that would grade the wrong thing.

**The one-way dialogue.** A prune-only flow asks the human to narrow the
agent's view instead of contributing their own — which reproduces the
Convener's founding failure one level up, and leaves S1's third honesty flag
`asked` with nothing to attach to. The highest-value voice in a session is
usually the one the agent could not derive.

## When

`ai-literacy-superpowers/skills/convener/SKILL.md` is read from the filesystem.

## Then

**Frontmatter:** `name: convener`, non-empty description.

**Content:**

- Carries an `<!-- evidence: ... -->` comment grounding the design.
- Shows the question/message line as a **side-by-side worked pair** — the same
  sentence, once bare and once wrapped — and names the wrapper as the whole
  difference.
- Gives at least three worked questions, each answerable in one line without
  preparation, and names that test explicitly.
- States that nothing validates the question, **with the reason**: the question
  is the agent's output rather than the human's, so there is nobody to gate.
- Describes the dialogue as running in **both directions**, and states that a
  human-named voice is flagged `asked`.
- Gives the derivation table for `inferred` voices and states that an absent
  stakeholder map is not an error.
- Caps at 8, biases 3–5, and states the merge-time asymmetry: deleting is cheap
  and immediate, failing to delete is expensive and deferred.
- Carries the **three-way** Routing Rule with the Convener tie-break stated.
- States that `deliberately-not-consulted` is a complete answer and must not
  read as a lesser one.
- States that outcomes must be **distinct**, and that the check never judges a
  reason.
- Carries an anti-pattern table including the vague ping, the agent-as-voice,
  the named individual, and the drafted message.
