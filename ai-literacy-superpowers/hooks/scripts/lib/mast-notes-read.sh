#!/usr/bin/env bash

# Strict mode when executed, never leaked into a sourcing shell.
(return 0 2>/dev/null) || set -euo pipefail
# mast-notes-read.sh — the read surface of the boundary note store.
#
# Spec: docs/superpowers/specs/2026-08-12-cadence-sentinels-s3b-boundary-notices-design.md §4
# Tests: tdad_tests/layer0_deterministic/test-mast-notes.sh (MN1, MN4, MN5)
#
# SOURCEABLE BY A SENTINEL. That is why it is separate from
# mast-notes-write.sh, and it defines no function that writes, deletes, or
# moves. The frontmatter check reads only an agent's declared `tools:` list and
# cannot see a `source` line, so this boundary holds by what an agent can
# reach.
#
# KEYED BY REPO, NOT SESSION. The store's writers include `/coda` and `/wip` —
# commands, which have no channel to learn a session id. Every hook takes it
# from stdin JSON; no command in this plugin can. Keying by session would have
# left the commands guessing, and the obvious guess (newest file) fails in
# exactly the multi-session world this epic exists for.
#
# WHAT IT HOLDS. Only what fired. There is no line recording that someone
# continued past a boundary, because nothing observes a choice — continuing is
# the absence of stopping, and reading intent into silence is what the boundary
# between counting and watching forbids.

notes_dir() { printf '%s' "${CLAUDE_MAST_DIR:-$HOME/.claude/mast}"; }

# notes_slug <repo-path> — a filesystem-safe key for a repo.
notes_slug() {
  printf '%s' "${1:-$PWD}" | sed -e 's#[^A-Za-z0-9._-]#-#g' -e 's#^-*##' -e 's#-*$##' \
    | cut -c1-120
}

notes_path() { printf '%s/%s.notes' "$(notes_dir)" "$(notes_slug "${1:-$PWD}")"; }

# notes_read [repo] — every line for this repo, oldest first. Empty when none.
notes_read() {
  local f
  f="$(notes_path "${1:-$PWD}")"
  [ -f "$f" ] || return 0
  cat "$f" 2>/dev/null || true
}

# notes_has <event> [repo] — true when an event of that kind was recorded.
# This is the once-per-session notice state: `reached` is recorded when it
# fires, and asking whether it was is how the hook stays silent afterwards.
notes_has() {
  local f
  f="$(notes_path "${2:-$PWD}")"
  [ -f "$f" ] || return 1
  grep -q " $1" "$f" 2>/dev/null
}
