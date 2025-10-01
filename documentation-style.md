# Documentation Style Guide

<!-- TOC -->
## Table of Contents

- [Purpose](#purpose)
- [Scope](#scope)
- [Headings](#headings)
- [Quick Index](#quick-index)
- [Using Both TOC and Quick Index](#using-both-toc-and-quick-index)
- [Line length and wrapping](#line-length-and-wrapping)
- [Lists](#lists)
- [Code Blocks](#code-blocks)
- [Link Hygiene](#link-hygiene)
- [Provenance Notes](#provenance-notes)
- [Automation Expectations](#automation-expectations)
- [Checklist for New Documents](#checklist-for-new-documents)
- [Navigation Tooling Scripts](#navigation-tooling-scripts)

<!-- /TOC -->

## Purpose

Define consistent conventions for authoring Workspace documentation so that
navigation, searchability, and automation remain reliable.

## Scope

Applies to all `.md` files in this repository except `CHANGELOG.md` (follows
standard semantic versioning formatting) and any externally imported, frozen
specification documents.

## Headings

- Use sentence case for section headings (only first word capitalised unless
  proper nouns).
- Avoid numeric prefixes (e.g. `## 1. Introduction`); rely on structural
  hierarchy instead.
- Keep heading text concise; prefer descriptive over clever.

## Table of Contents (TOC)

A structural navigation list mirroring document headings.

### When to Include a TOC

Include a TOC if ANY of the following are true:

- Document length > 80 lines
- More than 4 second-level (`##`) headings
- Contains nested subsections (`###` or deeper)

Skip TOC for very short, purely referential files (< 30 lines) or single-topic
notices.

### TOC Block Format

Insert immediately after the H1 and an optional status/admonition block. Example:

```markdown
<!-- TOC -->
## Table of Contents

- [Purpose](#purpose)
- [Scope](#scope)
- [Headings](#headings)
- [Quick Index](#quick-index)
- [Using Both TOC and Quick Index](#using-both-toc-and-quick-index)
- [Line length and wrapping](#line-length-and-wrapping)
- [Lists](#lists)
- [Code Blocks](#code-blocks)
- [Link Hygiene](#link-hygiene)
- [Provenance Notes](#provenance-notes)
- [Automation Expectations](#automation-expectations)
- [Checklist for New Documents](#checklist-for-new-documents)
- [Navigation Tooling Scripts](#navigation-tooling-scripts)

<!-- /TOC -->
```

### Anchor Generation Rules

Generated anchors (GitHub-compatible) follow:

- Lowercase
- Strip backticks and punctuation except hyphens
- Collapse consecutive spaces → single hyphen
- Remove leading/trailing hyphens
- Unicode symbols removed or simplified (`→` becomes `-` or removed)

Examples:

| Heading | Anchor |
|---------|--------|
| `## From Path Harness to Packaged` | `#from-path-harness-to-packaged-harness` |
| `## \`harness.yml\` Manifest` | `#harnessyml-manifest` |
| `## Pipeline & Build (Pipeline.yml)` | `#pipeline--build-pipelineyml` |

## Quick Index

A curated, non-exhaustive list of high-value entry points for power users.

### When to Include a Quick Index

Add ONLY if the document is a broad reference where users routinely jump to a
small subset of sections (e.g. command/function indices, large aggregation
summaries).

### Quick Index Format

Place BEFORE the TOC if both are present, otherwise after H1:

```markdown
<!-- QUICK-INDEX -->
## Quick Index

- [Enable environment](#workspace-management)
- [Database commands](#database-management)
- [Common functions](#common-functions-across-harnesses)
<!-- /QUICK-INDEX -->
```

> The Quick Index example above and TOC example earlier are illustrative only.
> Live Quick Index blocks are restricted to files listed in
> `tools/quick-index-allowlist.txt` (master workspace index, aggregated harness
> summary, and per-harness command/function references). Do not add a Quick
> Index elsewhere.

### Curation Guidelines

- Limit to 5–12 items
- Group by task or intent, not strict heading hierarchy
- May include cross-document links if essential

## Using Both TOC and Quick Index

Order:

1. (Optional) Status / context blockquote
2. Quick Index (if present)
3. TOC
4. Body content

Avoid redundancy: do not include every Quick Index item as a top-level TOC
item unless it is also a real section.

## Line length and wrapping

- Hard wrap at 80 characters for narrative text
- Do not wrap inside fenced code unless readability improves
- Keep tables narrow; split long phrases across lines if necessary

## Lists

- Single space after list marker (`-`)
- Wrap subordinate lines with 2-space indentation for alignment
- Avoid trailing punctuation unless full sentences

## Code Blocks

- Always specify a language (`bash`, `yaml`, `dockerfile`, `markdown`, etc.)
- Prefer minimal examples; link to deep dive rather than duplicate
- For multi-step shell sessions, consider a comment prefix for context

## Link Hygiene

- Use relative links for internal docs
- Ensure anchors reflect current (numberless) headings
- External links: prefer HTTPS; add short descriptive link text

## Provenance Notes

For generated or templated excerpts, optionally include a brief comment:

```markdown
<!-- Generated by: tools/build-index.php (do not edit manually) -->
```

## Automation Expectations

Planned automation tasks (see `TODO.md`):

- TOC regeneration (detect drift by comparing anchor set)
- Optional Quick Index allowlist file for curated targets
- Link/anchor validation script in CI

## Checklist for New Documents

- [ ] H1 present and unique
- [ ] TOC added (meets inclusion criteria) or explicitly skipped (comment)
- [ ] Quick Index added only if justified
- [ ] Anchors validated (no stale numbered forms)
- [ ] Lines wrapped at 80 chars
- [ ] Code fences have language
- [ ] Relative links used for internal references
- [ ] No trailing whitespace / proper EOF newline

## Navigation Tooling Scripts

The repository includes automation to keep navigation consistent.

### `tools/generate-toc.sh`

Usage:

```bash
# Mutate files inserting or updating TOC blocks
./tools/generate-toc.sh

# Non-mutating check (exits 1 if drift or missing TOC)
./tools/generate-toc.sh --check
```

Behavior:

- Scans all `*.md` (excluding `CHANGELOG.md`).
- Collects second-level and deeper headings (`##` ...).
<!-- (Removed duplicate generated TOC blocks that appeared inside narrative) -->
