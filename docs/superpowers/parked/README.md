# Parked records

Live threads captured at session close by `/coda`, so that stopping costs
nothing and resuming starts from a concrete step.

**The format lives in the reference documentation**, not here:

- [Parking record format](../../plugins/ai-literacy-superpowers/reference/parking-record-format.md)

This directory holds records; the reference page holds the contract. Keeping
them apart is deliberate — `mkdocs.yml` excludes `docs/superpowers/` from the
published site, so a schema written here would be the one format contract in
the repo an adopter cannot read. It would also be a second copy, free to drift
from the first.

Two rules that govern everything in this directory:

- **Append-only.** No record is ever edited in place or deleted. A transition
  writes a new file.
- **State is in the filename.** `<date>-<slug>.md` is parked;
  `<date>-<slug>.resumed.md` supersedes it.
