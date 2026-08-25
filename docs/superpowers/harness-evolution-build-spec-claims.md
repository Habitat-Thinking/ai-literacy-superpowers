# Harness evolution — build spec claims, checked

Every claim the S0–S5 specs make about the build spec, checked against the source
now that the source is in the repository at
`harness-evolution-build-spec.md`.

## Status

**All 19 references verified. All four recorded deviations are accurate. One
claim is wrong — a count, not a substantive claim — and it is the one the assay
of 2026-08-25 built its finding-1 on.**

Before 2026-08-25 this file was a register of unverifiable claims, because the
build spec existed only in a conversation. The author supplied it on 2026-08-25.
This is what the check found.

## The four deviations

Each was argued in its slice spec as a departure from the build spec. Each is now
checkable. All four hold.

### D1 — the cost rule was unimplementable as written · `s0:238`

**The build spec says** (§6, and again in §8 Refusals): an HDR with a `cost`
"byte-identical to the Harness Assayer's proposal" is refused.

**The deviation claimed:** the spec "never says where the Assayer's proposal is
stored — so there is nothing to compare against."

**Verdict: correct.** The §5 frontmatter schema carries `cost` and no field for
the Assayer's proposal. §8 has `/harness-propose` leave `cost` empty and says
nothing about preserving the proposed cost. So the refusal in §6 compares against
a value the spec's own schema never stores. The implementation added
`proposed_cost` to close it — a field that appears nowhere in the build spec.

### D2 — the compilation model collides in this repo · `s2:28–54`

**The build spec says** (§8, §9): compilation "regenerates the marked regions of
every control surface", each surface carrying a list of `targets`.

**The deviation claimed:** it "does not survive contact with this repo" — two
generators on one file, since `/convention-sync` already owns three of five
convention mirrors, plus ambiguity wherever a surface lists a directory.

**Verdict: correct.** §9's `surfaces.yaml` example lists `.claude/agents/` and
`.codex/skills/` as targets — directories, with nothing saying which file inside
them an agent-instruction belongs to. The collision with `/convention-sync` is a
fact about this repository the build spec could not have known.

### D3 — the Assayer cannot be a sentinel and also write · `s3:29–45`

**The build spec says:** §7 declares **"Role: `sentinel`"** and its procedure step
5 instructs it to **"Write the assay report to `harness/assay/<ISO8601>-assay.md`
and stop."** §4's permission table grants the Assayer "append new files only" on
`harness/assay/`.

**The deviation claimed:** those cannot both hold, because criterion S1 of the
sentinel signature is a read-only trust boundary and `sentinel-integrity-check.sh`
fails CI on a sentinel holding Write. The write moved to the command's authority.

**Verdict: correct, and the tension is visible in the source.** §7 says "Role:
sentinel" and four paragraphs later says "Write the assay report". The claim that
"§4's permission table survives intact — `harness/assay/` is still the only path
that gains a file" also holds: §4 grants the Assayer write access to exactly that
one path and read-only everywhere else.

### D4 — expiry and review triggers do not compose · `s4:132`

**The build spec says** (§6): every accepted HDR is `provisional: true` with "a
mandatory `expires` date (default 90 days) **or** a `review_trigger`". §11.5
separately requires that "Expiry is enforced by CI, not by a calendar."

**The deviation claimed:** "Those two do not compose. A `review_trigger` is free
text."

**Verdict: correct.** §5's own example is
`review_trigger: "Two consecutive assays with zero findings in this class"` —
prose. CI can evaluate a date; it cannot evaluate that sentence. Requiring expiry
to be CI-enforced while permitting a free-text alternative to the date makes the
alternative unenforceable.

### D5 — the feed must not carry expiry · `s5:35`, softer

**The build spec says** (§10): "One line per accepted, superseded or expired
HDR", with an example line carrying `provisional` but no state field.

**The deviation claimed:** the example "does not say whether 'expired' appears in
the feed. It must not" — a field derived from the current date makes an unchanged
corpus produce different output on different days.

**Verdict: correct on the facts.** The example line carries no state field, so the
spec genuinely leaves it open. `s5:56`'s companion claim — that the example
"records when a rule started" and needs an end — also holds: the line has `date`
and no terminator.

## The claim that is wrong

**The assay of 2026-08-25, finding-1, states:**

> Six specs — `2026-08-23-harness-evolution-s0` through `-s5` — carry the line
> `**Provenance:** the Harness Assayer / Harness Registrar build spec, supplied
> in conversation 2026-08-23`.

Four do: `s0` (line 14), `s1` (16), `s2` (14), `s3` (13). `s4-review-demotion`
and `s5-observatory` carry no provenance line, and are the source of D4 and D5.
The companion count is also off: `build spec` appears **19** times across the six
specs, not thirteen.

This was raised as O2 in
`objections/harness-provenance-citation.md` and is confirmed here.

## What the check changes about finding-1

The finding's harm claim was: **"A reader cannot check any of them."** That was
true when written and is no longer true — this file is the check.

The result is worth stating plainly, because it cuts against the rule the finding
proposed: **every deviation was accurately characterised.** The four departures
were argued honestly, and the arguments hold against the source. What was missing
was not correctness but *checkability* — and the remedy for that was
transcription, which cost one paste and no governance machinery.

The finding's own proposed rule would have exempted these six specs by date
permanently (`Specs with filename date before 2026-08-25 are exempt`), so under
its own remedy these four deviations would have stayed unverifiable forever. The
thing that fixed the observed harm was the thing `1133b9c` did for the previous
epic: transcribe it.

## Structural notes from the source

Two things the source settles that the slices could only refer to:

- **§14 Q5** — "Is `provisional: true` on first acceptance too aggressive for
  rules imported from an existing HARNESS.md during migration?" — is the open
  question S0 §5.5 answered with `imported: true`.
- **§14 Q2** — "Should the Harness Registrar be a plugin agent at all, or is it
  better as scripts plus commands, with no model in the write path?" — was
  resolved toward a plugin agent (`s1:55`), and then largely reversed in
  implementation: the thresholds, enums, grammar and refusals live in
  `harness-registrar.py`, not in the agent's prompt.

The spec's own status line reads **"candidate spec, for review before
implementation"**. It was a proposal, which is part of why departing from it in
five places was reasonable rather than insubordinate.
