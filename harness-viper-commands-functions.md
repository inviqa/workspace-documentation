# Harness Viper - Commands and Functions Documentation

This document covers all commands and functions available in the Viper harness.

## Overview

The Viper harness provides a Docker-based Node.js development environment with
optional chart publishing and helm validation.

---

## Commands

### File: `harness-viper/harness/config/commands.yml`

#### Environment Management

- `ws enable` — Start the environment
- `ws disable` — Stop the environment
- `ws destroy` — Remove containers and resources
- `ws networks external` — Ensure required external networks exist

#### Node Container Access and Ops

- `ws yarn %` — Run yarn commands inside the `node` container
- `ws exec %` — Run arbitrary commands in the `node` container
- `ws console` — Open interactive bash in the `node` container
- `ws logs %` — View logs for a service
- `ws ps` — List running services
- `ws port <service>` — Show port mappings for a service

#### Configuration Management

- `ws set <attribute> <value>` — Set a value in `workspace.override.yml`

### File: `harness-viper/harness/config/pipeline.yml`

- `ws app build` — Pull external images then build the `node` service image
- `ws app publish` — Login and push images in `pipeline.publish.services`
- `ws app publish chart <release> <message>` — Publish Helm chart to Git
- `ws helm template <chart-path>` — Render Helm chart
- `ws helm kubeval <chart-path>` — Validate templates (installs kubeval plugin)

### File: `harness-viper/harness/config/external-images.yml`

- Function `external_images(services)` — Collect upstream images not produced locally
- `ws external-images config` — Emit a docker-compose for external images
- `ws external-images pull` — Pull images via generated compose

---

## Functions

### File: `harness-viper/harness/config/functions.yml`

- `to_yaml(data)` / `to_nice_yaml(data, indentation, nesting)` — YAML helpers
- `deep_merge(arrays)` / `deep_merge_to_yaml(...)` — Deep merge arrays
- `publishable_services(services)` — Services marked `publish: true`
- `filter_local_services(services)` — Keep environment/enabled keys
- `docker_service_images()` — Enumerate service images and their upstreams
- `get_docker_external_networks()` — External networks from compose
- `docker_config(registryConfig)` — Docker auth config JSON
- `branch()` — Current Git branch
- `slugify(text)` — URL-safe slugs
