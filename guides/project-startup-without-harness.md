# Project startup without a harness (deep dive)

<!-- TOC -->
## Table of Contents

- [Scope](#scope)
- [When to Avoid a Harness Initially](#when-to-avoid-a-harness-initially)
- [Directory layout (incremental growth)](#directory-layout-incremental-growth)
- [Minimal config set](#minimal-config-set)
- [Adding attributes and expressions](#adding-attributes-and-expressions)
- [Implementing a local render pipeline command](#implementing-a-local-render-pipeline-command)
- [Managing state and overrides](#managing-state-and-overrides)
- [Promoting to local harness](#promoting-to-local-harness)
- [Promotion checklist](#promotion-checklist)
- [See also](#see-also)

<!-- /TOC -->

## Scope

This guide shows how to bootstrap a Workspace environment without any existing
published harness, retaining full control while keeping a path open to later
promotion.

## When to Avoid a Harness Initially

| Signal | Rationale |
|--------|-----------|
| Stack unsupported by existing harnesses | Avoid forced abstractions |
| Rapid throwaway prototype | Minimise surface area |
| Desire to fully understand internals | Educational value |
| Unclear long-term architecture | Avoid premature generalisation |

## Directory layout (incremental growth)

```text
my-app/
  workspace.yml
  workspace/config/
    commands.yml
    confd.yml
  docker/ (templates, scripts, etc.)
```

As complexity increases, mirror the local harness pattern (see
`local-harness.md`).

## Minimal config set

### `workspace.yml`

```yaml
import('workspace-local'): workspace/config/*.yml

workspace('my-app'): |
  description: Example scratch workspace

attribute('namespace'): my-app
```

### `workspace/config/commands.yml`

```yaml
command('refresh'): |
  #!php
  $ws->confd('workspace:/')->apply();

command('hello'): |
  #!bash(workspace:/)|@
  echo "Hi from @('namespace')"
```

### `workspace/config/confd.yml`

```yaml
confd('workspace:/'):
  - { src: docker/Dockerfile }
```

## Adding attributes and expressions

Attributes drive template variability:

```yaml
attribute('app.image'): alpine:3.19
```

In a template:

```Dockerfile
FROM @('app.image')
```

Expression example using `exec()`:

```yaml
attribute('build.timestamp'): = exec('date +%s')
```

## Implementing a local render pipeline command

The `refresh` command (PHP version above) centralises rendering. A bash variant:

```yaml
command('refresh-bash'): |
  #!bash(workspace:/)
  ws harness prepare || ws refresh || true
```

Without a harness the `harness prepare` section may be skipped—keep the bash
form tolerant.

## Managing state and overrides

Create `workspace.override.yml` for local, non-committed tweaks (gitignore it):

```yaml
attribute('namespace'): my-app-dev
```

Or prefer environment variables exported before running `ws`.

## Promoting to local harness

When you introduce multiple templates, scripts, and attribute groups:

1. Create `local-harness/harness/config/` tree
2. Move `confd.yml`, `commands.yml` under it
3. Add `harness.path: local-harness` inside `workspace.yml`
4. Run `ws harness prepare`

## Promotion checklist

- [ ] Directory moved under `local-harness/`
- [ ] `harness.path` set
- [ ] Render still succeeds
- [ ] Commands still callable
- [ ] README updated (optional)

## See also

- Getting Started (`getting-started.md`)
- Local Harness Pattern (`local-harness.md`)
- Building a Harness (`building-a-harness.md`)

---
*Refine and extend with community feedback.*
