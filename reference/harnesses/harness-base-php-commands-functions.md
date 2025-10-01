
# Harness Base PHP Commands and Functions

<!-- QUICK-INDEX -->
## Quick Index

- Orientation: [Overview](#overview)
- Core tasks: [Commands](#commands)
- Extensibility: [Functions](#functions)
- How-to: [Examples](#examples)
<!-- /QUICK-INDEX -->

<!-- TOC -->
## Table of Contents

- [Quick Index](#quick-index)
- [Introduction](#introduction)
- [Overview](#overview)
- [Commands](#commands)
- [Functions](#functions)
- [Examples](#examples)

<!-- /TOC -->

## Introduction

This document covers all commands and functions available in the Base PHP
harness.

## Overview

The Base PHP harness provides a Docker-based PHP development environment
with frontend tooling, composer, PHP-FPM, and extension management.

---

## Commands

### File: `harness-base-php/src/_base/harness/config/commands-php.yml`

- Frontend: `ws frontend build`, `ws frontend watch`, `ws frontend console`
- Composer: `ws composer %`
- PHP-FPM: `ws service php-fpm restart`, `ws console reload`
- Feature toggles:
  - `ws feature blackfire (on|off)`, `ws feature blackfire cli (on|off)`
  - `ws feature tideways (on|off)`, `ws feature tideways cli (on|off)`,
    `ws feature tideways cli configure <server_key>`
- Harness management: `ws harness post-update`

---

## Functions

### File: `harness-base-php/src/_base/harness/config/functions-php.yml`

- `php_fpm_exporter_scrape_url(hostname, pools)` — Generate scrape URLs for
  PHP-FPM status monitoring

---

## Examples

### Build frontend assets and install composer dependencies

```bash
ws composer install
ws frontend build
```

### Enable Blackfire for PHP-FPM

```bash
ws feature blackfire on
```

### Configuring PHP Extensions

```yaml
command('setup-profiling'): |
  #!bash
  ws feature blackfire on
  ws feature tideways cli on
  ws feature tideways cli configure ${TIDEWAYS_KEY}
```

### Using Functions in Configuration

```yaml
attribute('monitoring.php_fpm_urls'): = php_fpm_exporter_scrape_url(
  @('php.hostname'),
  @('php.pools')
)
```

### Environment Variables

The following environment variables are used by these commands:

- `CODE_OWNER` - User to run commands as (from `@('app.code_owner')`)
- `COMPOSE_BIN` - Docker Compose binary path (from `@('docker.compose.bin')`)
- `TIDEWAYS_SERVERKEY` - Tideways server key for CLI configuration

### Integration with Base Commands

This harness extends the base functionality and works with:

- Base container management commands
- Docker Compose integration
- Workspace attribute system
- Environment variable interpolation
