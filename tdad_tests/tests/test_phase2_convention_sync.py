"""Phase 2 spike — convention-sync helper tests.

Validates the per-category strategy from the design spec
(``docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md``)
for one P-category command. The helper at
``tdad_tests/spike_helpers/convention_sync.py`` implements the Cursor
``conventions.mdc`` slice of ``/convention-sync``; these tests cover
its behaviour against fixture HARNESS.md inputs.

Three cases earn their keep:

- ``parse_context`` extracts Stack and Conventions correctly from a
  fixture HARNESS.md with both subsections populated.
- ``render_cursor_conventions_mdc`` produces output that matches the
  format documented in
  ``ai-literacy-superpowers/skills/convention-sync/SKILL.md`` —
  frontmatter present, headings in order, body content preserved.
- ``sync_cursor_conventions`` (end-to-end) writes to disk and raises
  a clear error when HARNESS.md is missing.

These are pure offline tests — no LLM, no SDK invocation. Cost: $0.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from spike_helpers import convention_sync  # noqa: E402


@pytest.fixture
def harness_fixture(fixtures_dir: Path) -> Path:
    """The sample HARNESS.md used by every test in this module."""
    return fixtures_dir / "convention_sync" / "sample_harness.md"


@pytest.mark.structural
class TestParseContext:
    """The HARNESS.md parser extracts the right subsections."""

    def test_stack_subsection_parsed(self, harness_fixture: Path):
        text = harness_fixture.read_text(encoding="utf-8")
        sections = convention_sync.parse_context(text)
        body = "\n".join(sections.stack)
        assert "Python 3.12" in body
        assert "pytest" in body
        # Garbage Collection content is in a different top-level
        # section and must not leak into Stack.
        assert "Garbage Collection" not in body

    def test_conventions_subsection_parsed(self, harness_fixture: Path):
        text = harness_fixture.read_text(encoding="utf-8")
        sections = convention_sync.parse_context(text)
        body = "\n".join(sections.conventions)
        assert "snake_case" in body
        assert "literate programming" in body

    def test_constraints_section_not_in_stack_or_conventions(
        self, harness_fixture: Path
    ):
        """Stack and Conventions are subsections of Context. Other
        top-level sections (Constraints, Garbage Collection) must not
        leak into either."""
        text = harness_fixture.read_text(encoding="utf-8")
        sections = convention_sync.parse_context(text)
        for body in (sections.stack, sections.conventions):
            joined = "\n".join(body)
            assert "Consistent formatting" not in joined
            assert "No secrets in source" not in joined

    def test_missing_context_returns_empty_sections(self):
        """A HARNESS.md without a Context section yields empty bodies."""
        text = "# Some other doc\n\n## Constraints\n\n- nothing here\n"
        sections = convention_sync.parse_context(text)
        assert sections.stack == []
        assert sections.conventions == []


@pytest.mark.structural
class TestRenderCursorConventions:
    """The Cursor renderer produces correctly-formatted output."""

    def test_output_carries_frontmatter(self, harness_fixture: Path):
        text = harness_fixture.read_text(encoding="utf-8")
        sections = convention_sync.parse_context(text)
        rendered = convention_sync.render_cursor_conventions_mdc(sections)
        # Frontmatter is required by the Cursor format reference and
        # by Cursor itself when interpreting the .mdc.
        assert rendered.startswith("---\n")
        assert "description: Project conventions synced from HARNESS.md" in rendered
        assert "globs: **/*" in rendered
        assert "alwaysApply: true" in rendered

    def test_headings_in_documented_order(self, harness_fixture: Path):
        """The format reference declares the heading order:
        ``# Project Conventions`` → ``## Stack`` → ``## Conventions``.
        Test that ordering is preserved."""
        text = harness_fixture.read_text(encoding="utf-8")
        sections = convention_sync.parse_context(text)
        rendered = convention_sync.render_cursor_conventions_mdc(sections)
        title_idx = rendered.index("# Project Conventions")
        stack_idx = rendered.index("## Stack")
        conv_idx = rendered.index("## Conventions")
        assert title_idx < stack_idx < conv_idx

    def test_body_content_preserved(self, harness_fixture: Path):
        text = harness_fixture.read_text(encoding="utf-8")
        sections = convention_sync.parse_context(text)
        rendered = convention_sync.render_cursor_conventions_mdc(sections)
        # Both subsection bodies should appear in the output.
        assert "Python 3.12" in rendered
        assert "snake_case" in rendered

    def test_empty_subsections_render_a_placeholder(self):
        """A fully-empty Context renders without crashing — the
        renderer leaves a placeholder line so the output is still
        well-formed Cursor mdc."""
        empty = convention_sync.ContextSections()
        rendered = convention_sync.render_cursor_conventions_mdc(empty)
        assert "## Stack" in rendered
        assert "## Conventions" in rendered
        assert "(No stack section found in HARNESS.md.)" in rendered
        assert "(No conventions section found in HARNESS.md.)" in rendered


@pytest.mark.structural
class TestSyncCursorConventionsEndToEnd:
    """End-to-end: read HARNESS.md, render, write the output file."""

    def test_happy_path_writes_expected_file(
        self, harness_fixture: Path, tmp_path: Path
    ):
        output = tmp_path / ".cursor" / "rules" / "conventions.mdc"
        rendered = convention_sync.sync_cursor_conventions(
            harness_fixture, output
        )
        assert output.exists()
        on_disk = output.read_text(encoding="utf-8")
        # The function returns what it wrote — they must match.
        assert on_disk == rendered
        # And the disk content must carry the frontmatter and at least
        # the Stack heading. Full-content checks live in the renderer
        # tests above; this is the integration smoke.
        assert on_disk.startswith("---\n")
        assert "## Stack" in on_disk

    def test_missing_harness_raises_clear_error(self, tmp_path: Path):
        nonexistent = tmp_path / "no_such_harness.md"
        output = tmp_path / "conventions.mdc"
        with pytest.raises(FileNotFoundError) as excinfo:
            convention_sync.sync_cursor_conventions(nonexistent, output)
        message = str(excinfo.value)
        assert "HARNESS.md" in message
        assert str(nonexistent) in message
