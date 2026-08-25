#!/usr/bin/env python3
"""Render the harness evolution loop as a queue, with the next action per item.

Read-only by construction. It writes nothing, and it exits non-zero only on its
own failure — never on the corpus's state. The board reports; it does not gate.

Three properties matter more than the rendering, and each comes from an observed
failure on 2026-08-25:

**It quotes `precheck` rather than reimplementing it.** Two implementations of a
refusal rule diverge, and the divergence favours the board, because the board is
what someone reads.

**It never omits what it cannot classify.** A record this script does not
understand is rendered as `unclassified` with its path. A board that silently
drops what it cannot parse reports a smaller world than it checked — the subject
of the rule currently in force.

**It writes nothing.** A file that must be regenerated becomes a file that is
stale. This repository carries two stored dashboards that went 106 days unread.
"""
import argparse
import json
import os
import re
import subprocess
import sys

DECISIONS = "harness/decisions"
ASSAYS = "harness/assay"
OBJECTIONS = "docs/superpowers/objections"
REGISTRAR = "ai-literacy-superpowers/scripts/harness-registrar.py"

# Older records use singular forms. Normalised for counting; the raw value is
# preserved and shown where it differs, because the schema permits both and
# check-objection-taxonomy.py passes on all of them.
DISPOSITION_ALIASES = {"accept": "accepted", "amend": "amended", "reject": "rejected"}


def frontmatter(path):
    """The record's frontmatter as a flat dict of scalars. Never raises."""
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        return {}
    if not text.startswith("---"):
        return {}
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    out = {}
    for line in parts[1].split("\n"):
        m = re.match(r"^([a-z_]+):\s*(.*)$", line)
        if m:
            out[m.group(1)] = m.group(2).strip()
    return out


def run(cmd):
    """(rc, combined output). A tool that is absent is a failure, not a pass."""
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        return p.returncode, (p.stdout + p.stderr).strip()
    except (OSError, subprocess.SubprocessError) as exc:
        return 127, f"could not run {' '.join(cmd)}: {exc}"


def blocker_for(path):
    """The exact refusal standing between this record and acceptance.

    Quoted from precheck, never recomputed here.
    """
    rc, out = run(["python3", REGISTRAR, "precheck", "--hdr", path])
    if rc == 0:
        return None
    first = next((l for l in out.split("\n") if l.startswith("FAIL:")), out)
    return re.sub(r"^FAIL: [^:]+: ", "", first).strip()


def dispositions(path):
    """(normalised counts, raw values that differed)."""
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        return {}, set()
    counts, raw_seen = {}, set()
    for value in re.findall(r"^\s+disposition:\s*(\S+)\s*$", text, re.M):
        norm = DISPOSITION_ALIASES.get(value, value)
        if norm != value:
            raw_seen.add(value)
        counts[norm] = counts.get(norm, 0) + 1
    return counts, raw_seen


def findings(path):
    """(finding id, title, classification) for each finding in an assay."""
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        return []
    out = []
    for block in re.split(r"(?=^### finding-)", text, flags=re.M)[1:]:
        head = block.split("\n")[0]
        m = re.match(r"### (finding-\d+) — (.+)", head)
        if not m:
            continue
        cls = re.search(r"^classification:\s*(\S+)", block, re.M)
        out.append((m.group(1), m.group(2).strip(), cls.group(1) if cls else "?"))
    return out


def wrap(text, width, indent):
    words, lines, cur = text.split(), [], ""
    for w in words:
        if len(cur) + len(w) + 1 > width:
            lines.append(cur)
            cur = w
        else:
            cur = f"{cur} {w}".strip()
    if cur:
        lines.append(cur)
    return ("\n" + " " * indent).join(lines)


def timeline_states(root):
    """id -> derived state, read from the registrar rather than recomputed."""
    rc, out = run(["python3", REGISTRAR, "timeline"])
    if rc != 0:
        return {}
    states = {}
    for line in out.split("\n"):
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        if d.get("id"):
            states[d["id"]] = d.get("state", "?")
    return states


def queue_view(root):
    lines, unclassified = [], []

    # ---- assays -----------------------------------------------------------
    assays = sorted(
        p for p in os.listdir(os.path.join(root, ASSAYS))
        if p.endswith("-assay.md")
    ) if os.path.isdir(os.path.join(root, ASSAYS)) else []
    lines.append("ASSAYS")
    if not assays:
        lines.append("  none")
    for a in assays:
        fs = findings(os.path.join(root, ASSAYS, a))
        nochange = sum(1 for _, _, c in fs if c == "no-change")
        rule = len(fs) - nochange
        errata = os.path.exists(os.path.join(root, ASSAYS, a.replace("-assay.md", "-assay.errata.md")))
        note = "  (carries errata)" if errata else ""
        lines.append(f"  {a[:-3]:<26} {len(fs)} findings   "
                     f"{rule} proposing · {nochange} no-change{note}")

    # ---- decision records -------------------------------------------------
    recs = sorted(
        p for p in os.listdir(os.path.join(root, DECISIONS))
        if p.startswith("HDR-") and p.endswith(".md")
    ) if os.path.isdir(os.path.join(root, DECISIONS)) else []

    buckets = {"proposed": [], "accepted": [], "rejected": []}
    for r in recs:
        path = os.path.join(root, DECISIONS, r)
        fm = frontmatter(path)
        status = fm.get("status")
        if status in buckets:
            buckets[status].append((r, fm, path))
        else:
            unclassified.append((r, status or "no status field"))

    lines.append("")
    lines.append("PROPOSALS")
    if not buckets["proposed"]:
        lines.append("  none")
    for r, fm, path in buckets["proposed"]:
        slug = r[4:-3]
        blocker = blocker_for(path)
        state = "precheck: clean" if blocker is None else "precheck: REFUSED"
        lines.append(f"  {slug[:52]:<54} {state}")
        if blocker:
            lines.append("      → " + wrap(blocker, 66, 8))
        else:
            lines.append("      → gate-ready. Remaining: the cost, written at "
                         "/harness-accept")

    # `status: accepted` is not the same as in force — a superseded rule and a
    # retirement are both accepted and neither binds anything. The registrar's
    # timeline already derives that state, so it is read rather than recomputed.
    states = timeline_states(root)
    lines.append("")
    lines.append("IN FORCE")
    live = [(r, fm) for r, fm, _ in buckets["accepted"]
            if states.get(r[:-3]) == "in force"]
    if not live:
        lines.append("  none")
    for r, fm in live:
        slug = r[4:-3]
        exp = fm.get("expires")
        prov = " · provisional until " + exp if fm.get("provisional") == "true" and exp else ""
        lines.append(f"  {slug[:52]:<54} {fm.get('classification','?')}{prov}")

    closed = [(r, states.get(r[:-3], "?")) for r, _f, _p in buckets["accepted"]
              if states.get(r[:-3]) != "in force"]
    if closed:
        lines.append("")
        lines.append("ACCEPTED BUT NOT BINDING")
        for r, st in closed:
            lines.append(f"  {r[4:-3][:52]:<54} {st}")

    if buckets["rejected"]:
        lines.append("")
        lines.append("DECLINED")
        for r, _fm, _p in buckets["rejected"]:
            lines.append(f"  {r[4:-3][:52]}")

    # ---- objection records ------------------------------------------------
    objs = sorted(
        p for p in os.listdir(os.path.join(root, OBJECTIONS))
        if p.endswith(".md") and p != "README.md"
    ) if os.path.isdir(os.path.join(root, OBJECTIONS)) else []
    stuck = []
    raw_forms = set()
    for o in objs:
        counts, raw = dispositions(os.path.join(root, OBJECTIONS, o))
        raw_forms |= raw
        if counts.get("pending"):
            stuck.append((o, counts["pending"], sum(counts.values())))
    lines.append("")
    lines.append("OBJECTIONS AWAITING DISPOSITION")
    if not stuck:
        lines.append(f"  none — all {len(objs)} records adjudicated")
    for o, pending, total in stuck:
        lines.append(f"  {o[:-3][:52]:<54} {pending}/{total} pending")
        lines.append("      → dispose them, or record why they stand")

    if raw_forms:
        lines.append("")
        lines.append("  note: non-canonical disposition values normalised for "
                     "counting: " + ", ".join(sorted(raw_forms)))

    if unclassified:
        lines.append("")
        lines.append("UNCLASSIFIED — shown because omitting them would report a "
                     "smaller world than was checked")
        for r, why in unclassified:
            lines.append(f"  {DECISIONS}/{r}: {why}")

    return "\n".join(lines)


def timeline_view(root):
    rc, out = run(["python3", REGISTRAR, "timeline"])
    if rc != 0:
        return f"timeline unavailable (registrar exited {rc}):\n{out}"
    rows = []
    for line in out.split("\n"):
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            rows.append(("?", "?", "?", line[:60]))
            continue
        rows.append((d.get("date", "?"), d.get("direction", "?"),
                     d.get("state", "?"), d.get("id", "?")))
    if not rows:
        return "no accepted records — the timeline is empty"
    width = max(len(r[2]) for r in rows)
    return "\n".join(
        f"  {d}  {dirn:<8}  {state:<{width}}  {rid[:56]}"
        for d, dirn, state, rid in sorted(rows))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--root", default=".", help="repository root")
    ap.add_argument("--timeline", action="store_true",
                    help="render interventions over time instead of the queue")
    args = ap.parse_args()

    root = args.root
    if not os.path.isdir(os.path.join(root, DECISIONS)):
        print(f"no decision corpus at {os.path.join(root, DECISIONS)} — "
              "run /harness-propose first, or pass --root", file=sys.stderr)
        return 1

    cwd = os.getcwd()
    try:
        os.chdir(root)
        print(timeline_view(".") if args.timeline else queue_view("."))
    finally:
        os.chdir(cwd)
    return 0


if __name__ == "__main__":
    sys.exit(main())
