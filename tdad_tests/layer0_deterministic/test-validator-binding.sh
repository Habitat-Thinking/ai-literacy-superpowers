#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for validator binding
# (spec 2026-08-25-validator-binding-design.md; V1-V9 -> A1-A9).
#
# THE FIXTURES ARE THE #553 EVIDENCE TABLE. Each row was observed returning True
# from has_validator against the real repository before this change, so the suite
# is a direct transcription of the loophole rather than a guess at its shape.
#
# V4 IS THE ONE THAT MUST STAY TRUE. It is easy to write a check so strict that
# nothing reaches `validated` and call the problem solved; that would replace an
# over-claiming report with a useless one.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$REG" ] || fail "harness registrar not found at $REG"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
mkdir -p harness/decisions scripts docs

# Artifacts a validator might plausibly (and implausibly) name.
printf '# Readme\n' > README.md
printf '# Changelog\n' > CHANGELOG.md
printf 'node_modules\n' > .gitignore
printf '# doc\n' > docs/index.md
printf '#!/usr/bin/env python3\nprint("unrelated")\n' > scripts/unrelated.py
printf '#!/usr/bin/env python3\n# Enforces HDR-2026-08-25-bound\nprint("ok")\n' > scripts/bound.py
printf '#!/usr/bin/env bash\n# Enforces HDR-2026-08-25-bound\n' > scripts/bound.sh
# No recognised suffix, but executable — V5.
printf '#!/usr/bin/env bash\n# Enforces HDR-2026-08-25-bound\n' > scripts/bound-noext
chmod +x scripts/bound-noext

hdr() {  # hdr <slug> <validator-yaml>
  local slug="$1" validator="$2"
  cat > "harness/decisions/HDR-2026-08-25-$slug.md" <<EOF
---
id: HDR-2026-08-25-$slug
title: A rule about $slug
status: accepted
classification: agent-instruction
enforcement: validated
surfaces: [ci]
provisional: false
target: HARNESS.md
$validator
evidence:
  - harness/assay/2026-08-25T08-08Z-assay.md#finding-1
cost: |
  Written by a human.
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: harness/assay/2026-08-25T08-08Z-assay.md
approver: tester
approved_at: 2026-08-25T10:00Z
supersedes: null
superseded_by: null
---

## Finding

Observed.

## Rule

\`\`\`\`markdown
- **Rule**: Something.
\`\`\`\`

## Cost

Written by a human.
EOF
}

# achieved + reason for one record, straight from the library.
probe() {
  "$PY" - "$1" "${2:-}" <<'PYEOF'
import importlib.util, sys, os
spec = importlib.util.spec_from_file_location("reg", os.environ["REG"])
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
records = m.load_records(".")
rec = next(r for r in records if r.id == sys.argv[1])
supports = (sys.argv[2].split(",") if len(sys.argv) > 2 and sys.argv[2]
            else ["validated", "blocked"])
surfaces = {"ci": {"targets": [".github/workflows/"], "supports": supports}}
rows = m.enforcement_rows(rec, surfaces, ".")
print(f"{rows[0]['achieved']}|{rows[0]['reason']}")
PYEOF
}
export REG

expect() {  # expect <slug> <achieved> <reason-substring> <label>
  hdr "$1" "$2" >/dev/null 2>&1 || true
  local got; got="$(probe "HDR-2026-08-25-$1")"
  local achieved="${got%%|*}" reason="${got#*|}"
  [ "$achieved" = "$3" ] \
    || fail "$5: expected achieved='$3', got '$achieved' (reason: $reason)"
  if [ -n "$4" ]; then
    printf '%s' "$reason" | grep -qi -- "$4" \
      || fail "$5: reason must mention '$4', got '$reason'"
  fi
  echo "$5"
}

# === V1: documents must not reach validated ==================================
for doc in README.md CHANGELOG.md .gitignore; do
  slug="doc-$(printf '%s' "$doc" | tr -d '.' | tr '[:upper:]' '[:lower:]')"
  hdr "$slug" "validator: $doc"
  got="$(probe "HDR-2026-08-25-$slug")"
  [ "${got%%|*}" != "validated" ] \
    || fail "V1: '$doc' reached validated ($got)"
  rm -f "harness/decisions/HDR-2026-08-25-$slug.md"
done
echo "V1 ok (README.md, CHANGELOG.md, .gitignore rejected)"

# === V2: a list passes only when every entry resolves ========================
hdr listpartial "validator: [docs/index.md, nope/missing.py]"
got="$(probe HDR-2026-08-25-listpartial)"
[ "${got%%|*}" != "validated" ] || fail "V2: partial list reached validated ($got)"
printf '%s' "$got" | grep -qi 'not found' \
  || fail "V2: reason should name the missing path, got '$got'"
rm -f harness/decisions/HDR-2026-08-25-listpartial.md
echo "V2 ok (partial list rejected, missing path named)"

# === V3: a runnable script that does not name the record =====================
hdr unbound "validator: scripts/unrelated.py"
got="$(probe HDR-2026-08-25-unbound)"
[ "${got%%|*}" != "validated" ] || fail "V3: unrelated script reached validated ($got)"
printf '%s' "$got" | grep -qi 'name' \
  || fail "V3: reason should say the validator does not name the record, got '$got'"
rm -f harness/decisions/HDR-2026-08-25-unbound.md
echo "V3 ok (unrelated runnable script rejected)"

# === V4: a runnable script that names the record DOES reach validated ========
# The suite must prove the check is not merely strict.
expect bound "validator: scripts/bound.py" validated "" \
  "V4 ok (bound .py reaches validated)"
rm -f harness/decisions/HDR-2026-08-25-bound.md
hdr bound "validator: [scripts/bound.py, scripts/bound.sh]"
got="$(probe HDR-2026-08-25-bound)"
[ "${got%%|*}" = "validated" ] || fail "V4b: fully-resolving bound list rejected ($got)"
rm -f harness/decisions/HDR-2026-08-25-bound.md
echo "V4b ok (list of bound validators reaches validated)"

# === V5: the executable bit qualifies a path with no recognised suffix =======
hdr bound "validator: scripts/bound-noext"
got="$(probe HDR-2026-08-25-bound)"
[ "${got%%|*}" = "validated" ] || fail "V5: executable with no suffix rejected ($got)"
rm -f harness/decisions/HDR-2026-08-25-bound.md
echo "V5 ok (executable bit qualifies)"

# === V6: each state has its own reason =======================================
hdr nonrunnable "validator: docs/index.md"
R1="$(probe HDR-2026-08-25-nonrunnable)"; rm -f harness/decisions/HDR-2026-08-25-nonrunnable.md
hdr missing "validator: scripts/absent.py"
R2="$(probe HDR-2026-08-25-missing)";     rm -f harness/decisions/HDR-2026-08-25-missing.md
hdr none ""
R3="$(probe HDR-2026-08-25-none)";        rm -f harness/decisions/HDR-2026-08-25-none.md
printf '%s' "$R1" | grep -qi 'runnable'   || fail "V6: non-runnable needs its own reason: $R1"
printf '%s' "$R2" | grep -qi 'not found'  || fail "V6: missing needs its own reason: $R2"
printf '%s' "$R3" | grep -qi 'no validator declared' || fail "V6: absent field needs its own reason: $R3"
[ "$R1" != "$R2" ] && [ "$R2" != "$R3" ] \
  || fail "V6: states must not collapse to one reason"
echo "V6 ok (four states, four reasons)"

# === V7: an undeclared validator behaves exactly as before ===================
# The ladder decides which downgrade applies, and this change must not move it.
# On a surface supporting `advisory` an unvalidated rule lands there; on one that
# does not (ci supports only validated/blocked) it lands on `none`.
hdr none ""
got="$(probe HDR-2026-08-25-none advisory,validated,blocked)"
[ "${got%%|*}" = "advisory" ] \
  || fail "V7: surface supporting advisory should downgrade to advisory, got '$got'"
got="$(probe HDR-2026-08-25-none validated,blocked)"
[ "${got%%|*}" = "none" ] \
  || fail "V7: surface without advisory should give none, got '$got'"
rm -f harness/decisions/HDR-2026-08-25-none.md
echo "V7 ok (ladder unchanged: advisory where supported, none where not)"

echo "validator binding: all checks passed (V1-V7)"
