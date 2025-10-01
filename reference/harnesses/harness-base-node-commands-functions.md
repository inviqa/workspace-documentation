# Harness Base Node Commands and Functions

<!-- QUICK-INDEX -->
## Quick Index

- Orientation: [Overview](#overview)
- Core tasks: [Commands](#commands)
- Source: [Command Source](#file-harness-base-nodesrc_baseharnessconfigcommandsyml), [Function Source](#file-harness-base-nodesrc_baseharnessconfigfunctionsyml)
- Extensibility: [Functions](#functions)
- How-to: [Examples](#examples), [Usage Examples](#usage-examples)
<!-- /QUICK-INDEX -->

<!-- TOC -->
## Table of Contents

- [Quick Index](#quick-index)
- [Introduction](#introduction)
- [Overview](#overview)
- [Commands](#commands)
- [Functions](#functions)
- [Examples](#examples)
- [Usage Examples](#usage-examples)

<!-- /TOC -->

## Introduction

This document provides a comprehensive reference for all commands and
functions available in the `harness-base-node` harness.

## Overview

The Base Node harness provides a Docker-based Node.js development
environment with workspace management, network, container, and configuration
tooling.

## Commands

### File: `harness-base-node/src/_base/harness/config/commands.yml`

- Environment lifecycle: `ws enable`, `ws disable`, `ws destroy`
- Networks: `ws networks external`
- Node.js development: `ws yarn %`, `ws exec %`, `ws console`
- Container management: `ws logs %`, `ws ps`, `ws port <service>`
- Config: `ws set <attribute> <value>`

---
 
## Functions

### File: `harness-base-node/src/_base/harness/config/functions.yml`

- YAML: `to_yaml(data)`, `to_nice_yaml(data, indentation, nesting)`,
  `deep_merge_to_yaml(arrays, indentation, nesting)` (DEPRECATED)
- Arrays: `deep_merge(arrays)`
- Service management: `publishable_services(services)`, `filter_local_services(services)`
- Docker: `docker_service_images()`

---

## Examples

### Run yarn install in the node container

```bash
$ ws yarn install
Yarn install/build output, dependencies installed
```
 
### Enable the workspace

```bash
$ ws enable
All containers started, workspace ready
```

### Show running containers

```bash
$ ws ps
Table of running containers and ports
```

#### Utility Functions

**`branch()`**

- **Description:** Get current Git branch name
- **Returns:** Current branch name
- **Usage:** `= branch()`

**`slugify(text)`**

- **Description:** Convert text to URL-friendly slug format
- **Parameters:**
  - `text` - Text to slugify
- **Returns:** Slugified text (lowercase, hyphens, no special chars)
- **Usage:** `= slugify("My Project Name")` → `"my-project-name"`

## Usage Examples


### Using Commands in workspace.yml

```yaml
command('setup'): |
  #!bash
  ws enable
  ws yarn install
  ws exec npm run build

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

### Using Functions in Templates

```yaml
attribute('docker.images'): = docker_service_images()
attribute('git.branch'): = branch()
attribute('project.slug'): = slugify(@('workspace.name'))

services: = deep_merge([
  @('base_services'),
  @('custom_services')
])
```

### Environment Variables in Commands

```yaml
command('custom-build'):
  env:
    NAMESPACE: = @('namespace')
    BRANCH: = branch()
  exec: |
    #!bash|@
    echo "Building for namespace: ${NAMESPACE}"
    echo "Current branch: ${BRANCH}"
```
