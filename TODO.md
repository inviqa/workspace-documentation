<!-- QUICK-INDEX -->
**Quick Index**: [Navigation Automation](#navigation-automation) · [Quality](#quality)
· [Optional Enhancements](#optional-enhancements) · [Deferred](#deferred)
<!-- TOC -->
## Table of Contents

- [High Priority Tasks](#high-priority-tasks)
  - [Documentation Restructuring](#documentation-restructuring)
  - [Core Workspace Tool Documentation](#core-workspace-tool-documentation)
  - [Advanced Topics](#advanced-topics)
- [Technical Improvements](#technical-improvements)
  - [Documentation Infrastructure](#documentation-infrastructure)
  - [Community and Maintenance](#community-and-maintenance)
- [Additional Suggestions](#additional-suggestions)
  - [Educational Content](#educational-content)
  - [Integration Documentation](#integration-documentation)
  - [Reference Materials](#reference-materials)
- [Implementation Notes](#implementation-notes)
  - [Priority Levels](#priority-levels)
  - [Success Metrics](#success-metrics)
  - [Timeline Considerations](#timeline-considerations)

<!-- /TOC -->

## Introduction

This document outlines planned improvements and additions to the Workspace
Documentation project.

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
  - Import incomplete documentation from `workspace/docs/`
  - Complete missing sections for Workspace core development
  - Document Workspace architecture and internals
  - Add contribution guidelines for the `ws` tool itself
  - Include build and development environment setup

- [ ] **Add comprehensive harness directory**
  - Create complete list of all known harnesses with descriptions
  - Include links to repositories, documentation, and maintainers
  - Add status indicators (active, deprecated, experimental)
  - Categorize by technology/framework

## Content Enhancement

### User Experience Improvements

- [ ] **Create getting started guide**
  - Quick start tutorial for new users
  - Common use cases and workflows
  - Troubleshooting section for common issues

- [ ] **Add command reference documentation**
  - Complete reference for all built-in Workspace commands
  - Examples for each command with real-world scenarios
  - Integration with the existing defining-commands.md

- [ ] **Expand configuration documentation**
  - Complete workspace.yml reference
  - Environment variable documentation
  - Attribute system explanation and examples

### Advanced Topics

- [ ] **Create reference documentation for Workspace overlays**
  - Document how Workspace handles overlays
  - Explain the relationship between overlays, harnesses, and harness layers
  - Clarify overlay lifecycle and management
  - Provide examples of overlay usage in real projects

- [ ] **Disambiguate overlay commands and concepts**
  - Add clear information about the difference between the `app overlay:apply` command and harness overlay mechanisms
  - Document best practices for using overlays in both contexts
  - Provide guidance on when to use each overlay approach

- [ ] **Add deployment and CI/CD documentation**
  - Integration with popular CI/CD platforms
  - Docker deployment patterns
  - Production environment considerations

- [ ] **Create migration guides**
  - Migrating between harness versions
  - Converting existing projects to use Workspace
  - Legacy project integration strategies

## Technical Improvements

### Documentation Infrastructure

- [ ] **Implement documentation versioning**
  - Version-specific documentation for different Workspace releases
  - Backward compatibility notes
  - Breaking change documentation

- [ ] **Add automated testing for documentation**
  - Link validation
  - Code example testing
  - Markdown linting in CI/CD

- [ ] **Create interactive examples**
  - Runnable code snippets
  - Live configuration examples
  - Interactive harness explorer

- [ ] **Add generated table of contents to long docs**
  - Evaluate markdown linter compatibility (headings, HTML usage)
  - Insert TOC markers (e.g., `<!-- TOC -->`) in long documents
  - Automate TOC generation during documentation build
  - Decide on automation vs. manual maintenance

- [ ] **Introduce metadata badge block**
  - Add status / last-updated / source / related links block below H1
  - Apply to deep dives (confd, implementation references, command index)
  - Ensure no conflicts with lint rules (MD041, MD001, MD031)

- [ ] **Automate implementation reference + navigation regeneration**
  - Script parses `Builder.php`, `Installer.php`, service scripts
  - Rebuild tables in `implementation-references.md`
  - Provide `--check` mode for CI drift detection
  - Hook into documentation build pipeline
  - Generate / refresh TOC blocks where missing or stale
  - Optional Quick Index curation support (allowlist-driven)

- [ ] **Automate harness commands/functions docs & navigation regeneration**
  - Script parses the harness command and functions and scripts files
  - Rebuild tables in `harness-<harness>-commands-functions.md`
  - Provide `--check` mode for CI drift detection
  - Hook into documentation build pipeline
  - Insert/refresh TOC after H1 (skip short docs)
  - Maintain optional Quick Index for high-traffic sections

- [ ] **Create dedicated harness-template repository**
  - Scaffold repo mirroring the "Full Featured Reference Layout" (sanitised)
  - Include minimal starter variant branch (`starter`) with ultra-lean layout
  - Provide golden test script and sample `harness.yml`
  - Add GitHub Actions workflow for tag publication
  - Cross-link from documentation (building-a-harness.md) once live
  
- [ ] **Propagate Application Overlay doc links**
  - Insert short "Managed Overlay" section into each first-party harness README
  - Link to `application-overlay.md` canonical deep dive
  - Note which overlay files are managed (`Jenkinsfile`, `auth.json`, `.dockerignore`)
  - Add provenance header guidance if adopted

- [ ] **Audit overlaps between command index and harness summary**
  - Compare `workspace-commands-functions-index.md` vs `all-harnesses-summary.md`
  - Identify duplicated sections or conflicting descriptions
  - Decide canonical file per concept (core vs per-harness aggregation)
  - Add cross-links where consolidation is chosen over duplication
  - Produce remediation list (merge, trim, relocate) and update docs accordingly

- [ ] **Automate highlights section generation**
  - Script extracts representative commands per category from canonical index
  - Regenerates "Quick Reference" highlights in `all-harnesses-summary.md`
  - Provides `--check` mode to detect manual drift
  - Support allowlist for intentional omissions
  - Integrate into documentation CI pipeline

- [ ] **Add duplicate command allowlist support**
  - Introduce `tools/duplicate-command-allowlist.txt` (glob or exact matches)
  - Modify duplicate detection script to ignore allowlisted patterns
  - Document usage in README (Canonical Sources section)
  - Add CI failure guidance for newly added duplicates

#### Optional Enhancements

- [ ] **Standardise overlay apply command snippet**
  - Add a consistent snippet showing how to (re)apply the managed overlay
  - Insert snippet into `building-a-harness.md`, `local-harness.md`, and
    `application-overlay.md`
  - Mention idempotency expectations and safe re-run guidance
  - Provide copy-paste command (e.g. `ws harness overlay apply` if adopted)

- [ ] **Implement provenance header automation for managed overlay files**
  - Define metadata header format (Managed-By, Template-Source, Checksum)
  - Write generator script to stamp/update headers during publish process
  - Add CI check verifying header presence and checksum integrity
  - Document header specification in `application-overlay.md`
  - Optionally emit remediation instructions on failure

- [ ] **Add overlay drift detection tooling**
  - Implement `ws overlay status` (dry-run comparing applied files vs template)
  - Show concise diff summary; support `--diff` for full output
  - Exit non-zero on drift when run with `--strict` flag (CI usage)
  - Integrate optional CI job to prevent stale overlay artefacts
  - Document remediation workflow (reapply or accept & update template)

### Community and Maintenance

- [ ] **Establish contribution guidelines**
  - Documentation style guide
  - Review process for documentation changes
  - Community contribution recognition

- [ ] **Add feedback mechanism**
  - Documentation feedback system
  - Issue templates for documentation problems
  - Regular review and update schedule

## Additional Suggestions

### Educational Content

- [ ] **Create video tutorials**
  - Basic Workspace usage
  - Harness customization
  - Advanced configuration patterns

- [ ] **Add use case studies**
  - Real-world project examples
  - Industry-specific implementation patterns
  - Performance optimization case studies

### Integration Documentation

- [ ] **IDE and Editor Integration**
  - VS Code extensions and configurations
  - IntelliJ/PhpStorm setup guides
  - Vim/Neovim workspace integration

- [ ] **Third-party Tool Integration**
  - Integration with popular development tools
  - Monitoring and logging setup
  - Testing framework integration

### Reference Materials

- [ ] **Create glossary of terms**
  - Workspace-specific terminology
  - Harness-related concepts
  - Cross-references between related terms

- [ ] **Add FAQ section**
  - Common questions and answers
  - Troubleshooting guide
  - Performance optimization tips

## Implementation Notes

### Priority Levels

- **High Priority**: Core documentation restructuring and completion
- **Medium Priority**: User experience and advanced topics
- **Low Priority**: Enhanced features and community content

### Success Metrics

- Complete separation of Workspace tool vs. harness documentation
- Comprehensive getting started experience for new users
- Complete developer documentation for Workspace core contributors
- Centralized directory of all available harnesses

### Timeline Considerations

- Phase 1: Restructuring and core content (1-2 months)
- Phase 2: User experience enhancements (2-3 months)
- Phase 3: Advanced features and community content (ongoing)

---

**Note**: This TODO list should be regularly reviewed and updated as the
project evolves and user needs become clearer.

