# Changelog

All notable changes to the Workspace Documentation project will be documented
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial CHANGELOG.md to track project changes
- Comprehensive command definition documentation in `defining-commands.md`
  - Command structure and syntax explanation
  - Script interpreter documentation (bash and PHP)
  - Working directory options (workspace:/, harness:/, cwd:/)
  - Filter system documentation (@ for templates, = for capture)
  - Complete examples for both bash and PHP interpreters
  - Best practices and guidelines
  - Summary table with use cases

### Changed

- Updated README.md to include link to new command definition documentation
- Enhanced Table of Contents with "Defining Commands" section

### Fixed

- Markdown formatting compliance across all documentation files
- Line length limits adhered to (80 characters max)
- Proper table formatting in command documentation

## [1.0.0] - 2025-08-21

### Initial Release

- Initial workspace harness documentation project
- README.md with comprehensive overview of Workspace harnesses
  - Harness structure explanation
  - Parent and child harness relationships
  - Build and deployment process documentation
  - Project creation and customization guides
  - Workspace tools section
- harness-tree.md with detailed harness hierarchy documentation
  - Base, leaf, and primary harness classifications
  - PHP, Node.js, and specialized harness trees
  - Deployment pipeline explanations
  - Version management and release processes

### Documentation Structure

- Organized documentation with clear navigation
- Markdown compliance with proper formatting
- Cross-referenced sections and external links
- Comprehensive coverage of Workspace ecosystem

---

## Guidelines for Contributors

When updating this changelog:

1. **Version Format**: Use [Semantic Versioning](https://semver.org/)
2. **Section Order**: Added, Changed, Deprecated, Removed, Fixed, Security
3. **Date Format**: YYYY-MM-DD
4. **Link Style**: Include links to relevant documentation or issues
5. **Audience**: Write for users and maintainers who need to understand changes

### Change Types

- **Added** for new features or documentation
- **Changed** for changes in existing functionality or content
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes or corrections
- **Security** in case of vulnerabilities
