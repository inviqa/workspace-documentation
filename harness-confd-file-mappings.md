# Harness File Materialisation with `confd.yml`

See also:

- **[Workspace Commands Index](workspace-commands-functions-index.md)** for a full list of core and harness commands.
- **[Documentation README](README.md)** for orientation and other conceptual guides.

## Overview

`confd.yml` defines how source template files are materialised into a working
Workspace harness directory (`.my127ws/`) and, where required, directly into the
project root. It is processed when a harness is enabled, rebuilt, or refreshed.

The file is NOT a public API guarantee; its structure can evolve. Projects
should treat it as an internal mapping layer between versioned template assets
and the realised development environment.


## Purpose


- Assemble a coherent harness filesystem from curated source fragments.
- Support layering (base → overlay) by ordered mappings (last write wins).
- Allow select files to appear at the project root (e.g., `docker-compose.yml`).
- Keep template sources immutable while the realised harness remains disposable.


## Location & Lifecycle


| Phase | Path | Description |
|-------|------|-------------|
| Template (versioned) | `tools/workspace/harness/config/confd.yml` | Authoritative mappings you edit. |
| Realised (ephemeral) | `.my127ws/harness/config/confd.yml` | Copy used by tooling during enable. |

Typical workflow:

1. Edit template `confd.yml` and any referenced source files.
2. Re-enable / rebuild the harness (e.g., `workspace harness rebuild`).
3. Tool copies and processes mappings, writing files into `.my127ws/` and root destinations.
4. Use the environment; re-run rebuild after changes.

`.my127ws/` should usually stay uncommitted; treat it as generated output.


## Syntax Structure


At the top level, `confd.yml` contains one or more mapping blocks introduced by
a directive line of the form:

```yaml
confd('<prefix>'):
  - { src: <relative/source/path> [, dst: <destination-spec>] }
  - { src: ... }
```

Where:

- `src` is a path relative to the *template config context* (commonly the
  directory containing `confd.yml`). Importantly, this value is treated as a
  **Twig template stem**. The engine automatically appends `.twig` when reading
  the source. So `- { src: docker/image/nginx/root/etc/nginx/conf.d/default.conf.template }`
  will cause the renderer to load
  `docker/image/nginx/root/etc/nginx/conf.d/default.conf.template.twig` from the
  template tree and output a destination file with the `.twig` suffix removed.
- `dst` (optional) overrides the default destination path.
- Mappings are processed top-to-bottom; later mappings to the same destination overwrite earlier ones.

If you mistakenly include the `.twig` suffix inside `src`, the engine will look
for `<name>.twig.twig` and fail. Always omit `.twig` in `src` declarations.


### Supported Destination Prefixes


| Prefix | Meaning | Resolves To |
|--------|---------|-------------|
| `harness:/` | Place file inside the realised harness tree | `.my127ws/` root |
| `workspace:/` | Place file into the project working directory root | Project checkout root |

If `dst` is omitted, the default destination is: `harness:/<src>` (mirrors source path inside harness).

### Example Minimal Block


```yaml
confd('harness:/'):
  - { src: docker/image/app/Dockerfile }
  - { src: scripts/init.sh }
  - { src: overlay/.dockerignore, dst: workspace:/.dockerignore }
```

Results:

- `.my127ws/docker/image/app/Dockerfile`
- `.my127ws/scripts/init.sh`
- `./.dockerignore` in project root


## Practical Examples

### Template Rendering Pipeline (Conceptual)

```text
confd.yml mapping           Confd::apply()                Twig Loader Root             Output File
--------------------------- ----------------------------- --------------------------- ---------------------------------
src: path/to/file.conf      => adds .twig suffix          path/to/file.conf.twig       path/to/file.conf (no .twig)
src: config/app.env         => config/app.env.twig        config/app.env.twig          config/app.env
src: helm/app/values.yaml   => helm/app/values.yaml.twig  helm/app/values.yaml.twig    helm/app/values.yaml
```

Steps:

1. Definitions parsed into `my127\Workspace\Types\Confd\Definition` objects.
2. `ConfdFactory` builds a Twig environment rooted at the directory passed in the `confd('<prefix>')` declaration.
3. `Confd::apply()` loops templates:
4. Skips mapping if a `when:` expression exists and evaluates false.
5. Appends `.twig` to `src` to form the template filename.
6. Computes destination: `dst` if given, else removes trailing `.twig` and
  prepends the resolved root (e.g. `harness:/`).
7. Renders via Twig with workspace attributes, dynamic functions, expressions.
8. Ensures destination directory exists and writes file.


### 1. Basic Copy (implicit destination)


```yaml
- { src: docker/image/api/Dockerfile }
```

### 2. Overriding Destination Root


```yaml
- { src: support/dev-helper.sh, dst: workspace:/dev-helper.sh }
```

### 3. Renaming on Destination


```yaml
- { src: docs/template-env.example, dst: workspace:/env.example }
```

```yaml
- { src: docker/image/web/Dockerfile }               # base
- { src: docker/image/web/Dockerfile.overlay }       # refined variant
- { src: docker/image/web/Dockerfile.final, dst: harness:/docker/image/web/Dockerfile }
```

Outcome: final file at harness path is `Dockerfile.final` contents (last mapping wins).

### 5. Splitting Logical Groups


Multiple `confd()` blocks can be used (if supported by tooling) to logically separate concerns:

```yaml
confd('harness:/'):
  - { src: base/scripts/common.sh }

confd('harness:/'):
  - { src: services/cache/config.sh }
```
(Blocks with identical prefixes are concatenated in order.)

### 6. Commenting Out Mappings


```yaml
# - { src: docker/image/legacy/Dockerfile }
```
Temporarily disables generation without deleting history.

 
## Ordering Rules & Strategy

- Top-to-bottom: last mapping to a given destination path overwrites earlier content.
- Prefer explicit final overwrite lines for clarity when layering.
- Group logically: base assets first, then overlays, then root-level conveniences.
- Avoid accidental silent overrides—rename intermediate files (e.g., `.overlay`, `.final`) to self-document intent.

 
## Best Practices

| Practice | Rationale |
|----------|-----------|
| Keep `src` paths stable | Minimises churn and merge noise |
| Use explicit `dst` only when needed | Reduces cognitive overhead |
| Layer with suffixes (`.overlay`, `.final`) | Signals processing order |
| Avoid large binary blobs | Keeps harness lean |
| Treat `.my127ws` as disposable | Encourages clean rebuilds |
| Rebuild after changes | Ensures mapping reflects latest intent |

 
## Troubleshooting

| Symptom | Possible Cause | Fix |
|---------|----------------|-----|
| File missing in `.my127ws/` | Mapping omitted or comment left | Re-add / uncomment line, rebuild |
| Wrong file contents | Later override mapping present | Inspect ordering; adjust or remove override |
| Root file not updated | Stale local copy | Rebuild harness; delete old file manually if necessary |
| Template not found | Included `.twig` in `src` so loader searched for `*.twig.twig` | Remove the `.twig` suffix in `src` |
| Unexpected literal `{{ ... }}` in output | Twig not parsed (file not declared in `confd.yml` or wrong path) | Add correct mapping entry and rebuild |
| Permission issues on scripts | Mode lost on copy | Re-`chmod +x` after rebuild or adjust tooling support |

 
## Extending

Add new mappings at logical grouping locations. For multi-env variants, you can
create environment-specific overlay mappings (e.g.,
`docker/image/web/Dockerfile.prod`) and conditionally switch via separate
`confd` blocks (subject to tooling capabilities) or by having your build
scripts swap the chosen mapping.

 
 
## FAQ

**Q: Do I need multiple `confd()` blocks?**  
A: Only if you want conceptual separation; a single block works functionally.

**Q: Can I template files before placement?**  
**A:** Yes. All `src` entries are treated as Twig templates; the `.twig` suffix is implied, rendered, then stripped for the destination unless you override with `dst`.

**Q: Are `.j2` Jinja2 templates supported?**  
**A:** No—only Twig is supported. Use `.twig` template files.

**Q: How does rendering actually work?**  
**A:** `Installer::applyConfiguration()` and `Refresh::applyConfiguration()` call `ConfdFactory::create($path)->apply()`. The resulting `Confd` instance appends `.twig`, renders, and writes the output (see `my127\Workspace\Types\Confd\Confd::apply`).

**Q: How do overrides / layering work?**  
**A:** Harness packages are extracted into `.my127ws` in layer order (base first, later layers overwrite). Overlay directories (if present) then rsync on top. When `confd` runs, it sees the merged template tree; later mappings in a single file still follow last-write-wins ordering. To override a template, supply a file at the same path in a later harness layer or overlay.

**Q: Where do I edit mappings?**  
**A:** Edit `tools/workspace/harness/config/confd.yml`. This is copied/consumed during the prepare step; the generated copy under `.my127ws/` is ephemeral.

**Q: What happens if two blocks map the same destination?**  
A: The later mapping in the file wins (last write wins ordering).


## Deep Dive: Layering & Ephemeral Realisation

### 0. What is "confd processing"?

In this documentation, "confd processing" refers
to the internal Workspace engine that reads the mapping declarations from
`confd.yml`, loads the corresponding Twig template files, renders them with the
current attribute / expression context, and writes the realised files into the
ephemeral harness tree (`.my127ws/`) or the workspace root. It is implemented by
the PHP classes under `workspace/src/Types/Confd/`:

- `DefinitionFactory` – parses `confd('<prefix>')` blocks into `Definition` objects.
- `Factory` (a.k.a. `ConfdFactory`) – creates a `Confd` instance with a Twig environment rooted at the prefix path (e.g. `harness:/`).
- `Confd` – iterates each mapping, applies conditional `when:` expressions, appends `.twig` to `src`, renders, and writes the destination file.

Triggers (indirect): the installer call in `Installer::applyConfiguration()` is
invoked during the `prepare` step of the harness lifecycle (see below on
`ws harness prepare`). Any command that cascades through the install steps (e.g.
`ws enable`, `ws rebuild`, or directly `ws harness prepare`) will cause a fresh
confd render if the step reaches `prepare`.

Key properties of confd processing:

1. Idempotent: re-running produces the same output given the same inputs.
2. Layer-aware: operates on the already merged (downloaded + overlay-applied) template tree.
3. Deterministic ordering: mapping order defines last-writer for collisions.
4. Contextual: templates have access to workspace attributes and expression functions.
5. Ephemeral output: never edit generated files directly—change the template or mapping instead.

### 1. Filesystem Layering (Harness Stack)

When you declare a harness in `workspace.yml`, the system may reference multiple harness packages (base first, then more specific). Install step sequence:

1. Download/extract each harness package (tarball) into `.my127ws` in the declared order. Later packages overwrite existing files path-by-path.
2. If an overlay directory is defined (e.g. a project-specific customisations path), it is rsynced on top (see `Installer::applyOverlayDirectory()`).
3. At this point, `.my127ws/` represents the merged, effective template tree used by `confd` processing.

Practical implication: To override a template, supply a file at the same relative path in a later harness layer or overlay—no special configuration flags are required.

### 2. Mapping Resolution (`requiredConfdPaths`)

Harness definitions can declare "required confd paths". During the `prepare`
step, the installer calls:

```php
Installer::applyConfiguration($this->harness->getRequiredConfdPaths())
```

Each path passed to `ConfdFactory::create($path)` corresponds to a directory prefix (e.g. `harness:/`). The factory builds a Twig environment rooted at that directory and the associated `Definition` (from parsing `confd()` declarations) supplies the mapping list.

> **Important – Current Design Constraint**
>
> The set of confd roots that are processed is **only** what the harness
> definition exposes via `Harness::getRequiredConfdPaths()` (see
> `workspace/src/Types/Harness/Definition.php`). There is **no automatic file
> system scanning** for arbitrary `confd.yml` files elsewhere in a project, and
> there is currently **no workspace-level (non-harness) directive** that adds
> extra confd roots. If you place a `confd.yml` outside of the harness (or have
> no harness at all) it will be ignored unless you:
>
> 1. Introduce a minimal local harness that declares the desired confd path(s).
> 2. Or implement a custom command that manually instantiates and runs the
>    Confd pipeline (advanced / internal API usage).
>
> This deliberate limitation preserves determinism (only declared harness
> layers participate), avoids performance and security issues from unintended
> template discovery, and keeps layering semantics explicit. A future
> enhancement could add a `standaloneConfd:` style configuration to
> `workspace.yml`, but that does **not** exist at present.


### 3. Rendering Order & Last-Write Wins

Inside a single `confd()` block, mappings are processed top-to-bottom. If multiple mappings target the same destination (explicit `dst` or implicit from `src`), the later one overwrites earlier rendered output. Across harness layers, the *file presence* is already decided before rendering; only the merged final tree participates. Thus, layering first, then mapping order.

### 4. Ephemeral vs Authoritative Sources

Authoritative (human-edited) mapping file: `tools/workspace/harness/config/confd.yml` in your project repository. Ephemeral realised copy (and all rendered outputs): under `.my127ws/`. You should not commit `.my127ws`—it is a build artifact and can always be recreated by reinstalling or refreshing the harness.

Key advantages of ephemerality:

- Safe experimentation: edit templates and re-run prepare/refresh without polluting VCS.
- Deterministic regeneration ensures consistency across machines.
- Clean separation between *intent* (template + mapping) and *state* (rendered files).

### 5. Common Override Strategies

| Goal | Strategy | Example |
|------|----------|---------|
| Replace base Dockerfile | Add new file in later harness layer with same relative path | Provide customised `docker/image/web/Dockerfile` in overlay |
| Provide environment-specific variant | Introduce suffix (e.g. `.overlay`, `.final`) and map explicitly | Map `Dockerfile.final` to destination `Dockerfile` |
| Adjust only a small section | Use template inheritance (Twig `include`/`import`) instead of copy-paste | Keep shared logic in `_partial.conf.twig` |
| Remove an inherited file | Override with empty template or modify consuming config to ignore | Provide empty file to neutralise behaviour |

### 6. Diagnostics Checklist

- Is the override file physically present in `.my127ws` after install? If not, layer ordering or extraction path is wrong.
- Does `confd.yml` contain the expected mapping entry? If absent, template won't be rendered.
- Did you accidentally include `.twig` in `src`? Loader will look for `*.twig.twig`.
- Conflict between two mappings? Ensure only the intended final mapping targets the destination.

### 7. Recreating a Clean State

To fully rebuild after structural template changes:

```bash
ws disable
rm -rf .my127ws
ws enable
```

This guarantees a fresh extraction + render cycle.

### 8. Overlay Directory – Definition & Use

An "overlay directory" is an optional project-local directory whose contents
are copied on top of the downloaded harness packages *after* extraction but
*before* confd processing. This lets you override or add template files without
forking the upstream harness package.

Resolution flow (simplified):

1. Download harness layer tarballs into `.my127ws/` (first layer → last layer).
2. If an overlay path is configured in `workspace.yml`, rsync its contents into `.my127ws/` (last write wins per file path).
3. Run confd processing (render templates from the merged tree).

How to configure:

You specify the overlay directory path (relative to the workspace root) via the
`overlay` attribute on the workspace definition in `workspace.yml`. (If this
attribute is absent, no overlay step runs.) Example:

```yaml
workspace('my-app'):
  harness: inviqa/php
  overlay: tools/workspace
```

Directory structure example:

```text
workspace.yml
tools/workspace/
  docker/image/web/Dockerfile            # overrides harness version
  scripts/custom.sh                      # new file
```

During install step `overlay`, the engine executes (from code):

```php
applyOverlayDirectory($overlayPath); // rsync -a workspace:/overlayDir -> harness:/
```

Practical notes:

- Overlay precedes confd render, so replaced template stems will be used.
- You can remove a file by overlaying an empty file (or adjust consuming config to ignore it).
- Overlay is additive and overwriting only; deletions of existing harness files (by omission) are not performed—rsync copies what exists.

### 9. `ws harness prepare` Command

`ws harness prepare` is a convenience command that executes just the overlay
and prepare steps of the harness installer pipeline (without repeating the
initial download if already present). Internally it runs:

```bash
ws install --step=overlay
ws install --step=prepare
```

This means:

1. Apply overlay directory (if configured) – step `overlay`.
2. Run confd processing (render templates) – step `prepare`.

When to use it:

- After editing template files or mapping declarations where you do NOT need to re-download harness packages.
- After modifying overlay files to refresh generated outputs quickly.

Relation to other commands:

| Command | Includes Overlay? | Includes Prepare (confd)? | Re-downloads Harness? | Typical Use |
|---------|-------------------|---------------------------|------------------------|-------------|
| `ws harness prepare` | Yes | Yes | No (unless missing) | Fast re-render after local template changes |
| `ws enable` | Yes (via install cascade) | Yes | Only if first run | Start environment from scratch |
| `ws rebuild` | Yes | Yes | May (depending on implementation) | Recreate environment artifacts |
| `ws harness download` | No | No | Yes | Force refresh of harness packages only |

If you only changed application runtime state (containers, data) you do *not*
need `harness prepare`. If you changed template sources, overlay files, or
`confd.yml`, then `harness prepare` (or a broader command that includes it) is appropriate.

## Referencing in Other Docs

Link: `[Harness File Materialisation (confd.yml)](harness-confd-file-mappings.md)`
wherever contributors need to understand how files appear under `.my127ws/` or
why root files exist without being explicitly committed.

 
## Change Log

(Initial version) – Introduced explanation of purpose, syntax, layering, examples, best practices, and troubleshooting.
(Update – Added template rendering pipeline, override mechanics, Twig-only clarification, and troubleshooting entries.)
(Update – Added cross-links, clarified confd processing definition, overlay directory configuration, and `ws harness prepare` behavior.)
