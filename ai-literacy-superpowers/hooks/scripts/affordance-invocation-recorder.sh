#!/usr/bin/env bash
set -euo pipefail
# affordance-invocation-recorder.sh — PostToolUse hook (step 7 of the
# harness-affordances design, spec 2026-06-17-affordance-runtime-recorder-design.md).
#
# Appends one minimal NDJSON tuple per affordance-relevant tool call to the
# gitignored observability/affordance-invocations.json (NDJSON content). Records
# only Bash and mcp__* invocations (the tools that map to affordances) — never
# the built-in file tools. Privacy: it records the tool name, the Bash program
# NAME only (env-var prefixes stripped, path basename'd, allowlist-shaped — no
# arguments, no paths, no secrets), a best-effort invoker, an opaque session id,
# and a UTC timestamp. No tool arguments, no file contents, no user identity.
#
# Best-effort: uses grep/sed (no jq dependency), never blocks, never delays the
# session, and always exits 0 — a recorder must never interfere with a session.

FILE_REL="observability/affordance-invocations.json"
MAX_LINES=5000

record() {
  local input tool prog invoker session ts file
  input=$(cat)

  tool=$(printf '%s' "$input" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
         | sed -E 's/.*"tool_name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
  [ -n "$tool" ] || return 0

  # Only record affordance-relevant tools (CLIs via Bash, and MCP servers).
  case "$tool" in
    Bash|mcp__*) ;;
    *) return 0 ;;
  esac

  prog="null"
  if [ "$tool" = "Bash" ]; then
    local command c first base
    command=$(printf '%s' "$input" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
              | sed -E 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
    c="$command"
    # Strip leading KEY=VALUE env-var prefixes (which may carry secrets).
    while printf '%s' "$c" | grep -qE '^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]'; do
      c=$(printf '%s' "$c" | sed -E 's/^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+//')
    done
    first=$(printf '%s' "$c" | awk '{print $1}')
    base=$(basename -- "$first" 2>/dev/null || printf '')
    # Record only a clean program-name shape; a path, quote, or shell syntax
    # collapses to null so no path or argument can leak.
    if printf '%s' "$base" | grep -qE '^[A-Za-z0-9._-]+$'; then
      prog="\"$base\""
    fi
  fi

  session=$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
            | sed -E 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
  printf '%s' "$session" | grep -qE '^[A-Za-z0-9._-]+$' || session="unknown"

  # invoker: best-effort. PostToolUse rarely exposes the invoking agent; record
  # it only if a safe-shaped value is present, else "unknown". The feature's
  # value (dead-inventory) does not depend on it.
  invoker=$(printf '%s' "$input" | grep -oE '"(agent|invoker|subagent)"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
            | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/' || printf '')
  printf '%s' "$invoker" | grep -qE '^[A-Za-z0-9._-]+$' || invoker="unknown"

  ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

  file="${CLAUDE_PROJECT_DIR:-.}/$FILE_REL"
  mkdir -p "$(dirname "$file")"
  printf '{"tool":"%s","program":%s,"invoker":"%s","session":"%s","ts":"%s"}\n' \
    "$tool" "$prog" "$invoker" "$session" "$ts" >> "$file"

  # Bound the file (gitignored, per-machine) — keep well over the 30-day window.
  local n
  n=$(wc -l < "$file" 2>/dev/null | tr -d ' ' || printf '0')
  if [ "${n:-0}" -gt "$MAX_LINES" ]; then
    tail -n "$MAX_LINES" "$file" > "$file.tmp" 2>/dev/null && mv "$file.tmp" "$file"
  fi
}

# Never let a recorder failure surface to the session.
record 2>/dev/null || true
exit 0
