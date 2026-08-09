#!/usr/bin/env bash
set -euo pipefail
# next-action-hint.sh — decides whether the Coda should ask once more for a
# starting point.
#
# Spec: docs/superpowers/specs/2026-08-09-cadence-sentinels-s2-coda-design.md §3
# Tests: tdad_tests/layer0_deterministic/test-next-action.sh (N1–N8)
#
#     exit 0  — an anchor was found; do not ask again
#     exit 1  — no anchor; ASK ONE MORE QUESTION
#
# EXIT 1 IS NOT A FAILURE, AND THIS IS NOT A VALIDATOR. It renders no verdict
# on the human's wording, and whatever they answer next is parked either way —
# including the same words again. That is why nothing here writes to stderr and
# why no message uses the vocabulary of rejection: a caller that mistook a
# trigger for a fault would turn a question into a gate.
#
# Why it was demoted. The first design made this a check that refused to write
# a parking record until the text passed. It measures lexical form, not
# specificity — "keep going in src/" carries an anchor and passes — and its
# errors run systematically along the code/non-code axis rather than randomly.
# A heuristic that is reliably unfair to one kind of work is worse than one
# that is merely noisy, and the Coda parks decision-shaped threads by design.
# Demoted to a trigger, both error directions cost the same thing: one extra
# question.
#
# The evidence underneath it. A written plan for an unfinished task releases
# its pull, and specificity is the active ingredient rather than the writing —
# "continue work" is a written plan that does nothing. So the ritual asks for a
# starting point. It does not grade the answer.
#
# The grammar below is published verbatim in skills/coda/SKILL.md and
# reference/parking-record-format.md. A rule whose decisive term lives only in
# the implementation cannot be argued with, and this one is meant to be.

text="${1-}"

# Normalise once: collapse whitespace so a wrapped next action reads the same
# as a single-line one.
text="$(printf '%s' "$text" | tr '\n' ' ' | tr -s '[:space:]' ' ')"
text="${text#"${text%%[![:space:]]*}"}"
text="${text%"${text##*[![:space:]]}"}"

ask() {
  # Names what is missing — a file, a test, or a first step — never a judgement
  # on the wording. "Too vague" would be a verdict; this is a question.
  printf '%s\n' \
    "What is the first step? Naming a file, a test, or the decision to make will make this easy to pick up."
  exit 1
}

[ -n "$text" ] || ask

# --- The anchor grammar (spec §3.3) ------------------------------------------
#
# Six kinds. Five are artefacts of code-shaped work; the sixth exists because
# this plugin's own work is mostly specs, prose and decisions, and without it
# the table would tax the dominant kind of thread with an extra question at
# every close — from a published rule that reads as the house definition of a
# concrete next step.
#
# A bare English noun is deliberately NOT an anchor. "parser" names a thing;
# it does not name where to start. That is what separates "more work on the
# parser" from "add the B12 fixture".
# shellcheck disable=SC2016  # the backtick row is a regex matching literal
# backticks, not a shell expansion. Directives must sit in front of a complete
# command, so it lives here rather than on the branch it applies to.
anchor() {
  case "$1" in
    path)       printf '%s' '(^| )[A-Za-z0-9_.-]*/[A-Za-z0-9_./-]+|[A-Za-z0-9_-]+\.(sh|py|md|rs|ts|js|json|ya?ml|toml|txt)' ;;
    identifier) printf '%s' '[A-Za-z0-9_]+\(\)|[A-Za-z0-9]+_[A-Za-z0-9_]+|[A-Za-z0-9]+::[A-Za-z0-9]+|\b[A-Z][a-z0-9]+\.[A-Z][a-z0-9]+' ;;
    backtick)   printf '%s' '`[^`]+`' ;;
    scenario)   printf '%s' '(^| )#[0-9]+|(^| )[A-Z]+[0-9]+([^A-Za-z0-9]|$)' ;;
    linereg)    printf '%s' '[A-Za-z0-9_.-]+:[0-9]+|§[0-9]|\bline [0-9]+' ;;
    decision)   printf '%s' '\b(ask|decide|choose between|confirm with|agree with)\b|\b(whether|which|why)\b' ;;
  esac
}

for kind in path identifier backtick scenario linereg decision; do
  if printf '%s' "$text" | grep -qE "$(anchor "$kind")"; then
    exit 0
  fi
done

ask
