# Consultation records

The voices a spec affects, the question worth asking each of them, and what
was decided about each — written by `/convene` after a human disposes.

**The format lives in the reference documentation**, not here:

- [Consultation record format](../../plugins/ai-literacy-superpowers/reference/consultation-record-format.md)

This directory holds records; the reference page holds the contract. Keeping
them apart is deliberate — `mkdocs.yml` excludes `docs/superpowers/` from the
published site, so a schema written here would be the one format contract in
the repo an adopter cannot read. It would also be a second copy, free to drift
from the first.

Two rules that govern everything in this directory:

- **Append-only.** No record is ever edited in place or deleted. Disposing
  voices writes a new `.resolved.md` file.
- **State is in the filename.** `<date>-<slug>.md` is open;
  `<date>-<slug>.resolved.md` supersedes it.
