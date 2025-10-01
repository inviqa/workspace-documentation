# Getting started with Workspace

<!-- TOC -->
## Table of Contents

- [Who this is for](#who-this-is-for)
- [Prerequisites](#prerequisites)
- [Path A: starting with a harness](#path-a-starting-with-a-harness)
- [Path B: starting without a harness](#path-b-starting-without-a-harness)
- [Choosing a path (decision matrix)](#choosing-a-path-decision-matrix)
- [Next steps](#next-steps)
- [See also](#see-also)

<!-- /TOC -->

## Who this is for

New users deciding how to bootstrap a Workspace-based project. It offers two
paths: start from an existing harness (fastest) or build up from scratch
without one (max control, slower).

## Prerequisites

- Installed `ws` CLI (Homebrew: `brew install my127/formulae/workspace`).
- Docker Desktop (or compatible container runtime) running.
- Git repository initialised (recommended before generation).

## Path A: starting with a harness

### Harness selection guide

| Criteria | Use Existing Harness | Consider Scratch/Custom |
|----------|----------------------|--------------------------|
| Common tech stack (PHP, Drupal, Node, etc.) | ✅ |  |
| Wants batteries-included CI + tooling | ✅ |  |
| Needs only 1–2 bespoke files | ✅ (use overlay or attributes) |  |
| Novel stack / experimental runtime |  | ✅ |
| Need deep low-level control day one |  | ✅ |

### Create the project

Replace placeholders:

```bash
ws create my-app inviqa/harness-php:1.2.0
cd my-app
```

If unsure of the tag, browse the harness repository releases.

### First run workflow

```bash
ws enable            # build & start containers
ws console           # drop into the main app container
ws harness prepare   # (re)render templates if you change attributes
```

### Customising via attributes

Edit `workspace.yml` (or create `workspace.override.yml` if your harness
supports overrides) and add/modify attributes:

```yaml
attribute('namespace'): my-app
attribute('app.env'): dev
```

Re-render if templates depend on them:

```bash
ws harness prepare
```

### Verifying the environment

```bash
ws ps         # see container status
ws logs web   # or another service name
ws exec app php -v
```

## Path B: starting without a harness

### Why start without a harness?

- Ultra-minimal prototype
- Learning internals
- Unsupported stack
- Desire to evolve into a reusable harness later

### Minimal `workspace.yml` (no harness)

Create a directory and inside add:

```yaml
import('workspace-local'): workspace/config/*.yml

workspace('my-scratch'): |
  description: Scratch workspace without harness

attribute('namespace'): my-scratch
```

> The `import` allows you to modularise config under `workspace/config/`.

### Adding template rendering (`confd.yml`)

Create `workspace/config/confd.yml`:

```yaml
confd('workspace:/'):
  - { src: docker/Dockerfile.twig }
```

Add `docker/Dockerfile.twig`:

```Dockerfile
FROM alpine:3.19
CMD ["echo", "Hello from minimal workspace"]
```

Render:

```bash
ws refresh   # or define a command, see below
```

### Defining your first command

Create `workspace/config/commands.yml`:

```yaml
command('hello'): |
  #!bash(workspace:/)
  echo "Workspace name: @('namespace')"
```

Run it:

```bash
ws hello
```

### Iterating toward a local harness

When your `workspace/config/*` grows (templates, commands, events) consider
adopting the Local Harness Pattern (see `local-harness.md`). This formalises
layout and makes eventual promotion to a packaged harness trivial.

## Choosing a path (decision matrix)

| Need | Recommended Path |
|------|------------------|
| Production-grade stack quickly | Harness |
| Learning / pedagogy | No harness → Local harness |
| Unique infra constraints | No harness first |
| Minimal custom tweaks | Harness + overlay |
| Plan to upstream improvements | Harness + contribution |

## Next steps

- Explore command definitions (`defining-commands.md`).
- Review overlay concepts (`application-overlay.md`).
- If building a reusable harness later: `building-a-harness.md`.

## See also

- Local Harness Pattern (`local-harness.md`)
- Building a Harness (`building-a-harness.md`)
- Defining Commands (`defining-commands.md`)

---
*Evolve this guide as onboarding feedback arrives.*
