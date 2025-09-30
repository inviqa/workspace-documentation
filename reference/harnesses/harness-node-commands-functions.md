# Harness Node Commands and Functions

<!-- QUICK-INDEX -->
## Quick Index

- [Workspace Management](#workspace-management)
- [Network Management](#network-management)
- [Node.js Development](#nodejs-development)
- [Container Management](#container-management)
- [Configuration Management](#configuration-management)
- [Functions](#functions)
  - [YAML](#yaml-processing-functions)
  - [Arrays](#array-processing-functions)
  - [Service Management](#service-management-functions)

<!-- /QUICK-INDEX -->

<!-- TOC -->
## Table of Contents

- [Introduction](#introduction)
- [Commands](#commands)
  - [Workspace Management](#workspace-management)
  - [Network Management](#network-management)
  - [Node.js Development](#nodejs-development)
  - [Container Management](#container-management)
  - [Configuration Management](#configuration-management)
- [Functions](#functions)
  - [File: harness-node/harness/config/functions.yml](#file-harness-nodeharnessconfigfunctionsyml)
  - [YAML Processing Functions](#yaml-processing-functions)
  - [Array Processing Functions](#array-processing-functions)
  - [Service Management Functions](#service-management-functions)

<!-- /TOC -->

## Introduction

This document lists all commands and functions provided by the
`harness-node` harness.

## Commands

### Workspace Management

#### `ws enable`

**Description:** Enable and start the workspace
**Usage:** `ws enable`

#### `ws disable`

**Description:** Disable and stop the workspace
**Usage:** `ws disable`

#### `ws destroy`

**Description:** Destroy the workspace and clean up resources
**Usage:** `ws destroy`

### Network Management

#### `ws networks external`

**Description:** Create external Docker networks if they don't exist
**Usage:** `ws networks external`

### Node.js Development

#### `ws yarn %`

**Description:** Run yarn commands inside the node container
**Usage:** `ws yarn install` or `ws yarn build` or `ws yarn test`

#### `ws exec %`

**Description:** Execute commands inside the node container as node user
**Usage:** `ws exec npm test` or `ws exec node app.js`

#### `ws console`

**Description:** Open a bash console inside the node container
**Usage:** `ws console`

### Container Management

#### `ws logs %`

**Description:** View logs for specified service
**Usage:** `ws logs node` or `ws logs --follow web`

#### `ws ps`

**Description:** Show running containers and their status
**Usage:** `ws ps`

#### `ws port <service>`

**Description:** Show port mappings for a service
**Usage:** `ws port node`

### Configuration Management

#### `ws set <attribute> <value>`

**Description:** Set workspace attribute in workspace.override.yml
**Usage:** `ws set app.development yes`

## Functions

This harness includes the same functions as harness-base-node:

### File: `harness-node/harness/config/functions.yml`

### YAML Processing Functions

#### `to_yaml(data)`

**Description:** Convert data to YAML format with proper indentation
**Parameters:**

- `data` - The data to convert to YAML

**Usage:** `= to_yaml({'key': 'value'})`

#### `to_nice_yaml(data, indentation, nesting)`

**Description:** Convert data to YAML with custom indentation and nesting
**Parameters:**

- `data` - The data to convert
- `indentation` - Number of spaces for indentation (default: 2)
- `nesting` - Number of spaces for nesting level (default: 2)

**Usage:** `= to_nice_yaml(data, 4, 2)`

### Array Processing Functions

#### `deep_merge(arrays)`

**Description:** Deep merge multiple arrays recursively
**Parameters:**

- `arrays` - Array of arrays to merge

**Usage:** `= deep_merge([array1, array2, array3])`

### Service Management Functions

#### `publishable_services(services)`

**Description:** Filter services that have publish flag set to true
**Parameters:**

- `services` - Services configuration

**Returns:** Space-separated string of publishable service names

**Usage:** `= publishable_services(@('services'))`

#### `filter_local_services(services)`

**Description:** Filter services to only include local development relevant keys
**Parameters:**

- `services` - Services configuration

**Returns:** Filtered services with only environment and enabled keys

**Usage:** `= filter_local_services(@('services'))`

### Docker Functions

#### `docker_service_images()`

**Description:** Get Docker images and their upstream dependencies
**Returns:** Dictionary of service names with their image and upstream information
**Usage:** `= docker_service_images()`

#### `get_docker_external_networks()`

**Description:** Get external Docker networks from docker-compose config
**Returns:** Space-separated string of external network names
**Usage:** `= get_docker_external_networks()`

#### `docker_config(registryConfig)`

**Description:** Generate Docker config.json for registry authentication
**Parameters:**

- `registryConfig` - Registry configuration with url, username, password

**Returns:** JSON string for Docker config

**Usage:** `= docker_config(@('registry'))`

### Utility Functions

#### `branch()`

**Description:** Get current Git branch name
**Returns:** Current branch name
**Usage:** `= branch()`

#### `slugify(text)`

**Description:** Convert text to URL-friendly slug format
**Parameters:**

- `text` - Text to slugify

**Returns:** Slugified text (lowercase, hyphens, no special chars)

**Usage:** `= slugify("My Project Name")` → `"my-project-name"`

## Usage Examples

### Using Commands

```yaml
command('setup'): |
  #!bash
  ws enable
  ws yarn install
  
command('dev'): |
  #!bash
  ws yarn dev

command('test'): |
  #!bash
  ws yarn test

command('build'): |
  #!bash
  ws yarn build
```

### Using Functions

```yaml
attribute('project.slug'): = slugify(@('workspace.name'))
attribute('git.branch'): = branch()

services: = deep_merge([
  @('base_services'),
  @('node_services')
])

docker:
  config: = docker_config(@('registry_auth'))
```

### Environment Variables

- `NAMESPACE` / `COMPOSE_PROJECT_NAME` - Docker project naming
- `SYNC_STRATEGY` - File synchronization strategy
- `APP_DEVELOPMENT` - Development mode flag
- `APP_DYNAMIC` - Dynamic configuration flag

## Node.js Development Features

This harness is optimized for Node.js development with:

- Yarn package manager integration
- Node.js runtime environment
- NPM script execution support
- Development and production build workflows
- Container-based Node.js execution
- File synchronization for development

## Integration with Other Tools

The harness integrates well with:

- Docker Compose for container orchestration
- Mutagen for file synchronization (macOS)
- Git for version control
- Various Node.js frameworks and tools
- CI/CD pipelines
