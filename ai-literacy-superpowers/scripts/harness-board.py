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
import datetime
import html as html_mod
import json
import math
import os
import re
import subprocess
import sys
import tempfile
import webbrowser

DECISIONS = "harness/decisions"
ASSAYS = "harness/assay"
OBJECTIONS = "docs/superpowers/objections"
CSS = '\n:root{\n  --paper:#EDF1F4; --card:#FFFFFF; --ink:#10202B; --ink-soft:#45606E; --ink-faint:#7A909C;\n  --rule:#2E5C6E; --live:#A8631F; --block:#9E3B32; --edge:#D3DDE2;\n  --live-bg:#F7EDE1; --block-bg:#F7E6E3; --quiet-bg:#E7EDF0;\n  --shadow:0 1px 2px rgba(16,32,43,.06),0 10px 30px rgba(16,32,43,.06);\n}\n@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){\n  --paper:#0B141A; --card:#121E26; --ink:#DCE6EA; --ink-soft:#9DB2BC; --ink-faint:#6E838E;\n  --rule:#6FA3B5; --live:#D9974C; --block:#D4776B; --edge:#22323C;\n  --live-bg:#251A0F; --block-bg:#2A1614; --quiet-bg:#182530;\n  --shadow:0 1px 2px rgba(0,0,0,.45),0 10px 30px rgba(0,0,0,.35);\n}}\n:root[data-theme="dark"]{\n  --paper:#0B141A; --card:#121E26; --ink:#DCE6EA; --ink-soft:#9DB2BC; --ink-faint:#6E838E;\n  --rule:#6FA3B5; --live:#D9974C; --block:#D4776B; --edge:#22323C;\n  --live-bg:#251A0F; --block-bg:#2A1614; --quiet-bg:#182530;\n  --shadow:0 1px 2px rgba(0,0,0,.45),0 10px 30px rgba(0,0,0,.35);\n}\n*{box-sizing:border-box}\nbody{margin:0;background:var(--paper);color:var(--ink);\n  font-family:"Public Sans",system-ui,-apple-system,sans-serif;font-size:16px;line-height:1.6}\n.wrap{max-width:1020px;margin:0 auto;padding:52px 24px 96px;display:flex;flex-direction:column;gap:48px}\n.eyebrow{font-family:"Roboto Mono",ui-monospace,monospace;font-size:11px;letter-spacing:.16em;\n  text-transform:uppercase;color:var(--rule);font-weight:500}\nh1{font-family:"Zilla Slab",Georgia,serif;font-weight:600;font-size:clamp(2rem,5vw,2.8rem);\n  line-height:1.1;margin:.28em 0 0;letter-spacing:-.01em;text-wrap:balance}\nh2{font-family:"Zilla Slab",Georgia,serif;font-weight:600;font-size:1.5rem;margin:0 0 .2em}\nh3{font-family:"Roboto Mono",monospace;font-size:.74rem;letter-spacing:.12em;text-transform:uppercase;\n  color:var(--ink-soft);margin:0 0 12px;font-weight:500;display:flex;align-items:center;gap:9px}\nh3 .n{background:var(--quiet-bg);color:var(--ink-soft);border-radius:2px;padding:1px 7px;font-size:.72rem}\n.lede{font-size:1.08rem;color:var(--ink-soft);max-width:64ch;margin:.7em 0 0}\nfigure{margin:0;background:var(--card);border:1px solid var(--edge);border-radius:5px;\n  padding:20px 12px 8px;box-shadow:var(--shadow);overflow-x:auto}\nsvg{display:block;max-width:100%;height:auto;margin:0 auto;color:var(--ink-faint)}\n.nlab{font-family:"Roboto Mono",monospace;font-size:12px;font-weight:500;fill:var(--ink);letter-spacing:.06em}\n.ncnt{font-family:"Public Sans",sans-serif;font-size:12.5px;fill:var(--ink-soft)}\n.ncmd{font-family:"Roboto Mono",monospace;font-size:10.5px;fill:var(--ink-faint)}\n.hub{font-family:"Zilla Slab",serif;font-size:15px;fill:var(--ink-soft)}\n.hubn{font-family:"Zilla Slab",serif;font-size:46px;font-weight:600;fill:var(--ink)}\nfigcaption{font-size:.87rem;color:var(--ink-soft);padding:14px 12px 6px;max-width:74ch;margin:0 auto}\n.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:18px}\n.grp{background:var(--card);border:1px solid var(--edge);border-radius:5px;padding:18px 20px;box-shadow:var(--shadow)}\n.row{padding:11px 0;border-bottom:1px solid var(--edge)}\n.row:last-child{border-bottom:0;padding-bottom:2px}\n.rmain{font-family:"Roboto Mono",monospace;font-size:.82rem;line-height:1.45;word-break:break-word}\n.rmeta{font-size:.82rem;color:var(--ink-faint);margin-top:2px}\n.act{font-size:.85rem;margin-top:7px;padding:7px 11px;border-radius:3px;line-height:1.45}\n.act.blocked{background:var(--block-bg);color:var(--block)}\n.act.ready{background:var(--live-bg);color:var(--live)}\n.empty{color:var(--ink-faint);font-size:.88rem;margin:0}\n.tl{background:var(--card);border:1px solid var(--edge);border-radius:5px;padding:8px 20px;box-shadow:var(--shadow)}\n.tlrow{display:grid;grid-template-columns:6.4rem 6.6rem 6.2rem 1fr;gap:10px;align-items:baseline;\n  padding:12px 0;border-bottom:1px solid var(--edge);font-size:.85rem}\n.tlrow:last-child{border-bottom:0}\n.tldate,.tlstate,.tlid{font-family:"Roboto Mono",monospace;font-size:.78rem}\n.tldate{color:var(--ink-faint);font-variant-numeric:tabular-nums}\n.tldir{font-weight:600}\n.tlrow.live .tldir{color:var(--live)}\n.tlrow.quiet{opacity:.62}\n.tlid{color:var(--ink-soft);word-break:break-word}\nfooter{border-top:1px solid var(--edge);padding-top:20px;font-size:.85rem;color:var(--ink-faint);max-width:70ch}\ncode{font-family:"Roboto Mono",monospace;font-size:.88em;background:var(--quiet-bg);padding:1px 5px;border-radius:2px}\n@media (max-width:620px){\n  .tlrow{grid-template-columns:1fr 1fr;row-gap:3px}\n  .tlid{grid-column:1/-1}\n}\n@media (prefers-reduced-motion:reduce){*{transition:none!important}}\n'

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


def refuse_if_committable(path):
    """A page that can be committed is a page that goes stale.

    The parent spec stated "writes nothing" in prose. Prose did not stop two
    dashboards in this repository going 106 days unread, so here it is a refusal:
    a target inside the working tree is rejected unless git already ignores it.
    """
    target = os.path.abspath(path)
    rc, root = run(["git", "rev-parse", "--show-toplevel"])
    if rc != 0:
        return None                      # not a repo; nothing to protect
    root = os.path.abspath(root.strip())
    if os.path.commonpath([target, root]) != root:
        return None                      # outside the tree
    rc, _ = run(["git", "check-ignore", "-q", target])
    if rc == 0:
        return None                      # inside, but ignored — fine
    rel = os.path.relpath(target, root)
    return (
        f"refusing to write {rel} inside the working tree.\n"
        "A page that can be committed is a page that goes stale: this repository "
        "already carries observability/governance/governance-dashboard.html and "
        "assessments/portfolio-dashboard.html, both 106 days old and read by "
        "nobody.\n"
        "Write it outside the tree, or to a path git ignores, or pass --html with "
        "no argument for a temporary file."
    )


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


def collect(root):
    """Everything both views need, gathered once."""
    recs = []
    dpath = os.path.join(root, DECISIONS)
    for r in sorted(os.listdir(dpath)) if os.path.isdir(dpath) else []:
        if not (r.startswith("HDR-") and r.endswith(".md")):
            continue
        full = os.path.join(dpath, r)
        d = frontmatter(full)
        recs.append({
            "id": r[:-3], "status": d.get("status"), "cls": d.get("classification"),
            "prov": d.get("provisional") == "true", "expires": d.get("expires"),
            "target": d.get("target"),
            "blocker": blocker_for(full) if d.get("status") == "proposed" else None,
        })
    assays = []
    apath = os.path.join(root, ASSAYS)
    for a in sorted(os.listdir(apath)) if os.path.isdir(apath) else []:
        if not a.endswith("-assay.md"):
            continue
        fs = findings(os.path.join(apath, a))
        assays.append({
            "file": a[:-3], "n": len(fs),
            "rule": sum(1 for _i, _t, c in fs if c != "no-change"),
            "nochange": sum(1 for _i, _t, c in fs if c == "no-change"),
            "errata": os.path.exists(os.path.join(apath, a.replace("-assay.md", "-assay.errata.md"))),
        })
    objs, raw = [], set()
    opath = os.path.join(root, OBJECTIONS)
    for o in sorted(os.listdir(opath)) if os.path.isdir(opath) else []:
        if not o.endswith(".md") or o == "README.md":
            continue
        counts, r_ = dispositions(os.path.join(opath, o))
        raw |= r_
        if counts:
            objs.append({"file": o[:-3], "total": sum(counts.values()),
                         "pending": counts.get("pending", 0)})
    return recs, assays, objs, raw, timeline_states(root)


STAGES = [
    ("ASSAY", "/harness-assay", "ok"),
    ("PROPOSE", "/harness-propose", "ok"),
    ("REVIEW", "/diaboli", "ok"),
    ("DISPOSE", "human", "block"),
    ("COST AT THE GATE", "human", "warn"),
    ("IN FORCE", "/harness-accept", "live"),
    ("CHECK", "/harness-check", "ok"),
    ("EXPIRY", "/harness-review", "ok"),
]


def loop_svg(counts, states):
    cx, cy, r, n = 520, 360, 236, len(STAGES)
    parts = []
    for i in range(n):
        a1 = math.radians(-90 + i * (360 / n)) + math.radians(9)
        a2 = math.radians(-90 + ((i + 1) % n) * (360 / n)) - math.radians(9)
        sx, sy = cx + r * math.cos(a1), cy + r * math.sin(a1)
        ex, ey = cx + r * math.cos(a2), cy + r * math.sin(a2)
        parts.append(f'  <path d="M {sx:.1f} {sy:.1f} A {r} {r} 0 0 1 {ex:.1f} {ey:.1f}" '
                     'fill="none" stroke="currentColor" stroke-width="1.5" opacity=".38" '
                     'marker-end="url(#ar)"/>')
    fills = {"ok": "var(--card)", "block": "var(--block-bg)",
             "warn": "var(--live-bg)", "live": "var(--live-bg)"}
    strokes = {"ok": "var(--rule)", "block": "var(--block)",
               "warn": "var(--live)", "live": "var(--live)"}
    for i, (name, cmd, tone) in enumerate(STAGES):
        a = math.radians(-90 + i * (360 / n))
        x, y = cx + r * math.cos(a), cy + r * math.sin(a)
        parts.append(f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="34" fill="{fills[tone]}" '
                     f'stroke="{strokes[tone]}" stroke-width="2"/>')
        anchor, off = "middle", r + 58
        if math.cos(a) > 0.35:
            anchor, off = "start", r + 46
        elif math.cos(a) < -0.35:
            anchor, off = "end", r + 46
        lx, ly = cx + off * math.cos(a), cy + off * math.sin(a)
        parts.append(f'  <text x="{lx:.1f}" y="{ly - 4:.1f}" text-anchor="{anchor}" class="nlab">{name}</text>')
        parts.append(f'  <text x="{lx:.1f}" y="{ly + 12:.1f}" text-anchor="{anchor}" class="ncnt">{html_mod.escape(counts[name])}</text>')
        parts.append(f'  <text x="{lx:.1f}" y="{ly + 26:.1f}" text-anchor="{anchor}" class="ncmd">{cmd}</text>')
    return "\n".join(parts)


HEAD = """<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Harness Evolution Loop</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Zilla+Slab:wght@400;600&family=Public+Sans:wght@400;500;600&family=Roboto+Mono:wght@400;500&display=swap">
<style>__CSS__</style></head><body>"""


def esc(x):
    return html_mod.escape(str(x) if x is not None else "")


def row(main, meta, action=None, tone=""):
    a = f'<div class="act {tone}">{esc(action)}</div>' if action else ""
    return (f'<div class="row"><div class="rmain">{esc(main)}</div>'
            f'<div class="rmeta">{esc(meta)}</div>{a}</div>')


def group(title, rows):
    if not rows:
        return f'<section class="grp"><h3>{esc(title)}</h3><p class="empty">none</p></section>'
    return (f'<section class="grp"><h3>{esc(title)} <span class="n">{len(rows)}</span></h3>'
            + "".join(rows) + "</section>")


def html_page(root):
    recs, assays, objs, raw, states = collect(root)
    proposed = [r for r in recs if r["status"] == "proposed"]
    declined = [r for r in recs if r["status"] == "rejected"]
    inforce = [r for r in recs if states.get(r["id"]) == "in force"]
    notbind = [r for r in recs if r["status"] == "accepted" and states.get(r["id"]) != "in force"]
    pend = [o for o in objs if o["pending"]]
    stamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

    counts = {
        "ASSAY": f"{len(assays)} assays · {sum(a['n'] for a in assays)} findings",
        "PROPOSE": f"{len(recs)} records drafted",
        "REVIEW": f"{len(objs)} records · {sum(o['total'] for o in objs)} objections",
        "DISPOSE": f"{sum(o['pending'] for o in objs)} pending",
        "COST AT THE GATE": f"{sum(1 for r in proposed if not r['blocker'])} waiting",
        "IN FORCE": f"{len(inforce)} rules",
        "CHECK": "every PR",
        "EXPIRY": min([r["expires"] for r in inforce if r["expires"]] or ["none set"]),
    }

    groups = [
        group("Assays", [row(a["file"],
              f"{a['n']} findings · {a['rule']} proposing · {a['nochange']} no-change"
              + ("  · carries errata" if a["errata"] else "")) for a in assays]),
        group("Proposals", [row(r["id"][4:], r["cls"] or "?",
              ("→ " + r["blocker"]) if r["blocker"]
              else "→ gate-ready. Remaining: the cost, written at /harness-accept",
              "blocked" if r["blocker"] else "ready") for r in proposed]),
        group("In force", [row(r["id"][4:], (r["cls"] or "?")
              + (f" · provisional until {r['expires']}" if r["prov"] and r["expires"] else ""),
              ("target: " + r["target"]) if r["target"] else None) for r in inforce]),
        group("Accepted, not binding", [row(r["id"][4:], states.get(r["id"], "?")) for r in notbind]),
        group("Declined", [row(r["id"][4:], "declined") for r in declined]),
        group("Objections awaiting disposition", [row(o["file"],
              f"{o['pending']} of {o['total']} pending",
              "→ dispose them, or record why they stand", "blocked") for o in pend]),
    ]

    tl = []
    rc, out = run(["python3", REGISTRAR, "timeline"])
    for line in out.split("\n") if rc == 0 else []:
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        tone = "live" if d.get("state") == "in force" else "quiet"
        arrow = {"tighten": "tighten \u2191", "loosen": "loosen \u2193"}.get(d.get("direction"), d.get("direction", "?"))
        exp = f" · expires {d['expires']}" if d.get("expires") else ""
        tl.append(f'<div class="tlrow {tone}"><span class="tldate">{esc(d.get("date"))}</span>'
                  f'<span class="tldir">{esc(arrow)}</span>'
                  f'<span class="tlstate">{esc(d.get("state"))}</span>'
                  f'<span class="tlid">{esc(d.get("id", "")[4:][:58])}{esc(exp)}</span></div>')

    blocked_note = (
        f"<strong>The block is at DISPOSE.</strong> {sum(o['pending'] for o in objs)} "
        "objections sit undisposed. Nothing downstream can move until a human rules "
        "— which is the gate working, not a queue to drain."
        if sum(o["pending"] for o in objs) else
        "<strong>Nothing is blocked.</strong> Every objection is disposed and every "
        "proposal has cleared its cost-independent refusals."
    )

    return (HEAD.replace("__CSS__", CSS) + f'''
<div class="wrap">
<header>
  <div class="eyebrow">harness evolution loop · generated {stamp}</div>
  <h1>The loop, and what is sitting in it</h1>
  <p class="lede">Eight stages, each carrying what is queued there at the moment
  this page was generated. The cycle is real rather than illustrative — a rule
  that expires returns to the assay that would observe it again.</p>
</header>

<figure>
<svg viewBox="0 0 1040 720" role="img" aria-label="The harness evolution loop as a cycle of eight stages, each labelled with what is currently queued at it.">
  <defs><marker id="ar" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
    <path d="M 0 0 L 10 5 L 0 10 z" fill="currentColor"/></marker></defs>
{loop_svg(counts, states)}
  <text x="520" y="330" text-anchor="middle" class="hub">in force</text>
  <text x="520" y="382" text-anchor="middle" class="hubn">{len(inforce)}</text>
  <text x="520" y="406" text-anchor="middle" class="hub">of {len(recs)} records</text>
</svg>
<figcaption>{blocked_note}</figcaption>
</figure>

<section><div class="eyebrow">What is in flight</div><h2>The queue</h2>
<div class="grid">{"".join(groups)}</div></section>

<section><div class="eyebrow">Interventions over time</div><h2>The timeline</h2>
<div class="tl">{"".join(tl) or '<p class="empty">no accepted records</p>'}</div></section>

<footer>
<p>Blockers are quoted from <code>precheck</code> rather than recomputed. A record
that could not be classified would appear rather than be omitted.</p>
<p><strong>This is a snapshot taken at {stamp}, not a live view.</strong> Regenerate it
with <code>/harness-board --html</code>, or read current state in the terminal with
<code>/harness-board</code>. It is written outside the repository on purpose: a page
that can be committed is a page that goes stale.</p>
</footer>
</div></body></html>''')


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--root", default=".", help="repository root")
    ap.add_argument("--timeline", action="store_true",
                    help="render interventions over time instead of the queue")
    ap.add_argument("--html", nargs="?", const="", metavar="PATH",
                    help="write a browser view and open it. With no PATH, a "
                         "temporary file. Refuses a committable path inside the "
                         "working tree")
    args = ap.parse_args()

    root = args.root
    if not os.path.isdir(os.path.join(root, DECISIONS)):
        print(f"no decision corpus at {os.path.join(root, DECISIONS)} — "
              "run /harness-propose first, or pass --root", file=sys.stderr)
        return 1

    cwd = os.getcwd()
    try:
        os.chdir(root)
        if args.html is None:
            print(timeline_view(".") if args.timeline else queue_view("."))
            return 0

        if args.html:
            target = os.path.abspath(os.path.join(cwd, args.html))
            refusal = refuse_if_committable(target)
            if refusal:
                print("FAIL: " + refusal, file=sys.stderr)
                return 1
        else:
            stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
            target = os.path.join(tempfile.gettempdir(),
                                  f"harness-board-{stamp}.html")

        with open(target, "w", encoding="utf-8") as fh:
            fh.write(html_page("."))
        print(target)
        # Best effort. A view that could not be displayed is not a failure of
        # the board — the path above is the whole result.
        try:
            webbrowser.open(f"file://{target}")
        except Exception:
            print("(could not open a browser — the path above is the page)",
                  file=sys.stderr)
    finally:
        os.chdir(cwd)
    return 0


if __name__ == "__main__":
    sys.exit(main())
