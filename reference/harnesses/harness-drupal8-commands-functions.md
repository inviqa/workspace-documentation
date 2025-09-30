# Harness Drupal8 - Commands and Functions Documentation

<!-- QUICK-INDEX -->
**Quick Index**: [Overview](#overview) · [Commands](#commands) · [Functions](#functions)
<!-- /QUICK-INDEX -->

<!-- TOC -->
## Table of Contents

- [Overview](#overview)
- [Commands](#commands)
  - [File: `harness-drupal8/harness/config/commands.yml`](#file-harness-drupal8harnessconfigcommandsyml)
    - [Environment Management Commands](#environment-management-commands)
    - [Network Management Commands](#network-management-commands)
    - [Container Management Commands](#container-management-commands)
    - [Development Tools Commands](#development-tools-commands)
    - [Asset Management Commands](#asset-management-commands)
    - [Frontend Development Commands](#frontend-development-commands)
    - [Service Management Commands](#service-management-commands)
    - [Configuration Management Commands](#configuration-management-commands)
    - [Feature Toggle Commands](#feature-toggle-commands)
  - [File: `harness-drupal8/harness/config/functions.yml`](#file-harness-drupal8harnessconfigfunctionsyml)
- [Functions](#functions)
<!-- /TOC -->

This document provides comprehensive documentation of all commands and
functions available in the harness-drupal8 harness for Drupal 8/9/10
application development.

## Overview

The harness-drupal8 harness provides a complete Docker-based development
environment for Drupal applications with comprehensive tooling for
development, testing, deployment, and production management.

---

## Commands

### File: `harness-drupal8/harness/config/commands.yml`

#### Environment Management Commands

**`ws enable`** - Enable the complete Drupal development environment
**Purpose**: Starts all services including web server, database, caches,
and development tools
**Environment Variables**:

- `USE_MUTAGEN`: Darwin (macOS) file sync
- `APP_BUILD`: Application build configuration
- `APP_MODE`: Development/production mode
- `HAS_ASSETS`: Asset management availability
- `COMPOSE_DOCKER_CLI_BUILD`: BuildKit support
**Execution**: Sources enable.sh script with 'all' parameter
**Example output**: All Docker containers starting, services becoming
available, database connections established

**`ws enable console`** - Enable only console services
**Purpose**: Starts minimal environment for console-only operations
**Environment**: Same as full enable but limited scope
**Execution**: Sources enable.sh script with 'console' parameter
**Example output**: Console container ready, database accessible for CLI
operations

**`ws disable`** - Disable the Drupal development environment
**Purpose**: Stops all running services while preserving data
**Environment**: Mutagen sync control, namespace management
**Execution**: Sources disable.sh script
**Example output**: Services stopping gracefully, file sync terminating

**`ws destroy [--all]`** - Destroy the development environment
**Purpose**: Removes all containers, volumes, and optionally all data
**Options**: `--all` - Remove all data including databases and uploads
**Environment**: Complete environment teardown configuration
**Execution**: Sources destroy.sh script
**Example output**: All containers removed, volumes cleaned, fresh
environment ready

**`ws rebuild`** - Rebuild the entire environment
**Purpose**: Complete environment reconstruction from scratch
**Environment**: Full rebuild configuration
**Execution**: Sources rebuild.sh script
**Example output**: Environment destruction followed by fresh installation

#### Network Management Commands

**`ws networks external`** - Create external Docker networks
**Purpose**: Establishes external networks for multi-project connectivity
**Environment**: `NETWORKS` from get_docker_external_networks() function
**Execution**: Creates missing external networks
**Example output**: `docker network create frontend_network`

#### Container Management Commands

**`ws exec %`** - Execute commands in console container
**Purpose**: Runs arbitrary commands inside the Drupal console container
**Parameters**: `%` - Command and arguments to execute
**Environment**: Interactive/non-interactive terminal detection
**Execution**: `docker-compose exec console [command]`
**Example output**: Command execution results within container environment

**`ws logs %`** - View service logs
**Purpose**: Displays logs for specified services
**Parameters**: `%` - Service name(s) to show logs for
**Execution**: `docker-compose logs [service]`
**Example output**: Service log output with timestamps

**`ws ps`** - Show running containers
**Purpose**: Lists all containers and their status
**Execution**: `docker-compose ps`
**Example output**: Container status table with ports and health

**`ws console`** - Access Drupal console container
**Purpose**: Opens interactive bash shell in console container
**Execution**: `docker-compose exec -u build console bash`
**Example output**: Interactive bash prompt inside container

#### Development Tools Commands

**`ws composer %`** - Execute Composer commands
**Purpose**: Runs Composer package manager inside container
**Parameters**: `%` - Composer command and arguments
**Execution**: `ws exec composer [arguments]`
**Example output**: Composer command results, package installations/updates

**`ws db-console`** / **`ws db console`** - Access database console
**Purpose**: Opens MySQL/MariaDB command-line interface
**Execution**: MySQL client connection inside container
**Example output**: Interactive MySQL prompt with database connection

#### Asset Management Commands

**`ws assets download`** - Download assets from remote storage
**Purpose**: Syncs assets (uploads, files) from AWS S3 or similar
**Environment**: AWS credentials and configuration
**Execution**: `ws.aws s3 sync [remote] [local]`
**Example output**: File download progress, sync completion status

**`ws assets upload`** - Upload assets to remote storage
**Purpose**: Syncs local assets to AWS S3 or similar remote storage
**Environment**: AWS credentials and configuration
**Execution**: `ws.aws s3 sync [local] [remote]`
**Example output**: File upload progress, sync completion status

#### Frontend Development Commands

**`ws frontend build`** - Build frontend assets
**Purpose**: Compiles CSS, JavaScript, and other frontend assets
**Execution**: `docker-compose exec console app build:frontend`
**Example output**: Asset compilation logs, build artifacts created

**`ws frontend watch`** - Watch and rebuild frontend assets
**Purpose**: Monitors frontend files and rebuilds automatically on changes
**Environment**: Node Version Manager (nvm) environment
**Execution**: Watch process in frontend path with bash interactive shell
**Example output**: File watcher status, automatic rebuild notifications

**`ws frontend console`** - Access frontend development environment
**Purpose**: Opens shell in frontend working directory with Node.js tools
**Environment**: Interactive bash with nvm configuration
**Execution**: Interactive shell in frontend path
**Example output**: Shell prompt in frontend directory with Node.js available

#### Service Management Commands

**`ws port <service>`** - Show service port mappings
**Purpose**: Displays port mappings for specified service
**Parameters**: `service` - Service name to check ports for
**Execution**: `docker port [service-container]`
**Example output**: `3306/tcp -> 0.0.0.0:33060`

**`ws service php-fpm restart`** - Restart PHP-FPM service
**Purpose**: Restarts PHP-FPM service with updated configuration
**Execution**: Updates PHP configuration and restarts PHP-FPM via
supervisorctl
**Example output**: PHP-FPM configuration updated, service restarted

#### Configuration Management Commands

**`ws set <attribute> <value>`** - Set workspace attribute
**Purpose**: Sets configuration values in workspace.override.yml
**Parameters**:

- `attribute` - Configuration key to set
- `value` - Value to assign
**Execution**: Updates workspace.override.yml file
**Example output**: `Setting 'database.host' setting to 'localhost' in
workspace.override.yml`

#### Feature Toggle Commands

**`ws feature blackfire (on|off)`** - Toggle Blackfire profiler
**Purpose**: Enables/disables Blackfire PHP profiler
**Parameters**: `on` or `off`
**Environment**: Sets `php.ext-blackfire.enable` attribute
**Execution**: Updates configuration and restarts PHP-FPM
**Example output**: Blackfire enabled, PHP-FPM restarted with new
configuration

**`ws feature blackfire cli (on|off)`** - Toggle Blackfire CLI profiler
**Purpose**: Enables/disables Blackfire profiler for CLI commands
**Parameters**: `on` or `off`
**Environment**: Sets `php.ext-blackfire.cli.enable` attribute
**Example output**: Blackfire CLI enabled, console service updated

**`ws feature tideways (on|off)`** - Toggle Tideways profiler
**Purpose**: Enables/disables Tideways PHP profiler
**Parameters**: `on` or `off`
**Environment**: Sets `php.ext-tideways.enable` attribute
**Example output**: Tideways enabled, PHP-FPM restarted

**`ws feature tideways cli (on|off)`** - Toggle Tideways CLI profiler
**Purpose**: Enables/disables Tideways profiler for CLI
**Parameters**: `on` or `off`
**Environment**: Sets `php.ext-tideways.cli.enable` attribute
**Example output**: Tideways CLI enabled, services updated

**`ws feature tideways cli configure <server_key>`** - Configure Tideways CLI
**Purpose**: Imports Tideways server key for CLI profiling
**Parameters**: `server_key` - Tideways server key from dashboard
**Execution**: `docker-compose exec console tideways import [key]`
**Example output**: `Imported Tideways CLI key`

#### Database Management Commands

**`ws db import <database_file>`** - Import database dump
**Purpose**: Imports database from specified file
**Parameters**: `database_file` - Path to database dump file
**Execution**: `docker-compose exec console app database:import [file]`
**Example output**: Database import progress, tables created/updated

#### Harness Management Commands

**`ws harness update existing`** - Update existing harness
**Purpose**: Updates harness files while preserving customizations
**Execution**:

- Disables environment
- Downloads latest harness
- Prepares configuration
- Applies overlays and migrations
**Example output**: Harness updated, environment refreshed with new features

**`ws harness update fresh`** - Fresh harness installation
**Purpose**: Completely reinstalls harness from scratch
**Execution**: Destroys environment and runs fresh installation
**Example output**: Clean harness installation, all default configurations

#### Utility Commands

**`ws generate token <length>`** - Generate random token
**Purpose**: Creates cryptographically secure random token
**Parameters**: `length` - Desired token length
**Implementation**: PHP random_int with alphanumeric characters
**Example output**: `aB3xK7mN9qR2sT5u` (for length 16)

**`ws lighthouse [--with-results]`** - Run Lighthouse performance audit
**Purpose**: Performs web performance audit using Google Lighthouse
**Options**: `--with-results` - Display detailed results
**Execution**: Runs Lighthouse container with audit configuration
**Example output**: Performance scores, accessibility metrics, best
practices report

### File: `harness-drupal8/harness/config/pipeline.yml`

#### Application Build Commands

**`ws app build`** - Build all application services

- **Purpose**: Builds all Docker images for the application stack
- **Environment**: Service availability flags (HAS_CRON, HAS_WEBAPP, etc.)
- **Execution**: Dependency-ordered build of all enabled services
- **Example output**:

  ```text
  Pulling external images...
  Building console...
  Building php-fpm...
  Building nginx...
  ```

**`ws app build <service>`** - Build specific service

- **Purpose**: Builds Docker image for specified service only
- **Parameters**: `service` - Service name to build
- **Execution**: `docker-compose build [service]`
- **Example output**: `Building [service]... Successfully built`

#### Deployment Commands

**`ws app publish`** - Publish application images

- **Purpose**: Pushes built Docker images to container registry
- **Environment**: Extended Docker timeouts, registry credentials
- **Execution**:
  - Login to Docker registry
  - Push specified services
  - Logout from registry
- **Example output**:

  ```text
  Login Succeeded
  Pushing myapp/console:latest...
  Pushing myapp/nginx:latest...
  Logout Succeeded
  ```

**`ws app publish chart <release> <message>`** - Publish Helm chart

- **Purpose**: Publishes Helm chart to Git repository for deployment
- **Parameters**:
  - `release` - Release identifier
  - `message` - Commit message for chart update
- **Environment**: Git SSH key, repository configuration, user details
- **Execution**:
  - Clones chart repository
  - Syncs Helm templates
  - Commits and pushes changes
- **Example output**:

  ```text
  Cloning chart repository...
  Syncing Helm templates...
  Committing chart updates...
  Pushing to repository...
  ```

**`ws app deploy <environment>`** - Deploy to Kubernetes

- **Purpose**: Deploys application to specified Kubernetes environment
- **Parameters**: `environment` - Target environment (staging, production, etc.)
- **Environment**: Kubernetes cluster configuration, namespaces, timeouts
- **Execution**:
  - Connects to Kubernetes cluster
  - Builds Helm dependencies
  - Performs Helm upgrade/install
- **Example output**:

  ```text
  Connecting to cluster...
  Building Helm dependencies...
  Deploying to namespace...
  Release deployed successfully
  ```

#### Helm Management Commands

**`ws helm template <chart-path>`** - Render Helm templates

- **Purpose**: Generates Kubernetes YAML from Helm templates for validation
- **Parameters**: `chart-path` - Path to Helm chart directory
- **Execution**:
  - Builds Helm dependencies
  - Renders templates to stdout
- **Example output**: Complete Kubernetes YAML manifests

**`ws helm kubeval [--cleanup] <chart-path>`** - Validate Kubernetes manifests

- **Purpose**: Validates rendered Helm templates against Kubernetes schemas
- **Parameters**: `chart-path` - Path to Helm chart
- **Options**: `--cleanup` - Remove temporary files after validation
- **Environment**: Kubernetes version, schema locations
- **Execution**:
  - Installs kubeval plugin if needed
  - Validates manifests against schemas
- **Example output**:

  ```text
  PASS - Deployment is valid
  PASS - Service is valid
  PASS - ConfigMap is valid
  ```

### File: `harness-drupal8/harness/config/external-images.yml`

#### External Image Management Commands

**`ws external-images config [--skip-exists] [<service>]`** - Generate
external images config

- **Purpose**: Creates docker-compose configuration for external image pulling
- **Options**: `--skip-exists` - Skip images that already exist locally
- **Parameters**: `service` - Limit to specific service (optional)
- **Implementation**: Generates docker-compose YAML for image pulling
- **Example output**:

  ```yaml
  version: '3'
  services:
    mysql_8_0:
      image: mysql:8.0
    redis_6_alpine:
      image: redis:6-alpine
  ```

**`ws external-images pull [<service>]`** - Pull external images

- **Purpose**: Downloads all external images required by the application
- **Parameters**: `service` - Limit to specific service (optional)
- **Environment**: CI detection for skip-exists behavior
- **Execution**: Uses generated config to pull images with docker-compose
- **Example output**:

  ```text
  Pulling mysql_8_0...
  Pulling redis_6_alpine...
  Pull complete
  ```

**`ws external-images ls [--all]`** - List external images

- **Purpose**: Shows external images used by the application
- **Options**: `--all` - Show all required images (not just local)
- **Implementation**: Lists images from service analysis
- **Example output**:

  ```text
  mysql:8.0
  redis:6-alpine
  nginx:1.21-alpine
  ```

**`ws external-images rm [--force]`** - Remove external images

- **Purpose**: Removes external images to free disk space
- **Options**: `--force` - Force removal of images
- **Execution**: Removes all external images listed by `ls` command
- **Example output**:

  ```text
  Untagged: mysql:8.0
  Untagged: redis:6-alpine
  Deleted: sha256:abc123...
  ```

---

## Functions

### File: `harness-drupal8/harness/config/functions.yml`

#### System Information Functions

**`host_architecture([style])`** - Get host system architecture

- **Purpose**: Returns system architecture in various formats
- **Parameters**:
  - `style` - Format style ('native', 'go', or default)
- **Implementation**: Uses PHP's php_uname('m') with format conversion
- **Example output**:
  - Native: `x86_64`
  - Go format: `amd64`
  - ARM64: `arm64`

#### YAML Processing Functions

**`to_yaml(data)`** - Convert data to YAML format

- **Purpose**: Converts PHP data structures to YAML string
- **Parameters**: `data` - Data structure to convert
- **Implementation**: Symfony YAML component with 100-level depth, 2-space indentation
- **Example output**:

  ```yaml
  database:
    host: localhost
    port: 3306
  ```

**`to_nice_yaml(data, [indentation], [nesting])`** - Convert to formatted YAML

- **Purpose**: Converts data to YAML with custom formatting options
- **Parameters**:
  - `data` - Data to convert
  - `indentation` - Spaces per indent level (default: 2)
  - `nesting` - Initial nesting level (default: 2)
- **Example output**: Properly indented YAML with custom spacing

**`indent(text, [indentation])`** - Indent text block

- **Purpose**: Adds consistent indentation to multi-line text
- **Parameters**:
  - `text` - Text to indent
  - `indentation` - Number of spaces (default: 2)
- **Example output**: Text with specified indentation applied to each line

#### Array Processing Functions

**`deep_merge(arrays)`** - Deep merge multiple arrays

- **Purpose**: Recursively merges arrays handling nested structures
- **Parameters**: `arrays` - Array of arrays to merge
- **Implementation**: Drupal-style recursive merge with integer key renumbering
- **Example**: Merges configuration arrays with proper precedence

**`filter_local_services(services)`** - Filter services for local development

- **Purpose**: Extracts local development relevant properties from service definitions
- **Parameters**: `services` - Service configuration array
- **Filtering**: Keeps enabled, environment, environment_dynamic, extends,
  image, resources
- **Example output**: Simplified service config with only local-relevant settings

**`filter_empty(array_input)`** - Remove empty values from array

- **Purpose**: Filters out null, false, empty string, and empty array values
- **Parameters**: `array_input` - Array to filter
- **Implementation**: PHP's array_filter function
- **Example output**: Array with only truthy values retained

**`flatten(array_input)`** - Flatten multidimensional array

- **Purpose**: Converts nested array to single-dimensional array
- **Parameters**: `array_input` - Multidimensional array
- **Implementation**: RecursiveIteratorIterator for deep flattening
- **Example output**: Single-level array with all nested values

#### Docker Functions

**`get_docker_external_networks()`** - Get external network names

- **Purpose**: Extracts external network names from docker-compose configuration
- **Implementation**: Parses docker-compose config and identifies external networks
- **Example output**: `"frontend_network backend_network"`

**`docker_service_images([filterService])`** - Analyze service images

- **Purpose**: Extracts comprehensive image information from docker-compose services
- **Parameters**: `filterService` - Limit to specific service (optional)
- **Implementation**:

  - Parses docker-compose configuration
  - Analyzes Dockerfile FROM statements
  - Tracks image platforms and upstream dependencies
- **Example output**:

  ```php
  // Example PHP snippet
  [
    'console' => [
      'image' => 'myapp/console:latest',
      'platform' => 'linux/amd64',
      'upstream' => [
        ['image' => 'php:8.1-fpm', 'platform' => null],
        ['image' => 'composer:2', 'platform' => null]
      ]
    ]
  ]
  ```

**`get_docker_registry(dockerRepository)`** - Extract registry URL

- **Purpose**: Determines Docker registry URL from repository string
- **Parameters**: `dockerRepository` - Repository string
- **Implementation**: Parses repository path to identify custom registries
- **Example output**: `"https://registry.company.com"` or Docker Hub default

**`docker_config(registryConfig)`** - Generate Docker auth config

- **Purpose**: Creates Docker authentication configuration JSON
- **Parameters**: `registryConfig` - Registry credentials (url, username, password)
- **Implementation**: Base64 encodes credentials and formats as Docker config
- **Example output**:

  ```json
  {
    "auths": {
      "registry.company.com": {
        "auth": "dXNlcm5hbWU6cGFzc3dvcmQ="
      }
    }
  }
  ```

#### Utility Functions

**`branch()`** - Get current Git branch

- **Purpose**: Returns current Git branch name
- **Implementation**: `git branch | grep \* | cut -d ' ' -f2`
- **Example output**: `"main"`, `"develop"`, `"feature/user-auth"`

**`slugify(text)`** - Convert text to URL-safe slug

- **Purpose**: Creates URL-friendly string from arbitrary text
- **Parameters**: `text` - Input text to convert
- **Implementation**:
  - Replaces non-alphanumeric with hyphens
  - Converts to ASCII transliteration
  - Removes special characters
  - Normalizes to lowercase
- **Example output**: `"Hello World!"` becomes `"hello-world"`

**`php_fpm_exporter_scrape_url(hostname, pools)`** - Generate PHP-FPM exporter URLs

- **Purpose**: Creates scrape URLs for PHP-FPM metrics collection
- **Parameters**:
  - `hostname` - Server hostname
  - `pools` - Array of PHP-FPM pools with port information
- **Implementation**: Formats TCP URLs for each pool
- **Example output**: `"tcp://localhost:9001/status,tcp://localhost:9002/status"`

**`publishable_services(services)`** - Get publishable service names

- **Purpose**: Identifies services marked for publishing to registries
- **Parameters**: `services` - Service configuration array
- **Implementation**: Filters services with `publish: true`
- **Example output**: `"console nginx php-fpm"`

**`replace(haystack, needle, replacement)`** - String replacement

- **Purpose**: Simple string replacement function
- **Parameters**:
  - `haystack` - String to search in
  - `needle` - String to find
  - `replacement` - String to replace with
- **Example output**: String with replacements applied

**`template_key_value(template, key_value)`** - Template key-value pairs

- **Purpose**: Applies key-value pairs to template string
- **Parameters**:
  - `template` - Template string with `{{key}}` placeholders
  - `key_value` - Array of key-value pairs
- **Implementation**: Replaces `{{key}}` with corresponding values
- **Example output**: Templated strings with values substituted

**`version_compare(version1, version2, operator)`** - Compare version strings

- **Purpose**: Compares semantic version strings
- **Parameters**:
  - `version1`, `version2` - Version strings to compare
  - `operator` - Comparison operator (>, <, >=, <=, ==, !=)
- **Implementation**: Normalizes versions and uses PHP's version_compare
- **Example output**: `true` or `false` based on comparison

**`bool(value)`** - Convert to boolean

- **Purpose**: Converts various string representations to boolean
- **Parameters**: `value` - String or boolean value
- **Implementation**: Handles 'yes'/'no', 'true'/'false' strings
- **Example output**: `true` for 'yes'/'true', `false` for 'no'/'false'

**`boolToString(value)`** - Convert boolean to string

- **Purpose**: Converts boolean values to yes/no strings
- **Parameters**: `value` - Boolean value
- **Implementation**: Maps true→'yes', false→'no'
- **Example output**: `"yes"` or `"no"`

### File: `harness-drupal8/harness/config/external-images.yml` (Reference)

#### External Image Functions

**`external_images(services)`** - Extract external image list

- **Purpose**: Analyzes services to identify all external images needed

- **Implementation**:
  - Collects upstream images from build contexts
  - Includes direct image references
  - Excludes locally built images and 'scratch'
  - Returns JSON-encoded array for command compatibility
- **Example output**:

  ```json
  {"example": true}
  ```

---

## Usage Examples

### Basic Development Workflow

```bash
# Start the development environment
ws enable

# Access the console
ws console

# Install Drupal dependencies
ws composer install

# Access database
ws db console

# Import database dump
ws db import /path/to/dump.sql
```

### Asset Management

```bash
# Download assets from remote
ws assets download

# Upload local assets
ws assets upload
```

### Frontend Development

```bash
# Build frontend assets
ws frontend build

# Watch for changes
ws frontend watch

# Access frontend tools
ws frontend console
```

### Performance Profiling

```bash
# Enable Blackfire profiler
ws feature blackfire on

# Configure Tideways
ws feature tideways cli configure YOUR_KEY
ws feature tideways cli on
```

### Deployment Pipeline

```bash
# Build application images
ws app build

# Publish to registry
ws app publish

# Deploy to staging
ws app deploy staging

# Validate Helm templates
ws helm kubeval staging
```