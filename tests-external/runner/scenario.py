"""Markdown scenario parser for the TDAB test suite.

Layer 2 and Layer 3 tests are driven by markdown scenario files in
``scenarios/``. The format is human-readable by design: someone proposing
a new plugin component writes a scenario describing its behaviour, and a
runner translates that scenario into an SDK invocation plus assertions.

Why markdown rather than YAML or pure Python? Because the consumer is the
person reviewing a PR for a new component — not the test harness. A
reviewer should be able to read the scenario and judge whether the
component's intent has been captured. YAML is too terse for prose; Python
buries the intent under syntax. Markdown with structured frontmatter is
the medium that fits the audience.

The parser is deliberately minimal. It splits the file into frontmatter
(YAML) and named sections (everything under each ``##`` heading) and
hands a typed record back to the test. The test decides what to do with
each section — parsing does not assume which sections are required.

Sections supported by convention (not enforced by the parser):

- ``Given`` — the fixture state before the component runs
- ``When`` — what is dispatched (a query, a command invocation, an agent task)
- ``Then`` — assertions about outputs (file paths, file content, tool calls)
- ``Rubric`` — guidance for LLM-as-judge grading on probabilistic outputs
- ``Cleanup`` — fixture teardown if needed

A scenario need not include every section. The structural-only check at
Layer 1 typically uses only frontmatter.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

import yaml


# Match a level-2 heading line (e.g. "## Given"). The scenario format
# does not nest headings — sub-headings inside a section would confuse
# the splitter — so we deliberately match level-2 only.
_HEADING_RE = re.compile(r"^##\s+(?P<title>.+?)\s*$", re.MULTILINE)


@dataclass(frozen=True)
class Scenario:
    """A parsed scenario file."""

    path: Path
    """Absolute path to the scenario markdown file."""

    frontmatter: dict
    """Required keys (by convention): ``component``, ``component_type``, ``tier``."""

    sections: dict[str, str] = field(default_factory=dict)
    """Section title → section body. Bodies preserve their original markdown."""

    @property
    def component(self) -> str:
        return str(self.frontmatter.get("component", ""))

    @property
    def component_type(self) -> str:
        return str(self.frontmatter.get("component_type", ""))

    @property
    def tier(self) -> str:
        return str(self.frontmatter.get("tier", ""))


def parse_scenario(path: Path) -> Scenario:
    """Parse a scenario markdown file.

    Raises ``ValueError`` if the frontmatter is missing — every scenario
    must declare its component and tier explicitly. Silent defaults are
    a footgun: a scenario without a component would attach to the wrong
    test, and the test would pass for the wrong reason.
    """
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise ValueError(
            f"{path}: scenario must begin with YAML frontmatter "
            "delimited by '---' lines"
        )

    # Split off the frontmatter.
    body_after_open = text[len("---\n") :]
    closing = body_after_open.find("\n---\n")
    if closing == -1:
        raise ValueError(
            f"{path}: scenario frontmatter is not closed by a '---' line"
        )

    front_text = body_after_open[:closing]
    body_text = body_after_open[closing + len("\n---\n") :]

    frontmatter = yaml.safe_load(front_text) or {}
    if not isinstance(frontmatter, dict):
        raise ValueError(f"{path}: scenario frontmatter must be a YAML mapping")

    # Walk through every level-2 heading, collecting the body that
    # follows until the next heading or end-of-file. Anything before
    # the first heading is discarded — by convention scenarios do not
    # carry untitled prose between frontmatter and the first section.
    sections: dict[str, str] = {}
    matches = list(_HEADING_RE.finditer(body_text))
    for index, match in enumerate(matches):
        title = match.group("title").strip()
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(body_text)
        sections[title] = body_text[start:end].strip("\n")

    return Scenario(path=path, frontmatter=frontmatter, sections=sections)


def list_scenarios(scenarios_dir: Path) -> list[Scenario]:
    """Parse every ``.md`` scenario under a directory tree.

    Files prefixed with ``FINDING-`` are scenarios in the documentary
    sense — they record an architectural finding the spike surfaced
    rather than a test the runner should attempt. The runner skips
    them; the structural test at Layer 1 still validates their
    frontmatter so they cannot drift unnoticed.
    """
    return [parse_scenario(path) for path in sorted(scenarios_dir.rglob("*.md"))]
