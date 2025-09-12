# Harness WordPress - Commands and Functions Documentation

This document covers all commands and functions available in the WordPress
harness.

## Overview

The WordPress harness provides a Docker-based environment similar to other PHP
harnesses. It supports assets, frontend tooling, DB access, feature toggles
(Blackfire, Tideways), and Lighthouse audits.

---

## Commands

### File: `harness-wordpress/harness/config/commands.yml`

- Environment lifecycle: `ws enable`, `ws enable console`, `ws disable`,
  `ws destroy [--all]`, `ws rebuild`
- Networks: `ws networks external`
- Container access: `ws exec %`, `ws console`, `ws logs %`, `ws ps`
- Composer: `ws composer %`
- Database: `ws db-console`, `ws db console`, `ws db import <database_file>`
- Assets: `ws assets download`, `ws assets upload`
- Frontend: `ws frontend build`, `ws frontend watch`, `ws frontend console`
- Ports: `ws port <service>`
- PHP-FPM: `ws service php-fpm restart`
- Config: `ws set <attribute> <value>`
- Feature toggles:
  - `ws feature blackfire (on|off)`, `ws feature blackfire cli (on|off)`
  - `ws feature tideways (on|off)`, `ws feature tideways cli (on|off)`,
    `ws feature tideways cli configure <server_key>`
- Utilities: `ws generate token <length>`, `ws lighthouse [--with-results]`
- Harness updates: `ws harness update existing`, `ws harness update fresh`

### File: `harness-wordpress/harness/config/pipeline.yml`

- `ws app build` — Dependency-ordered multi-service build
- `ws app build <service>` — Build a specific service image
- `ws app publish` — Push images to registry
- `ws app publish chart <release> <message>` — Publish Helm chart to Git
- `ws app deploy <environment>` — Helm upgrade/install with kubeconfig
- `ws helm template <chart-path>` — Render templates
- `ws helm kubeval [--cleanup] <chart-path>` — Validate templates (installs
  plugin)

### File: `harness-wordpress/harness/config/external-images.yml`

- Function `external_images(services)` — JSON list of needed external images
  (excludes produced and scratch)
- `ws external-images config [--skip-exists] [<service>]` — Emit docker-compose
  for pulling
- `ws external-images pull [<service>]` — Pull using generated compose
- `ws external-images ls [--all]` — List required or locally present images
- `ws external-images rm [--force]` — Remove external images

---

## Functions

### File: `harness-wordpress/harness/config/functions.yml`

- `host_architecture(style)` — Host arch (native/go)
- `to_yaml(data)` / `to_nice_yaml(data, indentation, nesting)` — YAML
  formatting
- `indent(text, indentation)` — Indent lines
- `deep_merge(arrays)` — Deep merge
- `filter_local_services(services)` / `filter_empty(array)` /
  `flatten(array)` — Array helpers
- `get_docker_external_networks()` — External networks from compose config
- `docker_service_images([filterService])` — Image/platform/upstream
  extraction
- `get_docker_registry(repo)` / `docker_config(registryConfig)` — Registry
  parsing and auth JSON
- `branch()` — Current Git branch
- `slugify(text)` — URL slug
- `php_fpm_exporter_scrape_url(hostname, pools)` — Scrape URLs for PHP-FPM
  exporter
- `publishable_services(services)` — Space-separated service names with
  publish
- `replace(haystack, needle, replacement)` — String replace
- `template_key_value(template, key_value)` — Expand keys from template
- `version_compare(v1, v2, op)` — Version comparison
- `bool(value)` / `boolToString(value)` — Boolean conversions

---

## Examples

### List required external images

```bash
$ ws external-images ls
Required external images:
- redis:6.2-alpine
- traefik:2.9
```

### Toggle Tideways extension

```bash
$ ws feature tideways on
Tideways extension enabled

$ ws feature tideways off
Tideways extension disabled
```

### Import a database dump

```bash
$ ws db import dump.sql.gz
Importing database dump.sql.gz into service db...
Done.
```
