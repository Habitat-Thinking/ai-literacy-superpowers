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

# advisory < validated < blocked. The ladder exists so "achieved" can be derived
# rather than asserted.
LADDER = {"advisory": 1, "validated": 2, "blocked": 3}

REPORT_REL = os.path.join("harness", "enforcement-report.md")
INDEX_REL = os.path.join("harness", "decisions", "index.md")

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


class AssayError(Exception):
    """The assay document itself is unreadable — frontmatter, or no findings."""


class FindingError(Exception):
    """One finding does not satisfy the contract.

    A raise rather than an exit, because the two consumers need opposite
    behaviour. `propose` wants the first failure and nothing else — it is acting
    on one finding. `lint-assay` wants them all, because at write time the
    question is whether the DOCUMENT is well-formed, and a linter that stopped
    at the first defect would send an author round the loop once per mistake
    against a record that is append-only once written.
    """


class Finding:
    def __init__(self, fid, title, observation, meta, rule_block, cost_estimate):
        self.id = fid
        self.title = title
        self.observation = observation
        self.meta = meta
        self.rule_block = rule_block
        self.cost_estimate = cost_estimate


def parse_assay_doc(path: str) -> tuple[dict, list[tuple[str, str, str]]]:
    """(frontmatter, [(id, title, block)]). Raises AssayError, never exits."""
    with open(path, encoding="utf-8") as handle:
        text = handle.read()

    raw_fm, body = S0.split_frontmatter(text)
    if raw_fm is None:
        raise AssayError(f"{path}: no YAML frontmatter block.")
    try:
        fm = S0.parse_yaml(raw_fm)
    except S0.YamlError as exc:
        raise AssayError(f"{path}: frontmatter could not be read: {exc}")

    for key in ("agent", "model"):
        if not fm.get(key):
            raise AssayError(
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
        raise AssayError(f"{path}: no '## Findings' section.")

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
    if not raw:
        raise AssayError(
            f"{path}: the '## Findings' section contains no findings. "
            "`no-change` exists so that an assay with nothing to change can say "
            "so as a finding — recording that nothing needed to change is itself "
            "evidence, and an empty section records nothing at all."
        )
    return fm, raw


def parse_assay(path: str) -> tuple[dict, list[tuple[str, str, str]]]:
    """The exiting wrapper `propose` uses."""
    try:
        return parse_assay_doc(path)
    except AssayError as exc:
        die(str(exc))


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
        raise FindingError(f"{where}: no ```yaml metadata block.")
    try:
        meta = S0.parse_yaml(raw_meta)
    except S0.YamlError as exc:
        raise FindingError(f"{where}: metadata block could not be read: {exc}")
    for key in FINDING_REQUIRED_KEYS:
        if key not in meta:
            raise FindingError(f"{where}: metadata is missing '{key}'.")

    # The observation prose is everything before the metadata block. A finding
    # with no observation is not a finding — it is a rule with a citation, and
    # the HDR's `## Finding` section would have nothing to say.
    observation = preamble.split("```", 1)[0].strip()
    if not observation:
        raise FindingError(
            f"{where}: no observation prose between the heading and the metadata "
            "block. A finding must say what was observed."
        )

    if "Proposed rule" not in subsections:
        raise FindingError(f"{where}: no '#### Proposed rule' section.")
    if "Cost estimate" not in subsections:
        raise FindingError(f"{where}: no '#### Cost estimate' section.")

    cost_estimate = subsections["Cost estimate"].strip()
    if not cost_estimate:
        raise FindingError(f"{where}: '#### Cost estimate' is empty.")

    rule_text = subsections["Proposed rule"]
    if meta.get("classification") == "no-change":
        if "No change." not in rule_text:
            raise FindingError(f"{where}: a no-change finding's proposed rule must say 'No change.'")
        rule_block = None
    else:
        blocks = S0.rule_blocks(rule_text)
        if len(blocks) != 1:
            raise FindingError(
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
    # The finding may already know which artifact should own the rule. Often it
    # does not — an Assayer can see that a behaviour belongs to an agent without
    # knowing which of four agent files owns it — so this is copied when present
    # and left for the human at the acceptance gate when it is not.
    if meta.get("target"):
        lines.append(f"target: {meta['target']}")
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
    try:
        match = _parse_finding(assay_abs, selected[0], selected[1], selected[2])
    except FindingError as exc:
        die(str(exc))

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

    # Applying and compiling are NOT separate approval gates. Once an HDR is
    # accepted there is no decision left in either step, and a gate with no
    # decision behind it is the exact shape of approval theatre. The two gates
    # that remain are the two where a human is genuinely deciding: writing the
    # cost, and reviewing the resulting diff.
    #
    # So the plan is computed against the corpus as it WOULD be, before anything
    # is written. A target that does not exist, or a file with ambiguous
    # markers, refuses the whole acceptance rather than leaving a record
    # accepted and unapplied.
    records = substitute(load_records(args.root), args.hdr, candidate)
    _, errors, _ = compile_plan(args.root, records)
    if errors:
        for line in errors:
            print(line)
        die("acceptance refused: the rule could not be applied. Nothing was "
            "written and the HDR is still proposed.")

    with open(hdr_abs, "w", encoding="utf-8") as handle:
        handle.write(candidate)

    plan, errors, _ = compile_plan(args.root, load_records(args.root))
    if errors:  # pragma: no cover - the dry run above already refused these
        for line in errors:
            print(line)
        die("acceptance applied the record but compilation failed. Run "
            "/harness-compile.")
    write_plan(args.root, plan)
    print(f"accepted and applied {args.hdr}")
    return 0


# --------------------------------------------------------------------------- #
# Records                                                                      #
# --------------------------------------------------------------------------- #


class Record:
    """One HDR, parsed once and passed around.

    Compilation reads the corpus in three different ways — to route rule text, to
    build the index, to build the enforcement report — and acceptance has to do
    all three against a candidate that is not on disk yet. Parsing once into a
    value that can be substituted is what makes the dry run possible.
    """

    def __init__(self, rel: str, text: str):
        self.rel = rel
        self.text = text
        raw_fm, body = S0.split_frontmatter(text)
        self.fm = S0.parse_yaml(raw_fm) if raw_fm else {}
        self.body = body or ""
        self.id = str(self.fm.get("id") or os.path.basename(rel)[:-3])
        self.status = self.fm.get("status")
        self.classification = self.fm.get("classification")

    @property
    def surfaces(self) -> list[str]:
        return [str(s) for s in (self.fm.get("surfaces") or [])]

    @property
    def rule_body(self) -> str | None:
        section = S0.sections(self.body).get("Rule")
        if section is None:
            return None
        blocks = S0.rule_blocks(section)
        return blocks[0] if len(blocks) == 1 else None


def load_records(root: str) -> list[Record]:
    decisions = os.path.join(root, "harness", "decisions")
    out = []
    if os.path.isdir(decisions):
        for name in sorted(os.listdir(decisions)):
            if not name.startswith("HDR-") or not name.endswith(".md"):
                continue
            rel = os.path.join("harness", "decisions", name)
            with open(os.path.join(root, rel), encoding="utf-8") as handle:
                out.append(Record(rel, handle.read()))
    out.sort(key=lambda r: r.id)
    return out


def substitute(records: list[Record], rel: str, text: str) -> list[Record]:
    """The corpus as it WOULD be with one record replaced. No I/O."""
    rel = os.path.normpath(rel)
    out = [r for r in records if os.path.normpath(r.rel) != rel]
    out.append(Record(rel, text))
    out.sort(key=lambda r: r.id)
    return out


# --------------------------------------------------------------------------- #
# The index                                                                    #
# --------------------------------------------------------------------------- #


def render_index(records: list[Record]) -> str:
    rows = []
    for record in records:
            fm = record.fm
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
        handle.write(render_index(load_records(root)))
    return path


def cmd_lint_assay(args) -> int:
    """Check every finding in an assay against the contract, in one pass.

    Deliberately NOT a CI gate. An assay is an append-only record of what an
    agent observed at a moment; failing the build retroactively over one
    malformed block would pressure someone to edit a record, which is the one
    thing the append-only rule forbids. This runs at write time, where the
    author can still fix it.
    """
    path = os.path.join(args.root, args.assay)
    if not os.path.isfile(path):
        die(f"assay not found at {args.assay}")
    try:
        _, raw = parse_assay_doc(path)
    except AssayError as exc:
        die(str(exc))

    errors = []
    for fid, title, block in raw:
        try:
            _parse_finding(path, fid, title, block)
        except FindingError as exc:
            errors.append(f"FAIL: {exc}")

    for line in errors:
        print(line)
    if errors:
        print(f"\n{len(errors)} of {len(raw)} finding(s) do not satisfy the contract.")
        return 1
    print(f"assay OK ({len(raw)} finding(s) checked)")
    return 0


def cmd_index(args) -> int:
    path = write_index(args.root)
    print(f"wrote {os.path.relpath(path, args.root)}")
    return 0


# --------------------------------------------------------------------------- #
# Compilation: classification routes, surfaces report                          #
# --------------------------------------------------------------------------- #
#
# The build spec asks compilation to regenerate "the marked regions of every
# control surface". Taken literally that puts two generators on one file — in
# this repository `/convention-sync` already owns three of the five convention
# files — and it is ambiguous wherever a surface lists a directory among its
# targets, since nothing says which of `.claude/agents/`'s many files an
# agent-instruction belongs in.
#
# So: CLASSIFICATION decides where the rule text goes, one artifact per HDR.
# SURFACES decide who is told about it, and the enforcement report is what they
# are told. Every property the build spec was after survives — verbatim
# application inside markers, idempotent repair, a gap report as a primary
# output — without the collision or the ambiguity.


class MarkerError(Exception):
    """The generated markers in a file are ambiguous."""


def find_marker_span(text: str) -> tuple[int, int] | None:
    """(first, last) line indices of the marker pair, or None if absent.

    Refuses rather than guessing. Working out which BEGIN belongs to which END is
    exactly how a generator ends up eating hand-written content, and there is no
    safe default: picking the outermost pair swallows everything between two
    regions, picking the innermost silently orphans one.
    """
    lines = text.splitlines()
    begins = [i for i, line in enumerate(lines) if line.strip() == GENERATED_BEGIN]
    ends = [i for i, line in enumerate(lines) if line.strip() == GENERATED_END]
    if not begins and not ends:
        return None
    if len(begins) != 1 or len(ends) != 1:
        raise MarkerError(
            f"found {len(begins)} BEGIN and {len(ends)} END markers; exactly one "
            "of each is required"
        )
    if ends[0] < begins[0]:
        raise MarkerError("the END marker appears before the BEGIN marker")
    return begins[0], ends[0]


def apply_region(text: str, region: str) -> str:
    """Replace the marked region, or append one. Never touches anything else."""
    span = find_marker_span(text)
    lines = text.splitlines()
    if span is None:
        body = "\n".join(lines).rstrip("\n")
        return body + "\n\n" + region.rstrip("\n") + "\n"
    start, end = span
    new = lines[:start] + region.rstrip("\n").split("\n") + lines[end + 1:]
    return "\n".join(new).rstrip("\n") + "\n"


def load_matrix(root: str) -> tuple[dict[str, str], dict[str, dict]]:
    path = os.path.join(root, "harness", "surfaces.yaml")
    surfaces: dict = {}
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as handle:
            try:
                doc = S0.parse_yaml(handle.read())
                surfaces = doc.get("surfaces") or {}
            except S0.YamlError:
                surfaces = {}
    return S0.effective_routes(root), surfaces


def target_of(record: Record, routes: dict[str, str]) -> str | None:
    if record.classification == "no-change":
        return None
    routed = routes.get(str(record.classification))
    if routed:
        return routed
    target = record.fm.get("target")
    return str(target) if target else None


def has_validator(record: Record, root: str) -> bool:
    """A validator counts only if the file it names actually exists.

    A declared-but-absent validator is the failure the report is built to catch,
    so believing the declaration would defeat the mechanism at the one point it
    is supposed to bite.
    """
    value = record.fm.get("validator")
    if not value:
        return False
    items = value if isinstance(value, list) else [value]
    return any(os.path.exists(os.path.join(root, str(item))) for item in items)


def achieved_for(intended: str, supports: list[str], validated: bool) -> tuple[str, str]:
    """(achieved, reason). See the spec's §5.1 ladder."""
    supports = [s for s in supports if s in LADDER]
    if intended in supports:
        candidate, reason = intended, ""
    else:
        lower = [s for s in supports if LADDER[s] < LADDER.get(intended, 0)]
        if not lower:
            return "none", f"surface supports neither {intended} nor anything below it"
        candidate = max(lower, key=lambda s: LADDER[s])
        reason = f"surface supports at most {candidate}"
    if LADDER[candidate] >= LADDER["validated"] and not validated:
        if "advisory" in supports:
            return "advisory", "no validator declared or resolvable"
        return "none", "no validator declared or resolvable"
    return candidate, reason


def enforcement_rows(record: Record, surfaces: dict, root: str) -> list[dict]:
    intended = str(record.fm.get("enforcement") or "advisory")
    validated = has_validator(record, root)
    rows = []
    for name in record.surfaces:
        entry = surfaces.get(name) or {}
        supports = [str(s) for s in (entry.get("supports") or [])]
        achieved, reason = achieved_for(intended, supports, validated)
        if not supports:
            achieved, reason = "none", f"surface '{name}' is not declared"
        rows.append({
            "surface": name, "intended": intended, "achieved": achieved,
            "gap": achieved != intended, "reason": reason,
        })
    return rows


def enforcement_summary(record: Record, surfaces: dict, root: str) -> str:
    """The one-line account rendered beside the rule, where it is read.

    A rule declaring `blocked` that is merely advisory on the surface someone is
    actually reading should admit that there, not only in a report they may
    never open.
    """
    parts = [f"Intended: {record.fm.get('enforcement')}"]
    for row in enforcement_rows(record, surfaces, root):
        mark = " (gap)" if row["gap"] else ""
        parts.append(f"{row['surface']}: {row['achieved']}{mark}")
    if record.fm.get("provisional") is True:
        expiry = record.fm.get("expires") or record.fm.get("review_trigger")
        parts.append(f"provisional until {expiry}")
    return "_" + " · ".join(parts) + "_"


def render_region(records: list[Record], surfaces: dict, root: str) -> str:
    out = [GENERATED_BEGIN, "",
           "<!-- Compiled from harness/decisions/. "
           "Run /harness-compile to regenerate. -->"]
    for record in records:
        body = record.rule_body
        if body is None:
            continue
        out += ["", f"### {record.id} — {record.fm.get('title')}", "",
                enforcement_summary(record, surfaces, root), ""]
        out += body.rstrip("\n").split("\n")
    out += ["", GENERATED_END]
    return "\n".join(out)


def render_report(records: list[Record], surfaces: dict, root: str) -> str:
    accepted = [r for r in records
                if r.status == "accepted" and r.classification != "no-change"]
    routes, _ = load_matrix(root)

    total = gaps = 0
    sections: list[str] = []
    for record in accepted:
        rows = enforcement_rows(record, surfaces, root)
        total += len(rows)
        gaps += sum(1 for row in rows if row["gap"])
        sections += ["", f"## {record.id} — {record.fm.get('title')}", "",
                     f"Target: `{target_of(record, routes)}` · classification: "
                     f"`{record.classification}`", "",
                     "| Surface | Intended | Achieved | Gap | Why |",
                     "| --- | --- | --- | --- | --- |"]
        for row in rows:
            sections.append(
                f"| {row['surface']} | {row['intended']} | {row['achieved']} | "
                f"{'gap' if row['gap'] else 'ok'} | {row['reason'] or '—'} |")

    out = [
        "# Enforcement report",
        "",
        "For every accepted rule, on every surface it names: the enforcement "
        "level **intended**, and the level **achieved**.",
        "",
        "A rule that intends `blocked` on a surface that can only advise is "
        "reported as a gap, never silently downgraded. Knowing which rules are "
        "actually enforced, and which are merely written down, is the point.",
        "",
        GENERATED_BEGIN,
        "",
    ]
    if accepted:
        out.append(f"Gaps: {gaps} of {total} rule-surface pairs.")
        out += sections
    else:
        out.append("No accepted decisions.")
    out += ["", GENERATED_END, ""]
    return "\n".join(out)


def compile_plan(root: str, records: list[Record]) -> tuple[dict[str, str], list[str], list[str]]:
    """(files to write, errors, targets with no region yet). Writes nothing."""
    routes, surfaces = load_matrix(root)
    errors: list[str] = []
    unapplied: list[str] = []

    by_target: dict[str, list[Record]] = {}
    for record in records:
        if record.status != "accepted" or record.classification == "no-change":
            continue
        target = target_of(record, routes)
        if not target:
            errors.append(
                f"FAIL: {record.rel}: classification '{record.classification}' "
                "has no route and the HDR names no 'target'."
            )
            continue
        by_target.setdefault(target, []).append(record)

    plan: dict[str, str] = {}
    for target in sorted(by_target):
        abs_target = os.path.join(root, target)
        if not os.path.isfile(abs_target):
            errors.append(
                f"FAIL: target artifact '{target}' does not exist. The Registrar "
                "writes records, not governance documents — create it first."
            )
            continue
        with open(abs_target, encoding="utf-8") as handle:
            text = handle.read()
        try:
            span = find_marker_span(text)
        except MarkerError as exc:
            errors.append(f"FAIL: {target}: malformed generated markers — {exc}.")
            continue
        if span is None:
            unapplied.append(target)
        region = render_region(by_target[target], surfaces, root)
        plan[target] = apply_region(text, region)

    plan[INDEX_REL] = render_index(records)
    plan[REPORT_REL] = render_report(records, surfaces, root)
    return plan, errors, unapplied


def write_plan(root: str, plan: dict[str, str]) -> list[str]:
    written = []
    for rel, text in sorted(plan.items()):
        path = os.path.join(root, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        current = None
        if os.path.isfile(path):
            with open(path, encoding="utf-8") as handle:
                current = handle.read()
        if current == text:
            continue
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        written.append(rel)
    return written


def cmd_compile(args) -> int:
    root = args.root
    records = load_records(root)
    plan, errors, _ = compile_plan(root, records)
    if errors:
        for line in errors:
            print(line)
        die("compilation refused; nothing was written.")
    written = write_plan(root, plan)
    if written:
        print("compiled: " + ", ".join(written))
    else:
        print("compiled: already up to date")
    return 0


# --------------------------------------------------------------------------- #
# The drift check                                                              #
# --------------------------------------------------------------------------- #


def git(root: str, *args: str) -> tuple[int, str]:
    result = subprocess.run(["git", "-C", root, *args],
                            capture_output=True, text=True, check=False)
    return result.returncode, result.stdout


def frozen_violations(root: str, records: list[Record]) -> tuple[list[str], list[str]]:
    """(violations, notes) for accepted HDRs changed since they were accepted.

    Region drift catches a hand-edit to a COMPILED rule. It cannot catch the
    failure this whole design is arranged against: an agent with write authority
    rewording the rule in the accepted HDR and recompiling. The region would then
    match the corpus exactly, every byte-identity check would pass, and the rule
    in force would quietly differ from the one a human approved.

    So an accepted record is compared against its content at the commit that
    accepted it.
    """
    violations: list[str] = []
    notes: list[str] = []
    accepted = [r for r in records if r.status == "accepted"]
    if not accepted:
        return violations, notes
    code, _ = git(root, "rev-parse", "--git-dir")
    if code != 0:
        notes.append("note: not a git repository — the frozen-record check was skipped.")
        return violations, notes

    for record in accepted:
        code, out = git(root, "log", "--format=%H", "--reverse", "--", record.rel)
        revs = [line.strip() for line in out.splitlines() if line.strip()]
        if not revs:
            notes.append(
                f"note: {record.rel} is accepted but not yet committed, so its "
                "frozen-record check was skipped. Human review of the diff is "
                "what closes that window."
            )
            continue
        baseline = None
        for rev in revs:
            code, blob = git(root, "show", f"{rev}:{record.rel}")
            if code != 0:
                continue
            raw_fm, _ = S0.split_frontmatter(blob)
            if raw_fm and "status: accepted" in raw_fm:
                baseline = blob
                break
        if baseline is None:
            notes.append(
                f"note: {record.rel} has no committed revision in which it was "
                "accepted, so its frozen-record check was skipped."
            )
            continue
        if baseline != record.text:
            violations.append(
                f"FAIL: {record.rel}: an accepted HDR is frozen, and this one "
                "differs from its content at the commit that accepted it. A "
                "later decision supersedes a rule; nothing edits one."
            )
    return violations, notes


def cmd_check(args) -> int:
    root = args.root
    problems: list[str] = []
    notes: list[str] = []

    result = subprocess.run([sys.executable, VALIDATOR, root],
                            capture_output=True, text=True, check=False)
    if result.returncode != 0:
        problems.append((result.stdout + result.stderr).strip())

    records = load_records(root)
    plan, errors, unapplied = compile_plan(root, records)
    problems += errors

    for target in unapplied:
        problems.append(
            f"FAIL: {target}: accepted rules route here but the file has no "
            "generated region — the decision was accepted and never applied. "
            "Run /harness-compile."
        )

    for rel, text in sorted(plan.items()):
        if rel in unapplied:
            continue
        path = os.path.join(root, rel)
        current = None
        if os.path.isfile(path):
            with open(path, encoding="utf-8") as handle:
                current = handle.read()
        if current != text:
            problems.append(
                f"FAIL: {rel}: drift — the generated content differs from what "
                "the decision corpus produces. Run /harness-compile to repair, "
                "or supersede the decision if the change was intended."
            )

    violations, more_notes = frozen_violations(root, records)
    problems += violations
    notes += more_notes

    for note in notes:
        print(note)
    for line in problems:
        print(line)
    if problems:
        print(f"\n{len(problems)} harness problem(s). This is a build failure.")
        return 1
    print(f"harness check: OK ({len(records)} decision(s))")
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

    p = sub.add_parser("lint-assay", help="check every finding against the contract")
    p.add_argument("--assay", required=True)
    p.set_defaults(func=cmd_lint_assay)

    p = sub.add_parser("compile", help="idempotent repair of every generated region")
    p.set_defaults(func=cmd_compile)

    p = sub.add_parser("check", help="read-only drift detection; the CI entry point")
    p.set_defaults(func=cmd_check)

    args = parser.parse_args(argv[1:])
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
