# The board's browser view — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #590 follow-up
**Provenance:** `docs/superpowers/specs/2026-08-25-harness-board-design.md`, which
listed an HTML view under **Out of scope**. This spec revisits that, and the
reason it can be revisited is narrower than "we changed our mind".
**Scope:** a `--html` option on `/harness-board`.
**Out of scope:** any committed HTML; a CI-generated page; a live view.

## 1. Problem statement

The board's queue view is terminal text. The circular overview of the loop — eight
stages with live queue depth at each — cannot be drawn in a terminal, and it is the
view that answers "where is the constriction" at a glance rather than by reading.

That view was produced once by hand on 2026-08-25 and published as a Claude
artifact. It is a snapshot: it will be wrong the next time anything moves, and
nothing regenerates it.

## 2. Why the original spec ruled this out, and why that reasoning does not apply

The parent spec rejected a stored view, twice, and the reason was specific:

> A file that must be regenerated becomes a file that is stale. This repository
> carries two stored dashboards that went 106 days unread.

That is an argument against a **committed artefact**, not against HTML. The
2026-08-25 assessment found `observability/governance/governance-dashboard.html`
and `assessments/portfolio-dashboard.html` both 106 days stale — they are stale
because they are files in the repository that something must remember to
regenerate.

A page written to a temporary location on every invocation cannot go stale,
because it does not persist to be found later. The failure mode the parent spec
guarded against is **persistence without regeneration**, and this design has
neither half.

## 3. Decision — `--html [PATH]`

```bash
/harness-board --html            # write to a temp file, open it, print the path
/harness-board --html out.html   # write where asked, open it, print the path
```

Generates the same data the queue view renders, as a self-contained page: the
loop as a circular diagram with live depth per stage, the queue groups, and the
timeline.

### 3.1 The constraint becomes a refusal, not a note

The parent spec's "writes nothing" was prose. Here it is enforced:

**The command refuses to write inside the repository's working tree**, unless the
target is ignored by git. A path that would become a committed file is rejected
with the reason, and the reason names the two dashboards.

This is the point of the design. A note saying "do not commit this" is a note; a
tool that will not produce a committable file cannot be the thing that goes stale
in six weeks. The prose constraint failed for two dashboards already.

### 3.2 Default is temporary

With no path, the page is written under the system temp directory with a
timestamped name, so repeat runs do not overwrite a page someone still has open.

### 3.3 Opening is best-effort

`webbrowser.open()` from the standard library. Where no browser can be opened —
a headless session, a container — the command prints the path and exits 0. A view
that could not be displayed is not a failure of the board.

## 4. Acceptance criteria

1. `--html` with no path writes to a temp location, opens it, and prints the path
2. `--html <path>` writes where asked
3. **A path inside the working tree that is not gitignored is refused**, with the
   reason, and nothing is written
4. A gitignored path inside the tree is allowed — the tree stays clean either way
5. The page is self-contained: no external stylesheet, script, or image
6. The page states its own generation timestamp and that it is a snapshot, so a
   reader who finds it later knows what they are looking at
7. `git status` is unchanged after any successful run
8. Failure to open a browser is not an error

Criterion 3 is the one to test adversarially: attempt to write `BOARD.html` at
the repository root and assert both the refusal and that no file appears.

## 5. Rejected alternatives

**Generate into `docs/` and publish with the site.** Rejected — that is the
committed artefact the parent spec ruled out, and the two stale dashboards are the
evidence.

**A `--serve` mode with a local HTTP server.** Rejected: more moving parts than
the problem needs, and a served view invites bookmarking, which is persistence by
another route.

**Write the HTML but never open it.** Rejected as a worse default. A file written
and not shown is a file someone finds later without context, which is how a
snapshot becomes mistaken for current state.

## 6. Version

Minor bump — new behaviour on an existing command. 0.88.0 → 0.89.0.
