# Harness Registration & Repository Sources

This document explains **how harness packages are discovered, registered, and
resolved** by the Workspace tool, and how you can extend or override the
default set of harnesses.

## 1. Concepts

| Term | Meaning |
|------|---------|
| Harness Package | Versioned set of harness templates + config (e.g. `inviqa/php`, `my127/empty`). |
| Repository Source | JSON index URL defining harness packages + versions. |
| Registered Package | Harness whose metadata is loaded into the in‑memory package map. |
| Local / Fake Harness | Developer-created harness folder not published in a repository. |

## 2. Core Classes Involved

| File | Role |
|------|------|
| `workspace/src/Types/Harness/Repository/PackageRepository.php` | Maintains in‑memory map of harness packages and resolves versions. |
| `workspace/src/Types/Harness/Repository/Source/Builder.php` | Adds declared repository sources to the `PackageRepository`. |
| `workspace/src/Types/Harness/Repository/Source/DefinitionFactory.php` | Parses DSL declarations (`harness.repository.source('name'): <url>`). |
| `workspace/src/Types/Harness/Repository/Source/Definition.php` | Data object for a source. |
| `workspace/src/Types/Workspace/Builder.php` | Registers harness CLI commands only if a harness is present. |

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

### Multiple Sources

Merged in declaration order. Later sources may add packages or new versions.

## 7. Local / “Fake” Harness Strategies

| Strategy | Pros | Cons |
|----------|------|------|
| Use existing `my127/empty` | Zero setup | Different name |
| Publish JSON index | Scales; proper namespace | Requires hosting |
| `path` dist entry | Simple local dev | Manual JSON authoring |
| Custom render script | Full control | Outside official flow |

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

| Type | Meaning | Handling |
|------|---------|----------|
| `tar` / `zip` | Remote archive | Download → extract |
| `path` | Local directory | Symlink / copy |

## 9. Diagnosing “Package Not Registered” Errors

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Long package list, yours absent | Typo in name | Correct `use:` value |
| Only a few packages listed | Missing sources | Add declarations |
| Custom package missing | JSON not reachable | Verify URL/path |
| Command absent | No `harness:` block | Add stanza |

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

| Goal | Step |
|------|------|
| Add internal harness | Publish JSON → declare source |
| Local dev harness | JSON with `dist.type=path` |
| Just test commands | `harness.use: my127/empty` |
| Debug failure | Run command → read *UnknownPackage* list |

---
*Document clarifying harness registration and repository extensibility.*
