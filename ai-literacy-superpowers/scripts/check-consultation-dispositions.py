#!/usr/bin/env python3
"""Verify every consultation record has disposed each voice it names.

A consultation record (`reference/consultation-record-format.md`) lists the
voices a spec affects and the question worth asking each one. This check
enforces the S5 merge-time constraint: **a PR whose spec has a consultation
record must have no voice left `pending`.** Every voice is either `consulted`
or `deliberately-not-consulted`, each with its one-line outcome.

COMPLETE-IF-PRESENT, NOT REQUIRED. A spec with no record passes, and a repo
with no `consultations/` directory passes. Running `/convene` stays a choice.
The failure worth catching first is the *abandoned* conversation — someone ran
`/convene`, saw a voice they knew mattered, and shipped without saying either
way. A project that never convened has made a different mistake, and a merge
gate is not how you fix it.

WHY OUTCOMES MUST BE DISTINCT. `pending` is a detectable failure. Eight voices
bulk-filled `deliberately-not-consulted / "no time"` is an undetectable one, and
it is strictly worse: an all-`pending` record is at least truthful about
disengagement, while an all-declined one *launders* it into eight deliberate
decisions nobody made — permanently, because records are append-only and the
next reader will trust the file.

This never judges a reason. "No time; shipping Thursday and the docs owner is
on leave" passes, and is honest. What it refuses is one string standing for
several decisions, so that a bulk-fill costs more than thinking does.

Spec: docs/superpowers/specs/2026-08-12-cadence-sentinels-s5-convener-design.md
Tests: tdad_tests/layer0_deterministic/test-convene-check.sh (V1-V9)
No third-party dependencies (CI-friendly).
"""

from __future__ import annotations

import glob
import os
import re
import subprocess
import sys

CONSULTATIONS = "docs/superpowers/consultations"
SPECS = "docs/superpowers/specs"

VALID_DISPOSITIONS = {"pending", "consulted", "deliberately-not-consulted"}
VALID_SOURCE_FLAGS = {"observed", "inferred", "asked"}

# The one library that knows what a `.resolved.md` is.
RECORD_PATHS_LIB = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "hooks",
    "scripts",
    "lib",
    "record-paths.sh",
)


def latest_records(directory: str) -> list[str]:
    """The current state of every record chain, via S1's `records_latest`.

    Shelling out rather than re-deriving the walk is deliberate. A disposition
    only ever exists inside a `.resolved.md` — the append-only rule forbids
    editing a `disposition:` key in place — and `records_open` excludes those
    by name, so this check needs the *other* query. Reimplementing it here
    would make this the second place in the repo that knows what `.resolved.md`
    means, which is the duplication S1's library exists to prevent.
    """
    if not os.path.isdir(directory):
        return []
    if not os.path.isfile(RECORD_PATHS_LIB):
        print(f"::error::record-paths.sh not found at {RECORD_PATHS_LIB}")
        sys.exit(1)
    result = subprocess.run(
        ["bash", "-c", f'. "$1"; records_latest "$2"', "_", RECORD_PATHS_LIB, directory],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        print(f"::error::records_latest failed: {result.stderr.strip()}")
        sys.exit(1)
    return [line for line in result.stdout.splitlines() if line.strip()]


def frontmatter(text: str) -> str | None:
    """The YAML frontmatter block, or None when there is none to read."""
    if not text.startswith("---"):
        return None
    body = text[3:]
    end = body.find("\n---")
    if end == -1:
        return None
    return body[:end]


def parse_voices(fm: str) -> list[dict[str, str]] | None:
    """The `voices:` list as dicts, or None when the block is unreadable.

    A deliberately small subset of YAML: a `voices:` key, then list items of
    `- key: value` followed by `  key: value` lines. Anything outside that
    shape is reported malformed rather than guessed at — a matcher that cannot
    parse a record must not report it clean.
    """
    lines = fm.splitlines()
    try:
        start = next(i for i, ln in enumerate(lines) if re.match(r"^voices:\s*", ln))
    except StopIteration:
        return None

    inline = lines[start].split(":", 1)[1].strip()
    if inline in ("[]", "[ ]"):
        return []
    if inline:
        return None  # a flow-style list is outside the documented shape

    voices: list[dict[str, str]] = []
    for raw in lines[start + 1 :]:
        if raw.strip() == "":
            continue
        if not raw.startswith(" "):
            break  # a new top-level key ends the list
        item = re.match(r"^\s+-\s+(\S+):\s*(.*)$", raw)
        if item:
            voices.append({item.group(1): item.group(2).strip()})
            continue
        cont = re.match(r"^\s+(\S+):\s*(.*)$", raw)
        if cont and voices:
            voices[-1][cont.group(1)] = cont.group(2).strip()
            continue
        return None
    return voices


def normalise(outcome: str) -> str:
    """An outcome reduced to what it actually says.

    Case, surrounding whitespace and trailing punctuation do not make one
    decision two, so a bulk-fill cannot be disguised by capitalising one of
    them.
    """
    return re.sub(r"\s+", " ", outcome).strip().strip(".;,").lower()


def is_empty(value: str) -> bool:
    return value.strip().strip("\"'") in ("", "null", "~")


def spec_for(record_path: str) -> str | None:
    """The spec a record belongs to, resolved from the record's filename.

    The record is named `<spec-slug>.md` — the spec's filename with its date
    prefix and extension stripped — matching the objection and story records,
    so one spec resolves to one record across all three.
    """
    base = os.path.basename(record_path)
    slug = re.sub(r"\.md$", "", base)
    slug = re.sub(r"\.(resolved|superseded|resumed)$", "", slug)
    matches = sorted(glob.glob(os.path.join(SPECS, f"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-{slug}.md")))
    return matches[0] if matches else None


def check_record(path: str) -> list[str]:
    errors: list[str] = []
    slug = re.sub(r"\.md$", "", os.path.basename(path))

    with open(path, encoding="utf-8") as handle:
        text = handle.read()

    fm = frontmatter(text)
    if fm is None:
        return ["malformed: no YAML frontmatter — a record that cannot be read "
                "must not be reported clean"]

    if spec_for(path) is None:
        errors.append(
            f"no spec found at {SPECS}/<date>-{slug}.md — an orphan record is "
            "silently unenforced, which is the drift this check exists to find"
        )

    voices = parse_voices(fm)
    if voices is None:
        return errors + ["malformed: the `voices:` block could not be parsed"]

    seen_outcomes: dict[str, str] = {}
    for index, voice in enumerate(voices, start=1):
        name = voice.get("voice", f"<voice {index} has no `voice:` key>")

        flag = voice.get("source_flag", "")
        if flag.strip().strip("\"'") not in VALID_SOURCE_FLAGS:
            errors.append(
                f"voice '{name}': source_flag '{flag}' is not one of "
                f"{sorted(VALID_SOURCE_FLAGS)}"
            )

        disposition = voice.get("disposition", "").strip().strip("\"'")
        if disposition not in VALID_DISPOSITIONS:
            errors.append(
                f"voice '{name}': disposition '{disposition}' is not one of "
                f"{sorted(VALID_DISPOSITIONS)}"
            )
            continue

        if disposition == "pending":
            errors.append(
                f"voice '{name}' is still pending — consult them, or record "
                "deliberately-not-consulted with the because"
            )
            continue

        outcome = voice.get("outcome", "")
        if is_empty(outcome):
            errors.append(
                f"voice '{name}': {disposition} needs a one-line outcome. The "
                "because is what makes it a disposition rather than a shrug"
            )
            continue

        key = normalise(outcome)
        if key in seen_outcomes:
            errors.append(
                f"voice '{name}' repeats the outcome already given for "
                f"'{seen_outcomes[key]}' — each outcome must name something "
                "specific to that voice. One string cannot stand for several "
                "decisions"
            )
        else:
            seen_outcomes[key] = name

    return errors


def main() -> int:
    records = sorted(latest_records(CONSULTATIONS))
    failed = False
    for path in records:
        for error in check_record(path):
            print(f"::error file={path}::{error}")
            failed = True

    if failed:
        print(
            "\nConsultation disposition check FAILED. Every voice in a "
            "consultation record needs a disposition with its own outcome. A "
            "spec with no record passes — this check is complete-if-present, "
            "not a requirement to convene."
        )
        return 1

    print(f"Consultation disposition check passed ({len(records)} records).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
