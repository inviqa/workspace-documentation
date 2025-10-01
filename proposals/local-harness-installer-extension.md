# Proposal: First-Class Support for Embedded Local Harnesses

<!-- TOC -->
## Table of Contents

- [Summary](#summary)
- [Background](#background)
- [Goals](#goals)
- [Non-Goals](#non-goals)
- [Proposal Outline](#proposal-outline)
- [Migration Path](#migration-path)
- [Risks and mitigations](#risks-and-mitigations)
- [Next Steps](#next-steps)

<!-- /TOC -->


## Summary

Projects that incubate harness logic inside their repository currently build
a bespoke `ws install` override to avoid contacting remote harness catalogs.
The newly drafted override in `workspace-documentation/snippets/install-local-harness.yml`
proves the approach is viable but heavy. This proposal distils the behaviour
into small, reusable enhancements that could ship with Workspace itself.

## Background

- **Local harness pattern:** teams keep their harness sources under
  `harness.path` while iterating.
- **Current limitation:** the stock installer always resolves harness layers
  via `PackageRepository`, meaning every install requires a JSON catalog entry
  even when the harness resides locally.
- **Workaround:** override the `install` command, reimplement lifecycle steps,
  and manually extract tarballs or copy directories (see the snippet).

The workaround is functional but roughly 400 lines of YAML + PHP. Providing a
first-class extension point would eliminate the need for per-project clones of
that logic.

## Goals

1. Let `ws install` operate solely on locally declared harness layers when
   desired.
2. Avoid per-project command overrides while keeping lifecycle semantics
   identical (events, cascading steps, validation, confd rendering, services).
3. Support both `tar.gz` archives and plain directories as local harness
   sources, without requiring a JSON repository.
4. Preserve existing behaviour by default; the new feature must be opt-in.

## Non-Goals

- Replacing remote repository support.
- Changing how overlays or triggers work.
- Altering `ws harness prepare` semantics (it should continue to call into the
  installer with `--step=overlay`/`--step=prepare`).

## Proposal Outline

### 1. Add a Local Package Resolver

Introduce an additional resolver that inspects workspace attributes before
falling back to `PackageRepository`. Sketch:

```php
interface HarnessResolver
{
    public function supports(string $layer): bool;
    public function resolve(string $layer): Package; // Package has `dist` info
}
```

- **LocalHarnessResolver** reads a new attribute block, e.g.
  `workspace.attributes.local_harness.packages`.
- **RepositoryResolver** remains the existing `PackageRepository` path.
- `Installer` asks each resolver in order until one returns a package.

### 2. Extend Package Dist Types

The existing `Package` value object already accepts `dist.type` and `dist.url`.
Ensure the core loader accepts:

- `type: tar`, `url: workspace:/path/to/archive.tar.gz`
- `type: dir`, `url: workspace:/local-harness`

This mirrors the workaround and keeps compatibility with remote archives.

### 3. Attribute Contract

Support a concise schema in `workspace.yml`:

```yaml
attributes:
  local_harness:
    packages:
      - name: my127/local-app
        source: workspace:/tools/harness/local-app.tar.gz
        type: tar
        strip: 1
```

Optional flags:

- `strip` (defaults to `1`).
- `version` (defaults to the version requested in `harness.use`).
- `reset_before_download` (defaults to `true`).

The resolver can cache the parsed list for the duration of an install run.

### 4. Installer Updates

- Inject resolvers into `Installer` (constructor or a small locator).
- Replace the direct `PackageRepository::get()` call with a helper that loops
  through resolvers.
- Keep download/overlay/prepare logic intact, reusing the current private
  methods (the override reimplementations can guide the tar/rsync steps).

### 5. Optional CLI Enhancements

- Add `ws harness sources --local` to display configured local packages.
- Emit a short message during `--step=download` indicating whether the package
  came from a local or remote source for debugging.

## Migration Path

1. Implement the resolver + installer changes.
2. Document the new attribute block in `local-harness.md` and
   `building-a-harness.md`.
3. Encourage projects using the override snippet to migrate back to the stock
   installer by populating `attributes.local_harness.packages`.
4. Deprecate the snippet once adoption confirms parity.

## Risks and mitigations

- **Attribute collisions:** scope keys under `local_harness.*` to avoid
  interfering with existing attributes.
- **Extraction failures:** reuse the override's messaging so tar/rsync exit
  codes bubble up with clear context.
- **Behaviour drift:** add regression tests covering remote + local paths and
  cascade sequencing.

## Next Steps

- Socialise with Workspace maintainers, linking both this proposal and the
  override snippet for context.
- If accepted, derive a smaller merge request that introduces the resolver and
  associated tests.
- Retain the override document as a fallback until the core feature ships.
