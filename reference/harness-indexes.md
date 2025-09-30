# Harness Indexes in Workspace

Workspace discovers harness packages through **indexes** (JSON catalogs) that
map a package name to one or more distributable versions. This guide explains
how indexes work, how Workspace consumes them, and how to publish your own
catalog for internal harnesses.

## 1. Concepts Recap

* **Harness package** – Named, versioned archive or directory (for example
  `my127/php:v1.13.0`).
* **Repository source** – URL (HTTP/HTTPS/local path) that returns the index
  JSON document.
* **Index JSON** – Map of package names to version metadata (dist type + URL).
* **`harness.repository.source`** – Workspace DSL used to register sources.

The default Workspace distribution declares a single source named `my127` that
points at `https://my127.io/workspace/harnesses.json`.

## 2. Resolution Flow

When Workspace needs to realise a harness (for example during `ws install`), it
follows these steps:

1. Load all registered sources from configuration (`harness.repository.source`).
1. Fetch each JSON document once per invocation and merge the maps.
1. Resolve the requested package (`vendor/name[:version]`).

   * If no version is specified, Workspace uses a wildcard (`vx.x.x`) to pick
    the highest compatible version.

1. Download or copy the dist defined for the chosen version (`tar`, `zip`, or
  `path`).
1. Extract the archive into `.my127ws/` and continue with overlay/confd steps.

If the package cannot be found, Workspace throws an `UnknownPackage` exception
and lists all registered names to help with debugging.

## 3. Anatomy of an Index JSON

```jsonc
{
  "acme/php": {
    "v1.0.0": {
      "dist": {
        "type": "tar",
        "url": "https://internal.example.com/acme-php/v1.0.0.tar.gz"
      }
    },
    "v1.1.0": {
      "dist": {
        "type": "tar",
        "url": "https://internal.example.com/acme-php/v1.1.0.tar.gz"
      }
    }
  },
  "acme/minimal": {
    "v0.1.0": {
      "dist": {
        "type": "path",
        "url": "./packages/acme/minimal"
      }
    }
  }
}
```

Guidelines:

* **Keys must be unique:** each `vendor/name` entry overrides any previous one
  from earlier sources.
* **Version strings** must follow the `vMAJOR.MINOR.PATCH` pattern. Wildcard
  resolution requires all numeric segments.
* **Dist options:**
  * `type: tar` / `zip` – URL must return an archive. Workspace downloads and
    extracts it.
  * `type: path` – URL points at an existing directory (absolute, relative to
    the workspace, or `file://`). Workspace copies the directory contents.

## 4. Publishing Your Own Index

1. **Author the JSON**

    * Start from the template above; add entries for each harness version.
    * Check in the file to a repository (for example `tools/harnesses.json`).
    * Optionally automate generation during your release pipeline.

1. **Host the catalog**

    * Serve it over HTTPS for teams that need remote access.
    * Or keep it alongside the workspace repository and reference it via
      `file://` or a relative path (ideal for air-gapped setups).

1. **Register the source** in your `workspace.yml`:

   ```yaml
   harness.repository.source('acme'): file://./tools/harnesses.json

   workspace('my-app'):
     harness:
       use:
         - acme/php:v1.1.0
   ```

1. **Distribute dist artifacts**

    * Archive the harness directory (`tar -czf build/acme-php-v1.1.0.tar.gz harness/`).
    * Upload to the URL referenced in the JSON (or keep it inside the repo when
      using `file://`).

1. **Test the setup**

    * Run `ws harness prepare` (or `ws install`) to trigger resolution.
    * Inspect `.my127ws/.acme-php-v1.1.0` (or similar) to confirm the contents.
    * Use the `harness list` command (if available) or add diagnostic output to
      your installer override.

## 5. Mirroring / Replacing the Default Index

You can override the built-in `my127` source by re-declaring it:

```yaml
harness.repository.source('my127'): https://mirror.internal/workspace/harnesses.json
```

Declaration order matters; when multiple sources provide the same package,
versions from later sources augment the set.

## 6. Troubleshooting

* **`UnknownPackage` error** – Package absent or misnamed in the index.
  Confirm the JSON key (for example `vendor/name`).
* **`Could not load from source`** – URL unreachable or malformed. Curl the
  endpoint or check proxy/auth configuration.
* **Unexpected harness version** – No explicit version supplied, so the
  wildcard resolved to the latest. Pin a specific version (for example
  `vendor/name:vX.Y.Z`).
* **Local path ignored** – `dist.url` points at the wrong directory. Use an
  absolute path or a `file://` URL.

## 7. When You Do *Not* Need an Index

If you maintain the entire harness inside your project repository, you can
bypass indexes by implementing a **local realisation workflow**. See
See [Local Harness Pattern](../guides/local-harness.md) for the confd-driven approach
and command overrides that keep everything local without publishing JSON
catalogs.
