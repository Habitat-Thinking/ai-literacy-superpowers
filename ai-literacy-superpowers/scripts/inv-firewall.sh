#!/usr/bin/env bash
#
# inv-firewall.sh — the deterministic teeth of the dynamic-workflows
# governance invariants (INV-1 and INV-2). One matcher, invoked two ways:
# a PR-time GitHub gate (.github/workflows/dynamic-workflows-firewall.yml)
# and a Layer-0 deterministic test with red/green fixtures. Keeping the logic
# in a single script means both callers enforce exactly the same rule.
#
# Why this exists. A dynamic workflow is ephemeral and generated; the durable
# artefacts (HARNESS.md, AGENTS.md, CLAUDE.md, MODEL_ROUTING.md) are
# human-curated. INV-1 forbids a workflow from writing them directly. INV-2
# quarantines untrusted-content readers from high-privilege tools. Both are
# stated for agents in the skill's governance.md; this script is what makes
# them fail CI rather than merely advise.
#
# Design decisions (spec §7, human-approved at the S2 GATE; hardened after the
# S2 adversarial review closed three bypasses):
#   - INV-1 = layered "Option C". Strip comments first, then fail if any durable
#     STEM (HARNESS, AGENTS, CLAUDE, MODEL_ROUTING) survives into executable
#     code as a whole word — independent of the `.md` suffix. Matching the stem
#     rather than the full filename defeats name-splitting ("AGENTS" + ".md",
#     `${dir}/AGENTS.md`, ["AGENTS",".md"].join("")), and `grep -w` keeps
#     SCREAMING_SNAKE variables (MODEL_ROUTING_TABLE) safe. A literate preamble
#     that merely *names* a durable artefact passes (it is stripped first). The
#     consequence templates must respect: durable artefacts are reached only
#     through harness-provided indirection, never spelled in code.
#   - INV-2 = declared markers "Option I1". A template annotates an
#     untrusted-content reader with `// @untrusted-reader: true` and declares
#     its `// @tools: [...]`; the lint fails if that set names a high-privilege
#     tool (write, edit, bash, commit, push, fetch, webfetch). The check is
#     case-insensitive (markers and values), accumulates a multi-line `@tools`
#     list, fails closed on an unterminated list, and is independent of the
#     order of the three markers within an agent block. Passes vacuously when no
#     untrusted reader is declared.
#
# Known limit (by design). This is a deterministic backstop to a human PR
# review, not a sandbox against a hostile author. A durable filename split
# mid-stem ("AGEN" + "TS.md"), constructed from char codes, or written in a
# casing that never forms the uppercase stem token defeats static stem matching
# — closing that needs taint analysis well beyond a grep gate. The real control
# is the discipline the templates model (durable artefacts reached only through
# harness indirection); the firewall catches the natural mistakes, and a human
# reviewer reads the same PR.
#
# Portability: POSIX awk + grep -E only (no gawk/GNU extensions, no `grep -P`,
# no BSD-only date) so the Layer-0 test runs identically on macOS and Linux.
#
# Usage:
#   inv-firewall.sh --check=inv1 <file...>
#   inv-firewall.sh --check=inv2 <file...>
# Exit 0 = clean; non-zero = at least one violation (message on stdout).

set -euo pipefail

CHECK=""
FILES=()
for arg in "$@"; do
  case "$arg" in
    --check=*) CHECK="${arg#--check=}" ;;
    -*) echo "inv-firewall.sh: unknown flag: $arg" >&2; exit 2 ;;
    *) FILES+=("$arg") ;;
  esac
done

if [ -z "$CHECK" ] || [ "${#FILES[@]}" -eq 0 ]; then
  echo "usage: inv-firewall.sh --check=inv1|inv2 <file...>" >&2
  exit 2
fi

# strip_comments — emit <file> with /* ... */ block comments and // line
# comments removed, so the caller sees executable code only. `://` (as in a
# URL) is preserved rather than treated as a line comment.
strip_comments() {
  awk '
    BEGIN { inblock = 0 }
    {
      line = $0; out = ""; i = 1; n = length(line)
      while (i <= n) {
        two = substr(line, i, 2)
        if (inblock) {
          if (two == "*/") { inblock = 0; i += 2 } else { i += 1 }
          continue
        }
        if (two == "/*") { inblock = 1; i += 2; continue }
        if (two == "//") {
          if (substr(line, i - 1, 1) == ":") { out = out two; i += 2; continue }
          break   # rest of line is a comment
        }
        out = out substr(line, i, 1); i += 1
      }
      print out
    }
  ' "$1"
}

check_inv1() {
  local rc=0 f name code
  for f in "${FILES[@]}"; do
    code=$(strip_comments "$f")
    for name in HARNESS AGENTS CLAUDE MODEL_ROUTING; do
      # Match the durable STEM as a whole word in executable code, independent
      # of the `.md` suffix. This is what makes Option C robust against a
      # filename split to dodge the matcher — "AGENTS" + ".md",
      # `${dir}/AGENTS.md`, ["AGENTS", ".md"].join("") all still contain the
      # bare stem token. The stems never appear legitimately in template code:
      # every real mention is in a literate preamble and already stripped, so a
      # stem surviving into executable code is itself the smell. `grep -w` keeps
      # SCREAMING_SNAKE variables safe (MODEL_ROUTING_TABLE is a different word).
      if printf '%s\n' "$code" | grep -qwE "$name"; then
        echo "INV-1 VIOLATION: $f references the durable artefact ${name}.md in executable code — workflows may never read or write durable artefacts directly; reach them through harness indirection (INV-1)."
        rc=1
      fi
    done
  done
  return "$rc"
}

check_inv2() {
  local rc=0 f
  for f in "${FILES[@]}"; do
    if ! awk -v file="$f" '
      # High-privilege tool comparison is case-insensitive (Bash == bash) and
      # the @tools list is accumulated across continuation lines, so neither
      # casing nor line-wrapping can smuggle a tool past the check. The network
      # tools (fetch/webfetch) honour governance.md s "no network mutation".
      function check_tools(s,   lb, rb, inner, m, arr, k, t) {
        lb = index(s, "["); rb = index(s, "]")
        if (lb > 0 && rb > lb) {
          inner = substr(s, lb + 1, rb - lb - 1)
          m = split(inner, arr, /[, ]+/)
          for (k = 1; k <= m; k++) {
            t = arr[k]; gsub(/[^a-zA-Z]/, "", t); t = tolower(t)
            if (t == "write" || t == "edit" || t == "bash" || t == "commit" || t == "push" || t == "fetch" || t == "webfetch") {
              printf("INV-2 VIOLATION: %s — an @untrusted-reader agent is granted the high-privilege tool: %s. Quarantine it; act via a separate trusted agent (INV-2).\n", file, t)
              bad = 1
            }
          }
        }
      }
      function reset() { untrusted = 0; toolsseen = 0; toolsbuf = ""; collecting = 0 }
      BEGIN { reset() }
      # Marker detection is case-insensitive (via U = toupper) so uppercasing the
      # marker keywords cannot escape the lint, just as uppercasing a tool value
      # cannot. A new agent block resets state; order of the three markers within
      # a block does not matter — an @tools seen before the reader flag is
      # buffered and re-checked when the flag arrives.
      { U = toupper($0) }
      U ~ /@WORKFLOW-AGENT:/                { reset() }
      U ~ /@UNTRUSTED-READER:[ \t]*TRUE/    { untrusted = 1; if (toolsseen == 1) check_tools(toolsbuf) }
      U ~ /@UNTRUSTED-READER:[ \t]*FALSE/   { untrusted = 0 }
      {
        if (collecting == 1) {
          toolsbuf = toolsbuf " " $0
          if (index($0, "]") > 0) { collecting = 0; toolsseen = 1; if (untrusted == 1) check_tools(toolsbuf) }
          next
        }
      }
      U ~ /@TOOLS:/ {
        if (index($0, "[") > 0 && index($0, "]") > 0) {
          toolsbuf = $0; toolsseen = 1; if (untrusted == 1) check_tools(toolsbuf)
        } else if (index($0, "[") > 0) {
          collecting = 1; toolsbuf = $0
        }
      }
      # Fail closed: an untrusted reader whose @tools list never terminates
      # cannot be verified, so it is a violation rather than a silent pass.
      END {
        if (collecting == 1 && untrusted == 1) {
          printf("INV-2 VIOLATION: %s — an @untrusted-reader agent declares an unterminated @tools list; its privileges cannot be verified. Declare the tools on a closed list (INV-2).\n", file)
          bad = 1
        }
        if (bad == 1) exit 1
      }
    ' "$f"; then
      rc=1
    fi
  done
  return "$rc"
}

case "$CHECK" in
  inv1) check_inv1 ;;
  inv2) check_inv2 ;;
  *) echo "inv-firewall.sh: unknown check: $CHECK (expected inv1 or inv2)" >&2; exit 2 ;;
esac
