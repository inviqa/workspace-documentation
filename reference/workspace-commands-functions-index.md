# Workspace Commands and Functions - Master Index

<!-- QUICK-INDEX -->
## Quick Index

- [Core Commands](#core-workspace-commands)
- [Global Services](#global-service-management)
- [Harness Preparation](#harness-preparation)
- [Utilities & Attributes](#core-workspace-utilities-and-attributes)
- [Expression Functions](#expression-functions)
- [Built-in Attributes](#built-in-attributes)
- [Loading Order](#configuration-file-loading-order)
- [Implementation References](#related-documentation)
<!-- /QUICK-INDEX -->

<!-- TOC -->
## Table of Contents

- [Quick Index](#quick-index)
- [Introduction](#introduction)
- [Overview](#overview)
- [Related Documentation](#related-documentation)
- [Core Workspace Commands](#core-workspace-commands)
- [Core Workspace Utilities and Attributes](#core-workspace-utilities-and-attributes)
- [Harness-Specific Commands](#harness-specific-commands)
- [Common Functions Across Harnesses](#common-functions-across-harnesses)
- [File Structure Summary](#file-structure-summary)
- [Usage Patterns](#usage-patterns)
- [Environment Variables](#environment-variables)
- [Command Categories](#command-categories)
- [Integration Points](#integration-points)

<!-- /TOC -->

## Introduction

This document provides a comprehensive index of all commands and functions
available across the Workspace system and all harnesses. Each harness extends
the core functionality with specific tools for different application types.

## Overview

The Workspace system consists of:

- **Core Workspace**: Global commands and functions available to all projects
- **Base Harnesses**: Foundation functionality shared across harnesses
- **Application Harnesses**: Specialized environments for specific frameworks

---

## Related Documentation

the ephemeral `.my127ws/` directory, see:
For file materialisation, template layering, and how harness files appear under
the ephemeral `.my127ws/` directory, see:
**[Harness File Materialisation (confd.yml)](harness-confd-file-mappings.md)**.

- **Implementation References:** Source file mapping for key commands and
  lifecycle steps (see `implementation-references.md`).

---

## Core Workspace Commands

### File: `workspace/config/workspace/global.yml`

#### Global Service Management

- `ws global service logger (enable|disable)` — Manage global logger service
- `ws global service mail (enable|disable)` — Control Mailhog
- `ws global service proxy (enable|disable|restart)` — Manage Traefik proxy
- `ws global service tracing (start|stop|restart)` — Manage tracing service
- `ws global service` — Perform an action on a global service

#### What does `ws global service proxy restart` do?

Refreshes the global Traefik proxy with fresh TLS cert/key and a rebuilt
container. Use if dev domains (e.g. `*.my127.site`) show expired certificate
warnings.

Summary of actions: stop/remove container → fetch cert & key (configured URLs)
→ rebuild/start Traefik.

Run:

```bash
ws global service proxy restart
```

Implementation details: see `implementation-references.md` (Proxy Service) for
script path and lifecycle.

#### Configuration Management

- `ws global config get <key>` — Retrieve a workspace configuration value

#### System Management

- `ws poweroff` — Shut down all global containers

#### Workspace Creation

- `ws create <name> [<harness> [--no-install]]` — Create a new workspace
  with an optional harness

#### Harness Preparation

- `ws harness prepare` - Runs the overlay sync plus confd template rendering
  phases only (no harness download). Use after editing overlay files, template
  sources, or `confd.yml` when a full rebuild isn't needed.

See:

- Deep dive: **Harness File Materialisation (confd.yml)** (section “ws harness prepare”).
- Implementation references: `implementation-references.md` (Harness Preparation).

---

## Core Workspace Utilities and Attributes

In addition to commands, the core provides utility scripts, expression functions,
built-in attributes, and a defined configuration loading order that you can
rely on in any workspace.

### Utility scripts (workspace/home/bin)

- `ws.service` — Manage global/local services used by core commands
  (path: `workspace/home/bin/ws.service`).
- `ws.aws` — AWS CLI wrapper that works with or without a local AWS CLI
  (path: `workspace/home/bin/ws.aws`).
- `ws.poweroff` — Implements complete workspace shutdown used by `ws poweroff`
  (path: `workspace/home/bin/ws.poweroff`).

### Expression functions

- `exec(command)` — Execute a command and return its output.
  Example: `attribute('current_time'): = exec("date")`
- `passthru(command)` — Execute a command and stream its output (no capture).

### Built-in attributes

- `workspace.name` — The workspace name
- `workspace.description` — The workspace description
- `workspace.harnessLayers` — Array of harness layers
- `namespace` — Defaults to `workspace.name`; used for Compose project naming

### Configuration file loading order

1. Default harness packages (`config/harness/packages.yml`)
2. Global workspace configuration (`config/workspace/global.yml`)
3. Main workspace file (`workspace.yml`)
4. User-specific global overrides (`~/.config/my127/workspace/*.yml`)
5. Workspace override file (`workspace.override.yml`)
6. Harness configuration (`.my127ws/harness.yml`)

---

## Harness-Specific Commands

### Common Commands Across Harnesses

Most harnesses share these core commands with framework-specific implementations:

#### Environment Management

- `ws enable` - Start development environment
- `ws enable console` - Start console-only environment
- `ws disable` - Stop environment
- `ws destroy [--all]` - Remove environment
- `ws rebuild` - Rebuild environment

#### Container Access

- `ws console` - Access main application container
- `ws exec %` - Execute commands in container
- `ws logs %` - View service logs
- `ws ps` - Show container status

#### Development Tools

- `ws composer %` - Run Composer commands (PHP harnesses)
- `ws db console` / `ws db-console` - Database command line
- `ws set <attribute> <value>` - Set configuration value

#### Asset Management

- `ws assets download` - Download remote assets
- `ws assets upload` - Upload assets to remote

### Harness-Go Specific Commands

**File**: `harness-go/harness/config/commands.yml`

#### Go Development Tools

- `go docker generate` - Run go generate in container
- `go docker test` - Run Go tests
- `go docker vet` - Run go vet analysis
- `go docker gocyclo` - Cyclomatic complexity analysis
- `go docker gosec` - Security analysis
- `go docker ineffassign` - Ineffective assignment detection
- `go docker fmt check` - Format checking
- `go docker mod check` - Module consistency check

#### Testing & Benchmarking

- `go test coverage` - Generate coverage report
- `go test integration` - Run integration tests
- `go test integration <test-name>` - Run specific test
- `go test integration docker` - Run tests in Docker
- `go bench` - Run benchmarks
- `go bench current` - Current benchmark run
- `go bench compare` - Compare benchmarks
- `go bench report` - Generate benchmark report

#### Code Quality

- `go fmt` - Format Go code
- `recompile` - Recompile and restart
- `use prod` - Switch to production mode

### Harness-Drupal8 Specific Commands

**File**: `harness-drupal8/harness/config/commands.yml`

#### Frontend Development

- `frontend build` - Build frontend assets
- `frontend watch` - Watch for frontend changes
- `frontend console` - Access frontend environment

#### Service Management

- `port <service>` - Show service ports
- `service php-fpm restart` - Restart PHP-FPM

#### Feature Toggles

- `feature blackfire (on|off)` - Toggle Blackfire profiler
- `feature blackfire cli (on|off)` - Toggle Blackfire CLI
- `feature tideways (on|off)` - Toggle Tideways profiler
- `feature tideways cli (on|off)` - Toggle Tideways CLI
- `feature tideways cli configure <key>` - Configure Tideways

#### Database Management

- `db import <file>` - Import database dump

#### Utilities

- `generate token <length>` - Generate secure token
- `lighthouse [--with-results]` - Run performance audit

### Pipeline Commands (Drupal8, Symfony, WordPress, etc.)

**File**: `harness-*/harness/config/pipeline.yml`

#### Build & Deployment

- `ws app build` - Build all services
- `ws app build <service>` - Build specific service
- `ws app publish` - Publish to registry
- `ws app publish chart <release> <message>` - Publish Helm chart
- `ws app deploy <environment>` - Deploy to Kubernetes

#### Helm Operations

- `ws helm template <chart-path>` - Render templates
- `ws helm kubeval [--cleanup] <chart-path>` - Validate manifests

### External Images Commands

**File**: `harness-*/harness/config/external-images.yml`

#### Image Management

- `ws external-images config [--skip-exists] [<service>]` - Generate image config
- `ws external-images pull [<service>]` - Pull external images
- `ws external-images ls [--all]` - List external images
- `ws external-images rm [--force]` - Remove external images

---

## Common Functions Across Harnesses

### YAML Processing Functions

- `to_yaml(data)` - Convert data to YAML
- `to_nice_yaml(data, indentation, nesting)` - Formatted YAML conversion
- `indent(text, indentation)` - Indent text blocks

### Array Processing Functions

- `deep_merge(arrays)` - Deep merge arrays
- `filter_empty(array)` - Remove empty values
- `flatten(array)` - Flatten multidimensional array
- `filter_local_services(services)` - Filter for local development

### Docker Functions

- `docker_service_images([service])` - Analyze service images
- `get_docker_external_networks()` - Get external network names
- `get_docker_registry(repository)` - Extract registry URL
- `docker_config(credentials)` - Generate Docker auth config

### Utility Functions

- `branch()` - Get current Git branch
- `slugify(text)` - Convert to URL-safe slug
- `bool(value)` - Convert to boolean
- `boolToString(value)` - Convert boolean to string
- `version_compare(v1, v2, operator)` - Compare versions
- `replace(haystack, needle, replacement)` - String replacement

### Harness-Specific Functions

#### Harness-Go Functions

**File**: `harness-go/harness/config/functions.yml`

- `go_mod_exists(path)` - Check for go.mod file

#### Harness-Drupal8 Functions  

**File**: `harness-drupal8/harness/config/functions.yml`

- `host_architecture([style])` - Get system architecture
- `php_fpm_exporter_scrape_url(hostname, pools)` - PHP-FPM metrics URLs
- `publishable_services(services)` - Get publishable service names
- `template_key_value(template, key_values)` - Template substitution

#### External Images Functions

**File**: `harness-*/harness/config/external-images.yml`

- `external_images(services)` - Extract external image requirements

---

## File Structure Summary

### Core Workspace

```text
workspace/
├── config/workspace/global.yml          # Global service commands
└── home/bin/                           # Utility scripts
```

### Base Harnesses

```text
harness-base-node/harness/config/
├── commands.yml                        # Node.js base commands
└── functions.yml                       # YAML/array processing functions

harness-base-php/harness/config/
├── commands.yml                        # PHP base commands  
└── functions.yml                       # PHP utility functions
```

### Application Harnesses

```text
harness-*/harness/config/
├── commands.yml                        # Framework-specific commands
├── functions.yml                       # Utility functions
├── pipeline.yml                        # Build/deploy commands
├── external-images.yml                 # Image management
├── secrets.yml                         # Secret management
├── mutagen.yml                         # File sync (macOS)
├── cleanup.yml                         # Cleanup operations
├── xdebug.yml                          # PHP debugging (PHP harnesses)
└── docker-sync.yml                     # Alternative sync (some harnesses)
```

---

## Usage Patterns

### Basic Development Workflow

```bash
# Start environment
ws enable

# Access container
ws console

# Development tasks
ws composer install      # PHP projects
ws go docker test        # Go projects
ws frontend build        # Frontend assets

# View logs and status
ws logs app
ws ps
```

### Configuration and Attributes

```bash
# Set configuration
ws set database.host localhost
ws set app.debug true

# Feature toggles (PHP harnesses)
ws feature blackfire on
ws feature tideways cli on
```

### Asset and Database Management

```bash
# Database operations
ws db console
ws db import dump.sql

# Asset synchronization
ws assets download
ws assets upload
```

### Build and Deployment

```bash
# Build applications
ws app build
ws app build console

# External image management
ws external-images pull
ws external-images ls

# Deployment (with pipeline)
ws app publish
ws app deploy staging
```

### Testing and Quality Assurance

```bash
# Go projects
ws go docker test
ws go test coverage
ws go bench

# Performance and security
ws lighthouse --with-results
ws go docker gosec
```

---

## Environment Variables

Common environment variables used across harnesses:

### Core Environment

- `COMPOSE_PROJECT_NAME` - Docker Compose project namespace
- `NAMESPACE` - Workspace namespace
- `APP_BUILD` - Application build configuration
- `APP_MODE` - Development/production mode

### Platform Detection

- `USE_MUTAGEN` - Enable file sync on macOS
- `COMPOSE_DOCKER_CLI_BUILD` - Enable BuildKit
- `DOCKER_BUILDKIT` - BuildKit support

### Service Flags

- `HAS_ASSETS` - Asset management availability
- `HAS_WEBAPP` - Web application service
- `HAS_CRON` - Cron service
- `HAS_SOLR` - Solr search service

### AWS Integration

- `AWS_ACCESS_KEY_ID` - AWS credentials
- `AWS_SECRET_ACCESS_KEY` - AWS credentials
- `AWS_ID` / `AWS_KEY` - Alternative AWS credential names

---

## Command Categories

### By Function

- **Environment**: ws enable, ws disable, ws destroy, ws rebuild
- **Development**: ws console, ws exec, ws composer, ws frontend
- **Database**: ws db console, ws db import
- **Assets**: ws assets download/upload
- **Build**: ws app build, ws external-images pull
- **Deploy**: ws app publish, ws app deploy
- **Testing**: ws go docker test, ws lighthouse
- **Config**: ws set, ws feature toggles
- **Utility**: ws generate token, ws logs, ws ps

### By Harness Type

- **Universal**: All harnesses (enable, disable, console, etc.)
- **PHP-based**: Drupal8, Symfony, WordPress, Magento1
- **Language-specific**: Go, Node.js
- **Framework-specific**: Drupal, Symfony, WordPress

---

## Integration Points

### External Tools

- **Docker & Docker Compose**: Container orchestration
- **Git**: Version control integration
- **AWS S3**: Asset storage
- **Kubernetes/Helm**: Deployment platform
- **Mutagen**: File synchronization (macOS)

### Development Tooling

- **Composer**: PHP dependency management
- **npm/yarn**: Node.js packages (via frontend commands)
- **Go toolchain**: Testing, formatting, analysis
- **PHP tools**: Blackfire, Tideways profiling

### Monitoring & Quality

- **Lighthouse**: Performance auditing
- **PHP-FPM metrics**: Performance monitoring
- **Security scanning**: gosec, other tools
- **Code quality**: Various linters and formatters

This comprehensive index provides developers with a complete reference for all
available commands and functions across the entire Workspace ecosystem.
