---
spec: docs/superpowers/specs/2026-06-17-affordance-runtime-recorder-design.md
date: 2026-06-17
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: specification quality
    severity: high
    claim: "Changing the runtime-data filename from the committed .json to .ndjson breaks the O3 reference hardcoded in HARNESS.md, the parent spec, the explanation doc, and the step-3 spec."
    evidence: "Spec names .ndjson; templates/HARNESS.md header + parent O3 + docs all say .json."
    disposition: amend
    disposition_rationale: "Keep the filename observability/affordance-invocations.json (the established O3 reference) with NDJSON content (one JSON object per line). The extension stays .json so the human-facing section-header pointer remains valid; the spec states the content is line-delimited JSON."
  - id: O2
    category: implementation
    severity: high
    claim: "The Bash 'program' = first whitespace word can leak secrets/paths (VAR=secret gh ..., /abs/path/script.sh), defeating the no-arguments/no-secrets guarantee."
    evidence: "Only extraction rule is 'first whitespace-delimited word'; no normalisation."
    disposition: amend
    disposition_rationale: "Sanitise the program token: strip leading KEY=VALUE env-var prefixes, take the program word, basename it (a path becomes just the script name), and record it ONLY if it matches a safe program-name shape (^[A-Za-z0-9._-]+$). Anything else (quotes, slashes after basename, subshell/pipeline syntax) records program:null. The recorder never writes a raw path or an env assignment."
  - id: O3
    category: implementation
    severity: high
    claim: "Program-equality Bash matching over-matches: Bash(gh *) and Bash(gh pr *) both match any program:'gh' tuple, contradicting the steps-4+5 string-equality contract and masking a dead narrow grant."
    evidence: "Spec admits the gh-pr-vs-gh distinction cannot be made from the program alone."
    disposition: amend
    disposition_rationale: "Accept program-granular Bash matching as a documented limitation of the minimal-tuple choice, and make it CONSERVATIVE: an observed program marks EVERY Bash affordance sharing that program as observed (a false-alive, never a false-dead). The dead-inventory output states explicitly that Bash matching is program-coarse and does not distinguish narrow from broad grants — a report-only advisory that errs toward not-flagging. Exact matching holds for MCP/named tools."
  - id: O4
    category: risk
    severity: high
    claim: "'Records no arguments' is asserted but no mechanism enforces it; an env-var-prefixed or path-form first token writes a secret/path into the file."
    evidence: "Privacy guarantee stated three times; only rule is 'first word'."
    disposition: amend
    disposition_rationale: "Resolved by O2's sanitisation (strip KEY=VALUE, basename, shape-allowlist, else null). The spec specifies the exact normalisation so the no-secrets property is delivered by code, not merely declared, with an acceptance scenario for the env-prefix and path-form cases."
  - id: O5
    category: risk
    severity: high
    claim: "Gitignoring the file means the freshness/dead-inventory checks only ever run on one developer's machine on demand — the local-only governance gap step 6 explicitly fixed by wiring gc.yml."
    evidence: "Spec: 'run meaningfully only on a developer machine ... not the CI cron'."
    disposition: amend
    disposition_rationale: "Honest reframe (a direct consequence of the user-confirmed gitignored fork): the recorder and its checks are LOCAL, per-machine OBSERVABILITY, not a CI governance control — stated in the value proposition, not a footnote. Unlike step 6 (where HARNESS.md is committed so the cron could read it), here the DATA file is gitignored, so a gc.yml step would always self-skip and is deliberately NOT added. The checks run via the on-demand harness-gc agent locally. A future committed-aggregate step could add a team/CI view."
  - id: O6
    category: risk
    severity: high
    claim: "The jq dependency is a silent-no-op trap: no jq => recorder writes nothing silently => freshness reports stale forever and dead-inventory flags everything dead, with no breadcrumb."
    evidence: "Spec: recorder exits silently if jq absent; existing hooks deliberately use grep/sed."
    disposition: amend
    disposition_rationale: "The RECORDER uses grep/sed + printf (no jq), matching the established hook baseline (markdownlint-check.sh) — removing the trap. The ANALYZER (a deterministic script, not a hook) may use jq, but reports a clear 'jq not installed' line rather than silently flagging everything, so its verdict is interpretable."
  - id: O7
    category: premise
    severity: medium
    claim: "The marquee 'invoker' field is best-effort and likely 'unknown', so the feature's differentiator may ship non-functional."
    evidence: "Spec never verifies PostToolUse exposes the invoker."
    disposition: amend
    disposition_rationale: "Reframe the value around the dead-inventory question ('did this declared affordance fire?'), which does not depend on invoker. invoker is recorded best-effort as a bonus; the spec no longer presents 'which agent invoked it' as the headline. If a future payload reliably exposes the invoker, the field is already there."
  - id: O8
    category: risk
    severity: medium
    claim: "'NDJSON is concurrency-safe' is asserted; concurrent appends exceeding the atomic-append size can interleave mid-line, so corruption is not confined to the trailing line."
    evidence: "No mention of PIPE_BUF / O_APPEND atomicity bounds."
    disposition: amend
    disposition_rationale: "Keep the tuple small (well under 512 bytes / PIPE_BUF, so a single O_APPEND write is atomic on POSIX), and have the analyzer skip ANY unparseable line, not only the trailing one. Both stated."
  - id: O9
    category: implementation
    severity: medium
    claim: "'Never delays the session' is overstated for a per-tool-call hook doing a jq spawn + append on every call."
    evidence: "jq per call; PostToolUse fires on every tool."
    disposition: amend
    disposition_rationale: "Resolved largely by O6 (no jq in the recorder): the per-call cost is a grep/sed extraction + one short append, on par with the existing PreToolUse markdownlint hook. Stated as the cost, not asserted as negligible."
  - id: O10
    category: risk
    severity: medium
    claim: "The file grows unbounded with no compaction; the analyzer reads only the last N days, so old bytes are pure dead weight."
    evidence: "Recorder appends, never rewrites; no rotation rule."
    disposition: amend
    disposition_rationale: "The recorder self-trims: when the file exceeds a line cap (e.g. 5000 lines), it keeps the last N lines (cheap tail) before/after appending, bounding size while retaining well more than the 30-day dead-inventory window for a normal machine."
  - id: O11
    category: specification quality
    severity: medium
    claim: "Hook affordances (Permission hooks.<Trigger>) are structurally unobservable by a PostToolUse recorder, so every Mode: hook affordance is always flagged dead inventory."
    evidence: "Matching defined only for MCP/named tools and Bash programs; parent declares hook affordances."
    disposition: amend
    disposition_rationale: "Dead-inventory EXCLUDES Mode: hook affordances (a PostToolUse recorder cannot observe hook firings), consistent with steps-4+5 excluding hooks from the permission relation. Stated explicitly so a hook affordance is never mis-flagged as dead."
  - id: O12
    category: scope
    severity: medium
    claim: "The spec supersedes the parent's step-7 wording (SessionEnd, .json) without flagging the divergence the parent's downstream references depend on."
    evidence: "Parent step-7: 'SessionEnd hook ... affordance-invocations.json'; this spec: PostToolUse, NDJSON."
    disposition: amend
    disposition_rationale: "Add an explicit note that this spec supersedes the parent's step-7 hook-surface wording (PostToolUse, user-confirmed) while KEEPING the .json filename (O1), so the parent's section-header reference and freshness-constraint exemplar stay coherent."
---

# Objection record — affordance runtime recorder (spec mode)

Twelve objections (6 high, 6 medium); no critical. None re-opens the three
user-confirmed forks (hook surface, gitignored storage, minimal tuple) — they
are robustness/correctness refinements within them. All adjudicated 2026-06-17
— every objection **amend**. The load-bearing fixes: keep the .json filename
(O1); sanitise the Bash program token so the no-secrets guarantee is real
(O2/O4); recorder uses grep/sed not jq, removing the silent-no-op trap (O6);
exclude hooks from dead-inventory (O11); honest local-observability framing for
the gitignored consequence (O5); conservative program-granular Bash matching
(O3); bounded file via self-trim (O10).

## Explicitly not challenged

- The PostToolUse hook surface (user-confirmed; verified to expose tool_name).
- Gitignored per-machine storage (user-confirmed answer to cross-machine merge).
- The minimal tuple / no-arguments / no-identity privacy stance (the intent is
  right; O2/O4 are that the design must deliver it, not that it is wrong).
- The report-only, exit-0-always, --today-hermetic analyzer discipline.
- The example-marker skip (inherited, anchored, from the step-6 code-mode fix).
- NDJSON as the content shape for append-only event data.
