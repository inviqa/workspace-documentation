# TODO - Workspace Documentation Project

This document outlines planned improvements and additions to the Workspace
Documentation project.

## High Priority Tasks

### 1. Documentation Restructuring

- [ ] **Isolate harness-specific documentation**
  - Move harness-specific content to a separate harness documentation project
  - Keep only general Workspace tool documentation in this project
  - Clarify scope: this project should focus on Workspace tool usage, not
    harness implementation details

- [ ] **Create project startup documentation**
  - Document how to start a project **with** a harness
    - Harness selection guide
    - Project initialization process
    - Configuration best practices
  - Document how to start a project **without** a harness
    - Manual workspace setup
    - Custom command creation
    - Direct workspace.yml configuration

- [ ] **Create harness extension documentation**
  - Guide for extending existing harnesses
  - Creating custom harness variants
  - Override patterns and best practices
  - Contribution guidelines for harness repositories

### 2. Core Workspace Tool Documentation

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

### 3. User Experience Improvements

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

### 4. Advanced Topics

- [ ] **Add deployment and CI/CD documentation**
  - Integration with popular CI/CD platforms
  - Docker deployment patterns
  - Production environment considerations

- [ ] **Create migration guides**
  - Migrating between harness versions
  - Converting existing projects to use Workspace
  - Legacy project integration strategies

## Technical Improvements

### 5. Documentation Infrastructure

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

- [ ] **Automate implementation reference regeneration**
  - Script parses `Builder.php`, `Installer.php`, service scripts
  - Rebuild tables in `implementation-references.md`
  - Provide `--check` mode for CI drift detection
  - Hook into documentation build pipeline

- [ ] **Automate implementation of harness commands and functions documentation regeneration**
  - Script parses the harness command and functions and scripts files
  - Rebuild tables in `harness-<harness>-commands-functions.md`
  - Provide `--check` mode for CI drift detection
  - Hook into documentation build pipeline

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

### 6. Community and Maintenance

- [ ] **Establish contribution guidelines**
  - Documentation style guide
  - Review process for documentation changes
  - Community contribution recognition

- [ ] **Add feedback mechanism**
  - Documentation feedback system
  - Issue templates for documentation problems
  - Regular review and update schedule

## Additional Suggestions

### 7. Educational Content

- [ ] **Create video tutorials**
  - Basic Workspace usage
  - Harness customization
  - Advanced configuration patterns

- [ ] **Add use case studies**
  - Real-world project examples
  - Industry-specific implementation patterns
  - Performance optimization case studies

### 8. Integration Documentation

- [ ] **IDE and Editor Integration**
  - VS Code extensions and configurations
  - IntelliJ/PhpStorm setup guides
  - Vim/Neovim workspace integration

- [ ] **Third-party Tool Integration**
  - Integration with popular development tools
  - Monitoring and logging setup
  - Testing framework integration

### 9. Reference Materials

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
