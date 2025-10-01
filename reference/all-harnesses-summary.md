# All Harnesses Commands and Functions Summary

<!-- QUICK-INDEX -->
## Quick Index

- Common command highlights: [Quick Reference](#quick-reference-common-commands-across-harnesses)
- Shared functions: [Common Functions](#common-functions-across-harnesses)
- Feature map: [Harness-Specific Features](#harness-specific-features)
- Config examples: [Configuration Examples](#configuration-examples)
- Environment variables: [Environment Variables](#environment-variables)
<!-- /QUICK-INDEX -->

<!-- TOC -->
## Table of Contents

- [Quick Index](#quick-index)
- [Introduction](#introduction)
- [Harness Documentation Files](#harness-documentation-files)
- [Quick Reference: Common Commands Across Harnesses](#quick-reference-common-commands-across-harnesses)
- [Common Functions Across Harnesses](#common-functions-across-harnesses)
- [Harness-Specific Features](#harness-specific-features)
- [Configuration Examples](#configuration-examples)
- [Environment Variables](#environment-variables)
- [Best Practices](#best-practices)
- [Support and Documentation](#support-and-documentation)

<!-- /TOC -->

## Introduction

This document provides a comprehensive overview of all commands and
functions available across all harnesses in the workspace.

## Harness Documentation Files

Individual detailed documentation for each harness:

- [Workspace Commands and Functions - Master Index](./workspace-commands-functions-index.md)
- [Harness Base Node Commands and Functions](./harness-base-node-commands-functions.md)
- [Harness Base PHP Commands and Functions](./harness-base-php-commands-functions.md)
- [Harness Docker Commands and Functions](./harness-docker-commands-functions.md)

## Quick Reference: Common Commands Across Harnesses

For the full authoritative list of core and shared harness commands, see:
**[Workspace Commands and Functions - Master Index](./workspace-commands-functions-index.md)**.

Below are category highlights (non-exhaustive). Use the master index for
details, usage patterns, and implementation references.

### Core Workspace Management (Highlights)

- `ws enable` / `ws disable` — Start/stop environment
- `ws rebuild` — Rebuild containers & regenerate rendered files
- `ws console` — Open main application container
- `ws logs <service>` — Tail service logs

### Development & Tooling

- `ws exec <command>` — Execute inside container
- `ws composer <args>` (PHP harnesses)
- `ws frontend build|watch|console` (where frontend layer present)

### Data & Assets

- `ws db console` / `ws db import <file>` (where DB service provided)
- `ws assets download|upload` (harnesses with asset sync feature)

### Features / Extensions

- `ws feature xdebug|blackfire|tideways (on|off)` (PHP variants)
- `ws yarn <args>` (Node-based harnesses)

### Utilities

- `ws generate token <length>`
- `ws lighthouse`
- `ws networks external`

## Common Functions Across Harnesses

### YAML Processing

- `to_yaml(data)` - Convert to YAML format
- `to_nice_yaml(data, indentation, nesting)` - YAML with custom formatting
- `indent(text, indentation)` - Add indentation to text

### Array/Data Processing

- `deep_merge(arrays)` - Deep merge multiple arrays
- `flatten(array)` - Flatten multi-dimensional arrays
- `filter_local_services(services)` - Filter for local development

### Docker Functions

- `docker_service_images()` - Get service images and dependencies
- `get_docker_external_networks()` - Get external network names
- `docker_config(registryConfig)` - Generate Docker auth config
- `get_docker_registry(repository)` - Extract registry from repository

### Service Management

- `publishable_services(services)` - Filter publishable services

### Utility Functions

- `branch()` - Get current Git branch
- `slugify(text)` - Convert text to URL-friendly slug
- `boolToString(value)` - Convert boolean to yes/no
- `version_compare(v1, v2, operator)` - Compare version strings
- `replace(haystack, needle, replacement)` - String replacement

### PHP-Specific Functions

- `php_fpm_exporter_scrape_url(hostname, pools)` - PHP-FPM monitoring URLs

### Architecture Functions

- `host_architecture(style)` - Get host architecture in different formats

## Harness-Specific Features

### harness-base-node

- Node.js and Yarn command execution
- Node container management
- NPM/Yarn dependency management

### harness-base-php  

- PHP extension management (Blackfire, Tideways)
- Frontend build tools integration
- Composer integration
- PHP-FPM service management

### harness-docker

- Complete Docker container lifecycle management
- Asset management with AWS S3
- Database import/export
- Lighthouse performance auditing
- Token generation utilities

### harness-drupal8

- Drupal-specific development tools
- Standard Docker harness features
- PHP and frontend development tools

### harness-go

- Go language development environment
- Container-based Go execution

### harness-magento1

- Magento 1.x specific development tools
- PHP and frontend tools
- E-commerce development features

### harness-node

- Node.js application development
- NPM/Yarn package management
- JavaScript/TypeScript development

### harness-php

- Generic PHP development
- Multiple PHP extension support (Blackfire, Tideways, Xdebug)
- Docker Sync integration
- Frontend development tools

### harness-symfony

- Symfony framework development
- PHP development tools
- Symfony-specific optimizations

### harness-viper

- Microservices architecture
- Node.js and containerized development
- Service mesh integration

### harness-wordpress

- WordPress development environment
- PHP and frontend tools
- WordPress-specific optimizations

## Configuration Examples

### Basic Workspace Setup

```yaml
workspace('my-project'):
  description: My development project
  
harness('docker'):
  packages:
    - harness-docker
```

### Using Common Functions

```yaml
attribute('project.slug'): = slugify(@('workspace.name'))
attribute('git.branch'): = branch()
attribute('docker.arch'): = host_architecture('go')

services: = deep_merge([
  @('base_services'),
  @('custom_services')
])
```

### Custom Commands

```yaml
command('setup'): |
  #!bash
  ws enable
  ws composer install
  ws frontend build
  
command('deploy'): |
  #!bash
  ws assets upload
  ws harness update existing
```

## Environment Variables

Common environment variables used across harnesses:

- `NAMESPACE` / `COMPOSE_PROJECT_NAME` - Docker project naming
- `CODE_OWNER` - User for running commands
- `COMPOSE_BIN` - Docker Compose binary path
- `USE_MUTAGEN` - Enable Mutagen file sync (macOS)
- `APP_BUILD` / `APP_MODE` - Application configuration
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` - AWS credentials

## Best Practices

1. **Use appropriate harness** - Choose the harness that matches your
  technology stack
2. **Leverage common functions** - Use provided functions for consistent behavior
3. **Environment-specific configuration** - Use workspace.override.yml for
  local settings
4. **Attribute management** - Use `ws set` for runtime configuration changes
5. **Service lifecycle** - Follow enable → work → disable workflow
6. **Asset management** - Use provided upload/download commands for assets
7. **Extension management** - Use feature commands for PHP extensions
8. **Monitoring** - Use logs and ps commands for debugging

## Support and Documentation

For detailed information about specific harnesses, refer to the individual
documentation files linked at the top of this document. Each harness may have
additional commands and functions not covered in this summary.
