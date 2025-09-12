# Understanding `mutagen.yml` in the Harness

<!-- TOC -->
## Table of Contents

- [Overview](#overview)
- [Key Dependencies](#key-dependencies)
  - [Project Root mutagen.yml](#project-root-mutagenyml)
  - [The mutagen.sh Script](#the-mutagensh-script)
  - [Other Workspace (ws) Commands](#other-workspace-ws-commands)
  - [Required Software](#required-software)
- [Summary](#summary)

<!-- /TOC -->

## Overview

The `harness/config/mutagen.yml` file provides a set of helper commands to
manage Mutagen file synchronization and network forwarding within your
workspace. It is not a self-contained configuration but rather an
orchestration layer that depends on several other components.

Understanding these dependencies is key to customizing or troubleshooting
file synchronization.

## Key Dependencies

For the `ws mutagen` commands to work correctly, they rely on the following components:

### Project Root `mutagen.yml`

This is the main configuration file that you, the developer, create and manage.

- **Location:** Project root directory (e.g., `/path/to/my-project/mutagen.yml`).
- **Purpose:** It defines the actual `sync` and `forward` sessions that
  Mutagen will manage. The helper commands in the harness parse this file to
  get session names, paths, and other details.

**Example `mutagen.yml` in project root:**

```yaml
sync:
  code:
    alpha: "."
    beta: "docker://my-project_console_1/app"
    ignore:
      vcs: true

forward:
  web:
    source: "tcp:8080"
    destination: "docker://my-project_nginx_1:80"
```

### The `mutagen.sh` Script

The core logic for starting, stopping, and managing Mutagen sessions is not
in the YAML file itself but in a separate shell script.

- **Location:** `.my127ws/harness/scripts/mutagen.sh` (within the generated
  harness files).
- **Purpose:** The `mutagen (start|stop|...)` commands in
  `harness/config/mutagen.yml` gather environment variables (like session
  names from your root `mutagen.yml`) and then execute this script, passing
  the desired action (`start`, `stop`, etc.) as an argument.

### Other Workspace (`ws`) Commands

The `mutagen.yml` commands, especially `ws switch ...`, are integrated into
the larger workspace command system.

- **Dependencies:** It calls other `ws` commands like `ws disable`,
  `ws enable`, and `ws set`.
- **Location of Definitions:** These commands are typically defined in
  other configuration files within the harness, such as
  `harness/config/commands.yml`.
- **Purpose:** This allows the `switch` command to gracefully stop the
  environment, change the configuration attributes (e.g., toggle between
  `mutagen` and `delegated-volumes`), prepare the new configuration, and
  restart the environment.

### Required Software

The commands rely on specific software being installed and available in the
execution environment (the `my127/workspace` container).

- **PHP with Symfony YAML:** Used in the `get_mutagen_*` functions to parse
  the `mutagen.yml` file.
- **Bash:** Used to execute the shell scripts.
- **Docker:** The `ws mutagen rm` command directly calls `docker volume rm`
  to clean up Docker volumes created for synchronization.

## Summary

In essence, `harness/config/mutagen.yml` is the "glue" that connects your
high-level Mutagen configuration to the low-level scripts and environment
management commands, providing a seamless developer experience for managing
file synchronization.
