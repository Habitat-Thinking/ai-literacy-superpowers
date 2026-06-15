# Mermaid vendoring manifest

The `/pipeline-map` command renders its flowchart with [Mermaid](https://mermaid.js.org/).
Per spec §2.2 (as revised at P5), the bundle is **not** committed to this
repo as a multi-megabyte blob. Instead this manifest **pins** an exact
version and records its **SHA-256**; the command fetches the pinned bundle
once into a **gitignored cache**, **verifies the SHA-256 against this
manifest** (aborting on mismatch), and **inlines the verified bytes** into
each generated report. The report therefore carries **no** CDN `<script
src>` — it is a portable, self-contained single file — while the repo
stays free of the binary.

This is the supply-chain contract: the inlined bytes are always the exact
pinned, SHA-verified artefact. A tampered or substituted CDN response
fails the check and **no report is written**.

## Pinned bundle

| Field | Value |
| --- | --- |
| `name` | `mermaid` |
| `version` | `11.6.0` |
| `source_url` | `https://cdn.jsdelivr.net/npm/mermaid@11.6.0/dist/mermaid.min.js` |
| `sha256` | `3a93016a73dc82ba890d919f9bbb176f3da9d98341650c0b517f2595cc68fef8` |
| `bytes` | `2666850` |
| `integrity` | `sha256-OpMBanPcgrqJDZGfm7sXbz2p2YNBZQwLUX8llcxo/vg=` |

The `integrity` value is the same SHA-256 in the Subresource-Integrity
base64 form, for operators who prefer to cross-check with a browser SRI
tool. The canonical check is the hex `sha256` above.

## Cache location (gitignored)

```text
diagnostic-legibility/assets/cache/mermaid-<version>.min.js
```

The `diagnostic-legibility/assets/cache/` directory is gitignored. The
command creates it on first use (`mkdir -p`), writes the fetched bundle
there, and reuses it on subsequent runs (cache-warm path: no network).

## Fetch → verify → inline procedure (command-side)

1. **Cache hit?** If `assets/cache/mermaid-11.6.0.min.js` exists, compute
   its SHA-256 and compare to the manifest. On match, use it (no
   network). On mismatch, treat the cached file as corrupt: delete it and
   fall through to fetch.
2. **Fetch (cache miss).** `curl -fsSL <source_url>` into the cache path.
   A network failure here aborts the command with a clear message (no
   report written) — generation needs network until the cache is warm.
3. **Verify.** Compute the SHA-256 of the fetched bytes and compare to the
   manifest's `sha256`. **On mismatch, abort** — delete the bad file,
   surface the expected vs actual hash, write **no** report. The pin is
   only as good as this check.
4. **Inline.** Read the verified bytes and inline them into the report
   inside a `<script>…</script>` element (never a `<script src>`).

## Updating the pin

To bump Mermaid: fetch the new version, record its `bytes` and recompute
`sha256` (`shasum -a 256 <file>`), update the table above, and clear the
cache directory. The version is a deliberate, reviewed pin — not a
floating `@latest`.
