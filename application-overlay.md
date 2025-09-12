# Application Overlay Deep Dive

> Canonical reference for the `application/overlay/` directory pattern in a
> Workspace harness (distinct from `application/skeleton/`).

<!-- TOC -->
## Table of Contents

- [Purpose](#purpose)
- [Typical Contents](#typical-contents)
- [Render + Apply Lifecycle](#render--apply-lifecycle)
- [Attribute Injection](#attribute-injection)
- [Commands & Tasks](#commands--tasks)
- [Upgrade & Refresh Practices](#upgrade--refresh-practices)
- [Extension Guidelines](#extension-guidelines)
- [Anti-Patterns](#anti-patterns)
- [Provenance / Drift Detection (Optional Enhancements)](#provenance--drift-detection-optional-enhancements)
- [Quick Reference](#quick-reference)
- [Author Checklist](#checklist-author-perspective)

<!-- /TOC -->

## Purpose

The overlay provides **managed bootstrap artefacts** (CI pipeline, dependency
auth, ignore policy, etc.) that are *authored in the harness*, rendered via
`confd`, and then *applied into the consumer project* so every project gains a
consistent operational baseline with minimal manual setup.

It differs from `application/skeleton/` which is intended for **initial one-time
scaffolding** at project creation (e.g. README fragment) rather than an
artefact set that may be refreshed after upgrades.

| Dimension | Overlay | Skeleton |
|-----------|---------|----------|
| Intent | Managed, refreshable policy/config | One-time initial scaffold |
| Lifecycle | Re-applied on upgrade/update | Applied at project creation |
| Source of Truth | Harness templates | Harness templates (then project owns) |
| Typical Files | `Jenkinsfile`, `auth.json`, `.dockerignore` | README fragment |
| Re-apply Needed? | Yes (when harness updates) | Rarely (manual edits after) |

## Typical Contents

| File | Role | Notes |
|------|------|-------|
| `Jenkinsfile.twig` | CI pipeline definition | Conditional publish / preview |
| `auth.json.twig` | Dependency auth config | Pulls `composer.auth.*` attrs |
| `.dockerignore` (templated) | Build context hygiene | Dynamic + static frags |
| Future candidates | CODEOWNERS, SECURITY.md, policy files | Add when stable |

A supporting `_twig/` subtree can hold fragment pieces (e.g.
`.dockerignore/static.twig`, `.dockerignore/dynamic.twig`).

## Render + Apply Lifecycle

1. `ws harness prepare` renders harness templates into `.my127ws/...` according
   to `harness/config/confd.yml` mapping entries.
2. Overlay templates are rendered under the harness render root (not always
   directly into the workspace root).
3. A task (e.g. `app overlay:apply`) or scripted step copies / syncs the
   rendered artefacts into the project root (`/app/` inside containers or the
   local workspace root path) — typically via `rsync` excluding raw `.twig`.
4. Users commit / manage those files in their repository as policy artefacts.
5. On harness upgrade, re-run overlay apply to refresh changed templates.

### Minimal Flow Diagram (Text)

```text
[harness templates] --> (confd render) --> [.my127ws/harness/application/overlay]
      \                                                       |
       \ (rsync task overlay:apply) --------------------------+--> [project root]
```

## Attribute Injection

Examples of attribute groups often referenced:

| Attribute Prefix | Used For | Example Effect |
|------------------|----------|----------------|
| `pipeline.publish.*` | Conditional publish stage | Enables publish block |
| `pipeline.preview.*` | Preview env deploy logic | Adds preview stage(s) |
| `pipeline.qa.*` | QA branch deployment | Adds QA deploy stage |
| `composer.auth.basic[]` | Auth JSON creds | Iterates repos for auth.json |
| `composer.auth.github` | GitHub token | Adds `github-oauth` section |
| `git.default_branch` | Trigger scheduling | Cron trigger on default branch |
| `workspace.name` | Naming / resource prefix | Namespaces pipeline resources |

Keep attribute usage **declarative**: avoid embedding sensitive secrets; prefer
credential indirection via CI secret stores or environment injection.

## Commands & Tasks

Provide an explicit command to re-apply overlays:

```yaml
command('overlay apply'):
  exec: |
    #!bash(workspace:/)
    docker-compose exec -T -u build console app overlay:apply
```

Inside the container a script (example pattern):

```bash
run rsync --exclude='*.twig' --exclude='_twig' \
   -a /home/build/application/overlay/ /app/
```

Optionally add a `--dry-run` mode (e.g. `rsync -an`) to preview changes.

## Upgrade & Refresh Practices

| Scenario | Action |
|----------|--------|
| Harness version bump | Run `ws exec app overlay:apply` (or dedicated command) |
| Added new overlay file | Re-apply; commit new artefact |
| Removing an overlay file | Note in release notes (may be breaking) |
| Local modifications diverged | Diff before overwriting; maybe provenance |

## Extension Guidelines

Add new overlay files when they:

- Represent cross-project policy or compliance.
- Reduce boilerplate or setup friction.
- Are stable enough not to churn every week.

Avoid overlaying:

- Secrets or credential blobs (use secret managers / CI credentials).
- Large binaries (fetch dynamically instead).
- Highly experimental configs (stage locally first).

## Anti-Patterns

| Anti-Pattern | Why Problematic | Alternative |
|--------------|-----------------|------------|
| Embedding secrets in templates | Secret leak risk | Use attrs + CI secrets |
| Frequent churn of overlay files | Merge friction | Incubate outside first |
| Huge monolithic Jenkinsfile logic | Hard to reason | Extract tasks into cmds |
| Direct write to root w/out filtering | Copies `.twig` sources | Use excludes |

## Provenance / Drift Detection (Optional Enhancements)

You can add a header line to managed overlay files:

```text
# Managed by harness <name>@<version> – DO NOT EDIT DIRECTLY (run: ws overlay apply)
```

Then implement a check command that scans for outdated version markers or
missing headers.

Potential future improvements:

- `overlay-manifest.yml` enumerating managed files + checksum.
- `ws overlay status` command listing drifted files.
- Automatic PR generator for overlay updates.

## Quick Reference

| Need | Command / File |
|------|----------------|
| Re-render harness | `ws harness prepare` |
| Apply overlay | `ws overlay apply` (custom command) |
| Update harness + refresh overlay | `ws harness prepare && ws overlay apply` |
| Inspect mapped files | `harness/config/confd.yml` |

## Checklist (Author Perspective)

- [ ] Overlay documented & linked from authoring guide
- [ ] Explicit re-apply command provided
- [ ] Attribute usage kept minimal & declarative
- [ ] No secrets or binaries included
- [ ] Release notes mention overlay file additions/removals
- [ ] (Optional) Provenance header adopted

## 12. See Also

- Building a Harness (structure & promotion)
- Local Harness Pattern
- Harness File Materialisation (`confd.yml`)

---
*Evolve this document as overlay patterns mature; consolidate variants rather
than forking.*
