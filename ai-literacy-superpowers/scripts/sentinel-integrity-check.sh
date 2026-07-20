#!/usr/bin/env bash
set -euo pipefail
#
# sentinel-integrity-check.sh — the deterministic teeth of the sentinel
# integrity constraint (spec 2026-07-20-sentinel-agent-category-design.md, §5.4).
#
# Why this exists. A "sentinel" is an agent whose object of care is the human's
# understanding and judgement, not an artefact (README §Sentinels; the
# sentinel-design skill). Criterion S1 of the sentinel signature is a read-only
# trust boundary: a sentinel informs, challenges, surfaces, or warns — it never
# fixes, writes, merges, or decides. The `role: sentinel` frontmatter tag is a
# promise; this script is what makes breaking that promise fail CI rather than
# merely contradict the docs. Mislabel an agent — grant it Write while calling
# it a sentinel — and the category stops being decorative and starts being
# load-bearing.
#
# The check, per agent frontmatter block:
#   1. If `role:` is present and its value is outside the enum {sentinel},
#      FAIL — a typo (`role: sentinal`) must be loud, never a silent exemption.
#   2. If `role: sentinel`, the `tools:` list must NOT contain Write or Edit
#      (case-insensitive). Bash is permitted — read-only inspection (git log,
#      date) is within the boundary. FAIL on a Write/Edit grant, naming the
#      agent and the S1 criterion.
#
# Runs two ways from one script (mirroring inv-firewall.sh): a PR-time gate in
# .github/workflows/harness.yml and the weekly GC sweep, plus Layer-0 tests
# against red/green fixtures. One matcher, so every caller enforces the same
# rule.
#
# Known limit (by design). This is a deterministic backstop to human PR review,
# not a sandbox. It reads the declared `tools:` line; an agent that reaches a
# write capability through an undeclared channel is out of scope here and is the
# harness-enforcer's S2/S3 agent-review territory.
#
# Usage: sentinel-integrity-check.sh [agents-dir ...]
#   Defaults to the plugin's agents directory relative to this script.

# The single permitted role value. Widen only when a second category earns a
# name (spec §5.1: enum, not free-form).
ALLOWED_ROLES="sentinel"

# Resolve default agents dir relative to this script when no argument is given.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$#" -gt 0 ]; then
  DIRS=("$@")
else
  DIRS=("$SCRIPT_DIR/../agents")
fi

# Extract the value of a frontmatter key from the leading `---` block of a file.
# Prints the trimmed value, or nothing if the key is absent. Only the first
# frontmatter block (lines between the first two `---` fences) is considered.
frontmatter_value() {
  local file="$1" key="$2"
  awk -v key="$key" '
    NR == 1 && $0 != "---" { exit }        # no frontmatter at all
    NR == 1 { infm = 1; next }
    infm && $0 == "---" { exit }            # end of frontmatter
    infm {
      # match "key:" allowing leading spaces
      if ($0 ~ "^[[:space:]]*" key "[[:space:]]*:") {
        sub("^[[:space:]]*" key "[[:space:]]*:[[:space:]]*", "")
        print
        exit
      }
    }
  ' "$file"
}

failed=0
checked=0

for dir in "${DIRS[@]}"; do
  [ -d "$dir" ] || { echo "::warning::not a directory, skipping: $dir" >&2; continue; }
  while IFS= read -r -d '' file; do
    role="$(frontmatter_value "$file" role)"
    [ -n "$role" ] || continue   # untagged agent — pipeline/harness, not our concern

    checked=$((checked + 1))
    name="$(frontmatter_value "$file" name)"
    [ -n "$name" ] || name="$(basename "$file")"

    # Criterion: role value must be in the enum.
    is_allowed=0
    for allowed in $ALLOWED_ROLES; do
      [ "$role" = "$allowed" ] && { is_allowed=1; break; }
    done
    if [ "$is_allowed" -eq 0 ]; then
      echo "FAIL: agent '$name' declares unknown role '$role' (allowed: $ALLOWED_ROLES) — $file"
      failed=1
      continue
    fi

    # role: sentinel — enforce S1 read-only trust boundary.
    tools="$(frontmatter_value "$file" tools)"
    if printf '%s' "$tools" | grep -qiE '\b(Write|Edit)\b'; then
      echo "FAIL: sentinel '$name' is granted Write/Edit — violates criterion S1 (read-only trust boundary) — $file"
      failed=1
    fi
  done < <(find "$dir" -maxdepth 1 -name '*.agent.md' -print0 2>/dev/null)
done

if [ "$failed" -eq 0 ]; then
  echo "sentinel integrity: OK ($checked role-tagged agent(s) checked)"
fi
exit "$failed"
