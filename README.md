# Workspace Harness Documentation

## Overview
This documentation provides an organized explanation of the Workspace harness structure, how to use harnesses, and details about parent/child harness relationships and deployment.

---

## Table of Contents
- [What is a Workspace Harness?](#what-is-a-workspace-harness)
- [Harness Structure](#harness-structure)
- [Parent and Child Harnesses](#parent-and-child-harnesses)
- [How Harnesses are Built and Deployed](#how-harnesses-are-built-and-deployed)
- [Creating a New Project with a Harness](#creating-a-new-project-with-a-harness)
- [Customizing a Harness](#customizing-a-harness)
- [Defining Commands](#defining-commands)
- [Workspace Tools](#workspace-tools)
- [Changelog](#changelog)
- [References](#references)

---

## What is a Workspace Harness?
A Workspace harness is a reusable, versioned development environment template, typically for a specific technology or application (e.g., PHP, Drupal, Magento). Harnesses are used with the [Workspace](https://github.com/my127/workspace) tool to quickly bootstrap and manage projects.

---

## Harness Structure
A typical harness repository (e.g., `harness-base-php`) contains:

- `src/_base/` — Shared base files for all child harnesses
- `src/<child>/` — Child-specific files (e.g., `drupal8`, `magento1`)
- `dist/harness-<child>/` — Built, distributable harnesses
- `build` — Script to build harnesses from base and child sources
- `Jenkinsfile` — CI pipeline for building, testing, and deploying harnesses

---

## Parent and Child Harnesses

### How Inheritance Works
- The "parent" harness (e.g., `harness-base-php`) provides shared logic and files in `src/_base/`.
- "Child" harnesses (e.g., `harness-drupal8`) are built by combining the base with their own overrides from `src/<child>/`.
- The build script copies files from both locations into `dist/harness-<child>/`.
- There is no explicit `extends` or `parent` in the YAML config; inheritance is managed by the build process.

### Example Tree
```
harness-base-php/
  ├── src/
  │   ├── _base/         # shared base for all children
  │   ├── drupal8/       # child-specific files
  │   ├── magento1/
  │   └── ...
  ├── dist/
  │   ├── harness-drupal8/   # built, ready-to-publish child harness
  │   ├── harness-magento1/
  │   └── ...
```

### Example Parent/Child Relationships
- `harness-base-php` → `harness-drupal8`, `harness-magento1`, `harness-magento2`, `harness-symfony`, `harness-wordpress`, `harness-akeneo`, `harness-spryker`
- `harness-base-node` → `harness-node-spa`, `harness-viper`

---

## How Harnesses are Built and Deployed
- The `build` script in the base harness copies base and child files into `dist/harness-<child>/`.
- Each child harness in `dist/` is a complete, standalone harness (with its own `harness.yml`, `README.md`, etc.).
- These can be published to their own git repositories or distributed as tarballs.
- CI pipelines (e.g., Jenkinsfile) automate building, testing, and optionally deploying harnesses.

---

## Creating a New Project with a Harness
1. Install [Workspace](https://github.com/my127/workspace)
2. Run: `ws create <projectName> inviqa/<harness>:<version>`
3. Fill in any required credentials or configuration
4. Commit the generated files (excluding `workspace.override.yml`)

---

## Customizing a Harness

- Override attributes in `workspace.yml`
- Add or override commands in `harness/config/commands.yml`
- Extend or replace files as needed

---

## Defining Commands

For comprehensive information about creating custom commands in Workspace,
including command syntax, interpreters, filters, and examples, see:
**[Defining Commands](defining-commands.md)**

---

## Workspace Tools

- **workspace-tools**: A collection of tools and utilities for Workspace, not a parent or child harness. Location: `workspace-tools/`

---

## Changelog

For a complete list of changes, additions, and improvements to this
documentation, see: **[CHANGELOG.md](CHANGELOG.md)**

---

- [Workspace Documentation](https://github.com/my127/workspace)
- [harness-base-php](https://github.com/inviqa/harness-base-php)
- [harness-base-node](https://github.com/inviqa/harness-base-node)
- [workspace-tools](https://github.com/inviqa/workspace-tools)
