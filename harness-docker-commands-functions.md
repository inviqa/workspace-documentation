# Harness Docker Commands and Functions

This document lists all commands and functions provided by the `harness-docker` harness.

## Commands

### Workspace Management

#### `ws enable`

**Description:** Enable and start all workspace services
**Usage:** `ws enable`

#### `ws enable console`

**Description:** Enable and start only the console service
**Usage:** `ws enable console`

#### `ws disable`

**Description:** Disable and stop the workspace
**Usage:** `ws disable`

#### `ws destroy [--all]`

**Description:** Destroy the workspace and optionally clean up all resources
**Usage:** `ws destroy` or `ws destroy --all`

#### `ws rebuild`

**Description:** Rebuild the workspace containers
**Usage:** `ws rebuild`

### Network Management

#### `ws networks external`

**Description:** Create external Docker networks if they don't exist
**Usage:** `ws networks external`

### Container Management

#### `ws exec %`

**Description:** Execute commands inside the console container as build user
**Usage:** `ws exec php --version` or `ws exec composer install`

#### `ws logs %`

**Description:** View logs for specified service
**Usage:** `ws logs console` or `ws logs --follow web`

#### `ws ps`

**Description:** Show running containers and their status
**Usage:** `ws ps`

#### `ws console`

**Description:** Open a bash console inside the console container
**Usage:** `ws console`

#### `ws port <service>`

**Description:** Show port mappings for a service
**Usage:** `ws port web`

### Development Tools

#### `ws composer %`

**Description:** Run composer commands in the console container
**Usage:** `ws composer install` or `ws composer require package`

#### `ws db console`

**Description:** Open MySQL/database console
**Usage:** `ws db console`

#### `ws db-console`

**Description:** Alias for `ws db console`
**Usage:** `ws db-console`

### Asset Management

#### `ws assets download`

**Description:** Download assets from AWS S3 bucket
**Usage:** `ws assets download`

#### `ws assets upload`

**Description:** Upload assets to AWS S3 bucket
**Usage:** `ws assets upload`

### Database Management

#### `ws db import <database_file>`

**Description:** Import database from file
**Usage:** `ws db import backup.sql`

### Configuration Management

#### `ws set <attribute> <value>`

**Description:** Set workspace attribute in workspace.override.yml
**Usage:** `ws set app.development yes`

### Harness Management

#### `ws harness update existing`

**Description:** Update harness while preserving existing configuration
**Usage:** `ws harness update existing`

#### `ws harness update fresh`

**Description:** Fresh harness update, removing all existing configuration
**Usage:** `ws harness update fresh`

### Utilities

#### `ws generate token <length>`

**Description:** Generate a random token of specified length
**Usage:** `ws generate token 32`

#### `ws lighthouse [--with-results]`

**Description:** Run Lighthouse performance audit
**Usage:** `ws lighthouse` or `ws lighthouse --with-results`

## Functions

### File: `harness-docker/harness/config/functions.yml`

### Architecture Detection

#### `host_architecture(style)`

**Description:** Get the host system architecture in different formats
**Parameters:**

- `style` - Format style: 'native', 'go', or empty (default: 'go')

**Returns:** Architecture string (e.g., 'amd64', 'arm64', 'x86_64')

**Usage:**

```yaml
attribute('arch.go'): = host_architecture('go')
attribute('arch.native'): = host_architecture('native')
```

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

#### `indent(text, indentation)`

**Description:** Add indentation to text
**Parameters:**

- `text` - Text to indent
- `indentation` - Number of spaces for indentation (default: 2)

**Usage:** `= indent(@('some_text'), 4)`

### Array Processing Functions

#### `deep_merge(arrays)`

**Description:** Deep merge multiple arrays recursively
**Parameters:**

- `arrays` - Array of arrays to merge

**Usage:** `= deep_merge([array1, array2, array3])`

#### `flatten(array_input)`

**Description:** Flatten a multi-dimensional array
**Parameters:**

- `array_input` - Array to flatten

**Usage:** `= flatten(@('nested_array'))`

### Service Management Functions

#### `filter_local_services(services)`

**Description:** Filter services for local development
**Parameters:**

- `services` - Services configuration

**Returns:** Filtered services with relevant keys for local development

**Usage:** `= filter_local_services(@('services'))`

#### `publishable_services(services)`

**Description:** Filter services that have publish flag set to true
**Parameters:**

- `services` - Services configuration

**Returns:** Space-separated string of publishable service names

**Usage:** `= publishable_services(@('services'))`

### Docker Functions

#### `get_docker_external_networks()`

**Description:** Get external Docker networks from docker-compose config
**Returns:** Space-separated string of external network names
**Usage:** `= get_docker_external_networks()`

#### `docker_service_images(filterService)`

**Description:** Get Docker images and their upstream dependencies
**Parameters:**

- `filterService` - Optional service name to filter (default: all services)

**Returns:** Dictionary of service names with image and upstream information

**Usage:**

```yaml
attribute('all_images'): = docker_service_images()
attribute('web_image'): = docker_service_images('web')
```

#### `get_docker_registry(dockerRepository)`

**Description:** Extract registry URL from Docker repository string
**Parameters:**

- `dockerRepository` - Docker repository string

**Returns:** Registry URL (defaults to Docker Hub if none specified)

**Usage:** `= get_docker_registry(@('docker.repository'))`

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

#### `replace(haystack, needle, replacement)`

**Description:** Replace string occurrences
**Parameters:**

- `haystack` - String to search in
- `needle` - String to search for
- `replacement` - String to replace with

**Usage:** `= replace(@('text'), 'old', 'new')`

#### `template_key_value(template, key_value)`

**Description:** Template key-value pairs using a template string
**Parameters:**

- `template` - Template string with {{key}} placeholder
- `key_value` - Dictionary of key-value pairs

**Usage:**

```yaml
= template_key_value('prefix-{{key}}-suffix', {'a': 'value1', 'b': 'value2'})
```

#### `version_compare(version1, version2, operator)`

**Description:** Compare version strings
**Parameters:**

- `version1` - First version string
- `version2` - Second version string  
- `operator` - Comparison operator ('>', '<', '>=', '<=', '==', '!=')

**Usage:** `= version_compare('1.2.3', '1.2.0', '>')`

#### `boolToString(value)`

**Description:** Convert boolean to yes/no string
**Parameters:**

- `value` - Boolean value

**Returns:** 'yes' for true, 'no' for false

**Usage:** `= boolToString(true)` → `"yes"`

## Usage Examples

### Using Commands

```yaml
command('setup'): |
  #!bash
  ws enable
  ws composer install
  ws db import database.sql

command('deploy'): |
  #!bash
  ws assets upload
  ws harness update existing
```

### Using Functions in Configuration

```yaml
attribute('docker.arch'): = host_architecture('go')
attribute('git.branch'): = branch()
attribute('project.slug'): = slugify(@('workspace.name'))

services: = deep_merge([
  @('base_services'), 
  @('environment_services')
])

docker:
  registry: = get_docker_registry(@('docker.repository'))
  config: = docker_config(@('registry_auth'))
```

### Environment Variables

Key environment variables used:

- `USE_MUTAGEN` - Enable Mutagen file sync on macOS
- `APP_BUILD`, `APP_MODE` - Application build and mode settings
- `NAMESPACE`, `COMPOSE_PROJECT_NAME` - Docker namespace
- `COMPOSE_DOCKER_CLI_BUILD`, `DOCKER_BUILDKIT` - BuildKit settings
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - AWS credentials
