"""Phase 2 spike — observatory-verify helper tests.

Validates the per-category strategy from the design spec for the
second P-category command. The helper at
``tdad_tests/spike_helpers/observatory_verify.py`` implements the
Snapshot-source slice of ``/observatory-verify``; these tests cover
its parser and per-signal verifier against fixture snapshot files.

Three things earn coverage here:

- ``parse_signal_checklist`` reads the real
  ``observatory-signals.md`` from the plugin and extracts the
  Snapshot-source signals (real reference; not a fixture). This
  catches drift between the spike helper and the canonical signal
  list.
- ``verify_snapshot`` correctly classifies signals as PRESENT /
  PARTIAL / MISSING / NO_OUTPUT against fixture snapshot files.
- The ``NO_OUTPUT`` path triggers when the snapshot file does not
  exist — the same shape ``/observatory-verify`` produces when no
  snapshot has been generated yet.

These are pure offline tests — no LLM, no SDK invocation. Cost: $0.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from spike_helpers import observatory_verify  # noqa: E402
from spike_helpers.observatory_verify import Status  # noqa: E402


@pytest.fixture(scope="module")
def signal_checklist_path(plugin_path: Path) -> Path:
    """The real signal checklist shipped with the plugin."""
    return (
        plugin_path
        / "skills"
        / "harness-observability"
        / "references"
        / "observatory-signals.md"
    )


@pytest.fixture
def snapshot_signals(signal_checklist_path: Path):
    """Parsed Snapshot-source signals from the real reference doc."""
    return observatory_verify.parse_signal_checklist(signal_checklist_path)


@pytest.mark.structural
class TestParseSignalChecklist:
    """The signal-list parser reads the real checklist correctly."""

    def test_at_least_some_signals_parsed(
        self, snapshot_signals
    ):
        # The Snapshot source declares a substantial number of signals
        # in the reference file — exact count drifts as observability
        # evolves, so assert "more than a handful" rather than an
        # exact number.
        assert len(snapshot_signals) >= 10, (
            f"Expected ≥10 Snapshot signals; got {len(snapshot_signals)}"
        )

    def test_signal_records_carry_name_and_heading(
        self, snapshot_signals
    ):
        """Every parsed signal must have a non-empty name and a
        section heading that starts with the markdown level-2 marker.

        ``key_fields`` may legitimately be empty for some rows whose
        Key Fields column is documented in prose rather than as
        backticked tokens — those signals reduce to a "section
        heading present" check, which is still useful contract."""
        for signal in snapshot_signals:
            assert signal.name, (
                f"Signal record has empty name: {signal!r}"
            )
            assert signal.section_heading.startswith("## "), (
                f"Section heading must start with '## ': "
                f"{signal.section_heading!r}"
            )

    def test_known_signals_appear(self, snapshot_signals):
        """Spot-check: signals that are stable parts of the contract
        should be in the parsed list. Catches a regression where the
        parser silently drops rows."""
        names = {signal.name for signal in snapshot_signals}
        for required in (
            "Enforcement count",
            "Tier breakdown",
            "GC rules count",
            "Reflection count",
        ):
            assert required in names, (
                f"Expected signal {required!r} not parsed from "
                "observatory-signals.md (parser drift suspected)"
            )

    def test_missing_checklist_raises(self, tmp_path: Path):
        nonexistent = tmp_path / "no_signals.md"
        with pytest.raises(FileNotFoundError):
            observatory_verify.parse_signal_checklist(nonexistent)


@pytest.mark.structural
class TestVerifySnapshot:
    """Per-signal status classification against fixture snapshots."""

    def test_signals_whose_section_is_in_fixture_are_all_present(
        self, snapshot_signals, fixtures_dir: Path
    ):
        """For every section the fixture covers, every signal targeting
        that section should report PRESENT.

        The fixture deliberately covers a representative subset of
        snapshot sections — adding all 11+ sections would inflate the
        fixture without strengthening the architectural validation.
        Phase 3 (the rollout PR) is the right place to expand fixture
        coverage to the full snapshot template."""
        snapshot = (
            fixtures_dir / "observatory_verify" / "complete_snapshot.md"
        )
        snapshot_text = snapshot.read_text(encoding="utf-8")
        sections_in_fixture = {
            "## " + line[3:].strip()
            for line in snapshot_text.split("\n")
            if line.startswith("## ") and not line.startswith("###")
        }
        assert sections_in_fixture, (
            "Fixture has no level-2 sections; check it has not been "
            "accidentally emptied"
        )

        results = observatory_verify.verify_snapshot(
            snapshot, snapshot_signals
        )
        in_scope = [
            r for r in results
            if r.signal.section_heading in sections_in_fixture
        ]
        non_present = [
            r for r in in_scope if r.status is not Status.PRESENT
        ]
        assert in_scope, (
            "No signals had sections covered by the fixture; the "
            "fixture and signal list have drifted apart"
        )
        assert not non_present, (
            f"Among {len(in_scope)} in-scope signals, "
            f"{len(non_present)} were not PRESENT: "
            + ", ".join(
                f"{r.signal.name}={r.status.value} ({r.notes})"
                for r in non_present
            )
        )

    def test_missing_section_yields_missing_status(
        self, snapshot_signals, fixtures_dir: Path
    ):
        snapshot = (
            fixtures_dir
            / "observatory_verify"
            / "missing_enforcement_snapshot.md"
        )
        results = observatory_verify.verify_snapshot(
            snapshot, snapshot_signals
        )
        # Every signal whose section heading is "## Enforcement" should
        # be MISSING (the section is removed from the fixture).
        enforcement_signals = [
            r
            for r in results
            if r.signal.section_heading == "## Enforcement"
        ]
        assert enforcement_signals, (
            "Test fixture or signal list lost ## Enforcement signals"
        )
        for result in enforcement_signals:
            assert result.status is Status.MISSING, (
                f"Expected MISSING for {result.signal.name!r}, "
                f"got {result.status.value}"
            )

    def test_section_with_no_key_fields_is_partial(
        self, snapshot_signals, fixtures_dir: Path
    ):
        """The ``missing_enforcement_snapshot.md`` fixture deliberately
        keeps the ``## Mutation Testing`` heading but has no key field
        content. Mutation signals that *do* declare key fields should
        be PARTIAL (heading found, fields absent). Mutation signals
        that declare no key fields are PRESENT vacuously — that is
        the documented semantics of an empty key_fields list."""
        snapshot = (
            fixtures_dir
            / "observatory_verify"
            / "missing_enforcement_snapshot.md"
        )
        results = observatory_verify.verify_snapshot(
            snapshot, snapshot_signals
        )
        mutation_signals = [
            r
            for r in results
            if r.signal.section_heading == "## Mutation Testing"
        ]
        assert mutation_signals, (
            "Signal list lost ## Mutation Testing entries"
        )
        # At least one mutation signal must declare key fields and
        # be reported as PARTIAL — that is the case the test cares
        # about. Other mutation signals (with empty key_fields) are
        # legitimately PRESENT and are not the failure mode the test
        # is asserting.
        partial_with_fields = [
            r
            for r in mutation_signals
            if r.signal.key_fields and r.status is Status.PARTIAL
        ]
        assert partial_with_fields, (
            "Expected at least one PARTIAL mutation signal that "
            "declares key fields. Got: "
            + ", ".join(
                f"{r.signal.name}={r.status.value}"
                f" (fields={len(r.signal.key_fields)})"
                for r in mutation_signals
            )
        )

    def test_no_snapshot_file_yields_no_output(
        self, snapshot_signals, tmp_path: Path
    ):
        nonexistent = tmp_path / "no_snapshot.md"
        results = observatory_verify.verify_snapshot(
            nonexistent, snapshot_signals
        )
        assert results, (
            "verify_snapshot returned no results at all; should still "
            "produce one row per signal with NO_OUTPUT"
        )
        assert all(r.status is Status.NO_OUTPUT for r in results), (
            "All signals should be NO_OUTPUT when snapshot file is "
            "missing"
        )

    def test_none_snapshot_path_yields_no_output(
        self, snapshot_signals
    ):
        """Passing ``None`` as the snapshot path is the explicit
        'no snapshot exists yet' signal from the caller."""
        results = observatory_verify.verify_snapshot(
            None, snapshot_signals
        )
        assert all(r.status is Status.NO_OUTPUT for r in results)
