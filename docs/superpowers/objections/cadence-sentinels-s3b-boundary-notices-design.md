---
spec: docs/superpowers/specs/2026-08-12-cadence-sentinels-s3b-boundary-notices-design.md
date: 2026-08-12
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "The rail arbitrates at the wrong scope: reservoir-check.sh has no once-per-session guard and cannot have one, so it re-emits on every Stop firing while the Mast's notice is once-only — the rail therefore silences the single-prompt message in favour of the repeating one."
    evidence: "reservoir-check.sh persists nothing by charter and carries no once-per-session guard; verified zero occurrences of marker/once/already/fired. Spec 3.1: 'the first hook to claim stop in a given turn emits.' MB6 logs the note on the suppressed turn and MB7 stops reached firing again, so the message never arrives at all."
    disposition: accepted
    disposition_rationale: "Precedence replaces registration order. A once-only advisory outranks a repeating one, on the honest ground that the Warden loses nothing by deferring — it fires again next turn — while the Mast's notice has no next turn. The rail's purpose was to reduce accumulated pressure and it was protecting the source of it."
  - id: O2
    category: implementation
    severity: high
    claim: "Section 3.2's justification for the Warden winning — that 'decide your stop' subsumes 'you have reached the stop you decided' — is falsified by the Warden's shipped message text, which asks the human to decide a FUTURE stop before the NEXT session."
    evidence: "reservoir-check.sh: 'Decide your stop BEFORE the next session begins... do not negotiate the boundary with your tired self.' That is advice about a future session addressed to someone who has not drawn a line; the human who declared hard_stop_hour has already done it."
    disposition: accepted
    disposition_rationale: "Dissolved by O1's inversion. The subsumption argument was the stated reason for the Warden winning, and it was backwards at the moment that matters: the suppressed message was the one naming a line the person drew themselves. Precedence now runs the other way and the argument is withdrawn rather than repaired."
  - id: O3
    category: specification quality
    severity: critical
    claim: "'One claim per turn' is undefined: a Stop hook receives no turn identifier, every hook in one firing shares the same session_id, and the spec names neither the discriminator that scopes a claim nor the atomicity it requires."
    evidence: "No shipped hook reads or derives a turn id. AR1-AR4 all describe a single process making sequential calls and pass for a non-atomic implementation."
    disposition: accepted
    disposition_rationale: "A turn is defined operationally rather than metaphysically: hooks in one Stop firing run back-to-back, so a claim is scoped by a short wall-clock window (10s) recorded in the claim file, and the window and its two failure modes — two very fast turns collapsing, one very slow rail straddling — are disclosed in the skill and the reference page. Claiming is made atomic with mkdir, which is atomic on every POSIX filesystem. A rail whose guarantee is a race would flicker, and a sentinel that flickers teaches the human to discount it."
  - id: O4
    category: scope
    severity: high
    claim: "Section 6's file table omits hooks/hooks.json, in which the entire ordering guarantee lives, and skills/coda/SKILL.md, which carries the survey flag table section 5.1 changes."
    evidence: "hooks.json registers ten Stop hooks with reservoir-check ninth; the new hook does not run until registered there. skills/coda/SKILL.md carries the three-row survey table and advertises a four-step ritual. Third file-table omission in this epic after S3 O1 and S4 O11."
    disposition: accepted
    disposition_rationale: "Both added, and the ordering guarantee is stated where it lives. The Mast's hook is registered BEFORE reservoir-check so precedence and order agree rather than depending on precedence alone. Three file-table omissions in four slices is itself the finding: section 6 now lists every file the change cannot land without, including the ones only a scenario would have caught."
  - id: O5
    category: specification quality
    severity: high
    claim: "'80% of the way from session start to hard_stop_hour' is not computable as stated: started_at is UTC and hard_stop_hour is local, started_at is deliberately never reset across resume/clear/compact, and nothing is defined for a session starting after the line or a stop hour past midnight."
    evidence: "registry_touch writes started_at with date -u and its comment says it never resets. templates/pacts.md documents hard_stop_hour as local 24-hour. A session resumed the next morning reports yesterday's start, so the fraction is already past 80% at breakfast."
    disposition: accepted
    disposition_rationale: "The fraction is replaced by a lead time: approaching fires 30 minutes before hard_stop_hour, declarable as approaching_lead_minutes. A fraction needs two endpoints and only one of them is honest — the line the human drew. The other was a UTC timestamp deliberately frozen across resume, which would have fired the notice on resume every morning. A lead time needs one endpoint, is in the same frame as the value it measures against, and has no behaviour to define for midnight or for a session that starts late."
  - id: O6
    category: risk
    severity: critical
    claim: "The note store's own worked example carries a machine-authored claim about the person's conduct — 'continued past the 20:00 stop by choice' — timestamped identically to the notice that fired, with no stated author or trigger."
    evidence: "Spec 4's example shows both lines at 2026-08-12T20:00:00Z, so whatever wrote the second wrote it before the human had done anything. Section 4.4's judges-nothing condition and section 5.1's observed flag are both false of it. sentinel-design: 'Who authored the claim? If the agent did, it is about the person.'"
    disposition: accepted
    disposition_rationale: "The store records only what fired. There is no continued-by-choice line, because nothing observes a choice — continuing is the absence of stopping, and reading intent into silence is exactly what the boundary forbids. The Coda asks whether the human wants to record anything about the boundary, and their answer is the only account that exists. This also dissolves O10 entirely: there is no machine sentence left to accept by default."
  - id: O7
    category: risk
    severity: high
    claim: "The prune sits behind the same self-gate as everything else, so a human who deletes or breaks their Budgets block after using the feature leaves note files nothing will ever remove — the bounded condition fails precisely on the opt-out path."
    evidence: "Spec 4.3 exits 0 before touching the filesystem; section 6 gives mast-boundary-check.sh as the only home of the prune. Contrast session-registry-sweep.sh, whose registry_prune is unconditional for every user. sentinel-design: 'A record with no expiry is an archive.'"
    disposition: accepted
    disposition_rationale: "The prune runs unconditionally, before the self-gate, exactly as the registry's does. The janitor is separable from the opt-in and must be: the one path where a human has withdrawn consent is the one path where leftover state matters most, and gating the cleanup behind the feature meant deleting your pact left your history behind forever."
  - id: O8
    category: implementation
    severity: high
    claim: "The same unspecified lease must be aggressive enough to bound the store and conservative enough to hold the once-only notice state for a whole session; on the default 12-hour lease a long session loses its notice state and re-fires reached."
    evidence: "A notes file has no heartbeat and is appended to only on a boundary event, so whatever the lease measures from stops being renewed once the notices are done. S3's O3 named this door: 'if it is mtime under stale_after_hours, a long quiet session loses its notice state the same way.'"
    disposition: accepted
    disposition_rationale: "The notes file is touched on every Stop while its session is live, exactly as the registry entry is — the same heartbeat shape, for the same reason. A live session's notes never age out; a dead session's do. That makes one lease serve both jobs without compromise, and it is the mechanism S1 already proved rather than a second invention."
  - id: O9
    category: implementation
    severity: high
    claim: "The store is keyed by session id, but the two consumers are commands, and no channel exists by which a command learns the current session id."
    evidence: "Every shipped reader extracts session_id from hook stdin JSON; verified no command in the plugin reads it and no session environment variable exists anywhere in the repo. The newest-file workaround fails in exactly the multi-session world this epic exists for."
    disposition: accepted
    disposition_rationale: "Keyed by repo rather than session. A command knows its working directory, so everything that touches the store can name it. Boundary events concern a pact that is machine-global and a person who is singular, and the Coda closes a session in a repo — which is the scope it can actually address. Per-session isolation is not lost so much as never achievable: the commands could not have honoured it."
  - id: O10
    category: specification quality
    severity: high
    claim: "Section 5.4 offers the note's machine-authored content as the starting point for a sentence that lands in a committed, permanently archived file, and defines no behaviour for the human accepting it verbatim."
    evidence: "Spec 5.4 offers 'the note's plain content as a starting point'; section 4's plain content is 'continued past the 20:00 stop by choice'. Section 7 forbids a machine-authored sentence in a committed file; A2 does not distinguish authoring from accepting."
    disposition: accepted
    disposition_rationale: "Dissolved by O6. With no inference in the store there is no machine sentence to offer, so the accept-the-default path cannot exist. The Coda asks an open question about a fact — a boundary was passed — and whatever the human says is the whole of the record."
  - id: O11
    category: scope
    severity: high
    claim: "The two surfaces S4's O7 corrected to say the override is NOT recorded still say so, and neither appears in section 6 or section 9."
    evidence: "templates/pacts.md: 'What you say in answer is not written down anywhere yet.' reference/pacts-format.md carries the matching correction. Both become false with this slice, and the template is where the human decides whether to write strict at all."
    disposition: accepted
    disposition_rationale: "Both corrected, and both added to the file list. The carve-out's fourth condition is disclosed-and-declinable, and the place a person actually decides is the pact template — not the hooks reference. S4's own reasoning applies unchanged and in reverse."
  - id: O12
    category: specification quality
    severity: medium
    claim: "Consumption semantics are undefined in three ways: what a second /coda reports for events appended after consumed-by-coda, where in the ritual the marking happens, and what marking means on the abandon path."
    evidence: "Spec 4.1 claims idempotence without saying about what; section 5.3 names the actor and not the step; commands/coda.md's stopping section commits to naming everything written, and a consumption mark is a durable side effect it does not know about."
    disposition: accepted
    disposition_rationale: "Largely dissolved by O6 — with only fired-events in the store there is far less to reconcile — and the remainder is defined: marking happens at step 7, with the reflection, so a human who stops before it has consumed nothing; events after a mark are reported by the next close; and the abandon path names the mark among what was written, since it is now one of the few things that was."
---
# Objection record — Cadence Sentinels S3b (spec mode)

Twelve objections: three critical, eight high, one medium. The concentration is
a property of the slice rather than of the spec's care — this is the seam three
slices deferred into, and it inherits eight adjudicated objections it must
discharge rather than restate.

**Dispatcher verification note (2026-08-12).** Three claims were checked against
shipped code before recording, and all three held.

`reservoir-check.sh` carries **zero** occurrences of any once-per-session guard
and persists nothing by charter, so it re-emits on every `Stop` firing while a
threshold stays crossed. No command in the plugin reads `session_id`, and no
session environment variable exists anywhere in the repo. And §4's own worked
example timestamps `continued past the 20:00 stop by choice` **identically** to
the notice that fired — so whatever wrote it wrote it before the human had done
anything at all.

**The three that reshaped the slice.**

**O1** inverted the rail's purpose. It was built to reduce accumulated pressure
and, on the shipped code, it protected the source of it: the Warden repeats
every turn, the Mast's notice arrives once, and first-claim-wins with the Warden
ordered first meant the once-only message never arrived at all. Precedence now
replaces registration order.

**O6** is the sharpest finding in the epic so far, because the offending line
was in the spec's own illustration of what the store may hold. Nothing observes
a choice — continuing is the absence of stopping — and reading intent into
silence is exactly what the boundary forbids. The store now records only what
fired, which dissolves O10 entirely.

**O9** blocked implementation outright. The store was keyed by something its
own writers cannot know. Re-keyed by repo, which every participant can name.

**Inheritance audit.** S3's O2 is discharged by §4.2, and MN4's
transitive-source-closure assertion is stronger than S1's R9. S3's O11 is
discharged by §4.3 — and the self-gate it installed created O7. S3's O4 is now
discharged for both halves, the second by replacing the fraction outright. S3's
O3 is discharged for the consumption path by §4.1 and for the pruning path by
O8's heartbeat. S3's O8 is engaged by §3 and re-scoped by O1 and O2. S3's O9 is
resolved for the reflection fragment and, after O6, no longer re-enters in the
store. S4's deferred override is built and its two corrected surfaces are
corrected back. Nothing inherited is silently dropped.

## Explicitly not objecting to

- **The shared advisory rail's existence, and the coordination line in
  `reservoir-check.sh`.** Disposed at the design gate; O1 and O2 challenge the
  rail's period and priority, not whether it should exist.
- **Consumption marking rather than deleting.** Disposed, and §4.1's idempotence
  argument is a genuine improvement on the first design.
- **The two-library split.** Exactly S1's shape for S1's reason, and MN4 is
  stronger than S1's R9.
- **Only `hard_stop_hour` producing notices.** The right half of S3's O4,
  correctly discharged.
- **That the Coda writes the human's sentence rather than a machine verdict.**
  The right resolution of S3's O9.
- **Version and rollout arithmetic**, and the unchanged component counts.
- **Language discipline.** No instance of "addiction" or "dopamine", no fatigue
  claim, no score.
