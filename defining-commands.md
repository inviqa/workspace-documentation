# Defining Commands in Workspace

This document explains how to define new commands in Workspace harnesses
using the `command.yml` configuration files.

## Table of Contents

- [Command Structure](#command-structure)
- [Script Interpreters](#script-interpreters)
- [Working Directory (Path)](#working-directory-path)
- [Filters](#filters)
- [Complete Examples](#complete-examples)
- [Best Practices](#best-practices)

## Command Structure

Commands are defined in `harness/config/commands.yml` files with the
following structure:

```yaml
command('command-name [arguments]'):
  env:
    VARIABLE_NAME: = @('attribute.name')
    ANOTHER_VAR: 'static value'
  exec: |
    #!<interpreter>(<path>)|<filters>
    # script content here
```

## Script Interpreters

The first line of the `exec` block specifies the interpreter and execution
options:

### Syntax

```text
#!<interpreter>(<path>)|<filters>
```

- **interpreter**: `bash` or `php`
- **path**: (optional) working directory - `workspace:/`, `harness:/`, or
  `cwd:/`
- **filters**: (optional) processing filters - `@`, `=`, or combinations

### Available Interpreters

#### Bash

- **Use case**: Shell scripts, Docker commands, file operations
- **Example**: `#!bash(workspace:/)`

#### PHP

- **Use case**: Data processing, complex logic, variable manipulation
- **Example**: `#!php`
- **Note**: PHP scripts have access to `$env` array and extracted variables

## Working Directory (Path)

| Path Option   | Description                   | Example Use Case             |
|---------------|-------------------------------|------------------------------|
| `workspace:/` | Root of the workspace project | Running `ws` commands        |
| `harness:/`   | Root of the harness files     | Accessing harness templates  |
| `cwd:/`       | Current working directory     | Context-dependent operations |

## Filters

### `@` Filter (Template Rendering)

- Processes the script as a Twig template before execution
- Allows variable interpolation and workspace attribute access
- **Use when**: Script contains `@('attribute')` expressions or dynamic
  content

```yaml
exec: |
  #!bash(workspace:/)|@
  echo "Project namespace: @('namespace')"
  docker-compose exec console app migrate
```

### `=` Filter (Capture Output)

- Captures the script's output as a return value
- For bash: Replaces the last line with `echo -n` if it starts with `=`
- For PHP: Replaces the last line with `return` if it starts with `=`
- **Use when**: Command should return a value rather than just print

```yaml
exec: |
  #!bash(workspace:/)|=
  docker port "$(docker-compose ps -q web)"
```

### Combined Filters

You can combine filters: `|@|=` (template render, then capture output)

## Complete Examples

### Basic Shell Command

```yaml
command('logs <service>'):
  env:
    COMPOSE_PROJECT_NAME: = @('namespace')
  exec: |
    #!bash(workspace:/)
    docker-compose logs "${1}"
```

### Template-Rendered Command

```yaml
command('deploy'):
  env:
    ENVIRONMENT: = @('deploy.environment')
  exec: |
    #!bash(workspace:/)|@
    echo "Deploying to @('deploy.environment')"
    rsync -av ./build/ user@server:/path/to/@('deploy.environment')/
```

### Value-Returning Command

```yaml
command('get-port <service>'):
  env:
    COMPOSE_PROJECT_NAME: = @('namespace')
  exec: |
    #!bash(workspace:/)|=
    docker port "$(docker-compose ps -q ${1})" | cut -d: -f2
```

### PHP Script Command

```yaml
command('generate-config'):
  env:
    APP_NAME: = @('app.name')
    DATABASE_URL: = @('database.url')
  exec: |
    #!php
    $config = [
        'app_name' => $env['APP_NAME'],
        'database_url' => $env['DATABASE_URL'],
        'generated_at' => date('Y-m-d H:i:s')
    ];
    file_put_contents('config/generated.json', json_encode($config, JSON_PRETTY_PRINT));
    echo "Configuration generated successfully";
```

### PHP with Return Value

```yaml
command('calculate-memory'):
  env:
    CONTAINER_COUNT: = @('docker.container_count')
  exec: |
    #!php
    $baseMemory = 512;
    $containerMemory = $env['CONTAINER_COUNT'] * 256;
    $totalMemory = $baseMemory + $containerMemory;
    = $totalMemory . 'MB'
```

### Complex Template and Capture

```yaml
command('backup-database'):
  env:
    DB_NAME: = @('database.name')
    BACKUP_PATH: = @('backup.path')
  exec: |
    #!bash(workspace:/)|@|=
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="@('backup.path')/@('database.name')_${TIMESTAMP}.sql"
    docker-compose exec -T mysql mysqldump @('database.name') > "${BACKUP_FILE}"
    = "${BACKUP_FILE}"
```

## Best Practices

### When to Use Each Interpreter

- **bash**: File operations, Docker commands, system utilities
- **php**: Data processing, JSON/XML manipulation, complex calculations

### When to Use Each Filter

- **No filters**: Simple commands that print output
- **`|@`**: Commands using workspace attributes or dynamic content
- **`|=`**: Commands that should return values for use in other scripts
- **`|@|=`**: Dynamic commands that return processed values

### Working Directory Guidelines

- **`workspace:/`**: Default choice for most commands
- **`harness:/`**: When accessing harness-specific files or templates
- **`cwd:/`**: When the command should operate in the current directory
  context

### Environment Variables

- Use `env:` section to pass workspace attributes to scripts
- Variables are available as `$VARIABLE_NAME` in bash and
  `$env['VARIABLE_NAME']` in PHP
- Prefer workspace attributes over hardcoded values for flexibility

### Error Handling

- Bash scripts run with `set -e` (exit on error) by default
- Return appropriate exit codes for error conditions
- Use `passthru` for commands that should preserve their original output and
  exit codes

## Summary Table

| Shebang Example            | Interpreter | Working Dir | Filters |
|----------------------------|-------------|-------------|---------|
| `#!bash(harness:/)`        | bash        | harness     | none    |
| `#!bash(workspace:/)`      | bash        | workspace   | none    |
| `#!bash(workspace:/)\|@`   | bash        | workspace   | @       |
| `#!bash(workspace:/)\|=`   | bash        | workspace   | =       |
| `#!bash(workspace:/)\|@\|=`| bash        | workspace   | @, =    |
| `#!php`                    | php         | cwd         | none    |
| `#!php\|=`                 | php         | cwd         | =       |

**Use Cases:**

- **Standard shell commands**: Basic operations, Docker commands
- **Harness-specific operations**: Working with harness files/templates  
- **Template-rendered shell scripts**: Dynamic content using attributes
- **Shell commands returning values**: Capture output for further use
- **Dynamic shell scripts with return**: Template render + capture output
- **PHP logic and data processing**: Complex calculations, data manipulation
- **PHP functions returning values**: PHP scripts that return results

### Table Design Rationale

The summary table above reflects real-world usage patterns rather than
exhaustive theoretical combinations:

**Why More Bash Examples?**

- Bash is the primary interface for Workspace operations (Docker, file
  system, external tools)
- Bash commands benefit from all filter combinations in practical scenarios
- Different working directories are commonly needed for bash operations

**Why Fewer PHP Examples?**

- PHP scripts focus on data processing and logic rather than system operations
- Template filter (`@`) is rarely needed since PHP handles dynamic content
  natively
- Most PHP use cases are either simple processing or value-returning functions

**Working Directory Choices:**

- Bash examples show multiple directories (`harness:/`, `workspace:/`) because
  bash often operates on different file contexts
- PHP uses `cwd:/` since it typically works with data rather than specific
  file locations

The table prioritizes common, practical patterns that developers actually
encounter in Workspace harness development.
