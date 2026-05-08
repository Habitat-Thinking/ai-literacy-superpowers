#!/usr/bin/env bash
#
# Functional test for rewrite-docs-links.sh.
# Sets up a fixture move-map and a tree of markdown files containing
# both old-path and unrelated links; runs the script; asserts the
# old-path links are rewritten and unrelated links are untouched.
# Also asserts idempotency: running the script twice produces the same
# output as running it once.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$script_dir/rewrite-docs-links.sh"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

# Fixture move-map: TSV with two rows
cat >"$fixture/move-map.tsv" <<'EOF'
docs/plugins/test-plugin/research-a-model-card.md	docs/plugins/test-plugin/how-to/research-a-model-card.md
docs/plugins/test-plugin/agents.md	docs/plugins/test-plugin/reference/agents.md
EOF

# Fixture markdown files: a mix of links to be rewritten and untouched
mkdir -p "$fixture/docs/plugins/test-plugin"
cat >"$fixture/sample.md" <<'EOF'
See [Research a Model Card](docs/plugins/test-plugin/research-a-model-card.md)
and [Agents](docs/plugins/test-plugin/agents.md). Unrelated:
[README](README.md) and [Other](docs/plugins/other-plugin/agents.md).
EOF

cat >"$fixture/no-matches.md" <<'EOF'
Just a [README](README.md) link, nothing to rewrite.
EOF

# Fixture: an excluded path (.git/) containing a link that must NOT be rewritten
mkdir -p "$fixture/.git"
cat >"$fixture/.git/excluded.md" <<'EOF'
See [Old Doc](docs/plugins/test-plugin/research-a-model-card.md) — should not be rewritten.
EOF

# Regression fixture: a file containing a near-miss path where '.' is replaced
# by a literal 'X'. The old sed pattern without escaping would treat '.' as a
# wildcard and rewrite this line — the escape fix must prevent that.
cat >"$fixture/near-miss.md" <<'EOF'
See [Near Miss](docs/plugins/test-plugin/research-a-model-cardXmd) — must NOT be rewritten.
EOF

# Run the script against the fixture
cd "$fixture"
"$script" move-map.tsv

# Assert: links in sample.md are rewritten
if ! grep -qF "docs/plugins/test-plugin/how-to/research-a-model-card.md" sample.md; then
  echo "FAIL: research-a-model-card.md link was not rewritten in sample.md"
  cat sample.md
  exit 1
fi
if ! grep -qF "docs/plugins/test-plugin/reference/agents.md" sample.md; then
  echo "FAIL: agents.md link was not rewritten in sample.md"
  cat sample.md
  exit 1
fi

# Assert: unrelated links in sample.md are untouched
if ! grep -qF "[README](README.md)" sample.md; then
  echo "FAIL: README link was clobbered in sample.md"
  cat sample.md
  exit 1
fi
if ! grep -qF "docs/plugins/other-plugin/agents.md" sample.md; then
  echo "FAIL: other-plugin/agents.md link was clobbered in sample.md"
  exit 1
fi

# Assert: no-matches.md is unchanged
if ! grep -qF "[README](README.md) link" no-matches.md; then
  echo "FAIL: no-matches.md was modified unexpectedly"
  cat no-matches.md
  exit 1
fi

# Assert: .git/excluded.md was NOT rewritten (exclusion must apply)
if ! grep -qF "docs/plugins/test-plugin/research-a-model-card.md" .git/excluded.md; then
  echo "FAIL: .git/excluded.md was modified despite being in an excluded path"
  cat .git/excluded.md
  exit 1
fi

# Assert: near-miss.md is unchanged — 'X' must not be matched as a wildcard '.'
# This locks in the regex-metacharacter escaping of $old before passing to sed.
if ! grep -qF "docs/plugins/test-plugin/research-a-model-cardXmd" near-miss.md; then
  echo "FAIL: near-miss.md was rewritten — '.' in old path was not escaped for sed"
  cat near-miss.md
  exit 1
fi

# Assert: idempotency — running again produces no change
if command -v md5sum >/dev/null 2>&1; then
  md5_before=$(md5sum sample.md no-matches.md | sort)
  "$script" move-map.tsv
  md5_after=$(md5sum sample.md no-matches.md | sort)
elif command -v md5 >/dev/null 2>&1; then
  md5_before=$(md5 -r sample.md no-matches.md | sort)
  "$script" move-map.tsv
  md5_after=$(md5 -r sample.md no-matches.md | sort)
else
  echo "FAIL: neither md5sum nor md5 available"
  exit 1
fi

if [[ "$md5_before" != "$md5_after" ]]; then
  echo "FAIL: script is not idempotent"
  echo "Before: $md5_before"
  echo "After:  $md5_after"
  exit 1
fi

echo "PASS: rewrite-docs-links.sh"
