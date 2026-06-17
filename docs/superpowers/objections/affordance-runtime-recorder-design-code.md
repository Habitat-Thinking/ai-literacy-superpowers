---
spec: docs/superpowers/specs/2026-06-17-affordance-runtime-recorder-design.md
date: 2026-06-17
mode: code
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: risk
    severity: medium
    claim: "The self-trim's non-atomic read-then-mv (with a fixed $file.tmp name) races under concurrent PostToolUse hooks, reintroducing the concurrency hazard the append-only design avoided and able to lose committed lines."
    evidence: "recorder trim: tail > \"$file.tmp\" && mv; fixed tmp name, no lock."
    disposition: amend
    disposition_rationale: "Use a unique tmp name ($file.$$.<rand>.tmp) so concurrent trims cannot clobber each other's tmp or read a half-written one. Trim is best-effort on a per-machine file; bounded line loss under a rare simultaneous trim is acceptable, but the half-written-tmp read and same-name clobber are removed."
  - id: O2
    category: implementation
    severity: medium
    claim: "The Layer-0 recorder test proves no-leak only for benign shapes; escaped-quote-in-first-token, embedded newline, hostile session_id, and emitted-JSON validity are unverified."
    evidence: "test covers only easy inputs; never parses the emitted line as JSON."
    disposition: amend
    disposition_rationale: "Add adversarial recorder tests: a command with an escaped quote before the program, an embedded newline, a session_id carrying JSON metacharacters (must be sanitised to unknown), and an assertion that every emitted line parses as valid JSON (jq -e)."
  - id: O3
    category: risk
    severity: medium
    claim: "The `\"command\":\"[^\"]*\"` grep truncates at the first escaped quote, so a command whose program word follows a quoted segment records program:null — biasing dead-inventory toward false-DEAD (fail-safe for privacy, an accuracy bug)."
    evidence: "grep [^\"]* stops at an escaped quote; the program becomes null."
    disposition: acknowledge
    disposition_rationale: "Fail-SAFE: it nulls, never leaks — the A2/A4 privacy guarantee is unaffected. Robust JSON-string parsing in grep/sed (no jq, per A6) is fragile, and a leading-quoted-segment command is uncommon (real programs are bare: gh, git, npx). Documented as a known accuracy limitation in the reference page (a false-null program may cause a false-DEAD); the dead-inventory output already warns Bash matching is coarse and errs toward not-flagging."
  - id: O4
    category: risk
    severity: low
    claim: "wc -l on every call plus a full-file tail near the cap makes per-call cost O(file size), contradicting the 'single append, negligible' claim."
    evidence: "wc -l unconditional; full tail+mv every call while over cap."
    disposition: amend
    disposition_rationale: "Resolved with O1: gate the trim on an O(1) file-size check (stat -f%z / -c%s) against a byte cap, so the common path is a single append + one stat; the full tail+mv runs only when the file genuinely exceeds the byte cap."
  - id: O5
    category: implementation
    severity: low
    claim: "The hook matcher `mcp__.*` (unanchored regex) and the in-script `mcp__*` (anchored glob) use different match languages, so they disagree on a hypothetical `xmcp__y` tool."
    evidence: "hooks.json matcher regex vs recorder case glob."
    disposition: acknowledge
    disposition_rationale: "The in-script case-gate (Bash|mcp__*) is the authoritative filter; the matcher is only a coarse pre-filter that at worst wastes a no-op spawn on a non-existent substring-mcp tool. No real tool name contains mcp__ as a non-prefix substring. Not worth changing the matcher (and over-anchoring a Claude Code matcher risks breaking it)."
  - id: O6
    category: risk
    severity: low
    claim: "A quoted env value containing a space (FOO=\"a b\" gh ...) is not stripped, so the program records null."
    evidence: "the =[^[:space:]]* guard cannot span a quoted internal space."
    disposition: acknowledge
    disposition_rationale: "Fail-safe (nulls, never leaks); covered by the same documented accuracy-limitation note as O3. Quoted env-value prefixes are uncommon."
  - id: O7
    category: implementation
    severity: low
    claim: "The analyzer's MCP-prefix grep regex escaping omits \\, +, {, } — inert for the MCP naming charset but fragile if presented as general-purpose."
    evidence: "sed escape set omits several metacharacters."
    disposition: amend
    disposition_rationale: "Replace the grep -E prefix regex with a shell glob prefix match (case \"$tool\" in \"$prefix\"*) — no regex, no escaping concern, exact prefix semantics."
  - id: O8
    category: implementation
    severity: low
    claim: "The analyzer derives the Bash program from the declared pattern without basename, so a path-form declared pattern (Bash(/usr/local/bin/foo *)) never matches its recorded invocation (program foo)."
    evidence: "recorder basenames the program; analyzer takes the literal first token."
    disposition: amend
    disposition_rationale: "basename the analyzer-side program too, mirroring the recorder, so a path-qualified declared Bash pattern matches its observed program."
---

# Objection record — affordance runtime recorder (code mode)

Eight objections; **no critical, no high**. The privacy-critical claim survived
scrutiny — the diaboli could construct no input that emits a secret, path,
argument, or invalid JSON (the strip-env → basename → `^[A-Za-z0-9._-]+$`
allowlist → else-null pipeline is genuinely fail-safe, and every interpolated
JSON field is shape-gated). Adjudicated 2026-06-17: five **amend** (unique-tmp
+ O(1)-gated trim, adversarial privacy tests, glob MCP-prefix, basename the
analyzer program), three **acknowledge** (O3/O6 fail-safe accuracy limits
documented; O5 matcher pre-filter harmless).

## Explicitly not challenged

- JSON validity of the emitted tuple (every field shape-gated or literal null).
- The core no-secrets/no-args privacy property (fail-safe; verified).
- The never-blocks / always-exit-0 guarantee.
- The no-jq-in-recorder requirement (A6).
- The analyzer's `-R 'fromjson?'` NDJSON tolerance and UTC date math (step-6 reuse).
- Hook exclusion + anchored example-marker in the analyzer parser.
- Gitignore / LOCAL-not-CI framing (A5 honesty met; no step-8 leak).
