---
title: Audit Dependencies
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 13
redirect_from:
  - /how-to/audit-dependencies/
  - /how-to/audit-dependencies.html
---

# Audit Dependencies

This guide walks you through auditing your project dependencies for known vulnerabilities, supply chain risk, and staleness — covering Go modules and Maven/JVM projects.

**Never judge a dependency as safe based on your knowledge of its version number. Version numbers in training data are stale. Always run the tools.**

---

## 1. Install the scanner for your ecosystem

**Go — govulncheck:**

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
```

**Maven/JVM — OWASP Dependency-Check** is run via Maven plugin (no separate install needed). Add it to `pom.xml` under `<build><plugins>`:

```xml
<plugin>
  <groupId>org.owasp</groupId>
  <artifactId>dependency-check-maven</artifactId>
  <version>9.0.9</version>
  <executions>
    <execution>
      <goals><goal>check</goal></goals>
    </execution>
  </executions>
  <configuration>
    <failBuildOnCVSS>7</failBuildOnCVSS>
  </configuration>
</plugin>
```

---

## 2. Run the vulnerability scanner

**Go:**

```bash
# Run from the module root
govulncheck ./...
```

`govulncheck` cross-references the Go vulnerability database against the specific functions your code actually calls — not just which modules are present. This means fewer false positives than tools that flag any version of a module.

**Maven/JVM:**

```bash
# Downloads NVD data on first run — takes ~5 minutes
mvn org.owasp:dependency-check-maven:check
# HTML report generated at: target/dependency-check-report.html
```

---

## 3. Verify module integrity (Go)

```bash
# Confirms every module matches its go.sum hash
go mod verify
```

A failure here means a module has been tampered with or `go.sum` is stale. Do not proceed with a failing integrity check.

---

## 4. Check for supply chain red flags

**Go — look for suspicious replace directives:**

```bash
grep -A1 "^replace" go.mod
```

A `replace` directive pointing to a local path or private fork bypasses the module proxy and checksum verification. Treat any such entry as a supply chain risk until you can verify it is intentional.

**Go — list all transitive modules:**

```bash
go list -m all
```

Review for unfamiliar or unexpected module paths.

**Maven — check for version ranges:**

```bash
grep -E "\[|,|\)" pom.xml
```

Any match is a risk: Maven may silently resolve a different version than was tested.

**Maven — review the full dependency tree:**

```bash
mvn dependency:tree
```

Look for unexpectedly old versions, multiple conflicting versions of the same library, and unfamiliar group IDs.

---

## 5. Check dependency age with libyear

CVE scanners report known vulnerabilities. They do not measure overall staleness. Use libyear to get the full picture:

**npm:**

```bash
npx libyear
```

**Go:**

```bash
go list -m -u all
```

Flags modules with available updates. Calculate years manually by comparing release dates.

Recommended thresholds:

| Project size | Budget |
| --- | --- |
| Fewer than 20 direct dependencies | < 10 libyears |
| 20 or more direct dependencies | < 20 libyears |

---

## 6. Add the scanner to CI

**Go:**

```yaml
- name: Run vulnerability scan
  run: |
    go install golang.org/x/vuln/cmd/govulncheck@latest
    govulncheck ./...
```

**Maven:**

```yaml
- name: Run OWASP dependency scan
  run: mvn -B org.owasp:dependency-check-maven:check
```

---

## 7. Enable Dependabot for automatic update PRs

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: gomod
    directory: /
    schedule:
      interval: weekly

  - package-ecosystem: maven
    directory: /
    schedule:
      interval: weekly
```

---

## 8. Record findings

Produce a findings table to track what was discovered and what needs fixing:

```markdown
## Dependency Audit

| Ecosystem | Finding | Severity | Fix |
| --- | --- | --- | --- |
| Go | govulncheck not in CI | Medium | Add govulncheck step to workflow |
| Maven | OWASP Dependency-Check not in CI | Medium | Add plugin and CI step |
| All | No dependabot.yml | Medium | Add gomod and maven ecosystems |
```

Severity guide: **Critical** — actively exploited CVE in a direct dependency. **High** — CVE with CVSS ≥ 7. **Medium** — no scanner in CI; unverified provenance; unpinned dependency. **Low** — legacy group ID with no known CVE.

---

## Summary

After completing these steps you have:

- A vulnerability scan run against actual code call paths, not just module presence
- Module integrity verified against go.sum hashes
- Supply chain red flags identified and documented
- A libyear staleness baseline
- Automated scanning in CI that fails the build on high-severity CVEs
- Dependabot configured to keep dependencies current
