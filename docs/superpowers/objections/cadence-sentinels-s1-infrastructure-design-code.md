---
spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md
date: 2026-08-08
mode: code
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: risk
    severity: critical
    claim: "registry_count counts every entry file with no freshness test, so a session that ended normally is still counted as live for a full lease window, and the count is flagged `observed` — the published semantics is 'live sessions' but the delivered semantics is 'sessions that completed a turn in the last 12 hours'."
    evidence: "session-registry-read.sh registry_count uses `find -name '*.json' | wc -l` with no heartbeat comparison; the only removal path is registry_prune, which runs solely on the Stop rail. reference/pacts-format.md publishes `max_concurrent_sessions` as 'How many live sessions you will accept'. Reproduced: three sequential sessions (7h old, 3h old, live) yield '3 observed'."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: risk
    severity: high
    claim: "The two behavioural contracts the spec names for the new hooks — 'Both exit 0 unconditionally' and 'nothing in this slice blocks, warns, or requires a disposition' — are asserted by no test, and the test harness actively discards the evidence for both."
    evidence: "Every hook invocation in test-session-registry.sh is `bash \"$HOOK\" >/dev/null 2>&1 || true`. The redirect discards the stream that would prove no-gating; the `|| true` discards the status that would prove exits-0. Spec 4.5 and 6 both state the contracts explicitly."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: risk
    severity: high
    claim: "The registry writes an agent-authored durable record of which project the human was in and when, for every user of the plugin from the moment they upgrade — with no opt-in, no disclosure of contents or retention at the point of writing, and no documented way to decline; and this slice's own newly promoted BY/ABOUT test classifies such a record as about the person."
    evidence: "session-registry-write.sh writes repo (the session cwd) and started_at; hooks.json wires the writer to SessionStart with matcher '*' for every user. skills/sentinel-design/SKILL.md, added in this branch: 'Who authored the claim? If the agent did, it is about the person.' The skill's permitted list names the pact file, parking records and consultation dispositions; the registry is absent. Contrast templates/pacts.md: 'nothing writes this file on your behalf'."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: risk
    severity: medium
    claim: "A human-declared `stale_after_hours: 0` passes validation and makes registry_prune retire every entry — including the one registry_touch wrote milliseconds earlier on the same Stop — leaving the registry permanently empty while registry_count reports '0 observed'."
    evidence: "_lease_hours validates with `case \"$v\" in ''|*[!0-9]*) v=12 ;; esac`, which accepts 0. registry_prune's `-ge \"$lease\"` is true for a zero-age entry. registry_count's `-lt \"$lease\"` is false for 0 < 0, so the retirement is not disclosed. No lower bound is stated in the spec, the template, or the reference page."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: implementation
    severity: medium
    claim: "_block_span treats any line matching '^#{1,6}[[:space:]]+' as a markdown heading, so a standalone '# note to self' line in a human-authored pact file silently truncates the block — dropping every key below it and, with it, the mandatory clause, flipping a well-formed block to malformed."
    evidence: "pact-blocks.sh ends a span when `inblock && level <= want_level`; a '# ' line computes level 1, which is <= 2. The shipped guidance narrows the warning to value lines — 'never as a trailing # comment on a value line' — which reads as permission for a standalone # line. No fixture contains a #-prefixed line inside a block."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: implementation
    severity: medium
    claim: "R9's transitive mutation guard is narrower than the guarantee it advertises: its source-closure walker recognises exactly one spelling of source, and its mutation regexes miss several common write forms — so a future library added to the read closure by any other idiom is invisible while the test still prints 'read library inert'."
    evidence: "The walker's grep requires the `.` builtin, an unbraced all-caps variable, a single path segment, and a lowercase-hyphen filename; `source x`, `. \"${DIR}/x.sh\"`, and `json_helpers.sh` all drop out. The mutation patterns miss redirects to literal paths, ln, chmod, install, dd, `exec 3>`, and writes inside an awk program."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: risk
    severity: medium
    claim: "$CLAUDE_PACTS_FILE and $CLAUDE_SESSIONS_DIR are unauthenticated environment redirects with no origin check, so anything that sets an environment variable for a session can substitute the pact that S3-S5 will hold the human to, and can relocate the registry inside a work tree where it will be committed."
    evidence: "Both resolvers read the variable directly with a `:-` default. Spec 4.1 asserts 'nothing can accidentally commit it', which holds only while the override is unset; R13 tests the default path after an explicit unset. Neither variable is documented in reference/hooks.md or reference/pacts-format.md."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: specification quality
    severity: medium
    claim: "_flatten reverses an explicit, load-bearing sentence of the approved spec — the spec says a reflowed clause ceases to read as declared; the code says it still reads as declared. The reference page was updated to match the code; the spec, which is the document S2-S5 will be written from, was not."
    evidence: "Spec 3.4: 'the sentence cannot be reworded, translated, shortened, or reflowed across lines ... without the block silently ceasing to read as declared. That is deliberate.' pact-blocks.sh applies _flatten to both sides of the clause match. reference/pacts-format.md now says 'you may re-wrap the sentence across lines'."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: risk
    severity: medium
    claim: "The sweep is the tenth hook on the Stop rail and runs a full prune on every assistant turn — parsing the pact file with two awk passes and spawning several processes per registry entry — for every user of the plugin, before any consumer of the registry exists."
    evidence: "hooks.json adds session-registry-sweep.sh as the tenth Stop entry; the script calls registry_prune unconditionally per turn. registry_prune calls _lease_hours (two awk passes over the pact file), then per entry _json_field (grep + sed) and _iso_to_epoch (one or two date execs), then a find. Spec 6: S1 ships no consumer."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: specification quality
    severity: low
    claim: "hooks.json's own description field still enumerates the pre-S1 hook set, so the file's self-description is wrong on the day it ships."
    evidence: "hooks.json line 2 ends with the reservoir check and the template currency check; neither session-registry-sweep.sh nor session-registry-start.sh appears. reference/hooks.md tells the reader the file contains 'A description field summarising the hook set'."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: implementation
    severity: low
    claim: "The R14 escaping fix is one-directional: _json_escape is applied to repo on write but started_at is round-tripped from disk unescaped, and _json_field is not escape-aware on read, so a legitimately backslash- or quote-bearing repo path reads back truncated or doubled in registry_list."
    evidence: "registry_touch re-emits `started` (read via _json_field) without escaping while escaping repo. _json_field's `[^\"]*` stops at the first quote, escaped or not. registry_list is the surface that hands the value to a consumer, and spec 4.1 makes the field load-bearing."
    disposition: pending
    disposition_rationale: null
---

# Objection record — Cadence Sentinels S1 (code mode)

Code-mode adversarial review of branch `cadence-sentinels-s1-infrastructure`
against spec revision 3. Eleven objections: one critical, two high, six
medium, two low.

The implementation is materially better than the spec that produced it. The
first-delimiter extraction rule is implemented correctly and B8 is a genuinely
falsifying fixture rather than a confirming one. The read/write library split
is real, not nominal. The `_json_escape` fix is correct, including the
non-obvious ordering constraint. `records_open` implements both halves of the
open-record test rather than the easy half.

The objections concentrate in three places that quality does not reach: what
`registry_count` actually means as opposed to what it is documented to mean
(O1, O4); which of this slice's constitutional promises are guarded by a test
and which are merely asserted in a header comment (O2, O6); and what the
registry persists about a person who never asked for it (O3, O7).

**Dispatcher verification note (2026-08-08).** O1 was reproduced empirically
before this record was written: a registry holding one live entry and two from
earlier sessions the same day (7 hours and 3 hours old, both inside the
12-hour lease) returns `3 observed`. Under `max_concurrent_sessions: 2` the
WIP Warden would report a confidently-flagged breach on an ordinary working
day. The diaboli's verification of the two fixes it was asked to scrutinise
was also checked and stands: the guarded strict-mode form discriminates
correctly in bash, and `_json_escape` genuinely closes the immortal-entry case
rather than relocating it.

## O1 — risk — critical

### Claim

`registry_count` has no freshness test. It counts files. The only thing that
removes a file is `registry_prune`, and `registry_prune` runs only on the
`Stop` rail. Nothing removes an entry when a session ends, because by design
nothing knows a session has ended.

The consequence is not an edge case — it is the ordinary working day. A human
who runs a morning session, an afternoon session, and an evening session has
three entries by evening, all with heartbeats inside the 12-hour default
lease, all counted. One session is running.

The count's published name is "live sessions". Its delivered meaning is
"sessions that completed a turn within the lease window". Those are different
quantities, and the honesty flag asserts the stronger one.

### Evidence

`registry_count` sizes the count with `find -name '*.json' | wc -l` and makes
no comparison against `heartbeat` anywhere; the lease is consulted only to
size the `.retired` marker window. The write library states the retirement
rule plainly: "Nothing here deletes an entry because a session 'ended' — the
pruner retires entries whose lease expired, and that is the only removal
path." And `reference/pacts-format.md` publishes the consuming key as "How
many **live sessions** you will accept".

The spec discloses one direction of the lease's imprecision and not the other
(§4.2, "Known limit of the lease, disclosed"): the renewal interval is
unbounded above, so a live session may look dead. The false-*positive*
direction — a dead session looks live for up to `stale_after_hours`, and every
sequential session of the day accumulates — is never stated, in the spec, the
reference page, or the hook documentation.

Two secondary observations sharpen it. First, the unpruned window is at its
widest exactly when a WIP Warden would read: `SessionStart` fires, writes the
new entry, and returns, with no `Stop` yet in that session and therefore no
prune. Second, the flag fails toward overclaiming — a `find` failing on a
permission error, an unreadable `.retired` marker, and an unresolvable
registry directory all yield `observed`.

No test covers the gap. R4 counts two entries both freshly written in the same
process; R5 counts *after* a prune. No scenario has an expired-but-unpruned
entry present when `registry_count` runs, which is the state the registry
spends most of its life in.

### Why this matters

The count-plus-flag pair is Component 2's entire deliverable. The `.retired`
marker machinery is correct and works — but it guards the wrong quantity. It
discloses uncertainty introduced by *pruning*, and says nothing about
uncertainty introduced by *not having pruned yet*, which is the larger and far
more common source.

Three slices consume this. S4's WIP Warden is the one this component exists to
serve, and under `max_concurrent_sessions: 2` a normal day puts its keeper in
permanent, confidently-asserted breach. Because S1 gates nothing, the defect
ships green and surfaces first as a sentinel nobody believes — the worst
outcome for a category whose entire value is trust.

This does not reverse the spec-time disposition of O1. The lease with
heartbeat renewal is the right design. Two things follow from it that the
implementation has not drawn: `registry_count` should exclude entries whose
heartbeat is past the lease (a pure read — no mutation, no trust-boundary
change), and it should flag `inferred` whenever it saw one, because an
unpruned expired entry is exactly the "crashed or merely quiet?" uncertainty
the flag already exists to carry. Failing that, the quantity needs renaming
everywhere it is published.

## O2 — risk — high

### Claim

This slice's headline constitutional promise is that it gates nothing. The
mechanism by which a hook gates something is writing to stdout or exiting
non-zero. Neither new hook is tested for either property, and the harness
suppresses both signals on every invocation.

### Evidence

Every hook invocation in the registry test takes the form
`hook_input "sess-alpha" | bash "$START_HOOK" >/dev/null 2>&1 || true`. The
redirect discards the stream that would prove the no-gating property; the
`|| true` discards the status that would prove exits-0. Both contracts are
named explicitly in spec §4.5 and §6, and in each script's own header.

Both scripts are in fact silent and do exit 0 today. That is not the
objection. The objection is that the property is guarded by nothing, in a
slice whose sole justification is that it is a substrate three later slices
build on without re-deriving it. Any future edit that adds a `printf` outside
a redirect turns silent plumbing into a per-turn nudge, and the suite stays
green.

The adjacent gap: no test runs either hook with the registry unwritable,
absent, or `HOME` unset — the paths the exits-0 contract exists for.

### Why this matters

Constraint 6 is the constraint the epic's safety argument rests on, and the
one a human reviewing this PR most needs mechanised. A one-line assertion
costs less than the comment currently standing in for it. Every other
constitutional property in this slice got a test — R8 for purity, R9 for the
trust boundary, R10 for sanitisation, R13 for the work tree. The one property
that is *this slice's* reason to be safe got a `>/dev/null`.

## O3 — risk — high

### Claim

From the moment a user upgrades to 0.67.0, every session start writes a file
recording which project directory that person was working in and when. The
record is authored by an agent, not the human. It accumulates across
repositories. There is no opt-in, no notice at the point of writing, no
retention statement, and no documented way to decline short of editing the
plugin's `hooks.json`.

The rule this branch promotes into `sentinel-design` — expressly so S2–S5
inherit it rather than re-derive it — classifies exactly this record as being
*about* the person.

### Evidence

`registry_touch` writes `repo` (the session's `cwd`) and `started_at`;
`hooks.json` wires the writer to `SessionStart` with `matcher: "*"`, for
everyone. The promoted rule reads: "Who authored the claim? If the agent did,
it is about the person. Would the person recognise it as something they said?
If not, it is about them." A hook authored the entry, and no human would
recognise `{"repo":"/Users/x/code/foo","started_at":"..."}` as something they
said. The skill's permitted list is explicit — a budget, a stop hour, a
disposition, a next action they wrote themselves — and names the pact file,
parking records and consultation dispositions. The registry is absent.

There is a real steel-man, and the disposition may well be to write it down:
the boundary section is scoped to *sentinel*-authored records, the registry is
hook-authored operational state, and spec §2 argues it "records nothing about
who is in it". That defence covers `id` and `heartbeat`. It covers `repo` less
comfortably, because §4.1 makes that field load-bearing precisely so a
consumer can tell the human where their other sessions are — which is to say,
the field exists to describe where the person works.

The asymmetry inside the slice is the sharpest evidence. The pact file — which
the human authors about themselves, the *permitted* side of the line — got a
deliberate adoption ramp and an argument for why nothing writes it on their
behalf. The registry — agent-authored, on the contested side — is created for
everyone, silently, with no ramp. `reference/hooks.md` says only "local,
per-machine, outside every work tree, and never committed"; it does not say
what entries contain, how long they persist, or how to turn the hook off. The
repo has a precedent for the missing piece: the AGENTS.md readback hook
shipped with a documented "Disable the hook entirely" path.

### Why this matters

The BY/ABOUT distinction was promoted in this branch specifically so S2–S5 do
not each invent their own boundary. Shipping the rule alongside an unaddressed
counterexample is worse than shipping neither: the next author reads the rule,
sees the registry, and concludes the rule is advisory. The disposition need not
be "remove the registry" — it can be "the registry is hook-authored
operational state, not a sentinel record; here is the carve-out, written into
the skill", plus a documented opt-out and a retention sentence. What it cannot
be is silence, because silence sets the boundary by precedent, which spec §2
itself argues is the weakest way to settle a constitutional question.

## O4 — risk — medium

`stale_after_hours` accepts any digit string including `0`. With `0` declared,
`registry_prune` retires every entry on every `Stop` — including the one
`registry_touch` wrote one line earlier in the same script, since `0 -ge 0` is
true — and `registry_count` then reports `0 observed`, because `0 -lt 0` is
false so the retirement is not disclosed. A single character disables the
registry and the honesty flag says nothing.

No bound is stated in the spec's §3.3 table, the template, or the reference
page, which says only "Raise it if you routinely leave a session parked
mid-thought". R7 tests `2` and `24`. This is the same defect class §3.6 and
Note A exist to prevent — a human tunes a declared value in good faith and gets
silent degradation — except that here the degradation is total, and a reader
who takes `0` to mean "never expire", a common convention, gets the exact
opposite.

## O5 — implementation — medium

`_block_span` recognises a heading as any line of one to six `#` followed by
whitespace, and ends the span at a heading of equal-or-higher level. A
standalone `# revisit this in Q4` computes level 1, ends the span, and drops
every key below it — including the mandatory clause, flipping the block from
`declared` to `malformed`. Sub-headings are safe: `#### Notes` computes level 4
and the span continues.

The shipped guidance narrows the warning to value lines only — "never as a
trailing `#` comment **on a value line**" — which a careful reader takes as
licence for a `#` comment on its own line. No fixture exercises it.

The failure direction is safe: malformed degrades to observe-only, never to a
gate. It is a silent-degradation defect in the file the spec expects a human to
hand-edit, and the symptom is that the pact they wrote stopped being read with
no line telling them which sentence broke it.

## O6 — implementation — medium

R9's closure walk, added this cycle in response to a correct finding, asserts a
stronger property than it verifies. The walker requires the `.` builtin (not
`source`), an unbraced all-caps variable (not `${DIR}`), a single path segment,
and a lowercase-hyphen filename — so `source "$DIR/x.sh"`, `. "${DIR}/x.sh"`,
`. "$DIR/util/x.sh"`, and `json_helpers.sh` all drop silently out. The mutation
patterns miss redirects to literal paths, `ln`, `chmod`, `install`, `dd`,
`exec 3>file`, and any write inside an `awk` program.

The canary is the right instinct but is satisfied by the one library that
happens to use the recognised idiom, and would stay satisfied while a second,
unwalked library sat one `.` away from every sentinel. The architectural split
is right and R9's runtime half is a real test; the objection is to the textual
half, which is what the record will be read as guaranteeing.

## O7 — risk — medium

Both location overrides are read straight from the environment with no origin
check. They exist so tests need no home directory, but they are live in
production: anything that sets an environment variable for a session — direnv,
a project rc file, a wrapper — can substitute the pact S3 and S4 will hold the
human to, and can relocate the registry inside a work tree where it will be
committed. Spec §4.1's "nothing can accidentally commit it" holds only while
the override is unset, and R13 tests the default path after an explicit
`unset`. Neither variable is documented.

The clear-weather argument turns on authorship: a pact holds because its keeper
wrote it. An override that redirects which pact is read makes authorship
unverifiable, and `block_state` returns `declared` regardless of who wrote the
file. This matters little in S1, where nothing consumes a pact; it matters a
great deal in S3 and S4, and S1 is the slice that fixes the contract.

## O8 — specification quality — medium

`_flatten` deliberately reverses an explicit sentence of the approved spec.
§3.4 says a reflowed clause ceases to read as declared and calls that
deliberate; the code normalises whitespace so a reflowed clause still reads as
declared. The reference page was updated to match the code; the spec was not.

The behavioural change is right — the shipped template's own `Session WIP`
clause wraps, so the strict rule was unshippable, and B10 pins it. The
objection is to what did not happen alongside it: §3.4 claims authority over
this sentence's matching rule ("Only a spec-first change may reword it") and
was not amended when the rule changed. S2–S5 will be authored against §3, and
§3 states a matching rule the library does not implement. The remedy is a
revision-4 amendment, not a change to the code.

## O9 — risk — medium

The sweep is the tenth `Stop` hook and runs a full prune every assistant turn:
two `awk` passes over the pact file, then per entry a `grep`, a `sed`, and one
or two `date` execs, then a `find`. That lands on every user from the upgrade
onward, in service of a count nothing in this slice reads.

This does not gate anything. It is a proportionality point about where the cost
sits. The slice's protective argument for the pact file is that nothing is
imposed on someone who has not asked for it — §3.7, "nothing in this epic
should happen to someone who never asked for it." Per-turn work on the rail
that runs at the end of every response is something happening to everyone who
upgrades, months before the sentinel that would justify it exists. The pruner
does not need to run every turn; the lease is measured in hours.

## O10 — specification quality — low

`hooks.json`'s `description` field still enumerates the pre-S1 hook set, so the
file's summary of itself is wrong in the commit that changes it. Small, and
purely a currency defect — worth a line because this description is the first
thing a reader of `hooks.json` sees, and because the rest of the slice's
documentation work is thorough enough that the omission reads as an oversight.

## O11 — implementation — low

The escaping fix is one-directional. `_json_escape` is applied to `repo` on
write, but `started_at` is read back from disk and re-emitted unescaped, and
`_json_field`'s `[^"]*` stops at the first quote, escaped or not — so a repo
path legitimately containing a backslash or quote round-trips truncated or
doubled into `registry_list`, the surface that hands the value to a consumer.

Low, because the write-side injection R14 was about is genuinely closed. What
remains is a read-side asymmetry with a cosmetic worst case today and no
consumer to be wrong at yet. Worth recording because the reasoning in the
`_json_escape` comment is about correctness under a hostile value, and the same
reasoning applied to the read path would close the pair rather than one half.

## Explicitly not objecting to

- **The guarded strict-mode form.** `(return 0 2>/dev/null) || set -euo pipefail`
  discriminates correctly in bash; the shebang and `hooks.json`'s `bash ...`
  invocation guarantee bash; CI exercises Layer 0 on both Ubuntu and macOS. The
  `HOME`-unset path degrades safely to an empty directory, a failed `mkdir`,
  and `exit 0` with nothing on stderr.
- **The `_json_escape` fix and R14.** Correct, including the non-obvious
  requirement to replace the backslash before the quote. The injected key
  cannot match `_json_field`'s pattern, so the immortal-entry case is closed
  rather than moved.
- **The lease with heartbeat renewal.** Adjudicated at the spec gate and the
  reasoning holds. O1 objects to what `registry_count` counts and what flag it
  attaches, not to the lifecycle.
- **The read/write library split.** The right architecture, correctly
  implemented; R9's runtime half is a real test. O6 objects only to the reach
  of the textual half.
- **Session-id sanitisation.** Reuses the pattern this repo already adjudicated
  for the same field, and R10 checks the fallback path and that nothing landed
  outside the directory.
- **The first-delimiter extraction rule and block scoping.** B7 and B8 are
  genuinely falsifying rather than confirming; `shared-key.md` is the fixture a
  lazier test would have skipped.
- **`records_open`.** Implements both halves of the open-record test — the
  transition-suffix exclusion *and* the `supersedes` walk — where either alone
  would be wrong in an opposite direction, and C3 asserts both.
- **The Reservoir Warden.** Untouched. `reservoir-check.sh` is unmodified and
  appears in the new code only as a cited comparison in comments; constraint 5
  holds.
- **Language discipline.** No occurrence of "addiction", "addictive",
  "dopamine", or loose "reinforcing" in any new or changed file. Constraint 8
  holds.
- **`_flatten`'s behaviour.** Normalising whitespace before clause matching is
  the right call — the strict rule was unshippable against the slice's own
  template. O8 objects to the spec not being amended, not to the change.
