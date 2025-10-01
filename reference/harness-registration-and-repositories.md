# Harness Registration & Repository Sources

This document explains **how harness packages are discovered, registered, and
resolved** by the Workspace tool, and how you can extend or override the
default set of harnesses.

## 1. Concepts

| Term | Meaning |
|------|---------|
| Harness Package | Versioned harness set (e.g. `inviqa/php`, `my127/empty`) |
| Repository Source | JSON index listing packages + versions |
| Registered Package | Metadata loaded into in-memory map |
| Local / Fake Harness | Repo harness dir not published to shared repo |

## 2. Core Classes Involved

| File | Role |
|------|------|
| `.../Repository/PackageRepository.php` | In-memory map & version resolution |
| `.../Repository/Source/Builder.php` | Adds source URLs to repository |
| `.../Repository/Source/DefinitionFactory.php` | Parses source DSL defs |
| `.../Repository/Source/Definition.php` | Source definition value object |
| `.../Types/Workspace/Builder.php` | Registers commands when harness present |

## 3. Package Registration Flow

1. Parse configuration (collect any `harness.repository.source(...)`).
2. Register each source URL via `PackageRepository::addSource()`.
3. On first harness use:
   - Load JSON indexes (`importPackagesFromSources()`), once per source.
   - Merge JSON structures into the `$packages` map.
4. Resolve `harness.use:` (e.g. `inviqa/php:v1.2.3` or `inviqa/php`). Highest
compatible version chosen if none specified.
5. Unknown vendor/name → throw *UnknownPackage* and list registered packages.

### JSON Structure (Conceptual)

```jsonc
{
  "inviqa/php": {
    "v1.12.0": { "dist": { "type": "tar", "url": "https://.../v1.12.0.tar.gz" } },
    "v1.13.0": { "dist": { "type": "tar", "url": "https://.../v1.13.0.tar.gz" } }
  },
  "my127/empty": {
    "v0.0.1": { "dist": { "type": "path", "url": "./vendor/my127/empty" } }
  }
}
```

## 4. Harness Version Resolution

`PackageRepository::resolvePackageVersion()`:

- Accepts explicit versions like `v1.2.3`.
- Uses wildcard pattern (`vx.x.x`) internally when version omitted; selects
highest compatible.
- Matches numeric segments; `x` is a wildcard.
- Fails with *UnknownPackage* if no package or no matching version.

## 5. Why `ws harness prepare` Might Be Missing

The command is registered only if `Workspace::hasHarness()` returns true. If a
declared harness cannot be resolved, the command may still appear but fails
early with *UnknownPackage*. Without any `harness:` stanza it is not
registered.

## 6. Declaring Repository Sources

Add JSON repositories using the DSL parsed by `DefinitionFactory`:

```yaml
harness.repository.source('internal'): https://internal.example.com/harnesses.json
```

Each declaration becomes a `Definition` whose URL is passed to
`PackageRepository::addSource()`. JSON loads lazily on first resolution.

### 6.1 Default Built-In Source (`my127`)

Out of the box the Workspace tool seeds one repository source via the config
file `workspace/config/harness/packages.yml` in the core distribution:

```yaml
harness.repository.source('my127'): https://my127.io/workspace/harnesses.json
```

That single line is the *only* built-in harness catalog reference. There is no
hard‑coded fallback in PHP—remove or override it and the remote package list
disappears until you add another source.

Reference chain proving how it is used:

1. **DSL Parse** – `Source/DefinitionFactory.php` stores the raw body as `url`.
2. **Environment Build** – `Source/Builder.php` calls
   `PackageRepository::addSource($definition->getUrl())`.
3. **Lazy Import** – On first package resolution,
   `PackageRepository::importPackagesFromSources()` loads each URL exactly
   once.
4. **JSON Fetch** – `JsonLoader::loadArray()` → `FileLoader::load()` →
   `file_get_contents(…)` (no scheme filtering).

If that URL is unreachable you will see a `CouldNotLoadSource` exception when
resolving a harness.

#### Overriding or Mirroring

To point at an internal mirror (e.g., for air‑gapped environments):

```yaml
# Replace the default (order matters if both present)

<!-- TOC -->
## Table of Contents

- [1. Concepts](#1-concepts)
- [2. Core Classes Involved](#2-core-classes-involved)
- [3. Package Registration Flow](#3-package-registration-flow)
- [4. Harness Version Resolution](#4-harness-version-resolution)
- [5. Why `ws harness prepare` Might Be Missing](#5-why-ws-harness-prepare-might-be-missing)
- [6. Declaring Repository Sources](#6-declaring-repository-sources)
- [7. Local / “Fake” Harness Strategies](#7-local-fake-harness-strategies)
- [8. Dist Types](#8-dist-types)
- [9. Diagnosing “Package Not Registered” Errors](#9-diagnosing-package-not-registered-errors)
- [10. Frequently Asked Questions](#10-frequently-asked-questions)
- [11. Future Enhancements (Potential)](#11-future-enhancements-potential)
- [12. Quick Checklist](#12-quick-checklist)

<!-- /TOC -->

harness.repository.source('my127'): https://mirror.internal/workspace/harnesses.json
```

Or add a second catalog under a different logical name:

```yaml
harness.repository.source('internal'): https://mirror.internal/internal-harnesses.json
```

Resolution merges catalogs; duplicate package names aggregate their versions.

#### Verifying at Runtime

You can force early loading and verify connectivity:

```fish
# Trigger resolution (lists error if missing/unreachable)
# Trigger resolution (lists error if missing/unreachable)
ws harness prepare 2>&1 | grep -i "Could not load from source" || echo "Source reachable"

# Manually inspect first few bytes of the catalog
# Manually inspect first few bytes of the catalog
curl -I https://my127.io/workspace/harnesses.json | head -n 5
curl -s https://my127.io/workspace/harnesses.json | head
```

If using a local file mirror:

```fish
cp harnesses.json ./cache/harnesses.json
harness.repository.source('my127'): ./cache/harnesses.json
```

#### Security & Reliability Notes

- Treat the catalog as *untrusted input*—only dist URLs you trust should be
  used in production.
- Consider pinning explicit versions (`vendor/harness:vX.Y.Z`) in long‑lived
  projects to avoid silent upgrades.
- For disaster recovery, cache the JSON and referenced archive artifacts.
- A future enhancement could add checksum fields to each dist entry for
  integrity verification.

### Multiple Sources

Merged in declaration order. Later sources may add packages or new versions.

## 7. Local / “Fake” Harness Strategies

Use existing `my127/empty`  
: Zero setup.  
− Different name.

Publish JSON index  
: Scales; proper namespace.  
− Requires hosting.

`path` dist entry  
: Simple local dev.  
− Manual JSON authoring.

Custom render script  
: Full control.  
− Outside official flow.

### Minimal JSON for a Local Harness

If `dist.type: path` is supported, craft `local-harnesses.json`:

```json
{
  "my127/fake": {
    "v0.0.1": { "dist": { "type": "path", "url": "./harness" } }
  }
}
```

Declare and use it:

```yaml
harness.repository.source('local'): file://./local-harnesses.json

harness:
  use: my127/fake
```

> `file://` handling depends on the loader; fallback to absolute path or HTTP
if unsupported.

## 8. Dist Types

`tar` / `zip`  
: Remote archive.  
→ Download then extract.

`path`  
: Local directory.  
→ Symlink or copy.

## 9. Diagnosing “Package Not Registered” Errors

Long package list, yours absent  
→ Typo in name.  
Fix: Correct `harness.use` value.

Only a few packages listed  
→ Missing sources.  
Fix: Add source declarations.

Custom package missing  
→ JSON not reachable.  
Fix: Verify URL / path access.

Command absent  
→ No `harness:` block.  
Fix: Add harness stanza.

## 10. Frequently Asked Questions

**Does placing `harness/harness.yml` auto‑register a harness?**  
No. Registration occurs only via repository sources.

**Can I override an existing package?**  
Add a source supplying a higher version or earlier declaration order.

**Need template rendering only?**  
Use `my127/empty` or replicate `Confd::apply()` logic.

## 11. Future Enhancements (Potential)

- Inline path DSL (e.g. `harness.repository.path('my127/fake'): ./harness`)
- List sources command (`ws harness sources`)
- Runtime add-source (`ws harness add-source <url>`)

## 12. Quick Checklist

Add internal harness  
→ Publish JSON and declare a source.

Local dev harness  
→ JSON with `dist.type=path`.

Just test commands  
→ `harness.use: my127/empty`.

Debug failure  
→ Run command; read *UnknownPackage* list.

---
*Document clarifying harness registration and repository extensibility.*
