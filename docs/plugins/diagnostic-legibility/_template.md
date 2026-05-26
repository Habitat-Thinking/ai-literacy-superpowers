# How-To Guide Template

<!-- markdownlint-disable -->

Copy this file to create a new how-to guide. Replace all placeholder
text (in double curly braces) with real content. Delete this header
and the markdownlint-disable comment when done.

## Frontmatter

Add this at the top of the file (before the H1 heading):

```yaml
---
title: Title Goes Here
layout: default
parent: How-to Guides
nav_order: N
---
```

## Style Rules

- Direct, practical tone. No narrative, no Head First style.
- One-line description after the H1 title.
- Numbered steps as H2 headings: `## 1. Do the thing`
- Code blocks for commands and example output.
- 60-120 lines total.
- Horizontal rules (`---`) between sections.
- Run markdownlint before committing.

## Structure

```text
# {{Title}}

{{One sentence describing what this guide helps you do.}}

---

## Prerequisites

{{Installed tools, existing files, completed prior steps.
Remove this section if none.}}

---

## 1. {{First step}}

{{Brief explanation of what this step does and why.}}

    ```bash
    {{command or code}}
    ```

{{Expected output or what to look for.}}

---

## 2. {{Second step}}

{{Continue. Most guides have 4-8 steps.}}

---

## What you have now

{{One paragraph summarising the result.}}

## Next steps

{{2-3 bullet points linking to related guides.}}
```

<!-- markdownlint-enable -->
