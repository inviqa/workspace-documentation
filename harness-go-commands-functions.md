# Harness Go - Commands and Functions Documentation

This document provides comprehensive documentation of all commands and functions available in the harness-go harness for Go application development.

## Overview

The harness-go harness provides a Docker-based development environment for Go applications with extensive tooling support for testing, benchmarking, code quality analysis, and deployment.

---

## Commands

### File: `harness-go/harness/config/commands.yml`

#### Environment Management Commands

**`ws enable`** - Enable the Go development environment
- **Purpose**: Starts the complete Go development environment
- **Environment**: Sets COMPOSE_PROJECT_NAME to project namespace
- **Execution**: Sources enable.sh script
- **Example output**: Docker containers starting, services becoming available

**`ws disable`** - Disable the Go development environment  
- **Purpose**: Stops all running services and containers
- **Environment**: Sets COMPOSE_PROJECT_NAME to project namespace
- **Execution**: Sources disable.sh script
- **Example output**: Docker containers stopping, services shutting down

**`ws destroy`** - Destroy the Go development environment
- **Purpose**: Completely removes all containers, volumes, and networks
- **Environment**: Sets COMPOSE_PROJECT_NAME to project namespace  
- **Execution**: Sources destroy.sh script
- **Example output**: All Docker resources removed, clean slate environment

**`ws rebuild`** - Rebuild the entire environment
- **Purpose**: Destroys and reinstalls the complete environment
- **Execution**: Runs destroy then install commands
- **Example output**: Full environment recreation process

#### Network Management Commands

**`ws networks external`** - Create external Docker networks
- **Purpose**: Creates any external networks required by the Docker Compose configuration
- **Environment**: Sets NETWORKS from get_docker_external_networks() function
- **Execution**: Creates networks if they don't exist
- **Example output**: `docker network create my_external_network`

#### Build Commands

**`ws build`** - Build the Go application
- **Purpose**: Pulls external images and builds the app container
- **Execution**: 
  ```bash
  ws external-images pull
  docker-compose build app
  ```
- **Example output**: Docker build process, image layers being built

#### Container Access Commands

**`ws app`** - Access the main application container
- **Purpose**: Opens a bash shell in the Go application container
- **Execution**: `docker-compose exec app bash`
- **Example output**: Interactive bash shell inside the app container

**`ws console`** - Alias for app command
- **Purpose**: Provides familiar interface for users of other harnesses
- **Execution**: Runs the app command
- **Example output**: Same as app command

#### Go Development Commands

**`ws go docker generate`** - Run go generate in container
- **Purpose**: Executes `go generate` command inside the Docker container
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `docker-compose exec -T app go generate`
- **Example output**: Generated Go code, updated files

**`ws go docker test`** - Run Go tests in container
- **Purpose**: Executes all Go tests within the Docker environment
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `docker-compose exec -T app go test ./...`
- **Example output**: Test results, pass/fail status for all packages

**`ws go docker vet`** - Run go vet in container
- **Purpose**: Analyzes Go code for potential issues
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `docker-compose exec -T app go vet ./...`
- **Example output**: Code analysis results, potential issues identified

**`ws go docker gocyclo`** - Run cyclomatic complexity analysis
- **Purpose**: Analyzes code complexity using gocyclo tool
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `docker-compose exec -T app helper gocyclo`
- **Example output**: Complexity metrics for functions and methods

**`ws go docker gosec`** - Run security analysis
- **Purpose**: Scans Go code for security vulnerabilities
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `docker-compose exec -T app helper gosec`
- **Example output**: Security scan results, vulnerability reports

**`ws go docker ineffassign`** - Detect ineffective assignments
- **Purpose**: Identifies ineffective variable assignments
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `docker-compose exec -T app helper ineffassign`
- **Example output**: List of ineffective assignments found

**`ws go docker fmt check`** - Check Go code formatting
- **Purpose**: Verifies Go code follows standard formatting
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `test -z $(docker-compose exec -T app helper fmt:check)`
- **Example output**: Empty output if properly formatted, errors if not

**`ws go docker mod check`** - Check Go module consistency
- **Purpose**: Verifies go.mod file consistency
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `docker-compose exec -T app helper modules:check`
- **Example output**: Module consistency status, any discrepancies

#### Testing Commands

**`ws go test coverage`** - Generate test coverage report
- **Purpose**: Runs tests with coverage analysis and generates HTML report
- **Execution**: `go test -coverprofile=cp.out ./... && go tool cover -html=cp.out`
- **Example output**: HTML coverage report opened in browser

**`ws go test integration docker`** - Run integration tests in Docker
- **Purpose**: Executes integration tests within Docker environment
- **Environment**: Sets COMPOSE_PROJECT_NAME, GO_TEST_MODE=docker, LOG_LEVEL=error
- **Execution**: `docker-compose exec -T -e GO_TEST_MODE=docker -e LOG_LEVEL=error app go test -count=1 -v --tags=integration ./integration/`
- **Example output**: Integration test results with Docker setup

**`ws go test integration <test-name>`** - Run specific integration test
- **Purpose**: Executes a specific integration test by name
- **Environment**: Sets TEST_NAME from input argument, LOG_LEVEL=debug
- **Execution**: `LOG_LEVEL=debug go test -count=1 -v --tags=integration ./integration/ -run ${TEST_NAME}`
- **Example output**: Detailed test output for specific test

**`ws go test integration`** - Run all integration tests
- **Purpose**: Executes complete integration test suite
- **Execution**: Sources integration/run.sh script
- **Example output**: Full integration test suite results

#### Benchmarking Commands

**`ws go bench compare`** - Compare benchmark results
- **Purpose**: Compares current benchmark results with previous runs
- **Execution**: Sources bench/compare.sh script
- **Example output**: Benchmark comparison report showing performance differences

**`ws go bench report`** - Generate benchmark report
- **Purpose**: Creates detailed benchmark analysis report
- **Execution**: Sources bench/report.sh script
- **Example output**: Comprehensive benchmark performance report

**`ws go bench current`** - Run current benchmarks
- **Purpose**: Executes all benchmarks with memory profiling
- **Execution**: `go test -count=5 -bench=. -benchmem --tags=benchmarks ./...`
- **Example output**: Benchmark results with timing and memory allocation data

**`ws go bench`** - Run benchmarks (alias)
- **Purpose**: Convenience command for running current benchmarks
- **Execution**: Runs `go bench current`
- **Example output**: Same as `go bench current`

#### Code Formatting Commands

**`ws go fmt`** - Format Go code
- **Purpose**: Formats all Go code according to standard conventions
- **Execution**: `@('go.formatter') -w -l .`
- **Example output**: List of files that were reformatted

#### Development Commands

**`ws recompile`** - Recompile and restart application
- **Purpose**: Rebuilds and restarts the application container
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: `ws harness prepare && docker-compose up -d --build app`
- **Example output**: Rebuild process, container restart confirmation

**`ws use prod`** - Switch to production mode
- **Purpose**: Prepares and starts application in production configuration
- **Environment**: Sets COMPOSE_PROJECT_NAME
- **Execution**: Prepares harness, builds production version, starts app
- **Example output**: Production build process, optimized container startup

#### Configuration Management Commands

**`ws set <attribute> <value>`** - Set workspace attribute
- **Purpose**: Sets or updates a workspace configuration attribute
- **Environment**: Sets ATTR_KEY and ATTR_VAL from input arguments
- **Parameters**: 
  - `attribute`: The configuration key to set
  - `value`: The value to assign to the attribute
- **Execution**: Updates workspace.yml file with new attribute value
- **Example output**: 
  ```
  Setting 'database.host' setting to 'localhost' in workspace.yml
  ```

**`ws get <attribute>`** - Get workspace attribute value
- **Purpose**: Retrieves and displays the value of a workspace attribute
- **Environment**: Sets VALUE from the specified attribute
- **Parameters**: 
  - `attribute`: The configuration key to retrieve
- **Execution**: Echoes the attribute value
- **Example output**: `localhost` (for database.host attribute)

---

## Functions

### File: `harness-go/harness/config/functions.yml`

#### YAML Processing Functions

**`to_yaml(data, [indentation], [nesting])`** - Convert data to YAML format
- **Purpose**: Converts PHP data structures to YAML string representation
- **Parameters**: 
  - `data`: The data structure to convert
  - `indentation`: (deprecated) Indentation level
  - `nesting`: (deprecated) Nesting level
- **Implementation**: Uses Symfony YAML component with 100-level depth, 2-space indentation
- **Example output**: 
  ```yaml
  database:
    host: localhost
    port: 3306
  ```

**`to_nice_yaml(data, [indentation], [nesting])`** - Convert data to nicely formatted YAML
- **Purpose**: Modern version of to_yaml with better formatting
- **Parameters**: Same as to_yaml but without deprecation warnings
- **Implementation**: Uses Symfony YAML component with proper indentation
- **Example output**: Well-formatted YAML with consistent spacing

#### Array Processing Functions

**`deep_merge(arrays)`** - Deep merge multiple arrays
- **Purpose**: Recursively merges multiple arrays, handling nested structures
- **Parameters**: 
  - `arrays`: Array of arrays to merge
- **Implementation**: Custom recursive merge logic similar to Drupal's drupal_array_merge_deep_array
- **Behavior**: 
  - Integer keys are renumbered
  - Nested arrays are recursively merged
  - Later values override earlier ones for same keys
- **Example output**: Single merged array with all values combined

**`deep_merge_to_yaml(arrays, [indentation], [nesting])`** - (Deprecated) Merge arrays and convert to YAML
- **Purpose**: Combined deep merge and YAML conversion (deprecated)
- **Implementation**: Performs deep merge then YAML conversion
- **Note**: Use separate deep_merge and to_yaml functions instead

#### String Processing Functions

**`slugify(text)`** - Convert text to URL-friendly slug
- **Purpose**: Converts arbitrary text to lowercase, URL-safe string
- **Parameters**: 
  - `text`: Input text to slugify
- **Implementation**: 
  - Replaces non-alphanumeric with hyphens
  - Converts to ASCII
  - Removes special characters
  - Converts to lowercase
  - Removes duplicate hyphens
- **Example output**: `"Hello World!"` becomes `"hello-world"`

#### Service Management Functions

**`filter_local_services(services)`** - Filter services for local development
- **Purpose**: Extracts only environment and enabled properties from service definitions
- **Parameters**: 
  - `services`: Array of service configurations
- **Implementation**: Filters each service to only include relevant local development properties
- **Example output**: Simplified service configuration with only local-relevant settings

#### Docker Functions

**`get_docker_external_networks()`** - Get external network names
- **Purpose**: Extracts names of external networks from docker-compose configuration
- **Implementation**: 
  - Parses `docker-compose config` output
  - Identifies networks marked as external
  - Returns space-separated list of network names
- **Example output**: `"frontend_network backend_network"`

**`docker_service_images()`** - Get service image information
- **Purpose**: Analyzes docker-compose services to extract image and upstream dependency information
- **Implementation**: 
  - Parses docker-compose configuration
  - Extracts image names (adds :latest if no tag)
  - Analyzes Dockerfile FROM statements for upstream images
- **Example output**: 
  ```php
  [
    'app' => [
      'image' => 'myapp:latest',
      'upstream' => ['golang:1.19', 'alpine:latest']
    ]
  ]
  ```

**`get_docker_registry(dockerRepository)`** - Extract Docker registry URL
- **Purpose**: Determines the Docker registry URL from a repository string
- **Parameters**: 
  - `dockerRepository`: Docker repository string (e.g., `registry.com/org/repo`)
- **Implementation**: 
  - Splits repository by '/'
  - Checks if first part contains '.' (indicating custom registry)
  - Returns registry URL or defaults to Docker Hub
- **Example output**: `"https://registry.company.com"` or `"https://index.docker.io/v1/"`

#### Utility Functions

**`docker_config(attrConfig)`** - Generate Docker auth configuration
- **Purpose**: Creates Docker authentication configuration JSON
- **Parameters**: 
  - `attrConfig`: Array with 'url', 'username', 'password' keys
- **Implementation**: Creates base64-encoded auth string and formats as Docker config JSON
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

**`branch()`** - Get current Git branch
- **Purpose**: Returns the name of the currently checked out Git branch
- **Implementation**: Uses `git branch | grep \* | cut -d ' ' -f2`
- **Example output**: `"main"` or `"feature/new-functionality"`

**`go_mod_exists(modulePath)`** - Check if go.mod exists
- **Purpose**: Verifies whether a go.mod file exists in the specified path
- **Parameters**: 
  - `modulePath`: Path to check for go.mod file
- **Implementation**: Uses PHP's file_exists() function
- **Example output**: `true` or `false`

---

## Usage Examples

### Basic Development Workflow

```bash
# Start the development environment
ws enable

# Access the application container
ws console

# Run tests
ws go docker test

# Check code formatting
ws go docker fmt check

# Run benchmarks
ws go bench

# Rebuild the application
ws recompile
```

### Code Quality Analysis

```bash
# Run all quality checks
ws go docker vet
ws go docker gocyclo
ws go docker gosec
ws go docker ineffassign

# Generate test coverage
ws go test coverage
```

### Configuration Management

```bash
# Set a configuration value
ws set database.host localhost

# Get a configuration value  
ws get database.host
```

### Integration Testing

```bash
# Run all integration tests
ws go test integration

# Run specific integration test
ws go test integration TestUserRegistration
```

This documentation covers all commands and functions available in the harness-go harness, providing developers with comprehensive reference material for Go application development within the workspace environment.