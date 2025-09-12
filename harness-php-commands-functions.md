# Harness PHP Commands and Functions

This document lists all commands and functions provided by the `harness-php` harness.

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

### PHP Development

#### `ws composer %`

**Description:** Run composer commands in the console container
**Usage:** `ws composer install` or `ws composer require package`

### Database Management

#### `ws db console`

**Description:** Open MySQL/database console
**Usage:** `ws db console`

#### `ws db-console`

**Description:** Alias for `ws db console`
**Usage:** `ws db-console`

#### `ws db import <database_file>`

**Description:** Import database from file
**Usage:** `ws db import backup.sql`

### Asset Management

#### `ws assets download`

**Description:** Download assets from AWS S3 bucket
**Usage:** `ws assets download`

#### `ws assets upload`

**Description:** Upload assets to AWS S3 bucket
**Usage:** `ws assets upload`

### Frontend Development

#### `ws frontend build`

**Description:** Build frontend assets using the console container
**Usage:** `ws frontend build`

#### `ws frontend watch`

**Description:** Start frontend development watch mode
**Usage:** `ws frontend watch`

#### `ws frontend console`

**Description:** Open a bash console in the frontend working directory
**Usage:** `ws frontend console`

### Service Management

#### `ws service php-fpm restart`

**Description:** Restart PHP-FPM service with updated configuration
**Usage:** `ws service php-fpm restart`

### PHP Extensions Management

#### `ws feature blackfire (on|off)`

**Description:** Enable or disable Blackfire profiler extension for PHP-FPM
**Usage:** `ws feature blackfire on` or `ws feature blackfire off`

#### `ws feature blackfire cli (on|off)`

**Description:** Enable or disable Blackfire profiler extension for CLI
**Usage:** `ws feature blackfire cli on`

#### `ws feature tideways (on|off)`

**Description:** Enable or disable Tideways profiler extension for PHP-FPM
**Usage:** `ws feature tideways on` or `ws feature tideways off`

#### `ws feature tideways cli (on|off)`

**Description:** Enable or disable Tideways profiler extension for CLI
**Usage:** `ws feature tideways cli on`

#### `ws feature tideways cli configure <server_key>`

**Description:** Configure Tideways CLI with server key
**Usage:** `ws feature tideways cli configure your-server-key`

#### `ws feature xdebug (on|off)`

**Description:** Enable or disable Xdebug extension for PHP-FPM
**Usage:** `ws feature xdebug on` or `ws feature xdebug off`

#### `ws feature xdebug cli (on|off)`

**Description:** Enable or disable Xdebug extension for CLI
**Usage:** `ws feature xdebug cli on`

### Docker Sync Management

#### `ws feature docker-sync (on|off)`

**Description:** Enable or disable Docker Sync for file synchronization
**Usage:** `ws feature docker-sync on` or `ws feature docker-sync off`

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

## Functions

This harness includes all the standard Docker harness functions plus
PHP-specific extensions:

### File: `harness-php/harness/config/functions.yml`

### PHP-FPM Monitoring Functions

#### `php_fpm_exporter_scrape_url(hostname, pools)`

**Description:** Generate scrape URLs for PHP-FPM status monitoring
**Parameters:**

- `hostname` - The hostname to connect to
- `pools` - Array of pool configurations with port information

**Returns:** Comma-separated string of TCP URLs for PHP-FPM status endpoints

### Standard Docker Functions

Includes all functions from harness-docker:

- `to_yaml(data)` - Convert to YAML format
- `to_nice_yaml(data, indentation, nesting)` - YAML with custom formatting
- `indent(text, indentation)` - Add indentation to text
- `deep_merge(arrays)` - Deep merge multiple arrays
- `filter_local_services(services)` - Filter for local development
- `get_docker_external_networks()` - Get external network names
- `docker_service_images()` - Get service images and dependencies
- `get_docker_registry(repository)` - Extract registry from repository
- `docker_config(registryConfig)` - Generate Docker auth config
- `branch()` - Get current Git branch
- `slugify(text)` - Convert text to URL-friendly slug
- `publishable_services(services)` - Filter publishable services
- `version_compare(v1, v2, operator)` - Compare version strings

## Usage Examples

### Using Commands

```yaml
command('setup'): |
  #!bash
  ws enable
  ws composer install
  ws frontend build
  
command('debug'): |
  #!bash
  ws feature xdebug on
  ws feature blackfire on
  ws service php-fpm restart
```

### Using Functions

```yaml
attribute('php_fpm_monitoring'): = php_fpm_exporter_scrape_url(
  'php-fpm',
  @('php.pools')
)

services: = deep_merge([
  @('base_services'),
  @('php_services')
])
```

### Environment Variables

- `CODE_OWNER` - User to run commands as
- `COMPOSE_BIN` - Docker Compose binary path
- `NAMESPACE` / `COMPOSE_PROJECT_NAME` - Docker project naming
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` - AWS credentials
- Various attribute values for PHP extensions
