#!/usr/bin/env python3
"""Validate the Harness Decision Record corpus and the control-surface matrix.

A Harness Decision Record (HDR) is one governance change: the evidence that
justified it, the exact rule text, the enforcement level it intends, the
surfaces it reaches, who approved it, what it costs the next person, and when
it stops being true. `harness/surfaces.yaml` declares what each control surface
can actually enforce.

WHY EVERY REFUSAL LIVES HERE. The Harness Registrar is a plugin agent holding
`Write`/`Edit` over governance artifacts, which puts a model in the governance
write path. That is a deliberate choice — rule text has to land in a specific
place in a specific document, and that is judgement — but it means the two-role
separation cannot rest on the agent's instructions alone.

    A rule that only exists in an agent's prompt is a rule the agent can
    rationalise around. A rule that exists here is a rule that turns the
    build red.

So the promotion threshold, the cycle cap, the cost rule, the tier rules, the
enum checks and the identifier grammar all live in this file, and
`/harness-accept` is a thin caller: it prompts, it writes, and it invokes this.
If this says no, nothing is written.

TWO RULES CANNOT BE CHECKED FROM ONE FILE. The promotion threshold (§5.2) and
the cycle cap (§5.3) compare HDRs against each other. That is the second reason
they live in a corpus validator rather than in the accepting command — CI
re-checks the whole corpus on every PR, so a threshold cannot be evaded by a
merge that combines two individually-valid branches.

ONE THING THIS DELIBERATELY DOES NOT REJECT. A rule intending `blocked` on a
surface that supports only `advisory` is an *enforcement gap*, not an error.
Reporting it is the primary output of `/harness-compile`. Failing the build over
it would train authors to declare the weakest enforcement any surface supports,
which discards exactly the information the gap report exists to carry.

COMPLETE-IF-PRESENT, NOT REQUIRED. A repository with no `harness/` directory
passes. Adopting this mechanism stays a choice.

Spec: docs/superpowers/specs/2026-08-23-harness-evolution-s0-schema-validator-design.md
Tests: tdad_tests/layer0_deterministic/test-harness-decisions.sh (V1-V19)
No third-party dependencies (CI-friendly).
"""

from __future__ import annotations

import datetime
import os
import re
import sys

HARNESS_DIR = "harness"
DECISIONS_DIR = os.path.join(HARNESS_DIR, "decisions")
SURFACES_FILE = os.path.join(HARNESS_DIR, "surfaces.yaml")
ASSAY_DIR = os.path.join(HARNESS_DIR, "assay")

VALID_STATUS = {"proposed", "accepted", "rejected", "superseded", "expired"}
VALID_ENFORCEMENT = {"advisory", "validated", "blocked"}
VALID_CLASSIFICATION = {
    "harness-loop",
    "turn-instructions",
    "agent-instruction",
    "agent-reference",
    "script-validator",
    "regression-test",
    "new-agent",
    "no-change",
}

# Where a rule's text goes is decided by its classification. Two classifications
# have a fixed home; the rest name their own `target`, because no fixed rule can
# know which of four agent files a given agent instruction belongs in.
#
# A project may override these in `surfaces.yaml`'s `routes` block.
DEFAULT_ROUTES = {
    "harness-loop": "HARNESS.md",
    "turn-instructions": "AGENTS.md",
}

# The classifications whose reach extends beyond a single agent. Process burden
# should be proportional to blast radius, so only these three pay for the four
# extra body sections.
TIER2_CLASSIFICATIONS = {"harness-loop", "script-validator", "new-agent"}

TIER1_SECTIONS = ["Finding", "Rule", "Cost"]
TIER2_SECTIONS = ["Why this layer", "Enforcement", "Validation", "Rejected alternatives"]

ALWAYS_REQUIRED = [
    "id",
    "title",
    "status",
    "classification",
    "enforcement",
    "surfaces",
    "provisional",
    "evidence",
    "proposer",
]

HDR_FILENAME_RE = re.compile(r"^HDR-(\d{4}-\d{2}-\d{2})-(.+)$")
SLUG_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
SURFACE_KEY_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")

# The Rule block is delimited by FOUR backticks, not three. Rule text is
# markdown and routinely contains a three-backtick fence of its own; a
# three-backtick delimiter would terminate on the first nested fence and
# silently truncate the rule that is about to be written into HARNESS.md.
FENCE_RE = re.compile(r"^````\s*[A-Za-z0-9_-]*\s*$")


# --------------------------------------------------------------------------- #
# A YAML subset, and an honest one                                             #
# --------------------------------------------------------------------------- #
#
# This reads the shape these two files actually use — scalars, quoted scalars,
# block scalars (`|`), flow sequences, block sequences, and one level of nested
# mapping — and nothing else. It is not a YAML implementation and does not
# pretend to be: what it cannot read it reports, rather than guessing.
#
# The alternative was a PyYAML dependency. Every existing validator in this
# repository is dependency-free, and a governance gate that fails to install is
# a governance gate that gets removed.


class YamlError(Exception):
    """The document used a construct this reader deliberately does not support."""


def _strip_comment(value: str) -> str:
    """Drop a trailing ` # comment` from an unquoted scalar.

    Only whitespace-then-hash counts, which is what YAML itself does and what
    keeps `harness/assay/x.md#finding-3` intact. An evidence anchor is the most
    common `#` in this corpus, and eating it would silently change what a rule
    claims as its evidence.
    """
    return re.split(r"\s+#", value, maxsplit=1)[0].rstrip()


def _scalar(raw: str) -> object:
    """Interpret one scalar value: quotes, booleans, null, or plain text."""
    raw = raw.strip()
    if len(raw) >= 2 and raw[0] == raw[-1] and raw[0] in ("'", '"'):
        return raw[1:-1]
    raw = _strip_comment(raw)
    if raw in ("true", "True"):
        return True
    if raw in ("false", "False"):
        return False
    if raw in ("null", "~", ""):
        return None
    return raw


def _flow_sequence(raw: str) -> list:
    """`[a, b]` — a single-line sequence."""
    inner = raw.strip()[1:-1].strip()
    if not inner:
        return []
    return [_scalar(part) for part in inner.split(",")]


def _indent_of(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def parse_yaml(text: str) -> dict:
    """Parse the supported subset into a dict. Raises YamlError on the rest."""
    lines = text.splitlines()
    result, _ = _parse_mapping(lines, 0, 0)
    return result


def _parse_mapping(lines: list[str], i: int, indent: int) -> tuple[dict, int]:
    out: dict = {}
    while i < len(lines):
        line = lines[i]
        if not line.strip() or line.lstrip().startswith("#"):
            i += 1
            continue
        cur = _indent_of(line)
        if cur < indent:
            break
        if cur > indent:
            raise YamlError(f"unexpected indentation at line {i + 1}: {line!r}")

        if ":" not in line:
            raise YamlError(f"expected 'key: value' at line {i + 1}: {line!r}")
        key, _, rest = line.strip().partition(":")
        key = key.strip()
        rest = rest.strip()
        i += 1

        if rest.startswith("|"):
            out[key], i = _parse_block_scalar(lines, i, indent)
        elif rest.startswith("["):
            out[key] = _flow_sequence(rest)
        elif rest:
            out[key] = _scalar(rest)
        else:
            # An empty value means the child block below carries it — either a
            # sequence or a nested mapping. Which one is decided by the first
            # non-blank child line, not by the key's name.
            nxt = _peek(lines, i)
            if nxt is None or _indent_of(lines[nxt]) <= indent:
                out[key] = None
            elif lines[nxt].lstrip().startswith("- "):
                out[key], i = _parse_sequence(lines, i, _indent_of(lines[nxt]))
            else:
                out[key], i = _parse_mapping(lines, i, _indent_of(lines[nxt]))
    return out, i


def _peek(lines: list[str], i: int) -> int | None:
    while i < len(lines):
        if lines[i].strip() and not lines[i].lstrip().startswith("#"):
            return i
        i += 1
    return None


def _parse_sequence(lines: list[str], i: int, indent: int) -> tuple[list, int]:
    out: list = []
    while i < len(lines):
        line = lines[i]
        if not line.strip():
            i += 1
            continue
        if _indent_of(line) < indent:
            break
        stripped = line.strip()
        if not stripped.startswith("- "):
            break
        out.append(_scalar(stripped[2:]))
        i += 1
    return out, i


def _parse_block_scalar(lines: list[str], i: int, indent: int) -> tuple[str, int]:
    """A `|` block: every following line indented deeper than the key."""
    body: list[str] = []
    child_indent: int | None = None
    while i < len(lines):
        line = lines[i]
        if not line.strip():
            body.append("")
            i += 1
            continue
        cur = _indent_of(line)
        if cur <= indent:
            break
        if child_indent is None:
            child_indent = cur
        body.append(line[child_indent:])
        i += 1
    while body and not body[-1].strip():
        body.pop()
    return "\n".join(body), i


# --------------------------------------------------------------------------- #
# Markdown frontmatter and body                                                #
# --------------------------------------------------------------------------- #


def split_frontmatter(text: str) -> tuple[str | None, str]:
    """Return (frontmatter_yaml, body). Frontmatter is None when absent."""
    if not text.startswith("---"):
        return None, text
    rest = text[3:]
    end = rest.find("\n---")
    if end == -1:
        return None, text
    return rest[:end], rest[end + 4 :]


def sections(body: str) -> dict[str, str]:
    """Map each `## Heading` to its content, stripped.

    A heading with nothing under it maps to the empty string — which the
    caller then rejects. An empty section is a missing section that looks
    present, and that is worse than an absent one: it reads as done.
    """
    out: dict[str, str] = {}
    current: str | None = None
    buf: list[str] = []
    for line in body.splitlines():
        if line.startswith("## "):
            if current is not None:
                out[current] = "\n".join(buf).strip()
            current = line[3:].strip()
            buf = []
        elif current is not None:
            buf.append(line)
    if current is not None:
        out[current] = "\n".join(buf).strip()
    return out


def rule_blocks(rule_section: str) -> list[str]:
    """Every four-backtick block in the Rule section, content only.

    Phase 2's byte-identity check extracts from here: the text applied to a
    governance artifact must equal this exactly. Keeping the extraction in one
    function means the validator and the compiler can never disagree about
    where a rule ends.
    """
    blocks: list[str] = []
    buf: list[str] | None = None
    for line in rule_section.splitlines():
        if FENCE_RE.match(line):
            if buf is None:
                buf = []
            else:
                blocks.append("\n".join(buf))
                buf = None
            continue
        if buf is not None:
            buf.append(line)
    if buf is not None:
        # An unterminated fence is one block's worth of text with no end. Report
        # it as a block so the count check fires rather than passing vacuously.
        blocks.append("\n".join(buf))
    return blocks


def is_real_date(value: str) -> bool:
    if not DATE_RE.match(value):
        return False
    try:
        datetime.date.fromisoformat(value)
    except ValueError:
        return False
    return True


# --------------------------------------------------------------------------- #
# surfaces.yaml                                                                #
# --------------------------------------------------------------------------- #


def check_routes(doc: dict, errors: list[str]) -> dict[str, str]:
    """Validate the optional `routes` block and return the effective routing.

    Absent, the built-in defaults apply. Present, it must map a known
    classification to a non-empty path — a route to `no-change` is refused
    because a no-change decision has no text to place anywhere.
    """
    routes = doc.get("routes")
    if routes is None:
        return dict(DEFAULT_ROUTES)
    if not isinstance(routes, dict) or not routes:
        errors.append(
            f"FAIL: {SURFACES_FILE}: 'routes' must be a non-empty mapping of "
            "classification to target path."
        )
        return dict(DEFAULT_ROUTES)
    for classification, target in routes.items():
        if classification not in VALID_CLASSIFICATION:
            errors.append(
                f"FAIL: {SURFACES_FILE}: routes names unknown classification "
                f"'{classification}'."
            )
        if classification == "no-change":
            errors.append(
                f"FAIL: {SURFACES_FILE}: 'no-change' cannot be routed — a "
                "no-change decision has no rule text to place."
            )
        if not isinstance(target, str) or not target.strip():
            errors.append(
                f"FAIL: {SURFACES_FILE}: route for '{classification}' must be a "
                "non-empty path."
            )
    return {k: v for k, v in routes.items() if isinstance(v, str) and v.strip()}


def check_surfaces(root: str, errors: list[str]) -> dict[str, dict]:
    """Validate the capability matrix and return it, or {} if unusable."""
    path = os.path.join(root, SURFACES_FILE)
    if not os.path.isfile(path):
        errors.append(
            f"FAIL: {SURFACES_FILE} not found, but {DECISIONS_DIR}/ holds HDRs. "
            "Every HDR names the surfaces it reaches; without the matrix there "
            "is nothing to check those names against."
        )
        return {}

    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    try:
        doc = parse_yaml(text)
    except YamlError as exc:
        errors.append(f"FAIL: {SURFACES_FILE} could not be read: {exc}")
        return {}

    check_routes(doc, errors)

    surfaces = doc.get("surfaces")
    if not isinstance(surfaces, dict) or not surfaces:
        errors.append(
            f"FAIL: {SURFACES_FILE} must have a non-empty top-level 'surfaces' "
            "mapping."
        )
        return {}

    for key, entry in surfaces.items():
        where = f"{SURFACES_FILE} surface '{key}'"
        if not SURFACE_KEY_RE.match(str(key)):
            errors.append(
                f"FAIL: {where}: surface key '{key}' must be lowercase "
                "hyphen-separated (e.g. 'claude-code')."
            )
            continue
        if not isinstance(entry, dict):
            errors.append(f"FAIL: {where}: expected 'targets' and 'supports'.")
            continue

        targets = entry.get("targets")
        if not isinstance(targets, list) or not targets:
            errors.append(f"FAIL: {where}: 'targets' must be a non-empty list.")

        supports = entry.get("supports")
        if not isinstance(supports, list) or not supports:
            errors.append(f"FAIL: {where}: 'supports' must be a non-empty list.")
            continue
        seen: set[str] = set()
        for level in supports:
            if level not in VALID_ENFORCEMENT:
                errors.append(
                    f"FAIL: {where}: unknown enforcement level '{level}' in "
                    f"'supports' (allowed: {', '.join(sorted(VALID_ENFORCEMENT))})."
                )
            if level in seen:
                errors.append(
                    f"FAIL: {where}: duplicate enforcement level '{level}' in "
                    "'supports'."
                )
            seen.add(level)

    return surfaces


# --------------------------------------------------------------------------- #
# One HDR                                                                      #
# --------------------------------------------------------------------------- #


def effective_routes(root: str) -> dict[str, str]:
    """The routing table in force, defaults included."""
    path = os.path.join(root, SURFACES_FILE)
    if not os.path.isfile(path):
        return dict(DEFAULT_ROUTES)
    try:
        with open(path, encoding="utf-8") as handle:
            doc = parse_yaml(handle.read())
    except (OSError, YamlError):
        return dict(DEFAULT_ROUTES)
    routes = doc.get("routes")
    if not isinstance(routes, dict) or not routes:
        return dict(DEFAULT_ROUTES)
    return {k: v for k, v in routes.items() if isinstance(v, str) and v.strip()}


def check_hdr(path: str, surfaces: dict, errors: list[str],
              routes: dict[str, str] | None = None) -> dict | None:
    """Validate one HDR file. Returns its frontmatter for the corpus checks."""
    name = os.path.basename(path)
    stem = name[:-3]
    where = f"{DECISIONS_DIR}/{name}"

    match = HDR_FILENAME_RE.match(stem)
    if not match:
        errors.append(
            f"FAIL: {where}: filename must be HDR-YYYY-MM-DD-<slug>.md. "
            "Sequential numbering collides the moment two people propose on "
            "parallel branches; date-plus-slug is merge-safe."
        )
        return None
    file_date, file_slug = match.group(1), match.group(2)
    if not SLUG_RE.match(file_slug):
        errors.append(
            f"FAIL: {where}: slug '{file_slug}' must be lowercase "
            "hyphen-separated (e.g. 'observed-evidence')."
        )
    if not is_real_date(file_date):
        errors.append(f"FAIL: {where}: '{file_date}' is not a real calendar date.")

    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    raw_fm, body = split_frontmatter(text)
    if raw_fm is None:
        errors.append(f"FAIL: {where}: no YAML frontmatter block.")
        return None
    try:
        fm = parse_yaml(raw_fm)
    except YamlError as exc:
        errors.append(f"FAIL: {where}: frontmatter could not be read: {exc}")
        return None

    fm["__path"] = where

    for field in ALWAYS_REQUIRED:
        if field not in fm:
            errors.append(f"FAIL: {where}: missing required field '{field}'.")

    if "cost" not in fm:
        errors.append(
            f"FAIL: {where}: missing required field 'cost'. It may be empty "
            "while proposed - the human authors it at the acceptance gate - "
            "but the key must exist so the gap is visible."
        )

    if fm.get("id") is not None and fm.get("id") != stem:
        errors.append(
            f"FAIL: {where}: frontmatter id '{fm.get('id')}' does not match the "
            f"filename stem '{stem}'."
        )

    status = fm.get("status")
    if status is not None and status not in VALID_STATUS:
        errors.append(
            f"FAIL: {where}: unknown status '{status}' "
            f"(allowed: {', '.join(sorted(VALID_STATUS))})."
        )
    classification = fm.get("classification")
    if classification is not None and classification not in VALID_CLASSIFICATION:
        errors.append(
            f"FAIL: {where}: unknown classification '{classification}' "
            f"(allowed: {', '.join(sorted(VALID_CLASSIFICATION))})."
        )
    enforcement = fm.get("enforcement")
    if enforcement is not None and enforcement not in VALID_ENFORCEMENT:
        errors.append(
            f"FAIL: {where}: unknown enforcement '{enforcement}' "
            f"(allowed: {', '.join(sorted(VALID_ENFORCEMENT))})."
        )

    imported = fm.get("imported") is True
    provisional = fm.get("provisional")
    is_no_change = classification == "no-change"

    _check_surfaces_field(fm, surfaces, is_no_change, where, errors)
    _check_no_change(fm, is_no_change, where, errors)
    _check_provisional(fm, imported, is_no_change, where, errors)
    _check_imported(fm, imported, provisional, where, errors)
    _check_evidence(fm, where, errors)
    _check_acceptance(fm, status, where, errors)
    _check_body(fm, body, classification, is_no_change, where, errors)
    _check_promotion_threshold(fm, status, classification, imported, where, errors)
    _check_target(fm, status, classification, is_no_change,
                  routes if routes is not None else dict(DEFAULT_ROUTES),
                  where, errors)
    _check_validator(fm, where, errors)

    return fm


def _check_surfaces_field(fm, surfaces, is_no_change, where, errors) -> None:
    value = fm.get("surfaces")
    if value is None:
        return
    if not isinstance(value, list):
        errors.append(f"FAIL: {where}: 'surfaces' must be a list.")
        return
    if not value and not is_no_change:
        errors.append(
            f"FAIL: {where}: 'surfaces' must name at least one surface. Only a "
            "no-change HDR reaches nothing."
        )
    for surface in value:
        # An enforcement level the surface cannot reach is a GAP, reported by
        # the compiler, never a failure here. See the module docstring.
        if surfaces and surface not in surfaces:
            errors.append(
                f"FAIL: {where}: surface '{surface}' is not declared in "
                f"{SURFACES_FILE}."
            )


def _check_no_change(fm, is_no_change, where, errors) -> None:
    """A no-change HDR enforces nothing, so it cannot claim to.

    Recording that nothing needed to change is itself evidence, and an assay in
    which every finding resolves to no-change is a successful assay. What the
    shape must not allow is a no-change HDR that quietly carries an enforcement
    level, because that reads as a rule to everyone downstream.
    """
    if not is_no_change:
        return
    if fm.get("enforcement") not in (None, "advisory"):
        errors.append(
            f"FAIL: {where}: a no-change HDR must be 'advisory' - it enforces "
            f"nothing, so it cannot declare '{fm.get('enforcement')}'."
        )
    if fm.get("provisional") is True:
        errors.append(
            f"FAIL: {where}: a no-change HDR must have 'provisional: false' - "
            "nothing is in force, so nothing can lapse."
        )


def _check_provisional(fm, imported, is_no_change, where, errors) -> None:
    if fm.get("provisional") is not True:
        return
    expires = fm.get("expires")
    trigger = fm.get("review_trigger")
    has_trigger = isinstance(trigger, str) and trigger.strip()
    if expires is None and not has_trigger:
        errors.append(
            f"FAIL: {where}: 'provisional: true' requires 'expires' (a calendar "
            "date) or a non-empty 'review_trigger'. Permanence is earned at "
            "review, not at creation."
        )
        return
    if expires is not None and not is_real_date(str(expires)):
        errors.append(
            f"FAIL: {where}: 'expires' must be a real YYYY-MM-DD date, "
            f"got '{expires}'."
        )


def _check_imported(fm, imported, provisional, where, errors) -> None:
    """Grandfathering, and why it exists.

    A rule lifted from an existing HARNESS.md predates this mechanism, so it has
    no assay to cite and no proposer to name. Importing every legacy rule as
    provisional would manufacture a large expiry cliff on roughly day 90 of
    adoption, with /harness-check going red on rules nobody proposed. People
    then learn to ignore a red check, which costs far more than the
    un-evidenced legacy rules ever did.
    """
    if not imported:
        return
    if provisional is True:
        errors.append(
            f"FAIL: {where}: 'imported: true' with 'provisional: true' is a "
            "contradiction - an imported rule is grandfathered, not on trial."
        )
    if fm.get("expires") is not None:
        errors.append(
            f"FAIL: {where}: an imported HDR must not carry 'expires'."
        )
    proposer = fm.get("proposer")
    agent = proposer.get("agent") if isinstance(proposer, dict) else None
    if agent != "imported":
        errors.append(
            f"FAIL: {where}: an imported HDR must declare "
            f"'proposer.agent: imported', got '{agent}'."
        )


def _check_evidence(fm, where, errors) -> None:
    evidence = fm.get("evidence")
    if evidence is None:
        return
    if not isinstance(evidence, list) or not evidence:
        errors.append(
            f"FAIL: {where}: 'evidence' must be a non-empty list. A rule with no "
            "evidence is a preference."
        )


def _check_acceptance(fm, status, where, errors) -> None:
    """The cost rule, and the fields that make an acceptance attributable.

    THE COST RULE IS THE ANTI-THEATRE REQUIREMENT. A well-written proposal with
    a prioritised backlog is easy to rubber-stamp, and at the governance layer
    that is the worst place for cognitive surrender. So the human writes what
    the rule will demand of whoever works here next, in their own words.

    The source spec asked to refuse a cost "byte-identical to the Assayer's
    proposal" but never said where that proposal lived, which left the rule
    unimplementable. `/harness-propose` writes the Assayer's words into
    `proposed_cost`; the human's go in `cost`. Now it is mechanical - and it
    needs to be, because a copy-pasted cost reads exactly like a considered one.
    """
    if status != "accepted":
        return

    for field in ("approver", "approved_at"):
        value = fm.get(field)
        if value is None or not str(value).strip():
            errors.append(
                f"FAIL: {where}: an accepted HDR requires '{field}'. An "
                "unattributed acceptance is not an approval."
            )

    cost = fm.get("cost")
    cost_text = "" if cost is None else str(cost).strip()
    if not cost_text:
        errors.append(
            f"FAIL: {where}: an accepted HDR requires a non-empty 'cost', "
            "authored by the approver."
        )
        return

    proposed = fm.get("proposed_cost")
    if proposed is not None and str(proposed).strip() == cost_text:
        errors.append(
            f"FAIL: {where}: 'cost' is identical to 'proposed_cost'. The "
            "approver writes the cost in their own words - what the rule will "
            "demand of whoever works here next, and how it might be gamed."
        )


def _check_body(fm, body, classification, is_no_change, where, errors) -> None:
    found = sections(body)
    required = list(TIER1_SECTIONS)
    if classification in TIER2_CLASSIFICATIONS:
        required += TIER2_SECTIONS

    for heading in required:
        if heading not in found:
            errors.append(f"FAIL: {where}: missing required section '## {heading}'.")
        elif not found[heading].strip():
            errors.append(
                f"FAIL: {where}: section '## {heading}' is empty. A heading with "
                "nothing under it reads as done."
            )

    rule = found.get("Rule")
    if rule is None:
        return
    if is_no_change:
        if "No change." not in rule:
            errors.append(
                f"FAIL: {where}: a no-change HDR's '## Rule' section must say "
                "exactly 'No change.'"
            )
        return

    blocks = rule_blocks(rule)
    if len(blocks) != 1:
        errors.append(
            f"FAIL: {where}: section '## Rule' must hold exactly one "
            f"four-backtick block, found {len(blocks)}. That block is the "
            "verbatim text applied to the target artifact, and Phase 2 checks "
            "the applied text against it byte for byte."
        )
    elif not blocks[0].strip():
        errors.append(f"FAIL: {where}: the '## Rule' block is empty.")


def _check_promotion_threshold(
    fm, status, classification, imported, where, errors
) -> None:
    """A single incident cannot reach the loop layer.

    HARNESS.md governs the loop, so a change to it must survive the loop below:
    evidence from at least two distinct assays. Distinctness is by assay FILE,
    not by evidence entry - two anchors into one assay are one assay, and
    letting them count twice would make the threshold satisfiable by anyone
    willing to cite the same finding twice.

    The threshold binds at acceptance, not at proposal. A proposal citing one
    assay is exactly right: it sits and waits for corroboration.
    """
    if status != "accepted" or classification != "harness-loop" or imported:
        return
    evidence = fm.get("evidence")
    if not isinstance(evidence, list):
        return
    assays = {
        str(item).split("#", 1)[0]
        for item in evidence
        if str(item).startswith(ASSAY_DIR + os.sep) or str(item).startswith(ASSAY_DIR + "/")
    }
    if len(assays) < 2:
        errors.append(
            f"FAIL: {where}: a harness-loop change requires evidence from at "
            f"least two distinct assays, found {len(assays)}. Either wait for a "
            "second assay to corroborate, or reclassify to the layer that owns "
            "the behaviour."
        )


def _check_target(fm, status, classification, is_no_change, routes, where, errors) -> None:
    """A rule has to end up somewhere, and someone has to say where.

    Two classifications have a fixed home. The rest do not, and nothing in the
    schema can infer one: `agent-instruction` says the behaviour belongs to an
    agent, not which agent. That choice is the human's, made at the acceptance
    gate beside the cost — which is why it is required at acceptance rather than
    at proposal, when the Assayer often knows the behaviour without yet knowing
    its owner.
    """
    if is_no_change or status != "accepted":
        return
    if classification in routes:
        return
    target = fm.get("target")
    if target is None or not str(target).strip():
        errors.append(
            f"FAIL: {where}: classification '{classification}' has no route in "
            f"{SURFACES_FILE}, so the HDR must name its own 'target' — the "
            "artifact the rule text is written into."
        )


def _check_validator(fm, where, errors) -> None:
    """`validator` is a path or a list of paths. Its ABSENCE is never an error.

    A rule with no validator is not malformed; it is unenforced, which is a
    different fact and one the enforcement report exists to state. Failing here
    would collapse the distinction the whole report is built to preserve.
    """
    value = fm.get("validator")
    if value is None:
        return
    items = value if isinstance(value, list) else [value]
    if not items:
        errors.append(f"FAIL: {where}: 'validator' must not be an empty list.")
    for item in items:
        if not isinstance(item, str) or not item.strip():
            errors.append(
                f"FAIL: {where}: every 'validator' entry must be a non-empty path."
            )


def check_cycle_cap(records: list[dict], errors: list[str]) -> None:
    """At most three accepted HDRs may share one assay.

    The cap is what stops an assay becoming a legislative session. Excess
    proposals are not lost - they stay `proposed` and carry forward to the next
    cycle, where they compete with whatever the next assay found. A finding that
    cannot win a slot twice running probably was not worth a rule.
    """
    by_assay: dict[str, list[str]] = {}
    for fm in records:
        if fm.get("status") != "accepted":
            continue
        proposer = fm.get("proposer")
        if not isinstance(proposer, dict):
            continue
        assay = proposer.get("assay")
        if not assay:
            continue
        by_assay.setdefault(str(assay), []).append(fm.get("id") or fm["__path"])

    for assay, ids in sorted(by_assay.items()):
        if len(ids) > 3:
            errors.append(
                f"FAIL: assay '{assay}' has {len(ids)} accepted HDRs; the cap is "
                f"three per cycle ({', '.join(sorted(ids))}). Leave the excess "
                "'proposed' and carry them forward."
            )


def main(argv: list[str]) -> int:
    root = argv[1] if len(argv) > 1 else "."
    decisions = os.path.join(root, DECISIONS_DIR)

    if not os.path.isdir(os.path.join(root, HARNESS_DIR)):
        # Adopting this mechanism stays a choice.
        return 0

    paths = sorted(
        os.path.join(decisions, name)
        for name in os.listdir(decisions)
        # index.md is generated; README.md documents the corpus. Neither is a
        # decision, and treating either as one would make the directory
        # impossible to document or to compile into.
        if name.endswith(".md") and name not in ("index.md", "README.md")
    ) if os.path.isdir(decisions) else []

    # Check the matrix whenever it EXISTS, and demand it whenever HDRs exist.
    # Gating on `paths` alone would leave the matrix unchecked during day one of
    # adoption - which is precisely when it is being authored and most likely to
    # be wrong.
    errors: list[str] = []
    have_matrix = os.path.isfile(os.path.join(root, SURFACES_FILE))
    surfaces = check_surfaces(root, errors) if (have_matrix or paths) else {}

    routes = effective_routes(root)
    records = []
    for path in paths:
        fm = check_hdr(path, surfaces, errors, routes)
        if fm is not None:
            records.append(fm)
    check_cycle_cap(records, errors)

    for line in errors:
        print(line)
    if errors:
        print(f"\n{len(errors)} harness decision problem(s).")
        return 1
    print(f"harness decisions: OK ({len(records)} HDR(s) checked)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
