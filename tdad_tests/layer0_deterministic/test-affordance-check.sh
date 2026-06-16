#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for harness-affordance-check.sh (affordance chained constraints,
# steps 4+5). The check takes a project-dir argument and reads only project
# settings under it, so every scenario runs against a hermetic fixture dir.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/harness-affordance-check.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

# mkproj <harness-body> <allowlist-json|-> -> echoes a temp project dir.
# allowlist "-" means write no settings file.
mkproj() {
  local dir; dir=$(mktemp -d)
  mkdir -p "$dir/.claude"
  printf '%s\n' "$1" > "$dir/HARNESS.md"
  if [ "$2" != "-" ]; then
    printf '%s\n' "$2" > "$dir/.claude/settings.json"
  fi
  printf '%s' "$dir"
}

# run <dir> <direction> -> sets RC and OUT
run() {
  set +e
  OUT=$("$CHECK" --direction="$2" "$1" 2>&1)
  RC=$?
  set -e
}

REAL='# H
## Affordances
### my-tool
- **Mode**: cli
- **Permission**: `Bash(foo *)` (allowlist)
## Status'

# Scenario 1: no ## Affordances section -> unverified, exit 0.
d=$(mkproj '# H
## Constraints' '{"permissions":{"allow":["Bash(foo *)"]}}')
run "$d" blocking
[ "$RC" -eq 0 ] || fail "no-section should exit 0 (got $RC)"
echo "$OUT" | grep -q "unverified" || fail "no-section should report unverified: $OUT"
rm -rf "$d"

# Scenario 2: only an example-marked entry -> unverified.
d=$(mkproj '# H
## Affordances
### gh-cli
<!-- affordance-example -->
- **Mode**: cli
- **Permission**: `Bash(gh *)` (allowlist)
## Status' '{"permissions":{"allow":["Bash(gh *)"]}}')
run "$d" blocking
[ "$RC" -eq 0 ] || fail "examples-only should exit 0 (got $RC)"
echo "$OUT" | grep -q "unverified" || fail "examples-only should be unverified: $OUT"
rm -rf "$d"

# Scenario 3: real affordance but no readable allowlist -> unverified.
d=$(mkproj "$REAL" '-')
run "$d" blocking
[ "$RC" -eq 0 ] || fail "no-allowlist should exit 0 (got $RC)"
echo "$OUT" | grep -q "unverified" || fail "no-allowlist should be unverified: $OUT"
rm -rf "$d"

# Scenario 4: real affordance missing its permission -> blocking exit 1; advisory exit 0.
d=$(mkproj "$REAL" '{"permissions":{"allow":["Bash(other *)"]}}')
run "$d" blocking
[ "$RC" -eq 1 ] || fail "missing-permission blocking should exit 1 (got $RC)"
echo "$OUT" | grep -q "FAIL: affordance 'my-tool'" || fail "blocking should name the gap: $OUT"
run "$d" advisory
[ "$RC" -eq 0 ] || fail "advisory should always exit 0 (got $RC)"
echo "$OUT" | grep -q "ADVISORY: permission Bash(other \*)" || fail "advisory should flag the ungoverned permission: $OUT"
rm -rf "$d"

# Scenario: hook-mode affordance is skipped (its Permission is a hooks.* registration).
d=$(mkproj '# H
## Affordances
### a-hook
- **Mode**: hook
- **Trigger**: Stop
- **Permission**: `hooks.Stop` entry in `.claude/settings.local.json`
### my-tool
- **Mode**: cli
- **Permission**: `Bash(foo *)` (allowlist)
## Status' '{"permissions":{"allow":["Bash(foo *)"]}}')
run "$d" blocking
[ "$RC" -eq 0 ] || fail "hook should be skipped, my-tool matches -> exit 0 (got $RC: $OUT)"
echo "$OUT" | grep -q "a-hook" && fail "hook affordance must not appear as a finding: $OUT"
rm -rf "$d"

# Scenario 6: fully paired -> both clean, exit 0.
d=$(mkproj "$REAL" '{"permissions":{"allow":["Bash(foo *)"]}}')
run "$d" blocking; [ "$RC" -eq 0 ] || fail "paired blocking should exit 0 (got $RC: $OUT)"
run "$d" advisory; [ "$RC" -eq 0 ] || fail "paired advisory should exit 0 (got $RC: $OUT)"
echo "$OUT" | grep -q "every permission has a declared affordance" || fail "paired advisory should report clean: $OUT"
rm -rf "$d"

# Scenario 7: string equality — Bash(gh *) does not satisfy Bash(gh pr *).
d=$(mkproj '# H
## Affordances
### gh-pr
- **Mode**: cli
- **Permission**: `Bash(gh pr *)` (allowlist)
## Status' '{"permissions":{"allow":["Bash(gh *)"]}}')
run "$d" blocking
[ "$RC" -eq 1 ] || fail "string-equality: broad pattern must not satisfy narrow (got $RC: $OUT)"
rm -rf "$d"

# Scenario: malformed multi-pattern Permission -> DIAGNOSTIC, not a blocking FAIL.
d=$(mkproj '# H
## Affordances
### multi
- **Mode**: cli
- **Permission**: `Bash(echo *)`, `Bash(touch *)` (allowlist)
### good
- **Mode**: cli
- **Permission**: `Bash(ok *)` (allowlist)
## Status' '{"permissions":{"allow":["Bash(ok *)"]}}')
run "$d" blocking
[ "$RC" -eq 0 ] || fail "diagnostic should not block when no real gap (got $RC: $OUT)"
echo "$OUT" | grep -q "DIAGNOSTIC: affordance 'multi'" || fail "multi-pattern should emit a diagnostic: $OUT"
echo "$OUT" | grep -q "FAIL:" && fail "multi-pattern must not be a FAIL: $OUT"
rm -rf "$d"

# Allowlist union across both settings files.
d=$(mktemp -d); mkdir -p "$d/.claude"
printf '%s\n' "$REAL" > "$d/HARNESS.md"
echo '{"permissions":{"allow":["Bash(base *)"]}}' > "$d/.claude/settings.json"
echo '{"permissions":{"allow":["Bash(foo *)"]}}' > "$d/.claude/settings.local.json"
run "$d" blocking
[ "$RC" -eq 0 ] || fail "union: .local grant should satisfy the affordance (got $RC: $OUT)"
rm -rf "$d"

# O1: a real entry whose Notes mention "affordance-example" (without the
# comment marker) must NOT be skipped — it still enforces.
d=$(mkproj '# H
## Affordances
### real-tool
- **Mode**: cli
- **Permission**: `Bash(foo *)` (allowlist)
- **Notes**: see the affordance-example section of the docs
## Status' '{"permissions":{"allow":["Bash(other *)"]}}')
run "$d" blocking
[ "$RC" -eq 1 ] || fail "O1: entry mentioning affordance-example in Notes must still enforce (got $RC: $OUT)"
rm -rf "$d"

# O2: a DIAGNOSTIC (multi-pattern) entry's permissions must NOT be reported as
# ungoverned by the advisory direction.
d=$(mkproj '# H
## Affordances
### multi
- **Mode**: cli
- **Permission**: `Bash(a *)`, `Bash(b *)` (allowlist)
## Status' '{"permissions":{"allow":["Bash(a *)","Bash(b *)"]}}')
run "$d" advisory
echo "$OUT" | grep -q "ADVISORY" && fail "O2: governed multi-pattern permissions must not be flagged ungoverned: $OUT"
rm -rf "$d"

# O3: space-joined two patterns -> DIAGNOSTIC (not silently one OK).
d=$(mkproj '# H
## Affordances
### space-joined
- **Mode**: cli
- **Permission**: `Bash(a *)` `Bash(b *)` (allowlist)
### good
- **Mode**: cli
- **Permission**: `Bash(ok *)` (allowlist)
## Status' '{"permissions":{"allow":["Bash(ok *)"]}}')
run "$d" blocking
echo "$OUT" | grep -q "DIAGNOSTIC: affordance 'space-joined'" || fail "O3: space-joined patterns should diagnose: $OUT"
[ "$RC" -eq 0 ] || fail "O3: diagnostic must not block when no real gap (got $RC: $OUT)"
rm -rf "$d"

# O5: malformed settings JSON -> unverified (not a false FAIL).
d=$(mktemp -d); mkdir -p "$d/.claude"
printf '%s\n' "$REAL" > "$d/HARNESS.md"
printf '{ this is not json' > "$d/.claude/settings.json"
run "$d" blocking
[ "$RC" -eq 0 ] || fail "O5: malformed JSON should go unverified, not FAIL (got $RC: $OUT)"
echo "$OUT" | grep -q "not valid JSON" || fail "O5: should name the invalid settings file: $OUT"
rm -rf "$d"

# O7: a hook entry with NO Mode line is still skipped (its Permission is a
# hooks.* registration).
d=$(mkproj '# H
## Affordances
### modeless-hook
- **Trigger**: Stop
- **Permission**: `hooks.Stop` entry in `.claude/settings.local.json`
### my-tool
- **Mode**: cli
- **Permission**: `Bash(foo *)` (allowlist)
## Status' '{"permissions":{"allow":["Bash(foo *)"]}}')
run "$d" blocking
[ "$RC" -eq 0 ] || fail "O7: hook with no Mode line must be skipped (got $RC: $OUT)"
echo "$OUT" | grep -q "modeless-hook" && fail "O7: modeless hook must not be a finding: $OUT"
rm -rf "$d"

echo "All affordance-check tests passed."
