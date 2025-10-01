# Harness Magento 1 - Commands and Functions Documentation

<!-- QUICK-INDEX -->
## Quick Index

- Orientation: [Overview](#overview)
- Core tasks: [Environment Lifecycle](#environment-lifecycle), [Feature Toggles](#feature-toggles)
- Data & assets: [Database](#database)
- Build & deploy: [Pipeline](#file-harness-magento1harnessconfigpipelineyml)
- Reference: [Functions](#functions), [Usage Examples](#usage-examples)
<!-- /QUICK-INDEX -->

<!-- TOC -->
## Table of Contents

- [Quick Index](#quick-index)
- [Overview](#overview)
- [Commands](#commands)
- [Functions](#functions)
- [Usage Examples](#usage-examples)

<!-- /TOC -->

This document covers all commands and functions available in the Magento 1 harness.

## Overview

Magento 1 harness provides a Docker-based PHP stack plus optional docker-sync and
feature toggles for Blackfire, Tideways, and Xdebug. Includes pipeline and
external-images helpers.

---

## Commands

### File: `harness-magento1/harness/config/commands.yml`

#### Environment Lifecycle

**`ws enable`**

- **Description:** Enable and start all workspace services
- **Usage:** `ws enable`
- **Example output:** All containers started, workspace ready

**`ws enable console`**

- **Description:** Enable and start only the console service
- **Usage:** `ws enable console`
- **Example output:** Console container started, ready for CLI

**`ws disable`**

- **Description:** Disable and stop the workspace
- **Usage:** `ws disable`
- **Example output:** All containers stopped, workspace offline

**`ws destroy [--all]`**

- **Description:** Destroy the workspace and optionally clean up all resources
- **Usage:** `ws destroy` or `ws destroy --all`
- **Example output:** Containers and volumes removed, workspace reset

**`ws rebuild`**

- **Description:** Rebuild the workspace containers
- **Usage:** `ws rebuild`
- **Example output:** Environment destroyed and rebuilt from scratch

#### Network Management

**`ws networks external`**

- **Description:** Create external Docker networks if they don't exist
- **Usage:** `ws networks external`
- **Example output:** `docker network create frontend_network`

#### Container Access

**`ws exec %`**

- **Description:** Execute commands inside the console container as build user
- **Usage:** `ws exec php --version` or `ws exec composer install`
- **Example output:** Command output from inside the container

**`ws console`**

- **Description:** Open a bash console inside the console container
- **Usage:** `ws console`
- **Example output:** Interactive bash prompt in console container

**`ws logs %`**

- **Description:** View logs for specified service
- **Usage:** `ws logs console` or `ws logs --follow web`
- **Example output:** Service logs with timestamps

**`ws ps`**

- **Description:** Show running containers and their status
- **Usage:** `ws ps`
- **Example output:** Table of running containers and ports

#### Composer

**`ws composer %`**

- **Description:** Run composer commands in the console container
- **Usage:** `ws composer install` or `ws composer update`
- **Example output:** Composer install/update output

#### Database

**`ws db-console`** / **`ws db console`**

- **Description:** Open MySQL/database console
- **Usage:** `ws db console`
- **Example output:** Interactive MySQL prompt

**`ws db import <database_file>`**

- **Description:** Import database from file
- **Usage:** `ws db import backup.sql`
- **Example output:** Database import progress, tables created/updated

#### Frontend

**`ws frontend build`**

- **Description:** Build frontend assets using the console container
- **Usage:** `ws frontend build`
- **Example output:** Asset compilation logs, build artifacts created

**`ws frontend watch`**

- **Description:** Start frontend development watch mode
- **Usage:** `ws frontend watch`
- **Example output:** File watcher status, automatic rebuild notifications

**`ws frontend console`**

- **Description:** Open a bash console in the frontend working directory
- **Usage:** `ws frontend console`
- **Example output:** Shell prompt in frontend directory with Node.js available

#### Ports

**`ws port <service>`**

- **Description:** Show port mappings for a service
- **Usage:** `ws port web`
- **Example output:** `80/tcp -> 0.0.0.0:8080`

#### PHP-FPM

**`ws service php-fpm restart`**

- **Description:** Restart PHP-FPM service with updated configuration
- **Usage:** `ws service php-fpm restart`
- **Example output:** PHP-FPM configuration updated, service restarted

#### Configuration Management

**`ws set <attribute> <value>`**

- **Description:** Set workspace attribute in workspace.override.yml
- **Usage:** `ws set app.development yes`
- **Example output:** Setting 'app.development' to 'yes' in workspace.override.yml

#### Feature Toggles

**`ws feature blackfire (on|off)`**

- **Description:** Enable or disable Blackfire profiler extension for PHP-FPM
- **Usage:** `ws feature blackfire on` or `ws feature blackfire off`
- **Example output:** Blackfire enabled/disabled, PHP-FPM restarted

**`ws feature blackfire cli (on|off)`**

- **Description:** Enable or disable Blackfire profiler extension for CLI
- **Usage:** `ws feature blackfire cli on`
- **Example output:** Blackfire CLI enabled, console service updated

**`ws feature tideways (on|off)`**

- **Description:** Enable or disable Tideways profiler extension for PHP-FPM
- **Usage:** `ws feature tideways on` or `ws feature tideways off`
- **Example output:** Tideways enabled/disabled, PHP-FPM restarted

**`ws feature tideways cli (on|off)`**

- **Description:** Enable or disable Tideways profiler extension for CLI
- **Usage:** `ws feature tideways cli on`
- **Example output:** Tideways CLI enabled, services updated

**`ws feature tideways cli configure <server_key>`**

- **Description:** Configure Tideways CLI with server key
- **Usage:** `ws feature tideways cli configure your-server-key`
- **Example output:** Imported Tideways CLI key

**`ws feature xdebug (on|off)`**

- **Description:** Enable or disable Xdebug extension for PHP-FPM
- **Usage:** `ws feature xdebug on` or `ws feature xdebug off`
- **Example output:** Xdebug enabled/disabled, PHP-FPM restarted

**`ws feature xdebug cli (on|off)`**

- **Description:** Enable or disable Xdebug extension for CLI
- **Usage:** `ws feature xdebug cli on`
- **Example output:** Xdebug CLI enabled, console service updated

#### Docker Sync

**`ws docker-sync on`**, **`ws docker-sync off`**, **`ws docker-sync status`**

- **Description:** Manage Docker Sync for file synchronization (macOS)
- **Usage:** `ws docker-sync on` / `ws docker-sync off` / `ws docker-sync status`
- **Example output:** Docker Sync enabled/disabled/status shown

**`ws docker-sync start`**, **`ws docker-sync stop`**, **`ws docker-sync clean`**

- **Description:** Control Docker Sync lifecycle
- **Usage:** `ws docker-sync start` / `ws docker-sync stop` / `ws docker-sync clean`
- **Example output:** Docker Sync started/stopped/cleaned

#### Harness Updates

**`ws harness update existing`**

- **Description:** Update harness while preserving existing configuration
- **Usage:** `ws harness update existing`
- **Example output:** Harness updated, environment refreshed

**`ws harness update fresh`**

- **Description:** Fresh harness update, removing all existing configuration
- **Usage:** `ws harness update fresh`
- **Example output:** Clean harness installation, all default configurations

#### Utilities

**`ws generate token <length>`**

- **Description:** Generate a random token of specified length
- **Usage:** `ws generate token 32`
- **Example output:** `aB3xK7mN9qR2sT5u` (for length 16)

### File: `harness-magento1/harness/config/docker-sync.yml`

- **Description:** Provides docker-sync configuration for macOS file sync acceleration.
- **Usage:** Managed via Docker Sync commands above; this file defines sync volumes.

### File: `harness-magento1/harness/config/pipeline.yml`

**`ws app build`**

- **Description:** Build all service images (console, php-fpm, nginx; optional
  cron, jenkins-runner)
- **Usage:** `ws app build` or `ws app build <service>`
- **Example output:**

  ```text
  Pulling external images...
  Building console...
  Building php-fpm...
  Building nginx...
  ```

**`ws app publish`**

- **Description:** Push images to registry
- **Usage:** `ws app publish`
- **Example output:**

  ```text
  Pushing registry.example.com/project/php-fpm:abcd123
  Pushed.
  ```

**`ws app publish chart <release> <message>`**

- **Description:** Publish Helm chart to Git
- **Usage:** `ws app publish chart v1.2.3 "Release message"`
- **Example output:**

  ```text
  Cloning chart repository...
  Syncing Helm templates...
  Committing chart updates...
  Pushing to repository...
  ```

**`ws app deploy <environment>`**

- **Description:** Helm upgrade/install with kubeconfig
- **Usage:** `ws app deploy staging`
- **Example output:**

  ```text
  Connecting to cluster...
  Building Helm dependencies...
  Deploying to namespace...
  Release deployed successfully
  ```

**`ws helm template <chart-path>`**

- **Description:** Render Helm templates
- **Usage:** `ws helm template charts/mychart`
- **Example output:** Complete Kubernetes YAML manifests

**`ws helm kubeval [--cleanup] <chart-path>`**

- **Description:** Validate templates (installs plugin)
- **Usage:** `ws helm kubeval charts/mychart`
- **Example output:**

  ```text
  PASS - Deployment is valid
  PASS - Service is valid
  PASS - ConfigMap is valid
  ```

### File: `harness-magento1/harness/config/external-images.yml`

**`external_images(services)`**

- **Description:** JSON list of needed external images (excludes produced and scratch)
- **Usage:** Used by external image commands below
- **Example output:**

  ```json
  [
    {"image": "mysql:8.0", "platform": null},
    {"image": "redis:6-alpine", "platform": "linux/amd64"}
  ]
  ```

**`ws external-images config [--skip-exists] [<service>]`**

- **Description:** Emit docker-compose for pulling
- **Usage:** `ws external-images config --skip-exists`
- **Example output:**

  ```yaml
  version: '3'
  services:
    mysql_8_0:
      image: mysql:8.0
    redis_6_alpine:
      image: redis:6-alpine
  ```

**`ws external-images pull [<service>]`**

- **Description:** Pull using generated compose
- **Usage:** `ws external-images pull redis`
- **Example output:**

  ```text
  Pulling mysql_8_0...
  Pulling redis_6_alpine...
  Pull complete
  ```

**`ws external-images ls [--all]`**

- **Description:** List required or locally present images
- **Usage:** `ws external-images ls --all`
- **Example output:**

  ```text
  mysql:8.0
  redis:6-alpine
  nginx:1.21-alpine
  ```

**`ws external-images rm [--force]`**

- **Description:** Remove external images
- **Usage:** `ws external-images rm --force`
- **Example output:**

  ```text
  Untagged: mysql:8.0
  Untagged: redis:6-alpine
  Deleted: sha256:abc123...
  ```

---

## Functions

### File: `harness-magento1/harness/config/functions.yml`

#### YAML Helpers

**`to_yaml(data)`**

- **Description:** Convert data to YAML format with proper indentation
- **Parameters:**
  - `data` - The data to convert to YAML
- **Usage:** `= to_yaml({'key': 'value'})`

**`to_nice_yaml(data, indentation, nesting)`**

- **Description:** Convert data to YAML with custom indentation and nesting
- **Parameters:**
  - `data` - The data to convert
  - `indentation` - Number of spaces for indentation (default: 2)
  - `nesting` - Number of spaces for nesting level (default: 2)
- **Usage:** `= to_nice_yaml(data, 4, 2)`

#### Deep Merge

**`deep_merge(arrays)`**

- **Description:** Deep merge multiple arrays recursively
- **Parameters:**
  - `arrays` - Array of arrays to merge
- **Usage:** `= deep_merge([array1, array2, array3])`

**`deep_merge_to_yaml(arrays)`**

- **Description:** Deep merge arrays and convert to YAML
- **Parameters:**
  - `arrays` - Arrays to merge
- **Usage:** `= deep_merge_to_yaml([array1, array2])`

#### Service Filters

**`filter_local_services(services)`**

- **Description:** Filter services to only include local development relevant keys
- **Parameters:**
  - `services` - Services configuration
- **Usage:** `= filter_local_services(@('services'))`

#### Docker Helpers

**`docker_service_images([filterService])`**

- **Description:** Image/platform/upstream extraction
- **Parameters:**
  - `filterService` - Optional service name to filter (default: all services)
- **Usage:** `= docker_service_images()`

**`get_docker_external_networks()`**

- **Description:** External networks from compose
- **Usage:** `= get_docker_external_networks()`

**`get_docker_registry(repo)`**

- **Description:** Extract registry from repository
- **Parameters:**
  - `repo` - Docker repository string
- **Usage:** `= get_docker_registry(@('docker.repository'))`

**`docker_config(registryConfig)`**

- **Description:** Generate Docker auth config
- **Parameters:**
  - `registryConfig` - Registry configuration with url, username, password
- **Usage:** `= docker_config(@('registry'))`

#### Git/Slug

**`branch()`**

- **Description:** Get current Git branch name
- **Usage:** `= branch()`

**`slugify(text)`**

- **Description:** Convert text to URL-friendly slug format
- **Parameters:**
  - `text` - Text to slugify
- **Usage:** `= slugify("My Project Name")` → `"my-project-name"`

#### PHP-FPM Exporter

**`php_fpm_exporter_scrape_url(hostname, pools)`**

- **Description:** Generate scrape URLs for PHP-FPM status monitoring
- **Parameters:**
  - `hostname` - The hostname to connect to
  - `pools` - Array of pool configurations with port information
- **Usage:**

  ```yaml
  attribute('php_fpm_scrape_urls'): = php_fpm_exporter_scrape_url(
    'php-fpm',
    @('php.pools')
  )
  ```

#### Publishable Services

**`publishable_services(services)`**

- **Description:** Space-separated names with publish
- **Parameters:**
  - `services` - Services configuration
- **Usage:** `= publishable_services(@('services'))`

#### Version Compare

**`version_compare(v1, v2, op)`**

- **Description:** Compare version strings
- **Parameters:**
  - `v1` - First version string
  - `v2` - Second version string
  - `op` - Comparison operator (>, <, >=, <=, ==, !=)
- **Usage:** `= version_compare('1.2.3', '1.2.0', '>')`

---

## Usage Examples

### Start docker-sync

```bash
ws docker-sync start
Starting docker-sync for volume app-sync...
Sync strategy: rsync
Ready.
```

### Enable Xdebug for CLI

```bash
ws feature xdebug cli on
CLI Xdebug enabled
```

### Build and publish images

```bash
ws app build
Building images: console, php-fpm, nginx
Success.

ws app publish
Pushing registry.example.com/project/php-fpm:abcd123
Pushed.
```
