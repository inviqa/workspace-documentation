# Workspace documentation TODO

<!-- TOC -->
## Table of Contents

- [Introduction](#introduction)
- [High Priority Tasks](#high-priority-tasks)
- [Content Enhancement](#content-enhancement)
- [Technical Improvements](#technical-improvements)

<!-- /TOC -->

## Introduction

This document outlines planned improvements and additions to the Workspace
Documentation project.

**Total Estimated Time (with GitHub Copilot):** 10-16 continued working days

## High Priority Tasks

### Documentation Restructuring

- [x] **Isolate harness-specific documentation**
  - (Phase 1) Scope clarified in updated README; relocation plan noted.
  - (Pending Phase 2) Physical extraction to external repos.
  - Harness indexes retained temporarily with deprecation notice.

- [x] **Create project startup documentation**
  - Added `guides/getting-started.md` (with & without harness paths).
  - Added `guides/project-startup-without-harness.md` deep dive.
  - Harness selection & configuration best practices covered.

- [x] **Create harness extension documentation**
  - Added `guides/harness-extension.md` (patterns, variant promotion, contrib).
  - Checklist + pitfalls section included.

### Core Workspace Tool Documentation

- [ ] **Migrate and enhance developer documentation**
  - **Analysis:** This is a large and complex task that requires a deep understanding of the `workspace` source code.
  - **Estimate (days):** 5-8
  - **Sub-tasks:**
    - Review and refactor existing documentation from `workspace/docs/`.
    - Document the purpose and interactions of each major component in the `src` directory (e.g., `Definition`, `Environment`, `Interpreter`, `Types`).
    - Create a high-level architecture document that explains how all the components fit together.
    - Document the build and development environment setup for the `ws` tool itself.
    - Add contribution guidelines for new developers.

- [ ] **Add comprehensive harness directory**
  - **Analysis:** This task is less about deep code analysis and more about research, organization, and presentation.
  - **Estimate (days):** 2-3
  - **Sub-tasks:**
    - Identify all existing harnesses (both official and community-contributed).
    - For each harness, gather information about its purpose, maintainers, repository link, and status (active, deprecated, etc.).
    - Structure the information in a clear and easily searchable format.
    - Categorize harnesses by technology (e.g., PHP, Node.js, Go) and framework (e.g., Drupal, Symfony, Magento).

## Content Enhancement

- **Estimate (days):** 3-5

### User Experience Improvements

- [ ] **Create getting started guide**
  - **Analysis:** This is a crucial piece of documentation for new users. It should provide a smooth onboarding experience.
  - **Sub-tasks:**
    - Create a step-by-step tutorial that walks users through the process of creating a new project with Workspace.
    - Provide examples of common use cases and workflows.
    - Create a troubleshooting section that addresses common issues that new users might encounter.

- [ ] **Add command reference documentation**
  - **Analysis:** This task involves documenting every single command, its options, and providing real-world examples.
  - **Sub-tasks:**
    - Document all built-in Workspace commands.
    - For each command, provide a clear explanation of its purpose, arguments, and options.
    - Include practical examples that demonstrate how to use the command in different scenarios.
    - Integrate this documentation with the existing `defining-commands.md` guide.

- [ ] **Expand configuration documentation**
  - **Analysis:** This task is essential for users who want to customize their Workspace environment.
  - **Sub-tasks:**
    - Provide a complete reference for the `workspace.yml` file, explaining all the available options.
    - Document all the environment variables that can be used to configure Workspace.
    - Explain the attribute system in detail, with examples of how to define and use attributes.

### Advanced Topics

- [ ] **Create reference documentation for Workspace overlays**
  - **Analysis:** This task requires a deep understanding of the overlay mechanism in Workspace.
  - **Sub-tasks:**
    - Explain how Workspace handles overlays and how they interact with harnesses and harness layers.
    - Document the lifecycle of an overlay and how to manage it.
    - Provide practical examples of how to use overlays in real projects.

- [ ] **Disambiguate overlay commands and concepts**
  - **Analysis:** This task is important to avoid confusion between the different overlay mechanisms in Workspace.
  - **Sub-tasks:**
    - Clearly explain the difference between the `app overlay:apply` command and the harness overlay mechanism.
    - Document best practices for using overlays in both contexts.
    - Provide guidance on when to use each overlay approach.

- [ ] **Add deployment and CI/CD documentation**
  - **Analysis:** This task is for advanced users who want to integrate Workspace into their deployment pipelines.
  - **Sub-tasks:**
    - Provide examples of how to integrate Workspace with popular CI/CD platforms (e.g., GitHub Actions, GitLab CI).
    - Document best practices for deploying Workspace projects to production environments.
    - Explain how to use Workspace with Docker for containerized deployments.

- [ ] **Create migration guides**
  - **Analysis:** This task is important for users who want to upgrade their Workspace projects or migrate from other tools.
  - **Sub-tasks:**
    - Create a guide for migrating between different versions of a harness.
    - Provide a step-by-step guide for converting an existing project to use Workspace.
    - Document strategies for integrating Workspace with legacy projects.

## Technical Improvements

### Documentation Infrastructure

- [ ] **Implement documentation versioning**
  - **Analysis:** This is a "meta" task that improves the documentation process itself.
  - **Sub-tasks:**
    - Implement a system for generating version-specific documentation for different Workspace releases.
    - Add notes about backward compatibility and breaking changes to the documentation.

- [ ] **Add automated testing for documentation**
  - **Analysis:** This is another "meta" task that improves the quality of the documentation.
  - **Sub-tasks:**
    - Set up a CI/CD pipeline to automatically validate links, test code examples, and lint Markdown files.

- [ ] **Create interactive examples**
  - **Analysis:** This task can significantly improve the user experience of the documentation.
  - **Sub-tasks:**
    - Create runnable code snippets that users can execute directly in their browsers.
    - Provide live configuration examples that users can interact with.
    - Create an interactive harness explorer that allows users to browse and search for harnesses.

- [ ] **Add generated table of contents to long docs**
  - **Analysis:** This is a small but important improvement for the readability of the documentation.
  - **Sub-tasks:**
    - Evaluate different tools for generating tables of contents for Markdown files.
  - Choose a tool that is compatible with the existing Markdown linter.
