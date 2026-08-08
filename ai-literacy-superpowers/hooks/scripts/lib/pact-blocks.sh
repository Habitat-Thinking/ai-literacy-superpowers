#!/usr/bin/env bash

# Strict mode, applied only when this file is EXECUTED. `return` succeeds
# solely inside a sourced context, so the `set` is skipped when a hook script
# or a sentinel sources us. That matters: `set` mutates the CALLER's shell, and
# a library whose whole purpose is being safely sourceable must not impose
# -e/-u/-o pipefail on whatever sourced it. Satisfies the "Shell scripts use
# strict mode" constraint (HARNESS.md) in the only context where strict mode
# is meaningful for a library.
(return 0 2>/dev/null) || set -euo pipefail
# pact-blocks.sh — the one reader for ~/.claude/pacts.md.
#
# Spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md §3
# Tests: tdad_tests/layer0_deterministic/test-pact-blocks.sh (B1–B9)
#
# Why this exists at all. Four cadence sentinels (S2–S5) need to read the same
# three blocks. Left to themselves that becomes three near-identical parsers
# and three subtly different answers to "is this block declared". This library
# is the single answer, so none of them re-derives one.
#
# THE NULL OBJECT CONTRACT. A consumer never branches on absence. `block_key`
# always returns something — the declared value or the caller's default — and
# `block_absent_note` supplies the one sentence every sentinel says when a
# block is missing. That is why absent and malformed collapse to the same
# behaviour: it is the guarantee, not a coincidence. Sentinels run one code
# path whether or not the human has authored a pact file.
#
# THE EXTRACTION RULE, and why this does not reuse read_key. The reservoir
# hook's `read_key` does `sed -E "s/.*[:=][[:space:]]*//"` — greedy, so it
# consumes through the LAST colon on the line — then `tr -d '[:space:]'`,
# which deletes interior spaces. That is safe for the reservoir block, whose
# every value is a bare integer or a single word. It is destructive here:
#
#     hard_stop_hour: 18:30                    -> 30
#     focus_blocks: 09:00-12:00, 14:00-17:00   -> 00
#     daily_cost_ceiling: not observable       -> notobservable
#
# So: split on the FIRST delimiter after the key, and trim at the ends only.
# B7 is the test that forbids the greedy version from creeping back in.
#
# Everything here is read-only. A sentinel may source this file.

# The pact file. $CLAUDE_PACTS_FILE overrides, so tests need no home directory.
pact_file() {
  printf '%s' "${CLAUDE_PACTS_FILE:-$HOME/.claude/pacts.md}"
}

# _block_span <heading> — the lines belonging to a block: from its heading to
# the next heading of equal-or-higher level, exclusive. Prints nothing when
# the block or the file is absent.
#
# Scoping is the whole point of a purpose-built parser. A whole-file lookup
# returns the first match in document order, so two blocks declaring the same
# key would both answer with the first one's value (B8).
_block_span() {
  local heading="$1" file
  file="$(pact_file)"
  [ -f "$file" ] || return 0
  awk -v want="$heading" '
    # Heading line: capture its level and title.
    /^#{1,6}[[:space:]]+/ {
      level = 0
      while (substr($0, level + 1, 1) == "#") level++
      title = substr($0, level + 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", title)

      if (inblock && level <= want_level) { exit }   # equal-or-higher ends it
      if (!inblock && title == want) { inblock = 1; want_level = level; next }
      next
    }
    inblock { print }
  ' "$file"
}

# block_key <heading> <key> [default] — the value, first-delimiter split,
# trimmed at the ends only. Returns the default when the block, the file, or
# the key is absent. Never fails.
block_key() {
  local heading="$1" key="$2" def="${3-}" val
  val="$(_block_span "$heading" | awk -v key="$key" '
    {
      line = $0
      sub(/^[[:space:]]*[-*][[:space:]]*/, "", line)     # optional list bullet
      if (substr(line, 1, length(key)) != key) next
      rest = substr(line, length(key) + 1)
      if (rest !~ /^[[:space:]]*[:=]/) next              # key must be followed by a delimiter
      sub(/^[[:space:]]*[:=][[:space:]]*/, "", rest)     # FIRST delimiter only
      print rest
      exit
    }
  ')"
  # Trim trailing whitespace and the backticks a human may have typed. Interior
  # spaces are preserved on purpose — `not observable` is a valid value.
  val="${val%"${val##*[![:space:]]}"}"
  val="${val#\`}"; val="${val%\`}"
  if [ -n "$val" ]; then printf '%s' "$val"; else printf '%s' "$def"; fi
}

# _mandatory_clause <heading> — the literal sentence a block must carry, or
# empty when the block has none.
#
# The clause is part of the block, not a comment on it: a pact enforced
# without its governing sentence is a pact enforced against a framing nobody
# agreed to. Because detection is literal-string matching, the wording is a
# published interface — only a spec-first change may reword it, and rewording
# is a coordinated migration across every adopter.
_mandatory_clause() {
  case "$1" in
    "Session WIP") printf '%s' 'It counts; it does not assess.' ;;
    "Budgets")     printf '%s' 'Unspent budget is not a debt.' ;;
    *)             printf '%s' '' ;;   # Sync cadence is reserved and inert
  esac
}

# _flatten — collapse every run of whitespace, including newlines, to one
# space. Clause matching runs through this.
#
# The clause's WORDS are the interface; its line breaks are not. Without this,
# a markdown reflow that wraps the sentence across two lines silently
# downgrades a perfectly good block to malformed — which is the brittleness
# choice story #1 named when it accepted literal matching, and which the
# shipped template hit on the very first run. Normalising keeps the wording
# load-bearing and un-rewordable while letting a human wrap their own file.
_flatten() { tr '\n' ' ' | tr -s '[:space:]' ' '; }

# block_state <heading> — absent | malformed | declared. Always exits 0:
# absence is never an error and malformed is never a gate.
block_state() {
  local heading="$1" span clause
  span="$(_block_span "$heading")"
  if [ -z "$span" ]; then printf '%s' 'absent'; return 0; fi

  clause="$(_mandatory_clause "$heading")"
  if [ -n "$clause" ] \
     && ! printf '%s' "$span" | _flatten | grep -qF "$(printf '%s' "$clause" | _flatten)"; then
    printf '%s' 'malformed'
    return 0
  fi
  printf '%s' 'declared'
}

# block_absent_note <heading> — the fixed sentence, emitted by the library so
# every consumer says the same thing rather than inventing its own phrasing.
block_absent_note() {
  # shellcheck disable=SC2016  # the backticks are markdown for the reader, not
  # a shell expansion — single quotes are exactly what we want here.
  printf 'no `%s` block declared — running in observe-only mode' "$1"
}
