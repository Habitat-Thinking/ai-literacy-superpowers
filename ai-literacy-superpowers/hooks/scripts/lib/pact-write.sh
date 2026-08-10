#!/usr/bin/env bash

# Strict mode, applied only when this file is EXECUTED. `return` succeeds
# solely inside a sourced context, so the `set` is skipped when a command
# sources us — `set` mutates the CALLER's shell, and a library must not impose
# -e/-u/-o pipefail on whatever sourced it.
(return 0 2>/dev/null) || set -euo pipefail
# pact-write.sh — the write surface of the pact file.
#
# Spec: docs/superpowers/specs/2026-08-10-cadence-sentinels-s3-mast-design.md §5.5
# Tests: tdad_tests/layer0_deterministic/test-pact-write.sh (T1–T9)
#
# COMMANDS AND HOOKS ONLY. A `role: sentinel` agent must never source this
# file — that is the whole reason it is separate from pact-blocks.sh, which a
# sentinel may source freely. S1 made the same split for the registry, and
# `sentinel-design` promoted the rule out of it: a read surface a sentinel may
# source, a write surface it may not. The frontmatter check cannot see a
# `.sh` file, so the boundary holds by what an agent can reach.
#
# Why this library exists at all. The first draft of S3 shipped no shell: the
# write path was six numbered rules for a model to follow in a command file.
# That did not survive its own acceptance scenarios — T1–T9 are Layer-0
# deterministic tests, and there is nothing deterministic to test when the
# writer is prose. Either the round trip was not real or the writer was.
#
# THE READER AND THE WRITER ARE ONE CONTRACT. Whatever this emits,
# `block_state` must call `declared`. Getting that wrong fails in the quietest
# possible way: the block reads `malformed`, every consumer drops to
# observe-only per S1's Null Object contract, and nothing tells the human which
# sentence is missing. T1 is the guard.

_PW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_PW_TEMPLATE="$_PW_DIR/../../../templates/pacts.md"

# _pw_pact_file — the file being written. Mirrors pact-blocks.sh's resolution
# so the writer and the reader never disagree about which file they mean.
_pw_pact_file() {
  printf '%s' "${CLAUDE_PACTS_FILE:-$HOME/.claude/pacts.md}"
}

# _pw_template_prose <heading> — the prose a block must carry, lifted from the
# shipped template: everything after the block's value lines, up to the next
# heading.
#
# DERIVED, NEVER RESTATED. The mandatory clauses and the reserved marker are
# matched literally by the reader, so a copy in this file would agree with it
# only by coincidence of wording — and the promoted decision is that harness
# artefacts derive from the source of truth rather than pinning a copy of it.
# T9 is the test: change the template, and what this emits changes with no
# edit here.
_pw_template_prose() {
  local heading="$1"
  [ -f "$_PW_TEMPLATE" ] || return 0
  awk -v want="$heading" '
    /^#{1,6}[[:space:]]+/ {
      title = $0
      sub(/^#+[[:space:]]+/, "", title)
      if (inblock) { exit }
      if (title == want) { inblock = 1 }
      next
    }
    inblock && /^[[:space:]]*-[[:space:]]/ { next }   # value lines come from the caller
    inblock { print }
  ' "$_PW_TEMPLATE"
}

# _pw_trim_blanks — collapse leading and trailing blank lines from stdin.
_pw_trim_blanks() {
  awk 'NF { blank = 0; buf = buf sep $0; sep = "\n"; next }
       { if (buf != "") sep = sep "\n" }
       END { if (buf != "") print buf }'
}

# pact_write_block <heading> <body-file> — replace the block, or append it if
# absent. The body file holds the caller's value lines and nothing else.
#
# REPLACE, NEVER APPEND-A-SECOND. `_block_span` exits at the next known
# heading, so a duplicate `## Budgets` is silently unread: the human's newly
# tuned values become invisible with no error anywhere. T5 is the guard.
#
# Everything outside the replaced block survives, including the template's
# editing guidance and any other declared block (T8).
pact_write_block() {
  local heading="$1" body_file="$2" file tmp prose stamped
  file="$(_pw_pact_file)"
  mkdir -p "$(dirname "$file")" 2>/dev/null || return 1
  [ -f "$file" ] || _pw_seed_file "$file"

  prose="$(_pw_template_prose "$heading")"

  # The stamps live in Budgets only, where S1's grammar defines them. Stamping
  # every block would leave "when was this pact authored" a per-block fact with
  # no rule for combining them (T6).
  stamped=""
  if [ "$heading" = "Budgets" ]; then
    stamped="- authored_at: $(date -u +%Y-%m-%d)
- authored_via: tune"
  fi

  # Written as if-blocks, not `[ -n "$x" ] && printf ...` chains: an empty
  # value makes such a chain return non-zero, and the whole group is guarded by
  # `|| return 1` — so an absent optional would read as a write failure.
  tmp="$file.$$.tmp"
  {
    _pw_emit_without_block "$file" "$heading"
    printf '## %s\n\n' "$heading"
    cat "$body_file"
    if [ -n "$stamped" ]; then printf '%s\n' "$stamped"; fi
    printf '\n'
    if [ -n "$prose" ]; then printf '%s\n' "$prose" | _pw_trim_blanks; printf '\n'; fi
  } > "$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  mv -f "$tmp" "$file" 2>/dev/null || { rm -f "$tmp"; return 1; }
}

# _pw_emit_without_block <file> <heading> — the file with that block removed,
# every other line intact.
_pw_emit_without_block() {
  awk -v want="$2" '
    /^#{1,6}[[:space:]]+/ {
      title = $0
      sub(/^#+[[:space:]]+/, "", title)
      skipping = (title == want) ? 1 : 0
      if (skipping) next
    }
    !skipping { print }
  ' "$1" | _pw_trim_blanks
  printf '\n'
}

# _pw_seed_file <path> — a new pact file's preamble, taken from the template so
# a human who later hand-edits still has the template's guidance in front of
# them. Value lines and block headings are deliberately not carried: the pact
# is authored, never scaffolded.
_pw_seed_file() {
  local path="$1"
  if [ -f "$_PW_TEMPLATE" ]; then
    awk '/^#{1,6}[[:space:]]+/ && !/^# Pacts$/ { exit } { print }' \
      "$_PW_TEMPLATE" > "$path" 2>/dev/null && return 0
  fi
  printf '# Pacts\n\nYour pacts — the limits you set for yourself, in advance.\n' > "$path"
}
