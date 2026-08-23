#!/usr/bin/env python3
"""The Harness Registrar's write path: propose, precheck, accept, index.

The Registrar applies human-approved governance changes and keeps the decision
record. It has write authority over governance artifacts and **no interpretive
authority** — it never authors a rule, and it never decides that one is a good
idea.

WHY THE COPY IS A SCRIPT AND NOT AN AGENT. The build spec says
`/harness-propose` copies the proposed rule text verbatim. The Registrar is a
plugin agent, so the obvious implementation is to let it read the assay and
write the HDR — and that implementation cannot deliver what the sentence
promises. A model asked to copy text usually copies it and occasionally
*improves* it: fixes a typo, tidies an inconsistent bullet, rewraps a line.
Every one of those is a silent edit to a rule a human is about to approve
believing it to be the Assayer's words.

    Verbatim by construction, not verbatim by instruction.

So the rule block and the evidence list are extracted here, byte for byte, and
the agent never holds them in its output at all. Its job is to locate the assay,
present the findings, run this script, and read refusals back in plain language.

WHY ACCEPTANCE STAGES THE WHOLE CORPUS. Acceptance must be all-or-nothing, and
two of the S0 refusals are corpus-level: the three-per-cycle cap and the
two-assay promotion threshold compare HDRs against each other, so neither can be
evaluated from the candidate alone. `accept` therefore copies the entire
`harness/` tree to a temporary root with the candidate substituted, runs the S0
validator there, and writes the real file only on exit 0. "Nothing is written
and the HDR stays proposed" is then a property of the mechanism rather than a
promise in a document.

WHY THE S0 MODULE IS IMPORTED RATHER THAN REIMPLEMENTED. `check-harness-
decisions.py` already knows what frontmatter is, what a section is, and — most
importantly — where a four-backtick rule block ends. A second implementation
here would be a second opinion about the shape of a rule, and the two would
diverge on exactly the input that matters.

Spec: docs/superpowers/specs/2026-08-23-harness-evolution-s1-registrar-design.md
Tests: tdad_tests/layer0_deterministic/test-harness-registrar.sh (R1-R16)
No third-party dependencies (CI-friendly).
"""

from __future__ import annotations

import argparse
import datetime
import importlib.util
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
VALIDATOR = os.path.join(HERE, "check-harness-decisions.py")

# The marker a proposed tier-2 section carries until a human fills it in. It has
# to be recognisable to a machine and obvious to a reader, because the failure it
# guards against is somebody accepting an HDR whose argument was never made.
PLACEHOLDER_PREFIX = "_TODO —"

GENERATED_BEGIN = "<!-- BEGIN GENERATED: harness-registrar — do not edit by hand -->"
GENERATED_END = "<!-- END GENERATED: harness-registrar -->"

DEFAULT_PROVISIONAL_DAYS = 90

TIER2_PLACEHOLDERS = [
    ("Why this layer",
     "why this change belongs at this layer and not one layer down"),
    ("Enforcement",
     "how the rule binds on each listed surface, and where it is only advisory"),
    ("Validation",
     "how anyone would know later whether this rule helped"),
    ("Rejected alternatives",
     "including the 'no change' option, with the reason it was not taken"),
]


def _load_validator_module():
    """Import the S0 validator as a module, hyphenated filename and all."""
    spec = importlib.util.spec_from_file_location("harness_decisions", VALIDATOR)
    if spec is None or spec.loader is None:  # pragma: no cover - packaging error
        die(f"cannot load the S0 validator at {VALIDATOR}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def die(message: str, code: int = 1) -> None:
    print(f"FAIL: {message}")
    sys.exit(code)


S0 = _load_validator_module()


# --------------------------------------------------------------------------- #
# Fence-aware markdown scanning                                                #
# --------------------------------------------------------------------------- #
#
# A heading inside a fenced block is not a heading. This matters more here than
# it usually would: the thing being copied IS markdown, routinely containing its
# own fences and occasionally its own headings, and a naive split would cut a
# rule in half at the exact moment the mechanism is supposed to be preserving it
# byte for byte.


def fence_aware_lines(text: str):
    """Yield (line, inside_fence) for each line, tracking backtick fences."""
    open_len = 0
    for line in text.splitlines():
        stripped = line.strip()
        match = re.match(r"^(`{3,})", stripped)
        if open_len:
            # A closing fence is a run of at least as many backticks, alone.
            if match and len(match.group(1)) >= open_len and stripped == match.group(1):
                yield line, True
                open_len = 0
                continue
            yield line, True
            continue
        if match:
            open_len = len(match.group(1))
            yield line, True
            continue
        yield line, False


def split_on_heading(text: str, prefix: str) -> list[tuple[str, str]]:
    """Split into (heading_text, block_text) on `prefix` headings outside fences."""
    out: list[tuple[str, str]] = []
    current: str | None = None
    buf: list[str] = []
    for line, in_fence in fence_aware_lines(text):
        if not in_fence and line.startswith(prefix):
            if current is not None:
                out.append((current, "\n".join(buf)))
            current = line[len(prefix):].strip()
            buf = []
            continue
        if current is not None:
            buf.append(line)
    if current is not None:
        out.append((current, "\n".join(buf)))
    return out


def first_info_fence(text: str, info: str) -> str | None:
    """The contents of the first ```<info> block, or None."""
    collecting = False
    buf: list[str] = []
    for line in text.splitlines():
        stripped = line.strip()
        if not collecting and re.match(r"^`{3,}" + re.escape(info) + r"\s*$", stripped):
            collecting = True
            continue
        if collecting:
            if re.match(r"^`{3,}\s*$", stripped):
                return "\n".join(buf)
            buf.append(line)
    return None


# --------------------------------------------------------------------------- #
# The assay-finding contract                                                   #
# --------------------------------------------------------------------------- #
#
# S1 owns this contract; S3's Assayer writes to it. It is deliberately narrow —
# only what `propose` must read. Everything else in an assay report (the
# executive summary, what created friction, rejected candidates, unresolved
# questions) is prose for a human, and the Registrar never parses it.

FINDING_HEADING = re.compile(r"^([a-z0-9]+(?:-[a-z0-9]+)*)\s*[—–-]\s*(.+)$")

FINDING_REQUIRED_KEYS = ["classification", "enforcement", "surfaces", "evidence", "priority"]


class Finding:
    def __init__(self, fid, title, observation, meta, rule_block, cost_estimate):
        self.id = fid
        self.title = title
        self.observation = observation
        self.meta = meta
        self.rule_block = rule_block
        self.cost_estimate = cost_estimate


def parse_assay(path: str) -> tuple[dict, list[Finding]]:
    with open(path, encoding="utf-8") as handle:
        text = handle.read()

    raw_fm, body = S0.split_frontmatter(text)
    if raw_fm is None:
        die(f"{path}: no YAML frontmatter block.")
    try:
        fm = S0.parse_yaml(raw_fm)
    except S0.YamlError as exc:
        die(f"{path}: frontmatter could not be read: {exc}")

    for key in ("agent", "model"):
        if not fm.get(key):
            die(
                f"{path}: assay frontmatter must declare '{key}'. An HDR records "
                "which model proposed it, because a rule proposed by a model that "
                "has since been replaced is a rule whose evidence deserves "
                "re-reading."
            )

    findings_block = None
    for heading, block in split_on_heading(body, "## "):
        if heading.lower() == "findings":
            findings_block = block
            break
    if findings_block is None:
        die(f"{path}: no '## Findings' section.")

    # Headings only. Findings are parsed LAZILY, one at a time, because a single
    # malformed finding must not block proposing from a well-formed one — an
    # assay is written by an agent under a materiality test, not by a compiler,
    # and one bad block should cost one finding rather than the whole report.
    raw = []
    for heading, block in split_on_heading(findings_block, "### "):
        match = FINDING_HEADING.match(heading)
        if not match:
            continue
        raw.append((match.group(1), match.group(2), block))
    return fm, raw


def _parse_finding(path: str, fid: str, title: str, block: str) -> Finding:
    where = f"{path} finding '{fid}'"

    subsections = dict(split_on_heading(block, "#### "))
    # Everything before the first `#### ` — prose then the metadata block.
    preamble = block
    for line, in_fence in fence_aware_lines(block):
        if not in_fence and line.startswith("#### "):
            preamble = block[: block.index(line)]
            break

    raw_meta = first_info_fence(preamble, "yaml")
    if raw_meta is None:
        die(f"{where}: no ```yaml metadata block.")
    try:
        meta = S0.parse_yaml(raw_meta)
    except S0.YamlError as exc:
        die(f"{where}: metadata block could not be read: {exc}")
    for key in FINDING_REQUIRED_KEYS:
        if key not in meta:
            die(f"{where}: metadata is missing '{key}'.")

    # The observation prose is everything before the metadata block. A finding
    # with no observation is not a finding — it is a rule with a citation, and
    # the HDR's `## Finding` section would have nothing to say.
    observation = preamble.split("```", 1)[0].strip()
    if not observation:
        die(
            f"{where}: no observation prose between the heading and the metadata "
            "block. A finding must say what was observed."
        )

    if "Proposed rule" not in subsections:
        die(f"{where}: no '#### Proposed rule' section.")
    if "Cost estimate" not in subsections:
        die(f"{where}: no '#### Cost estimate' section.")

    cost_estimate = subsections["Cost estimate"].strip()
    if not cost_estimate:
        die(f"{where}: '#### Cost estimate' is empty.")

    rule_text = subsections["Proposed rule"]
    if meta.get("classification") == "no-change":
        if "No change." not in rule_text:
            die(f"{where}: a no-change finding's proposed rule must say 'No change.'")
        rule_block = None
    else:
        blocks = S0.rule_blocks(rule_text)
        if len(blocks) != 1:
            die(
                f"{where}: '#### Proposed rule' must hold exactly one "
                f"four-backtick block, found {len(blocks)}."
            )
        rule_block = blocks[0]

    return Finding(fid, title.strip(), observation, meta, rule_block, cost_estimate)


# --------------------------------------------------------------------------- #
# Writing an HDR                                                               #
# --------------------------------------------------------------------------- #


def slugify(title: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
    return re.sub(r"-{2,}", "-", slug)


def block_scalar(value: str, indent: str = "  ") -> str:
    lines = value.rstrip("\n").split("\n")
    return "\n".join(indent + line if line.strip() else "" for line in lines)


def render_hdr(hdr_id: str, finding: Finding, assay_path: str, assay_fm: dict,
               today: datetime.date) -> str:
    meta = finding.meta
    classification = meta["classification"]
    is_no_change = classification == "no-change"

    # The finding's evidence, plus the assay anchor. This is what makes the
    # two-assay promotion threshold behave as the worked cycle describes: a
    # first-time loop-layer finding cites one assay and is refused at
    # acceptance; a corroborated one names the prior assay in its own evidence,
    # reaches two, and passes.
    evidence = [str(item) for item in (meta.get("evidence") or [])]
    anchor = f"{assay_path}#{finding.id}"
    if anchor not in evidence:
        evidence.append(anchor)

    surfaces = meta.get("surfaces") or []

    lines = ["---"]
    lines.append(f"id: {hdr_id}")
    lines.append(f"title: {finding.title}")
    lines.append("status: proposed")
    lines.append(f"classification: {classification}")
    lines.append(f"enforcement: {meta['enforcement']}")
    lines.append("surfaces: [" + ", ".join(str(s) for s in surfaces) + "]")
    if is_no_change:
        lines.append("provisional: false")
    else:
        lines.append("provisional: true")
        expires = today + datetime.timedelta(days=DEFAULT_PROVISIONAL_DAYS)
        lines.append(f"expires: {expires.isoformat()}")
    lines.append("evidence:")
    for item in evidence:
        lines.append(f"  - {item}")
    lines.append("proposed_cost: |")
    lines.append(block_scalar(finding.cost_estimate))
    lines.append('cost: ""')
    lines.append("proposer:")
    lines.append(f"  agent: {assay_fm['agent']}")
    lines.append(f"  model: {assay_fm['model']}")
    lines.append(f"  assay: {assay_path}")
    lines.append("supersedes: null")
    lines.append("superseded_by: null")
    lines.append("---")
    lines.append("")

    lines.append("## Finding")
    lines.append("")
    lines.append(finding.observation)
    lines.append("")

    lines.append("## Rule")
    lines.append("")
    if is_no_change:
        lines.append("No change.")
    else:
        lines.append("````markdown")
        lines.append(finding.rule_block)
        lines.append("````")
    lines.append("")

    # The body Cost section must be non-empty from the moment the HDR exists —
    # S0 refuses an empty required section. So it carries the Assayer's estimate,
    # explicitly labelled as not yet the approver's, and acceptance replaces it
    # wholesale. The frontmatter `cost` stays empty, which is what makes the gap
    # visible rather than merely absent.
    lines.append("## Cost")
    lines.append("")
    lines.append("_Proposed by the Assayer. To be replaced at acceptance by the "
                 "approver's own words:_")
    lines.append("")
    lines.append(finding.cost_estimate)
    lines.append("")

    if classification in S0.TIER2_CLASSIFICATIONS:
        for heading, prompt in TIER2_PLACEHOLDERS:
            lines.append(f"## {heading}")
            lines.append("")
            lines.append(f"{PLACEHOLDER_PREFIX} {prompt}._")
            lines.append("")

    return "\n".join(lines).rstrip("\n") + "\n"


# --------------------------------------------------------------------------- #
# Staging: the transaction                                                     #
# --------------------------------------------------------------------------- #


def validate_staged(root: str, candidate_rel: str, candidate_text: str) -> tuple[int, str]:
    """Validate the corpus as it WOULD be, without writing anything to it."""
    with tempfile.TemporaryDirectory() as staging:
        shutil.copytree(os.path.join(root, "harness"),
                        os.path.join(staging, "harness"))
        target = os.path.join(staging, candidate_rel)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with open(target, "w", encoding="utf-8") as handle:
            handle.write(candidate_text)
        result = subprocess.run(
            [sys.executable, VALIDATOR, staging],
            capture_output=True, text=True, check=False,
        )
        return result.returncode, (result.stdout + result.stderr).strip()


# --------------------------------------------------------------------------- #
# Subcommands                                                                  #
# --------------------------------------------------------------------------- #


def cmd_propose(args) -> int:
    root = args.root
    assay_abs = os.path.join(root, args.assay)
    if not os.path.isfile(assay_abs):
        die(f"assay not found at {args.assay}")

    assay_fm, raw_findings = parse_assay(assay_abs)
    selected = next((r for r in raw_findings if r[0] == args.finding), None)
    if selected is None:
        available = ", ".join(r[0] for r in raw_findings) or "none"
        die(f"finding '{args.finding}' is not in {args.assay} (found: {available})")
    match = _parse_finding(assay_abs, selected[0], selected[1], selected[2])

    today = datetime.date.fromisoformat(args.today) if args.today \
        else datetime.date.today()
    slug = args.slug or slugify(match.title)
    if not slug:
        die(f"could not derive a slug from the finding title {match.title!r}; "
            "pass --slug")
    hdr_id = f"HDR-{today.isoformat()}-{slug}"
    rel = os.path.join("harness", "decisions", hdr_id + ".md")
    target = os.path.join(root, rel)

    # Never overwrite. A collision means two findings resolved to one slug, and
    # silently replacing the first would destroy a proposal nobody knew existed.
    if os.path.exists(target):
        die(f"{rel} already exists — pass --slug to give this one a distinct name.")

    text = render_hdr(hdr_id, match, args.assay, assay_fm, today)

    code, output = validate_staged(root, rel, text)
    if code != 0:
        print(output)
        die(f"the proposed HDR would not validate; nothing was written.")

    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "w", encoding="utf-8") as handle:
        handle.write(text)
    print(f"proposed {rel}")
    if match.meta["classification"] in S0.TIER2_CLASSIFICATIONS:
        print("  tier-2 classification: four sections are placeholders and must "
              "be filled by a human before acceptance.")
    return 0


def unfilled_placeholders(text: str) -> list[str]:
    _, body = S0.split_frontmatter(text)
    return [heading for heading, content in S0.sections(body).items()
            if content.strip().startswith(PLACEHOLDER_PREFIX)]


def build_accepted(text: str, cost: str, approver: str, now: str) -> str:
    """Return the HDR as it would look accepted. Purely textual, no I/O."""
    raw_fm, body = S0.split_frontmatter(text)
    fm_lines = raw_fm.split("\n")

    out: list[str] = []
    skipping_block = False
    for line in fm_lines:
        if skipping_block:
            if line.startswith("  ") or not line.strip():
                continue
            skipping_block = False
        if line.startswith("status:"):
            out.append("status: accepted")
            continue
        if line.startswith("cost:"):
            out.append("cost: |")
            out.append(block_scalar(cost))
            skipping_block = line.rstrip().endswith("|")
            continue
        if line.startswith("supersedes:"):
            out.append(f"approver: {approver}")
            out.append(f"approved_at: {now}")
            out.append(line)
            continue
        out.append(line)

    # The `## Cost` section carried the Assayer's estimate. Acceptance replaces
    # it wholesale — the record must read as the approver's decision, not as a
    # proposal with an annotation.
    body = re.sub(
        r"(?ms)^## Cost\n.*?(?=^## |\Z)",
        "## Cost\n\n" + cost.rstrip("\n") + "\n\n",
        body,
        count=1,
    )
    return "---" + "\n".join(out) + "\n---" + body.rstrip("\n") + "\n"


def _accept_common(args, cost: str, label: str) -> tuple[str, str, str]:
    root = args.root
    hdr_abs = os.path.join(root, args.hdr)
    if not os.path.isfile(hdr_abs):
        die(f"HDR not found at {args.hdr}")
    with open(hdr_abs, encoding="utf-8") as handle:
        text = handle.read()

    raw_fm, _ = S0.split_frontmatter(text)
    if raw_fm is None:
        die(f"{args.hdr}: no YAML frontmatter block.")
    fm = S0.parse_yaml(raw_fm)
    if fm.get("status") != "proposed":
        die(f"{args.hdr}: status is '{fm.get('status')}', not 'proposed'. An "
            "accepted HDR is frozen; a later decision supersedes it rather than "
            "editing it.")

    # Placeholders first. A tier-2 HDR whose argument was never written is not a
    # validation problem — the sections are present and non-empty — so S0 cannot
    # see it. Neither the Assayer nor the Registrar is entitled to write that
    # argument, so acceptance is where it has to be caught.
    missing = unfilled_placeholders(text)
    if missing:
        die(f"{args.hdr}: these sections are still placeholders and must be "
            f"written by a human: {', '.join(missing)}.")

    candidate = build_accepted(text, cost, args.approver, args.now)
    code, output = validate_staged(root, args.hdr, candidate)
    if code != 0:
        print(output)
        die(f"{label} refused; nothing was written and the HDR is still proposed.")
    return hdr_abs, candidate, text


def cmd_precheck(args) -> int:
    # A cost that is non-empty and cannot collide with any proposed_cost, so the
    # cost rule passes vacuously and every OTHER refusal is reported. Asking
    # someone to compose a considered cost for a rule that is about to be
    # refused spends exactly the attention this mechanism exists to protect.
    args.approver = "precheck@example.invalid"
    args.now = "1970-01-01T00:00Z"
    _accept_common(args, "(cost pending — precheck only)", "precheck")
    print(f"{args.hdr}: no refusal stands in the way of acceptance.")
    return 0


def cmd_accept(args) -> int:
    cost_abs = os.path.join(args.root, args.cost_file)
    if not os.path.isfile(cost_abs):
        die(f"cost file not found at {args.cost_file}")
    with open(cost_abs, encoding="utf-8") as handle:
        cost = handle.read().strip()
    if not cost:
        die("the cost is empty. The approver writes what this rule will demand "
            "of whoever works here next, and how it might be gamed.")

    hdr_abs, candidate, _ = _accept_common(args, cost, "acceptance")
    with open(hdr_abs, "w", encoding="utf-8") as handle:
        handle.write(candidate)
    write_index(args.root)
    print(f"accepted {args.hdr}")
    return 0


# --------------------------------------------------------------------------- #
# The index                                                                    #
# --------------------------------------------------------------------------- #


def render_index(root: str) -> str:
    decisions = os.path.join(root, "harness", "decisions")
    rows = []
    if os.path.isdir(decisions):
        for name in sorted(os.listdir(decisions)):
            if not name.startswith("HDR-") or not name.endswith(".md"):
                continue
            with open(os.path.join(decisions, name), encoding="utf-8") as handle:
                raw_fm, _ = S0.split_frontmatter(handle.read())
            if raw_fm is None:
                continue
            fm = S0.parse_yaml(raw_fm)
            surfaces = fm.get("surfaces") or []
            rows.append((
                str(fm.get("id") or name[:-3]),
                str(fm.get("status") or "?"),
                str(fm.get("classification") or "?"),
                str(fm.get("enforcement") or "?"),
                ", ".join(str(s) for s in surfaces) or "—",
                "yes" if fm.get("provisional") is True else "no",
                str(fm.get("expires") or fm.get("review_trigger") or "—"),
            ))
    rows.sort(key=lambda row: row[0])

    out = [
        "# Harness decision index",
        "",
        "One row per Harness Decision Record. Generated from "
        "`harness/decisions/`; the file is rewritten in full on every "
        "acceptance, so hand edits do not survive.",
        "",
        GENERATED_BEGIN,
        "",
    ]
    if rows:
        out.append("| ID | Status | Classification | Enforcement | Surfaces | "
                   "Provisional | Expires |")
        out.append("| --- | --- | --- | --- | --- | --- | --- |")
        for row in rows:
            out.append("| " + " | ".join(row) + " |")
    else:
        out.append("No decisions recorded yet.")
    out += ["", GENERATED_END, ""]
    return "\n".join(out)


def write_index(root: str) -> str:
    decisions = os.path.join(root, "harness", "decisions")
    os.makedirs(decisions, exist_ok=True)
    path = os.path.join(decisions, "index.md")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(render_index(root))
    return path


def cmd_index(args) -> int:
    path = write_index(args.root)
    print(f"wrote {os.path.relpath(path, args.root)}")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--root", default=".", help="repository root")
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("propose", help="draft an HDR from an assay finding")
    p.add_argument("--assay", required=True)
    p.add_argument("--finding", required=True)
    p.add_argument("--slug")
    p.add_argument("--today", help="YYYY-MM-DD; injected so nothing races the clock")
    p.set_defaults(func=cmd_propose)

    p = sub.add_parser("precheck", help="report every refusal that does not need a cost")
    p.add_argument("--hdr", required=True)
    p.set_defaults(func=cmd_precheck)

    p = sub.add_parser("accept", help="the single write transaction")
    p.add_argument("--hdr", required=True)
    p.add_argument("--cost-file", required=True,
                   help="a FILE, never an argument: a cost is multi-line prose, "
                        "and an argument would put the approver's own words into "
                        "shell history one copy-paste from the next HDR")
    p.add_argument("--approver", required=True)
    p.add_argument("--now", required=True, help="ISO timestamp; injected, not read")
    p.set_defaults(func=cmd_accept)

    p = sub.add_parser("index", help="regenerate harness/decisions/index.md")
    p.set_defaults(func=cmd_index)

    args = parser.parse_args(argv[1:])
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
