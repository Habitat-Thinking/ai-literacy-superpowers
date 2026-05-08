#!/usr/bin/env bash
#
# Functional test for check-redirect-sunsets.sh.
# Sets up fixture markdown files with past, future, and missing sunset
# markers; runs the script against the fixture directory; asserts the
# output is correct.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$script_dir/check-redirect-sunsets.sh"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

# Fixture 1: a page with a past sunset marker (YAML comment form)
mkdir -p "$fixture/docs/plugins/test-plugin/how-to"
cat >"$fixture/docs/plugins/test-plugin/how-to/expired.md" <<'EOF'
---
title: Expired
redirect_from:
  - /old-path/
# redirect-sunset: 2020-01-01
---

# Expired
EOF

# Fixture 2: a page with a future sunset marker
cat >"$fixture/docs/plugins/test-plugin/how-to/future.md" <<'EOF'
---
title: Future
redirect_from:
  - /old-path/
# redirect-sunset: 2099-01-01
---

# Future
EOF

# Fixture 3: a page with no sunset marker
cat >"$fixture/docs/plugins/test-plugin/how-to/none.md" <<'EOF'
---
title: None
---

# None
EOF

# Fixture 4: a page with an HTML-comment-form past sunset marker
cat >"$fixture/docs/plugins/test-plugin/how-to/html-expired.md" <<'EOF'
---
title: HTML expired
---

# HTML expired

<!-- redirect-sunset: 2020-06-01 -->
EOF

# Fixture 5: a page with two markers — one future, one past.
# The file must be flagged even though the first marker is in the future.
cat >"$fixture/docs/plugins/test-plugin/how-to/multi-marker.md" <<'EOF'
---
title: Multi-marker
# redirect-sunset: 2099-12-31
---

# Multi-marker

<!-- redirect-sunset: 2020-03-15 -->
EOF

# Fixture 6: a page with a marker dated exactly today — must NOT be flagged.
today="$(date +%Y-%m-%d)"
cat >"$fixture/docs/plugins/test-plugin/how-to/today.md" <<EOF
---
title: Today
# redirect-sunset: $today
---

# Today
EOF

# ---------------------------------------------------------------------------
# Run the script. Capture stdout and stderr separately so we can assert that
# per-file findings go to stdout and the summary line goes to stderr.
# ---------------------------------------------------------------------------
stdout_out=$("$script" "$fixture/docs/plugins" 2>/dev/null) && rc=$? || rc=$?
stderr_out=$("$script" "$fixture/docs/plugins" 2>&1 >/dev/null || true)

# Assert: exit code is non-zero (findings exist)
if [[ "$rc" -eq 0 ]]; then
  echo "FAIL: expected non-zero exit code, got $rc"
  echo "stdout: $stdout_out"
  exit 1
fi

# Assert: stdout mentions expired.md
if ! grep -q "expired.md" <<<"$stdout_out"; then
  echo "FAIL: expected 'expired.md' in stdout"
  echo "stdout: $stdout_out"
  exit 1
fi

# Assert: stdout does NOT mention future.md
if grep -q "future.md" <<<"$stdout_out"; then
  echo "FAIL: future.md should not be flagged"
  echo "stdout: $stdout_out"
  exit 1
fi

# Assert: stdout does NOT mention none.md
if grep -q "none.md" <<<"$stdout_out"; then
  echo "FAIL: none.md should not be flagged"
  echo "stdout: $stdout_out"
  exit 1
fi

# Assert: stdout mentions html-expired.md (HTML comment form is exercised)
if ! grep -q "html-expired.md" <<<"$stdout_out"; then
  echo "FAIL: expected 'html-expired.md' in stdout (HTML marker form not detected)"
  echo "stdout: $stdout_out"
  exit 1
fi

# Assert: stdout mentions multi-marker.md (file with any expired marker is flagged)
if ! grep -q "multi-marker.md" <<<"$stdout_out"; then
  echo "FAIL: expected 'multi-marker.md' in stdout (expired second marker not detected)"
  echo "stdout: $stdout_out"
  exit 1
fi

# Assert: stdout does NOT mention today.md (today boundary — must not be flagged)
if grep -q "today.md" <<<"$stdout_out"; then
  echo "FAIL: today.md should not be flagged (marker dated exactly today)"
  echo "stdout: $stdout_out"
  exit 1
fi

# Assert: summary line goes to stderr, not stdout
if grep -q "Total findings" <<<"$stdout_out"; then
  echo "FAIL: 'Total findings' summary must go to stderr, not stdout"
  echo "stdout: $stdout_out"
  exit 1
fi

if ! grep -q "Total findings" <<<"$stderr_out"; then
  echo "FAIL: expected 'Total findings' on stderr"
  echo "stderr: $stderr_out"
  exit 1
fi

echo "PASS: check-redirect-sunsets.sh"
