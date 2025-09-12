# Harness Symfony - Commands and Functions Documentation

This document covers all commands and functions available in the Symfony harness.

## Overview

The Symfony harness provides a Docker-based environment for Symfony
applications with commands for environment lifecycle, frontend tooling,
assets, DB access, and profiling.

---

## Commands

### File: `harness-symfony/harness/config/commands.yml`

#### Environment Management

**`ws enable`** — Start full environment

- Purpose: Starts all services (console, php-fpm, nginx, db, etc.)
- Env: USE_MUTAGEN, APP_BUILD, APP_MODE, NAMESPACE, HAS_ASSETS,
  COMPOSE_PROJECT_NAME, COMPOSE_DOCKER_CLI_BUILD, DOCKER_BUILDKIT
- Execution: Source `.my127ws/harness/scripts/enable.sh`

Example output:

```bash
Creating network symfony_default
Starting symfony_console ... done
Starting symfony_php-fpm ... done
Starting symfony_nginx ... done
```

**`ws enable console`** — Start only console service

- Purpose: Minimal environment for CLI tasks
- Execution: `enable.sh` with console subset

**`ws disable`** — Stop running services

- Purpose: Gracefully stops containers (and mutagen if enabled)
- Execution: Source `.my127ws/harness/scripts/disable.sh`

**`ws destroy [--all]`** — Remove environment

- Purpose: Removes containers, networks, and optionally volumes/data when `--all`
- Execution: Source `.my127ws/harness/scripts/destroy.sh`

**`ws rebuild`** — Recreate services from scratch

- Purpose: Re-applies templates and rebuilds containers
- Execution: Source `.my127ws/harness/scripts/rebuild.sh`

#### Networking

**`ws networks external`** — Ensure external networks exist

- Purpose: Creates any external docker networks referenced by compose
- Env: NETWORKS from `get_docker_external_networks()`

#### Container Access and Ops

**`ws exec %`** — Execute command in console container

- Purpose: Runs arbitrary commands (TTY-aware)
- Example: `ws exec php -v`

**`ws logs %`** — Show service logs

- Purpose: Stream logs for a given service
- Example: `ws logs php-fpm`

**`ws ps`** — List containers

- Purpose: Show status/ports of all services

**`ws console`** — Open shell

- Purpose: Interactive bash in console container as `build` user

#### Development Tools

**`ws composer %`** — Run Composer

- Purpose: Executes Composer inside container
- Example: `ws composer install`

**`ws db-console` / `ws db console`** — DB shell

- Purpose: Opens MySQL/MariaDB CLI using env vars

#### Asset Management

**`ws assets download`** — Pull assets from S3 (or compatible)

- Purpose: Sync remote assets to local

**`ws assets upload`** — Push assets to S3

- Purpose: Sync local assets to remote

#### Frontend

**`ws frontend build`** — Build frontend assets

- Purpose: Runs `app build:frontend` inside console

**`ws frontend watch`** — Watch and rebuild

- Purpose: Runs watch command in `frontend.path` with nvm init via `bash -i`

**`ws frontend console`** — Open shell in frontend path

- Purpose: Interactive Node tooling shell

#### Service Utilities

**`ws port <service>`** — Show ports for a service

- Example output: `80/tcp -> 0.0.0.0:8080`

**`ws service php-fpm restart`** — Reload php-fpm with updated config

- Purpose: Sync conf.d and restart via supervisorctl

#### Configuration Management

**`ws set <attribute> <value>`** — Set attribute in `workspace.override.yml`

- Example output:

```bash
Removing old 'php.ext-xdebug.enable' setting from workspace.override.yml
Setting 'php.ext-xdebug.enable' setting to 'yes' in workspace.override.yml
```

#### Feature Toggles

**`ws feature blackfire (on|off)`**, **`ws feature blackfire cli (on|off)`**

- Purpose: Enable/disable Blackfire (FPM/CLI)

**`ws feature tideways (on|off)`**, **`ws feature tideways cli (on|off)`**,
**`ws feature tideways cli configure <server_key>`**

- Purpose: Enable/disable Tideways (FPM/CLI) and import CLI key

#### DB Utilities

**`ws db import <database_file>`** — Import SQL dump

- Purpose: Import database using app tooling inside console container

#### Harness Updates

**`ws harness update existing`** — Update keeping data and overlays

- Steps: disable → download → prepare → refresh → composer install → migrate → welcome

**`ws harness update fresh`** — Clean reinstall

- Steps: disable → remove `.my127ws` → install

#### Misc

**`ws generate token <length>`** — Generate random alphanumeric token

**`ws lighthouse [--with-results]`** — Run Lighthouse audits

---

### File: `harness-symfony/harness/config/pipeline.yml`

- `app build` — Build images in dependency order (console → php-fpm → nginx /
  cron / jenkins-runner / job-queue when enabled)
- `app build <service>` — Build a single service
- `app publish` — Login and push images defined in
  `pipeline.publish.services`
- `app publish chart <release> <message>` — Publish Helm chart to Git repo
- `app deploy <environment>` — Helm upgrade/install to k8s cluster
- `helm template <chart-path>` — Render templates
- `helm kubeval [--cleanup] <chart-path>` — Validate manifests (installs
  plugin if needed)

Example output (build):

```bash
Pulling external images...
Building console...
Building php-fpm...
Building nginx...
```


### File: `harness-symfony/harness/config/external-images.yml`

- Function `external_images(services)` — Collect upstream images (excluding
  produced images and scratch) and return as JSON
- Command `external-images config [--skip-exists] [<service>]` — Emit
  docker-compose for pulling external images
- Command `external-images pull [<service>]` — Pull via generated compose
- Command `external-images ls [--all]` — List required or local-present images
- Command `external-images rm [--force]` — Remove listed images

Example output (ls):

```bash
mysql:8.0
redis:6-alpine
```


## Functions

### File: `harness-symfony/harness/config/functions.yml`

- `host_architecture(style)` — Return host arch (native or go-style mapping)
- `to_yaml(data)` / `to_nice_yaml(data, indentation, nesting)` — YAML
  serialization helpers
- `indent(text, indentation)` — Indent each line
- `deep_merge(arrays)` — Deep-merge arrays (Drupal algorithm)
- `filter_local_services(services)` — Keep enabled/environment/... keys for
  local view
- `flatten(array)` — Flatten nested arrays
- `get_docker_external_networks()` — Parse compose config, return external networks
- `docker_service_images([filterService])` — For each service, return image /
  platform / upstream FROM images
- `get_docker_registry(dockerRepository)` — Extract registry host or Docker Hub default
- `docker_config(registryConfig)` — JSON for docker auths (base64 user:pass)
- `branch()` — Current git branch
- `slugify(text)` — URL-safe slug
- `php_fpm_exporter_scrape_url(hostname, pools)` — Comma-separated PHP-FPM
  status URLs
- `publishable_services(services)` — Space-separated service names with
  publish: true
- `replace(haystack, needle, replacement)` — String replace
- `template_key_value(template, key_value)` — Render map into templated keys
- `version_compare(v1, v2, op)` — Compare versions with normalization
- `bool(value)` / `boolToString(value)` — Boolean conversions
