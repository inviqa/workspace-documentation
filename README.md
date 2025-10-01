# Workspace Documentation (Core Usage & Guidance)

> This repository now focuses on **core Workspace usage, onboarding, and
> extension patterns**. Deep harness implementation internals are being
> progressively relocated to dedicated harness repositories. Harness specific
> command/function indexes remain temporarily for convenience and will be
> flagged when migrated.

> ⚠️ **WORK IN PROGRESS**: This documentation set is being actively
> refactored toward a canonical-source model. Sections, filenames, and
> anchors may change. Please report broken links instead of copying or
> recreating content.

## Scope Overview

Focus areas retained here:

- Getting started (with & without a harness)
- Core Workspace commands, attributes & configuration
- Local / path harness incubation and promotion
- Overlay & extension practices
- High-level harness selection guidance

Out-of-scope (moving / summarised only):

- Detailed per-harness implementation internals
- Full variant-specific CI pipeline logic
- Exhaustive template inventories (refer to harness repos)

---

<!-- TOC -->
## Table of Contents

- [Scope Overview](#scope-overview)
- [What is a Workspace Harness?](#what-is-a-workspace-harness)
- [Harness Structure](#harness-structure)
- [Parent and Child Harnesses](#parent-and-child-harnesses)
- [How Harnesses are Built and Deployed](#how-harnesses-are-built-and-deployed)
- [Creating a New Project with a Harness (Summary)](#creating-a-new-project-with-a-harness-summary)
- [Customizing a Harness (Summary)](#customizing-a-harness-summary)
- [File Materialisation (confd.yml)](#file-materialisation-confdyml)
- [Defining Commands](#defining-commands)
- [Workspace Tools](#workspace-tools)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [References](#references)
- [Documentation Canonical Sources](#documentation-canonical-sources)
- [Related Deep Dives](#related-deep-dives)
- [New user onboarding (guides)](#new-user-onboarding-guides)
- [Deprecation Guidelines (Summary)](#deprecation-guidelines-summary)

<!-- /TOC -->

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

## Creating a New Project with a Harness (Summary)

1. Install Workspace: `brew install my127/formulae/workspace` (or per docs)
2. Create project: `ws create <projectName> <vendor>/<harness>:<version>`
3. Provide requested inputs (credentials, domain, etc.).
4. Commit generated files (exclude transient overrides as needed).

---

## Customizing a Harness (Summary)

- Adjust attributes in `workspace.yml`.
- Add or override commands via `harness/config/commands.yml`.
- Introduce or override files (they’ll be layered by directory precedence).

---

## File Materialisation (confd.yml)

File mapping from template sources into the realized development harness is
controlled by `confd.yml`. See **[Harness File Materialisation
(confd.yml)](reference/harness-confd-file-mappings.md)** for
prefix semantics (`harness:/`, `workspace:/`), layering, ordering, and
examples.

---

## Defining Commands

See **[Defining Commands](guides/defining-commands.md)** for syntax,
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

- Core workspace commands & functions:
  `reference/workspace-commands-functions-index.md` (authoritative list).
  Summaries: harness summaries, deep dives.
- Template & file materialisation pipeline:
  `reference/harness-confd-file-mappings.md` (deep dive: `confd.yml`, layering,
  overlay, diagnostics).
- Implementation source mapping:
  `reference/implementation-references.md` (maps features to PHP classes &
  scripts).
- Aggregated harness overview: `reference/all-harnesses-summary.md`
  (high-level feature highlights).
- Harness architecture & authoring concepts: this `README.md` (conceptual orientation).
- Planned improvements / roadmap: `TODO.md` (tasks & roadmap).
- Getting started (decision paths): `guides/getting-started.md`.
- Scratch / no-harness bootstrap (deep dive): `guides/project-startup-without-harness.md`.
- Extension patterns & variant promotion: `guides/harness-extension.md`.

Guidelines:

1. Add new conceptual deep dives as separate files; link them in the list below.
2. Avoid copying command lists—prefer a single bullet with a link.
3. Move detailed operational sequences (step-by-step) out of summary indexes.
4. Update this section if a new documentation domain is introduced.

### Duplicate Command Listing Detection

A CI (or manual) check validates that identical command lines do not appear redundantly
across multiple canonical docs (excluding intentional highlights). It scans
for repeated backtick-wrapped command tokens and fails the build on duplicates
outside approved files.

If the check fails:

1. Remove duplication from the non-canonical file.
2. Replace it with a short pointer to the canonical source.
3. Re-run CI to confirm resolution.

See `.github/workflows/docs-duplicate-commands.yml` (when enabled) and
`tools/check-duplicate-commands.sh` for implementation details.

---

## Related Deep Dives

The following focused documents provide additional technical depth:

- Harness command & function index:
  [workspace-commands-functions-index.md](reference/workspace-commands-functions-index.md)
- Harness summary highlights:
  [all-harnesses-summary.md](reference/all-harnesses-summary.md)
- Implementation references:
  [implementation-references.md](reference/implementation-references.md)
- Harness file materialisation:
  [harness-confd-file-mappings.md](reference/harness-confd-file-mappings.md)
- Mutagen integration:
  [mutagen-integration.md](guides/mutagen-integration.md)
- Visual harness tree: [harness-tree.md](reference/harness-tree.md)
- Local harness pattern: [local-harness.md](guides/local-harness.md)
- Building a reusable harness:
  [building-a-harness.md](guides/building-a-harness.md)
- Getting started overview: [getting-started.md](guides/getting-started.md)
- Project startup without harness (deep dive): [project-startup-without-harness.md](guides/project-startup-without-harness.md)
- Harness extension & customisation: [harness-extension.md](guides/harness-extension.md)

---

## New user onboarding (guides)

Primary entry points for new adopters:

- Getting Started (overview & decision matrix): `guides/getting-started.md`
- Starting Without a Harness (deep dive): `guides/project-startup-without-harness.md`
- Harness Extension Patterns: `guides/harness-extension.md`

These complement existing lifecycle documents:

- Local Harness Pattern: `guides/local-harness.md`
- Building a Reusable Harness: `guides/building-a-harness.md`

---

## Deprecation Guidelines (Summary)

Harness maintainers should follow a predictable deprecation process:

1. Mark upcoming removals (template paths, command names, attribute keys) in the
  harness CHANGELOG one MINOR version before removal.
2. If feasible, provide a shim (wrapper command or pass-through template) that
  emits a warning rather than hard-breaking immediately.
3. Track active deprecations in the harness manifest (`harness.yml`) under a
  field such as `notes.deprecations` (see example in
  [building-a-harness.md](guides/building-a-harness.md)).
4. Remove deprecated surface only in the next MAJOR release unless a security
  or correctness issue forces earlier action.
5. Communicate upgrade steps (attribute renames, destination file changes)
  clearly in release notes.

Full rationale, contract definition, and versioning detail: see
**[Building a Reusable Harness](guides/building-a-harness.md)** (Sections:
Versioning, Backwards Compatibility Contract, Deprecation Policy).

---
