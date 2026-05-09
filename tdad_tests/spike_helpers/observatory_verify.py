"""Observatory-verify helper: snapshot signal verification.

Implements the deterministic core of ``/observatory-verify`` for one
of its five signal sources — Snapshot — and leaves the other four
sources for Phase 3. The intent is to demonstrate that the command's
verification logic *can* be extracted and tested; the slice covered
is enough to validate the pattern.

Two pieces of logic are exposed:

- ``parse_signal_checklist`` reads
  ``ai-literacy-superpowers/skills/harness-observability/references/
  observatory-signals.md`` and returns the structured list of
  Snapshot signals (signal name, expected section heading, expected
  key fields).
- ``verify_snapshot`` reads a snapshot markdown file and returns
  per-signal status (PRESENT / PARTIAL / MISSING / NO_OUTPUT) using
  the same vocabulary the slash command does.

Status values match the command's prose definitions:

- ``PRESENT``: the expected section heading exists *and* every
  declared key field is present in the section's body.
- ``PARTIAL``: the section heading exists but at least one key field
  is missing.
- ``MISSING``: the section heading is not in the snapshot at all.
- ``NO_OUTPUT``: the snapshot file does not exist.

Why a partial-only check on key fields rather than full format
validation? Because per-field format rules (regex of expected values)
would couple the verifier tightly to the snapshot template's evolving
shape. A presence check on the heading + each named key string is
strict enough to catch the failure modes the command was designed for
(missing section, renamed field) without becoming brittle to wording
changes that don't change semantics.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from enum import Enum
from pathlib import Path


class Status(str, Enum):
    PRESENT = "PRESENT"
    PARTIAL = "PARTIAL"
    MISSING = "MISSING"
    NO_OUTPUT = "NO_OUTPUT"


@dataclass(frozen=True)
class Signal:
    """One row from the Snapshot table in observatory-signals.md."""

    name: str
    """Human-readable signal name (e.g. ``Enforcement count``)."""

    section_heading: str
    """The level-2 heading the signal lives under (e.g. ``## Enforcement``)."""

    key_fields: tuple[str, ...]
    """Sub-strings the signal's row declared as key fields. Each must
    appear in the section's body for the signal to be PRESENT."""


@dataclass
class SignalResult:
    signal: Signal
    status: Status
    notes: str = ""


# Match a level-2 heading line.
_H2 = re.compile(r"^##\s+(?P<heading>.+?)\s*$")

# Match a row in the snapshot section's signal table. The table looks
# like ``| Signal | Section Heading | Key Fields |``. The exact column
# ordering is fixed by the reference file's convention.
_TABLE_ROW = re.compile(r"^\|\s*(?P<col>[^|]*?)\s*(?=\||$)")


def parse_signal_checklist(checklist_path: Path) -> list[Signal]:
    """Parse Snapshot-source signals from observatory-signals.md.

    The reference file groups signals under ``## Source N: <name>``
    headings. This helper picks out the Snapshot source specifically
    (Source 1) and parses its table rows. Rows whose first column is
    blank or starts with a separator (``---``) are skipped.

    Other sources are intentionally ignored at this spike scope.
    """
    if not checklist_path.exists():
        raise FileNotFoundError(
            f"Signal checklist not found at {checklist_path!r}. "
            "Without it the verifier has no contract to check against."
        )

    text = checklist_path.read_text(encoding="utf-8")
    lines = text.split("\n")

    # Find the Snapshot source's bounds. Format:
    #   ## Source 1: Snapshot ...
    #   ... preamble ...
    #   | Signal | Section Heading | Key Fields |
    #   | --- | --- | --- |
    #   | Enforcement count | `## Enforcement` | ... |
    #   ...
    #   ## Source 2: ...      <-- end of source 1
    in_source_1 = False
    table_lines: list[str] = []
    for line in lines:
        if line.startswith("## Source 1:"):
            in_source_1 = True
            continue
        if line.startswith("## Source ") and "Source 1" not in line:
            in_source_1 = False
            continue
        if in_source_1 and line.startswith("|"):
            table_lines.append(line)

    # The table rows have three columns. Skip header and separator
    # rows; parse the rest.
    signals: list[Signal] = []
    for row in table_lines:
        cols = _split_table_row(row)
        if len(cols) < 3:
            continue
        if not cols[0] or cols[0].startswith("---"):
            continue
        if cols[0].lower() == "signal":  # header row
            continue

        name = cols[0]
        heading = _strip_inline_code(cols[1])
        key_fields = _parse_key_fields(cols[2])
        signals.append(
            Signal(
                name=name,
                section_heading=heading,
                key_fields=tuple(key_fields),
            )
        )
    return signals


# Split a markdown table row on bare ``|`` separators, leaving ``\|``
# (an escaped pipe inside a cell) intact. Negative lookbehind for
# backslash is the cleanest way to express "pipe not preceded by
# backslash". After splitting, each cell is stripped of leading and
# trailing whitespace and any literal ``\|`` is restored to ``|``.
_TABLE_SPLIT_RE = re.compile(r"(?<!\\)\|")


def _split_table_row(row: str) -> list[str]:
    raw = _TABLE_SPLIT_RE.split(row.strip().strip("|"))
    return [cell.strip().replace(r"\|", "|") for cell in raw]


def _strip_inline_code(text: str) -> str:
    """Strip a single pair of surrounding backticks from a string.

    The Section Heading column carries headings as backticked code
    spans (``\\`## Enforcement\\```). Real snapshot files write the
    heading without backticks, so the verifier needs the unquoted form
    to compare against. Stripping is conservative: only one balanced
    pair is removed; markdown that is already plain text passes through.
    """
    if text.startswith("`") and text.endswith("`") and len(text) >= 2:
        return text[1:-1]
    return text


def _parse_key_fields(cell_text: str) -> list[str]:
    """Split a 'Key Fields' table cell into individual field tokens.

    Cell convention is one or more backtick-quoted phrases separated
    by escaped pipes (``\\|``) which ``_split_table_row`` has already
    restored to literal ``|``. Backticked spans become individual
    fields; cells with no backticked spans return an empty list (some
    reference rows describe their key fields as prose, which we treat
    as 'no strict field check' rather than synthesising a field).
    """
    return re.findall(r"`([^`]+)`", cell_text)


def _split_into_sections(snapshot_text: str) -> dict[str, list[str]]:
    """Split snapshot text into ``heading → body lines``.

    Headings are stored verbatim including the ``## `` prefix to match
    how the signal checklist declares them.
    """
    sections: dict[str, list[str]] = {}
    current: str | None = None
    for line in snapshot_text.split("\n"):
        match = _H2.match(line)
        if match:
            current = "## " + match.group("heading")
            sections[current] = []
            continue
        if current is not None:
            sections[current].append(line)
    return sections


def verify_snapshot(
    snapshot_path: Path | None,
    signals: list[Signal],
) -> list[SignalResult]:
    """Check each signal against the snapshot and return per-signal status.

    Pass ``None`` (or a non-existent path) for ``snapshot_path`` and
    every signal returns ``NO_OUTPUT``.
    """
    if snapshot_path is None or not snapshot_path.exists():
        return [
            SignalResult(
                signal=signal,
                status=Status.NO_OUTPUT,
                notes="Snapshot file not found.",
            )
            for signal in signals
        ]

    snapshot_text = snapshot_path.read_text(encoding="utf-8")
    sections = _split_into_sections(snapshot_text)

    results: list[SignalResult] = []
    for signal in signals:
        body_lines = sections.get(signal.section_heading)
        if body_lines is None:
            results.append(
                SignalResult(
                    signal=signal,
                    status=Status.MISSING,
                    notes=(
                        f"Section {signal.section_heading!r} not "
                        "found in snapshot."
                    ),
                )
            )
            continue

        body = "\n".join(body_lines)
        missing_fields = [
            field
            for field in signal.key_fields
            if not _field_present(field, body)
        ]
        if not missing_fields:
            results.append(
                SignalResult(signal=signal, status=Status.PRESENT)
            )
        else:
            results.append(
                SignalResult(
                    signal=signal,
                    status=Status.PARTIAL,
                    notes=(
                        "Section present; missing key field(s): "
                        + ", ".join(repr(f) for f in missing_fields)
                    ),
                )
            )
    return results


def _field_present(field_pattern: str, body: str) -> bool:
    """Decide whether a key-field pattern is present in the section body.

    The signal checklist's Key Fields column declares patterns like
    ``Constraints: N/M enforced (P%)`` where ``N``, ``M``, ``P`` are
    placeholders for actual numbers. Real snapshots write
    ``Constraints: 22/23 enforced (96%)`` — the prefix before the
    first colon is stable; the values after vary. Matching on that
    stable prefix is strict enough to catch field-rename regressions
    without becoming brittle to value changes.

    Two cases:

    - Pattern contains a colon: require the part before-and-including
      the colon to appear in the body.
    - Pattern contains no colon: require the whole pattern as a
      literal substring (rare; covers fields documented as prose).
    """
    colon_index = field_pattern.find(":")
    if colon_index == -1:
        return field_pattern in body
    prefix = field_pattern[: colon_index + 1].strip()
    return prefix in body
