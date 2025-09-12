# Workspace Harness Documentation

## Overview

This documentation explains the Workspace harness structure, how harnesses are
composed, extended, and customized, and how they are built and used in
projects.

---

## Table of Contents

- [What is a Workspace Harness?](#what-is-a-workspace-harness)
- [Harness Structure](#harness-structure)
- [Parent and Child Harnesses](#parent-and-child-harnesses)
- [How Harnesses are Built and Deployed](#how-harnesses-are-built-and-deployed)
- [Creating a New Project with a Harness](#creating-a-new-project-with-a-harness)
- [Customizing a Harness](#customizing-a-harness)
- [File Materialisation (confd.yml)](#file-materialisation-confdyml)
- [Defining Commands](#defining-commands)
- [Workspace Tools](#workspace-tools)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [References](#references)

---

## What is a Workspace Harness?

A Workspace harness is a reusable, versioned development environment template
for a specific technology or application (e.g., PHP, Drupal, Magento). Harnesses
are used with the [Workspace](https://github.com/my127/workspace) CLI to rapidly
bootstrap and manage projects.

---

## Harness Structure

A typical harness repository (e.g., a base harness) contains:

- `src/_base/` — Shared base files for all children
- `src/<child>/` — Child-specific files (e.g., `drupal8`, `magento1`)
- `dist/harness-<child>/` — Built distributable harnesses
- `build` — Script to assemble harnesses from base + child sources
- `Jenkinsfile` — CI pipeline for building, testing, publishing

---

## Parent and Child Harnesses

### How Inheritance Works

- The base harness provides shared logic and files in `src/_base/`.
- Each child harness adds overrides in `src/<child>/`.
- A build step merges `_base` and child directories into `dist/harness-<child>/`.
- There is no YAML `extends` keyword—inheritance is by file overlay.

### Example Tree

```text
base-harness/
  src/
    _base/
    drupal8/
    magento1/
  dist/
    harness-drupal8/
    harness-magento1/
```

### Example Parent/Child Relationships

- PHP base → drupal8, magento1, magento2, symfony, wordpress, akeneo, spryker
- Node base → node-spa, viper

---

## How Harnesses are Built and Deployed

- Run the build script in the base harness repository.
- Each child output appears in `dist/harness-<child>/` as a self-contained set.
- Outputs can be published (git tag/release or tarball).
- CI can validate (lint/test), build, and publish automatically.

---

## Creating a New Project with a Harness

1. Install Workspace: `brew install my127/formulae/workspace` (or per docs)
2. Create project: `ws create <projectName> <vendor>/<harness>:<version>`
3. Provide requested inputs (credentials, domain, etc.).
4. Commit generated files (exclude transient overrides as needed).

---

## Customizing a Harness

- Adjust attributes in `workspace.yml`.
- Add or override commands via `harness/config/commands.yml`.
- Introduce or override files (they’ll be layered by directory precedence).

## File Materialisation (confd.yml)

File mapping from template sources into the realized development harness is
controlled by `confd.yml`. See
**[Harness File Materialisation (confd.yml)](harness-confd-file-mappings.md)** for
prefix semantics (`harness:/`, `workspace:/`), layering, ordering, and
examples.

---

## Defining Commands

See **[Defining Commands](defining-commands.md)** for syntax, interpreters,
filters, and composition patterns.

---

## Workspace Tools

- `workspace-tools/` contains auxiliary helpers and utilities (not a parent or
  child harness).

---

## Changelog

See **[CHANGELOG.md](CHANGELOG.md)** for a chronological list of documentation
changes.

---

## Contributing

See **[TODO.md](TODO.md)** for planned improvements and contribution ideas.
Contributions (clarity edits, additional examples, structural improvements)
are welcome—please open a PR.

---

## References

- Workspace CLI: <https://github.com/my127/workspace>
- Example PHP base harness: <https://github.com/inviqa/harness-base-php>
- Example Node base harness: <https://github.com/inviqa/harness-base-node>
- Harness tools: <https://github.com/inviqa/workspace-tools>

---

## Documentation Canonical Sources

To avoid duplication and drift, each documentation concern has a single
canonical file. Other documents should only summarize and link back.

Canonical sources:

- Core workspace commands & functions: `workspace-commands-functions-index.md`
  (authoritative list). Summaries: harness summaries, deep dives.
- Template & file materialisation pipeline: `harness-confd-file-mappings.md`
  (deep dive: `confd.yml`, layering, overlay, diagnostics). Linked from index,
  implementation references.
- Implementation source mapping: `implementation-references.md` (maps
  features to PHP classes & scripts). Linked from index and deep dives.
- Aggregated harness overview: `all-harnesses-summary.md` (high-level feature
  highlights). Linked from README and marketing docs.
- Harness architecture & authoring concepts: this `README.md` (conceptual
  orientation). Linked from all other docs.
- Planned improvements / roadmap: `TODO.md` (tasks & roadmap). Linked from
  README and contributor docs.

Guidelines:

1. Add new conceptual deep dives as separate files; link them in the table.
2. Avoid copying command lists—prefer a single bullet with a link.
3. Move detailed operational sequences (step-by-step) out of summary indexes.
4. Update this table if a new documentation domain is introduced.

### Duplicate Command Listing Detection

A CI check validates that identical command lines do not appear redundantly
across multiple canonical docs (excluding intentional highlights). It scans
for repeated backtick-wrapped command tokens and fails the build on duplicates
outside approved files.

If the check fails:

1. Remove duplication from the non-canonical file.
2. Replace it with a short pointer to the canonical source.
3. Re-run CI to confirm resolution.

See `.github/workflows/docs-duplicate-commands.yml` and
`tools/check-duplicate-commands.sh` for implementation details.

