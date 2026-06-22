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
# Design decisions (spec §7, human-approved at the S2 GATE):
#   - INV-1 = layered "Option C". Strip comments first, then fail on ANY of the
#     four durable filenames appearing in executable (non-comment) code —
#     whether or not the specific write call is recognised. This kills the
#     false positive (a literate preamble that merely *names* AGENTS.md passes)
#     and the false negative (a write expressed an unenumerated way), and is
#     robust to runtime-API drift. The consequence templates must respect:
#     durable artefacts are reached only through harness-provided indirection,
#     never by spelling the filename in code.
#   - INV-2 = declared markers "Option I1". A template annotates an
#     untrusted-content reader with `// @untrusted-reader: true` and declares
#     its `// @tools: [...]`; the lint fails if that set names a high-privilege
#     tool (write, edit, bash, commit, push). Passes vacuously when no
#     untrusted reader is declared.
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
      if printf '%s\n' "$code" | grep -qE "${name}\.md"; then
        echo "INV-1 VIOLATION: $f writes the durable artefact ${name}.md in executable code — workflows may never write durable artefacts directly (INV-1)."
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
      /@workflow-agent:/                     { untrusted = 0 }
      /@untrusted-reader:[ \t]*true/         { untrusted = 1 }
      /@untrusted-reader:[ \t]*false/        { untrusted = 0 }
      /@tools:/ {
        if (untrusted == 1) {
          lb = index($0, "["); rb = index($0, "]")
          if (lb > 0 && rb > lb) {
            inner = substr($0, lb + 1, rb - lb - 1)
            m = split(inner, arr, /[, ]+/)
            for (k = 1; k <= m; k++) {
              t = arr[k]; gsub(/[^a-zA-Z]/, "", t)
              if (t == "write" || t == "edit" || t == "bash" || t == "commit" || t == "push") {
                printf("INV-2 VIOLATION: %s — an @untrusted-reader agent is granted the high-privilege tool: %s. Quarantine it; act via a separate trusted agent (INV-2).\n", file, t)
                bad = 1
              }
            }
          }
        }
      }
      END { if (bad == 1) exit 1 }
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
