# Local Harness Pattern (Minimal Harness for `confd` Rendering)

<!-- TOC -->
## Table of Contents

- [Motivation](#motivation)
- [When to Use (and When Not To)](#when-to-use-and-when-not-to)
- [Directory Layout](#directory-layout)
- [Defining the Local Harness in `workspace.yml`](#defining-the-local-harness-in-workspaceyml)
- [Minimal `confd.yml`](#minimal-confdyml)
- [Template Examples](#template-examples)
- [Running the Render Pipeline](#running-the-render-pipeline)
- [How It Works Internally](#how-it-works-internally)
- [Local Realisation Workflow (No Index Required)](#local-realisation-workflow-no-index-required)
- [Version Control Guidance](#version-control-guidance)
- [Limitations](#limitations)
- [Migration to a Full Harness Later](#migration-to-a-full-harness-later)
- [Upgrading to a Complete In-Repo Harness (Using `.my127ws/` Structure)](#upgrading-to-a-complete-in-repo-harness-using-my127ws-structure)
- [Comparison with Custom Command Approach](#comparison-with-custom-command-approach)
- [Future Direction (Potential Enhancement)](#future-direction-potential-enhancement)
- [Quick Start Checklist](#quick-start-checklist)

<!-- /TOC -->
> Status: Experimental usage pattern. This document describes how to leverage
> the existing harness lifecycle to render templates into a project **without**
> depending on a published upstream harness. It is a pragmatic workaround until
> a potential future `standaloneConfd` feature exists.

## Motivation

Sometimes you want:

- Templated file generation (Dockerfiles, env examples, config stubs)
- Access to Workspace attribute and expression rendering
- The ordering, Twig environment, and idempotency of the harness `confd` engine

…but you **do not** want to adopt or vendor an external harness (PHP, Node,
Drupal, etc.). The *Local Harness Pattern* creates the smallest possible harness
layer in-repo whose sole purpose is to register a `confd.yml` and any template
files. All outputs can be targeted directly at the project root via the
`workspace:/` destination prefix.

## When to Use (and When Not To)

| Use When | Avoid When |
|----------|------------|
| Simple templating + helper scripts | Need upstream updates (use real harness) |
| Deterministic generation, no stack | Need multi-layer inheritance |
| Avoid custom ad-hoc Twig scripting | Will soon adopt official base harness |
| Can tolerate `.my127ws/` dir | Cannot allow any ephemeral directory |

## Directory Layout

```text
workspace.yml
local-harness/
  config/
    confd.yml
  templates/
    docker/Dockerfile.twig
    env/app.env.twig
    notices/NOTICE.md.twig
```

You may choose different names; `local-harness` simply conveys intent.

## Defining the Local Harness in `workspace.yml`

```yaml
workspace('my-app'):
  harnessLayers:
    - path: ./local-harness
  attributes:
    app:
      name: my-app
      php_version: 8.3
```

Key points:

- `harnessLayers:` accepts one or more local directories. Even with a single
  layer, using the list form keeps future layering obvious. (Workspace still
  supports the legacy `harness:` shorthand if you encounter it.)
- Each layer `path` points to a directory treated as a harness source (no
  vendor download).
- You can add attributes consumed by Twig templates.

### Required Helper Commands (Local Harness Overrides)

These two helper commands are essential for a path‑based local harness to
behave like a downloaded harness during install and prepare phases:

- `install local trigger-event` – emits lifecycle events (`before.harness.install`,
  `after.harness.install`, etc.) so existing event hooks still run.
- `install local list-layers` – enumerates every configured entry in
  `harnessLayers` ensuring all layer directories are copied into `.my127ws/`
  in declared order.

Do not remove or rename them unless Workspace gains native support for
path‑based installs without these helpers. Copy their implementations into
`workspace/config/install.local.yml` as shown later in this document.

## Minimal `confd.yml`

`local-harness/config/confd.yml`:

```yaml
confd('workspace:/'):
  - { src: templates/docker/Dockerfile }
  - { src: templates/env/app.env, dst: workspace:/.env.example }
  - { src: templates/notices/NOTICE.md, dst: workspace:/NOTICE.md }
```

Note:

- A separate `confd('harness:/'):` block is **not required** in the minimal
  pattern because the goal is to place every rendered artefact directly into
  the project root. All templates still reside under the local harness
  directory; the prefix only controls the *destination* root.
- If you later need some files to live inside the ephemeral harness tree (e.g.
  helper scripts that should not clutter the repository root) you can either:
  1. Keep a single `confd('workspace:/')` block and use explicit
     `dst: harness:/path/to/file` overrides for those few cases, or
  2. Introduce an additional `confd('harness:/'):` block for clearer grouping
     when there are many harness-internal outputs.

### Why `workspace:/` Prefix?

It directs all rendered outputs into the project root (not the ephemeral
`.my127ws/` tree). This keeps cognitive load low: generated files appear where
developers expect them.

## Template Examples

`local-harness/templates/docker/Dockerfile.twig`

```dockerfile
FROM alpine:3.19
LABEL org.opencontainers.image.title="{{ app.name }}"
```

`local-harness/templates/env/app.env.twig`

```env
APP_NAME={{ app.name }}
PHP_VERSION={{ app.php_version }}
```

`local-harness/templates/notices/NOTICE.md.twig`

```markdown
# Local Build Assets
Generated by Local Harness via `ws harness prepare`.
```

## Running the Render Pipeline

Initial realisation (creates `.my127ws/` and renders templates):

```bash
ws install --step=prepare
```

> **Heads-up**: The install lifecycle is the only place where Workspace runs
> the harness installer logic that renders your templates (see
> `workspace/src/Types/Workspace/Installer.php::applyConfiguration()`).
> Skipping `ws install` leaves `.my127ws/` empty; `ws enable` will not help
> unless your local harness defines its own command that shells out to the
> installer.

Subsequent template or mapping changes (no re-download):

```bash
ws harness prepare
```

Resulting files in project root after first run:

```text
./Dockerfile
./.env.example
./NOTICE.md
```

## How It Works Internally

1. Workspace sees `harness.path` and treats that directory as the harness.

2. During `prepare` the installer invokes:

  ```php
  Installer::applyConfiguration($this->harness->getRequiredConfdPaths())
  ```

1. `getRequiredConfdPaths()` includes the harness root so `confd.yml` is parsed.

1. `confd('workspace:/')` mappings render directly to the root.

## Local Realisation Workflow (No Index Required)

Workspace normally downloads harness packages from a JSON index. When the
entire harness lives inside your repository you can bypass the index by
overriding two commands:

1. `ws install` – copy the local harness into `.my127ws/`, apply the optional
   overlay, and trigger install events.
2. `ws harness prepare` – run the same `confd` render phase the installer would
   execute.

Create `workspace/config/install.local.yml` (or a similar file under
`workspace/config/`) with the following definitions:

> ⚠️ **Importer required:** Workspace reads only the root `workspace.yml`
> by default. Add an import statement so your local command overrides load.

```yaml
import('workspace-local'): workspace/config/*.yml
```

Place it at the top of `workspace.yml` (before `workspace('…')`). Without
this line Workspace will ignore the files under `workspace/config/` and the
`ws install local` and `ws harness prepare local` commands will not exist.

> **Overlay attribute heads-up:** Workspace reads `overlay:` from
> `workspace.yml` so it can apply the directory during the standard install
> step, but it does **not** publish that value into the attribute collection.
> If you want to access the overlay path via `@('…')` in your commands, define
> your own attribute (for example `attribute('install.overlay_dir')`) and
> reference that instead.

Workspace does publish harness layer paths under `workspace.harnessLayers`.
The helper command `install local list-layers` (defined below) uses
`$ws->getHarnessLayers()` so every configured layer is automatically synced in
render order—add a new entry to `harnessLayers` and it will be copied without
further adjustments.

```yaml
command('install local [--skip-events]', 'install local'):
  description: Realise local harness without remote repositories
  env:
    INSTALL_DIR: .my127ws
    OVERLAY_DIR: ./tools/workspace-overlay
    SKIP_EVENTS: "= input.option('skip-events') ? 1 : 0"
  exec: |
    #!bash(workspace:/)|@
    set -euo pipefail

    trigger_event() {
      ws install local trigger-event "$1"
    }

    HARNESS_DIRS=()
    while IFS= read -r layer_path || [ -n "$layer_path" ]; do
      HARNESS_DIRS+=("${layer_path}")
    done < <(ws install local list-layers)

    if [ ${#HARNESS_DIRS[@]} -eq 0 ]; then
      echo "No harness layers defined; aborting."
      exit 1
    fi

    if [ ${SKIP_EVENTS} -eq 0 ]; then
      trigger_event before.harness.install
    fi

    if [ -d "${INSTALL_DIR}" ]; then
      rm -rf "${INSTALL_DIR}"
    fi
    mkdir -p "${INSTALL_DIR}"

    for layer_dir in "${HARNESS_DIRS[@]}"; do
      if [ ! -d "${layer_dir}" ]; then
        echo "Expected harness layer directory '${layer_dir}' not found." >&2
        exit 1
      fi
      echo "Syncing ${layer_dir} → ${INSTALL_DIR}"
      rsync -a "${layer_dir}/" "${INSTALL_DIR}/"
    done

    if [ -n "${OVERLAY_DIR}" ] && [ -d "${OVERLAY_DIR}" ]; then
      echo "Applying overlay ${OVERLAY_DIR}"
      rsync -a "${OVERLAY_DIR}/" "${INSTALL_DIR}/"
    fi

    if [ ${SKIP_EVENTS} -eq 0 ]; then
      trigger_event after.harness.install
    fi

    echo "Harness files staged in ${INSTALL_DIR}."
    echo "Run 'ws harness prepare local' next."

command('harness prepare local [--skip-events]', 'harness prepare local'):
  description: Render local harness templates via confd
  env:
    SKIP_EVENTS: "= input.option('skip-events') ? 1 : 0"
  exec: |
    #!php(workspace:/)
    $skipOption = $input->getOption('skip-events');
    $triggerEvents = !(
      $skipOption instanceof \my127\Console\Usage\Model\BooleanOptionValue
      && $skipOption->value()
    );

    if ($triggerEvents) {
      $ws->trigger('before.harness.prepare');
    }

    $paths = [];

    if (
      isset($harness)
      && is_object($harness)
      && method_exists($harness, 'getRequiredConfdPaths')
    ) {
      $paths = $harness->getRequiredConfdPaths();
    }

    foreach ($paths as $path) {
      $ws->confd($path)->apply();
    }

    if ($triggerEvents) {
      $ws->trigger('after.harness.prepare');
    }

    if (empty($paths)) {
      echo "No confd paths defined; nothing to render.";
      return;
    }

    echo "Rendered harness templates.";

command('install local trigger-event %', 'install local trigger-event'):
  description: Internal helper to emit workspace events for local install
  env:
    EVENT_NAME: "= input.argument('%')"
  exec: |
    #!php(workspace:/)
    $ws->trigger($env['EVENT_NAME']);

command('install local list-layers'):
  description: Internal helper to list configured harness layer paths
  exec: |
    #!php(workspace:/)
    $layers = $ws->getHarnessLayers() ?? [];
    foreach ($layers as $layer) {
      if (!empty($layer['path'])) {
        echo rtrim($layer['path']) . "\n";
      }
    }
```

With these overrides in place the workflow is:

1. `ws install` – realises `.my127ws/` from the local harness and optional
   overlay.
1. `ws harness prepare` – renders Twig templates through `confd` (no index
   lookup needed).

The commands honour `--skip-events` to remain compatible with existing hooks.
See [Harness Indexes](../reference/harness-indexes.md) for background on
indexes and
when you still need them.

## Version Control Guidance

Add (or ensure) `.my127ws/` in your `.gitignore`; commit the **rendered** files
if they are part of the reproducible dev environment. Do *not* edit rendered
files—modify the Twig templates or mappings and re-run instead.

## Limitations

- Still produces `.my127ws/` (cannot be suppressed currently).
- No multi-layer override semantics beyond what you manually add (only one layer).
- Cannot (yet) declare additional standalone confd roots outside the harness path.
- Internal harness APIs may evolve; keep the pattern minimal to reduce churn.

## Migration to a Full Harness Later

If you later adopt an upstream harness:

1. Move local templates into an overlay directory or new layer.
2. Replace `harness.path` with vendor harness name (e.g. `inviqa/php`).
3. Merge `confd.yml` entries (avoid duplicate destinations).

## Upgrading to a Complete In-Repo Harness (Using `.my127ws/` Structure)

Sometimes you want to go beyond a minimal template layer but still keep the
entire harness logic inside your repository (rather than immediately depending
on a published package). This section shows how to evolve the local harness
into a more complete structure modelled after `harness-php` while continuing to
use the standard `.my127ws/` realisation directory produced by Workspace.

### Why Build a Complete In-Repo Harness First?

| Motivation | Rationale |
|------------|-----------|
| Iterative hardening | Expand gradually before externalising as a package |
| Faster feedback | Change + enable cycle stays local (no publish step) |
| Custom stack mix | Combine patterns from multiple existing harnesses |
| Pre-packaging audit | Validate naming, layering, generated outputs |
| Temporary divergence | Maintain project-specific tweaks before upstreaming |

### Target Layout (Authoritative Sources)

You define an authoritative tree under your existing `local-harness/` (keeping
the name consistent for clarity) mirroring the directory semantics of an
upstream harness (compare with `harness-php/_twig/`, `docker/`, `harness/`,
etc.). Example minimal scaffold:

> Overlay vs Skeleton: if, during this evolution, you start needing centrally
> managed CI/auth/ignore policy files that should be refreshable across
> multiple projects, introduce an `application/overlay/` directory. See the
> [Application Overlay](./application-overlay.md) deep dive for rationale and
> lifecycle. Keep `application/skeleton/` for one‑time scaffolding only.

```text
workspace.yml
local-harness/
  config/
    confd.yml
  templates/                 # (Optional) if you prefer this naming
  docker/
    image/
      php/Dockerfile.twig
  harness/
    scripts/
      bootstrap.sh.twig
  docs/
    README.partial.md.twig
```

You should keep using `local-harness/` while iterating. Only once you are
ready to extract and publish a reusable package would you optionally rename it
to a neutral `harness/` (or move it into a separate repository). Naming is not
enforced by tooling—`harness.path` directs the lookup.

### Example Expanded Confd Yml

`local-harness/config/confd.yml` (showing both destination roots):

```yaml
# Harness-internal artefacts (end up under .my127ws/ ...)
confd('harness:/'):
  - { src: harness/scripts/bootstrap.sh }

# Project-root artefacts
confd('workspace:/'):
  - { src: docker/image/php/Dockerfile }
  - { src: docs/README.partial.md, dst: workspace:/HARNESS-NOTES.md }
```

Notes:

- Two blocks make destination intent obvious: first purely harness files,
  second project-root files.
- You could collapse these into a single `confd('workspace:/')` block and keep
  `dst: harness:/...` for harness-internal outputs; separate blocks scale
  better once you have several internal scripts.
- Use clear naming for root artefacts (`HARNESS-NOTES.md`) to avoid conflicts
  with repository user-facing docs.

### Declaring the Harness

In `workspace.yml` keep using a path-based harness during the incubation phase:

```yaml
workspace('my-app'):
  harnessLayers:
    - path: ./local-harness
  attributes:
    php:
      version: 8.3
```

Later, when you convert it into a distributable harness, you can switch to a
package reference (e.g. `inviqa/php`) after publishing.

### Minimal `harness.yml` Template (When Preparing to Publish)

When you are ready to package the current `local-harness/` into a reusable
artifact, introduce a `harness.yml` file at the root of the *authoritative*
directory (the one that will be archived / tagged). A minimal starting point:

```yaml
name: acme/generic
version: 0.1.0
summary: Generic reusable development harness.
license: MIT
maintainers:
  - name: Platform Team
    email: platform@example.com
compatibility:
  workspace: ">=1.0 <2.0"   # adjust to supported CLI versions
  docker: ">=24"            # optional; document tested range
notes:
  deprecations: []          # list identifiers or paths scheduled for removal
```

Guidelines:

- Keep `version` aligned with your changelog tag.
- Add additional metadata *only when needed* (avoid premature surface area).
- Track upcoming removals under `notes.deprecations` (see deprecation section
  in the main README once added).

> Deprecation planning: see **Deprecation Guidelines** in `README.md` and the
> "Deprecation Policy" portion of [Building a Reusable Harness](building-a-harness.md)
> before removing or renaming public files / commands.

### Layering Within an In-Repo Harness

If you need internal layering (base vs overrides) before packaging, emulate it
by splitting directories and merging them manually at build time, or by adding
an `overlay` directory referencing additional overrides:

```yaml
workspace('my-app'):
  harnessLayers:
    - path: ./local-harness
  overlay: tools/workspace-overlay    # optional
```

`tools/workspace-overlay/` contents will rsync over the realised `.my127ws/`
tree prior to confd rendering, just like with external harness packages.

### Migrating to a Published Package Later

When stable:

1. Extract the authoritative harness directory into its own repository.
2. Add packaging metadata (e.g., `harness.yml`, licensing, versioning).
3. Publish (internal registry / VCS tag / package archive).
4. Update project `workspace.yml` to reference the new harness package name.
5. Remove `path:` harness reference and any now-redundant local harness files.

### Pros / Cons of Staying In-Repo Longer

| Aspect | Benefit | Trade-off |
|--------|---------|-----------|
| Velocity | Immediate edits / enables | Harder to share across projects |
| Risk | Low risk while iterating | Drift from community improvements |
| Review | PR review with app code | PR noise (infra + app mixed) |
| Versioning | Single repo version gate | No semantic version boundary |
| Distribution | No publish pipeline needed | Cannot reuse externally yet |

### Choosing Between Minimal vs Complete In-Repo Harness

| Scenario | Minimal Local Harness | Complete In-Repo Harness |
|----------|-----------------------|--------------------------|
| Only a few generated files | Ideal | Overkill |
| Need scripts + multi-dir templates | Cumbersome | Appropriate |
| Planning to upstream soon | Acceptable | Good staging step |
| Heavy reuse across teams | Insufficient | Transition to package |
| Strict separation infra/app needed | Less clear | Can isolate infra tree |

### Practical Tips

- Keep template stems stable early to avoid noisy future diffs when packaging.
- Group harness docs under `docs/` but avoid duplicating repository README
  content—link instead.
- Use explicit `dst:` only when placing files outside harness tree.
- Periodically run a clean rebuild to ensure no accidental reliance on stale
  generated artefacts:

```bash
ws disable && rm -rf .my127ws && ws install --step=prepare
```

### Do I Need an Overlay with a Complete In-Repo Harness?

You do **not** have to use an `overlay` when everything lives in
`local-harness/`. An overlay remains an *optional* second local layer that is
useful only when you want separation of concerns, simulated layering, or an
easy path to later packaging.

#### When You Can Skip It

- All harness artefacts (templates, scripts, docs) evolve together.
- No need to distinguish "core" vs "project-only" changes.
- You are not yet preparing to extract/publish a reusable package.
- Minimal file set (a few templates) – overlay would just add noise.

#### When an Overlay Still Adds Value

| Use Case | Why Overlay Helps | Alternative | Worth? |
|----------|-------------------|------------|--------|
| Simulate layering | Mirrors upstream model | Dir naming (`base/`) | Likely |
| Prepare for extraction | Keeps publish set clean | Manual curate later | Yes |
| Risky experiments | Easy to drop layer | Git branch / revert | Maybe |
| Multi-variant builds | Swap `overlay:` path | Template conditionals | Yes |
| Internal-only scripts | Separate review / filter | Git attrs | Sometimes |
| Gradual vendor migration | Override until replaced | Fork earlier | Yes |
| Dev sandboxing | Ephemeral tweaks | Feature branch | Rare |

#### Mental Model

Final realised tree ordering (top overwrites lower):

1. (Optional) downloaded harness packages (not present if only path harness)
2. Path harness directory: `local-harness/`
3. Overlay directory (if configured)
4. `confd` mapping order (last write wins per destination)

If you have only (2) and (4), you already get deterministic rendering.

#### Practical Patterns

1. **Incubation Before Packaging**  
   Keep `local-harness/` pristine; put ad-hoc tweaks in `tools/workspace-overlay/`.

2. **Multi-Variant in One Repo**  
   Structure:

   ```text
   local-harness/
   overlays/
     variant-a/
     variant-b/
   ```

   Select with:

   ```yaml
   workspace('app'):
     harnessLayers:
       - path: ./local-harness
     overlay: overlays/variant-a
   ```

3. **Refactor Staging**  
   Move refactored replacement files into overlay first, diff outputs, then promote.

4. **Conditional Feature Trials**  
   Overlay holds experimental scripts; delete directory to revert completely.

#### Overlay vs Pseudo-Layers Inside `local-harness/`

Without overlay you can still emulate layering:

```text
local-harness/
  base/
  overrides/
  config/confd.yml
```

Then map both regions in `confd.yml`. Trade-off: harder to extract a clean
package later (you must manually separate base vs override content).

#### Smells (Overlay Misuse)

- Exists but is empty or rarely touched – delete it.
- Long-term project logic stranded in overlay (belongs in harness core).
- Used to "delete" files by omission (overlay cannot remove, only overwrite).
- Becomes a dumping ground for unrelated experiments.

#### Decision Summary

| Situation | Use Overlay? | Rationale |
|-----------|--------------|-----------|
| Early minimal adoption | No | Extra ceremony |
| Preparing to publish | Yes | Clean separation aids extraction |
| Multiple variants required | Yes | Swapable directory pointer |
| Occasional one-off tweak | No | Commit directly to harness |
| Heavy experimentation phase | Maybe | If churn would pollute core |

If unsure, start **without** an overlay. Introduce it deliberately when a
clear separation goal emerges.

### When to Stop and Publish

Publish when:

1. Another project wants the same harness logic.
2. You need versioned change control independent of application code.
3. Upgrade cadence diverges from application release cadence.

Until then, the complete in-repo harness path lets you iterate safely while
adhering to the same lifecycle (`install` → `prepare` → render) used by official
packages (you can still add your own `enable` shortcut if you need runtime
commands).

## Comparison with Custom Command Approach

| Aspect | Local Harness | Custom Confd Command |
|--------|---------------|----------------------|
| Supported lifecycle | Yes (reuse prepare) | No (bespoke) |
| Maintenance risk | Low | Higher (internal APIs) |
| Additional code | None | Script + loader |
| Extensibility | Can grow into real harness | Must be rewritten |

## Future Direction (Potential Enhancement)

A future `workspace.yml` key (e.g. `standaloneConfd:`) could allow harness-less
confd paths. Until then, this pattern is the simplest supported approach.

## Quick Start Checklist

1. Create `local-harness/config/confd.yml` with `confd('workspace:/')` block.
2. Add templates under `local-harness/templates/` (omit `.twig` in `src`).
3. Reference harness via `harness.path` in `workspace.yml`.
4. Run `ws install --step=prepare` → inspect generated files.
5. Iterate using `ws harness prepare` after template edits.
  Rerun `ws install --step=prepare` if you want the full installer cascade.

### See also

- [Harness File Materialisation (confd.yml)](../reference/harness-confd-file-mappings.md)
- [Workspace Commands & Functions Index](../reference/workspace-commands-functions-index.md)
- [Building a Reusable Harness](building-a-harness.md)
