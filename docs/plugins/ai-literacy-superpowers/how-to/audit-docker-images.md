---
title: Audit Docker Images
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 14
redirect_from:
  - /how-to/audit-docker-images/
  - /how-to/audit-docker-images.html
---

# Audit Docker Images

This guide walks you through using Docker Scout to audit your Docker images for CVEs, assess base image staleness, and apply hardening recommendations.

**Never assert that a base image version is safe based on training knowledge. Tag aliases like `alpine:3.21` can float. Always run Scout to get the current state.**

---

## 1. Build the image locally

Docker Scout analyses image layers, not Dockerfiles. Build before scanning:

```bash
docker build -t my-app:local .
```

If you have multiple images, build all of them before starting the audit.

---

## 2. Get a quick overview

```bash
docker scout quickview my-app:local
```

This prints a one-line summary such as `5C  3H  6M  63L` (Critical / High / Medium / Low), plus whether a base image refresh or update is available. Run this first for every image to triage where to spend time.

---

## 3. List actionable CVEs

Limit the output to CVEs that have a known patch and are high severity or above — the immediately actionable set:

```bash
docker scout cves \
  --only-severity critical,high \
  --only-fixed \
  my-app:local
```

Drop `--only-fixed` to see the full picture including CVEs with no available patch.

---

## 4. Separate base image CVEs from your own package CVEs

```bash
docker scout cves --ignore-base my-app:local
```

This shows only CVEs introduced by packages your Dockerfile installs, not the base image itself. Use it to separate "update the FROM line" work from "change our installed packages" work.

---

## 5. Get base image recommendations

```bash
docker scout recommendations my-app:local
```

Shows whether a patch refresh of the same base tag or an update to a newer tag would eliminate CVEs, with a count for each option.

If the image uses a hardened base (distroless, chiseled), Scout may error with `image has no base image`. This is expected. In CI, add `continue-on-error: true` to that step.

---

## 6. Follow the triage workflow

Work through each image in this order:

1. `quickview` — is there anything worth fixing?
2. `recommendations` — can a base image bump fix most of it?
3. `cves --only-fixed --only-severity critical,high` — what must be fixed now?
4. `cves --ignore-base` — anything in our own installed packages?

Act on base image CVEs first. A single `FROM` line update often eliminates tens of vulnerabilities in one commit.

---

## 7. Apply Alpine runtime hardening

For Alpine-based runtime stages, use `apk upgrade --no-cache` rather than upgrading specific packages. A targeted upgrade can silently no-op if the fixed version is not yet in the current Alpine repo index:

```dockerfile
RUN apk add --no-cache bash \
    && apk upgrade --no-cache
```

---

## 8. Consider hardened base images

Where a hardened base is available, prefer it over patching individual packages:

| Use case | Hardened base | Why |
| --- | --- | --- |
| Go static binary | `gcr.io/distroless/static:nonroot` | No shell, no libc, no package manager |
| .NET app | `mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled` | Ubuntu Chiseled strips shell and package manager |

---

## 9. Add a `.dockerignore` to prevent false positives

`COPY . .` in a Dockerfile copies development artefacts (`.venv`, `node_modules`) that Scout will scan and report CVEs against — even though they are unreachable at runtime. Exclude them:

```text
.venv
node_modules
.pytest_cache
__pycache__
*.pyc
```

---

## 10. Add Scout to CI

Block merges with critical or high CVEs that have available fixes:

```yaml
- name: Scan for critical/high CVEs
  run: |
    docker scout cves \
      --only-severity critical,high \
      --only-fixed \
      --exit-code \
      my-app:local
```

`--exit-code` returns `2` if any matching CVEs are found, failing the CI job. Pair with `--only-fixed` so builds are not blocked by CVEs with no available patch.

---

## 11. Compare before and after a base image change

After updating a `FROM` line, quantify the security improvement before committing:

```bash
docker scout compare \
  --to my-app:new \
  my-app:old
```

---

## Summary

After completing these steps you have:

- A CVE baseline for every image, separated into base image and own-package findings
- Base image recommendations reviewed and applied where available
- Alpine runtime stages hardened with `apk upgrade --no-cache`
- A `.dockerignore` that prevents development artefacts from inflating scan results
- CI configured to block merges with fixable critical or high CVEs
