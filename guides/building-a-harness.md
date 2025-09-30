# Building a Reusable Workspace Harness

<!-- TOC -->
## Table of Contents

- [Status](#status)
- [Should You Create a New Harness?](#should-you-create-a-new-harness)
- [Prerequisites](#prerequisites)
- [Authoritative Layout (Incubation Phase)](#authoritative-layout-incubation-phase)
  - [3.1 Minimal Starter (Ultra-Lean)](#31-minimal-starter-ultra-lean)
  - [3.2 Full Featured Reference Layout](#32-full-featured-reference-layout)
  - [3.3 Overlay vs Skeleton (Summary)](#33-overlay-vs-skeleton-summary)
  - [Layout FAQ & Rationale](#layout-faq--rationale)
- [harness.path → Path-Based Development](#harnesspath--path-based-development)
- [`confd.yml` Design](#confdyml-design)
- [Attributes & Configuration Structure](#attributes--configuration-structure)
- [Commands (`commands.yml`)](#commands-commandsyml)
- [Functions (`functions.yml`)](#functions-functionsyml)
- [Events (`events.yml`)](#events-eventsyml)
- [Pipeline & Build (`pipeline.yml`)](#pipeline--build-pipelineyml)
- [External Image / Dependency Helpers](#external-image--dependency-helpers)
- [Secrets & Security](#secrets--security)
- [Helm / Deployment Assets (Optional)](#helm--deployment-assets-optional)
- [Quality Gates & Testing](#quality-gates--testing)
- [From Path Harness to Packaged Harness](#from-path-harness-to-packaged-harness)
- [`harness.yml` Manifest](#harnessyml-manifest)
- [Versioning & Changelog](#versioning--changelog)
- [Backwards Compatibility Contract](#backwards-compatibility-contract)
- [Publishing Workflow (Example)](#publishing-workflow-example)
- [Consumer Upgrade Checklist](#consumer-upgrade-checklist)
- [Deprecation Policy](#deprecation-policy)
- [Security & Hardening Guidelines](#security--hardening-guidelines)
- [Migrating from Local Harness Pattern](#migrating-from-local-harness-pattern)
- [FAQ (Focused)](#faq-focused)
- [See Also](#see-also)

<!-- /TOC -->

## Status

Draft – end-to-end guide for creating, iterating, and publishing a
new harness.

Goal: Provide a canonical process from **local path-based incubation** →
**packaged, versioned harness** resembling existing first-party harnesses,
using `harness-php` as a structural reference (language specifics omitted).

## Should You Create a New Harness?

| Consideration | Create New Harness | Reuse / Extend Existing |
|---------------|--------------------|--------------------------|
| Technology stack fundamentally different | Yes | - |
| Need only a few templated files | No (use Local Harness Pattern) | - |
| Want to generalise a pattern used across >1 project | Yes | - |
| Only project-specific tweaks to an existing harness | - | Overlay or fork |
| Long-term maintenance capacity available | Yes | - |

Decision heuristic: **Start with a Local Harness**. Graduate to a reusable
harness when a second project or team wants it or when abstraction reduces
duplication.

## Prerequisites

- Current Workspace CLI (ensure contributors share a baseline version).
- Familiarity with: `confd.yml` mappings, `workspace.yml` structure, attributes
  & expressions.
- Optional: container tooling (Docker), Helm (if you ship charts), or any
  domain-specific orchestrations you include.

## Authoritative Layout (Incubation Phase)

During incubation you keep sources inside the consuming repository via
`harness.path`. Below is a layout that **faithfully mirrors the real
first‑party harness directory model** (using `harness-php` as the structural
reference) while stripping language / stack specific file content. Retain the
shape even if you start with many empty files – it makes promotion to a
packaged harness smoother.

### 3.1 Minimal Starter (Ultra-Lean)

Use this if you want the **absolute minimum viable harness** to get rendering
and a single custom command working. Grow toward the full layout only when a
real need appears.

```text
local-harness/
  harness/
    config/
      confd.yml          # required: maps templates
      commands.yml       # optional: a single helper command
    attributes/
      common.yml         # optional: a few defaults (namespace, etc.)
```

Example minimal `confd.yml`:

```yaml
confd('harness:/'):
  - { src: harness/scripts/enable.sh }
```

You can defer adding `harness.yml` until you publish.

### 3.2 Full Featured Reference Layout

```text
local-harness/
  harness.yml                      # (only once you publish; omit at very start)
  README.md                        # root readme for the harness itself
  LICENSE                          # choose a license if distributing
  docker-compose.yml.twig          # main compose template (optional initially)
  docker-sync.yml.twig             # sync tooling template (optional)
  mutagen.yml.twig                 # mutagen config template (optional)
  _twig/                           # global twig helpers
    docker-compose.yml/            # sub-helper dirs (keep if you need advanced composition)
      application.yml.twig         # application amalgamation layer
      environment.yml.twig         # environment conditional fragments
      service/                     # per-service compose fragments
        console.yml.twig
        cron.yml.twig
        nginx.yml.twig
        relay.yml.twig
        webapp.yml.twig
  application/
  overlay/                       # project bootstrap overlay (scaffolding +
                   # CI bits)
      Jenkinsfile.twig             # CI pipeline example (generic)
      auth.json.twig               # credentials placeholder
  .dockerignore.twig           # overlay dockerignore (rendered to
               # workspace root)
      _twig/
        .dockerignore/             # split dynamic/static fragments example
          dynamic.twig
          static.twig
    skeleton/
      README.md.twig               # README fragment for newly bootstrapped app
  docker/
    image/                         # image build contexts (multi-service capable)
      console/                     # generic "console" / toolbox image
        .dockerignore
        Dockerfile.twig
        root/
          entrypoint.sh.twig
          entrypoint.dynamic.sh    # (optional dynamic stub)
          home/
            build/
              .my.cnf.twig         # example of small config artefact
          lib/
            functions.sh           # shared shell helpers
            sidekick.sh            # auxiliary logic script
            task/                  # task scripts grouped logically
              init.sh.twig
              install.sh.twig
              migrate.sh.twig
              welcome.sh.twig
              build/
                frontend.sh.twig
                backend.sh.twig
              database/
                import.sh.twig
              composer/
                install.sh.twig
              overlay/
                apply.sh           # example non‑templated script
          usr/
            local/
              bin/
                send_mail          # utility binary / script placeholder
      web/                          # example runtime service
        Dockerfile.twig
        root/
          etc/                     # service config tree
      worker/                       # (optional additional runtime service)
        Dockerfile.twig
      proxy/                        # (example reverse proxy service)
        Dockerfile.twig
  helm/                             # optional helm charts / deployment blueprints
    app/
      Chart.yaml.twig
      values.yaml.twig
      values-preview.yaml.twig      # (additional environment values)
      values-production.yaml.twig   # (additional environment values)
      _twig/
        templates/                  # example templated chart resources
          service/varnish/configmap.yaml.twig
    qa/
      Chart.yaml.twig
      values.yaml.twig
      requirements.yaml.twig        # (if you use legacy requirements pattern)
  .ci/                             # CI helper scripts / workflows (optional)
  harness/
    config/                         # harness runtime config (public-ish entrypoints)
      confd.yml                     # REQUIRED: maps templates -> materialised files
      commands.yml                  # developer command definitions
      functions.yml                 # custom expression & command functions
      events.yml                    # lifecycle hooks
      pipeline.yml                  # build / publish pipeline commands
      external-images.yml           # helper image pre-pull / compose augmentation
      secrets.yml                   # secret helper commands (placeholders, no secrets)
      docker-sync.yml               # additional sync config fragments (optional)
      mutagen.yml                   # additional sync config fragments (optional)
    attributes/
      common.yml                    # default attribute values
      docker-base.yml               # base docker attribute customisations
      environment/
        local.yml                   # local env overrides
        pipeline.yml                # CI / pipeline env overrides
    scripts/
      enable.sh.twig                # orchestrates initial enable steps
      disable.sh                    # disable hook script
      destroy.sh                    # destroy / tear‑down script
      docker_sync.sh                # helper for docker-sync (if used)
      mutagen.sh                    # helper for mutagen (if used)
  latest-mutagen-release.php    # (EXAMPLE: if you auto-resolve versions;
             # replace w/ generic helper)
  docs/
    README.partial.md.twig          # additional docs fragments for consumer project
  tools/
    test-golden-confd.sh            # golden output test script (if adopted early)
  tests/
    golden/
      confd/                        # stored rendered snapshot tree
```

Notes:

- Replace service directory names (`web`, `worker`, `proxy`) with
  domain‑relevant ones (e.g. `api`, `frontend`).
- Omit any directories you truly do not need – but the above mirrors a
  **full featured** harness shape so you understand where concerns live.
- Keep `harness/config/confd.yml` as the *only mandatory* file to start rendering.

Keep only what you will actually use. Everything above is optional except `harness/config/confd.yml`.

### 3.3 Overlay vs Skeleton (Summary)

| Aspect | `application/overlay/` | `application/skeleton/` |
|--------|------------------------|-------------------------|
| Purpose | Managed CI/auth/ignore bootstrap | One-time scaffold docs |
| Reapply | Yes (after harness upgrades) | Rarely (project takes ownership) |
| Delivery | Rendered via `confd`, then copied/applied | Rendered once on init |
| Typical Files | `Jenkinsfile`, `auth.json`, `.dockerignore` | README fragment |
| Ownership After Apply | Still harness-managed | Project-managed |

Introduce `application/overlay/` once you need centrally governed CI or
credential bootstrap across multiple projects. Start without it if unsure.

Deep dive: see [Application Overlay](application-overlay.md).

### Layout FAQ & Rationale

**Why separate `application/overlay` and `application/skeleton`?**  Overlay
seeds CI and bootstrap artefacts directly into a consumer project; skeleton
holds scaffold content (e.g. README fragment) used at project creation time.

**Why the `_twig/docker-compose.yml/service/*.yml.twig` fragments?**  This lets
you enable or disable services via attributes without editing a monolithic
compose file; each service fragment can be conditionally included.

**Do I need Helm directories from day one?**  No. Omit `helm/` until you have a
real deployment target or need chart templating.

**Why keep both `commands.yml` and shell scripts?**  Commands provide a stable
CLI contract; scripts encapsulate procedural logic. This separation simplifies
refactoring without breaking consumer habits.

**Should `harness.yml` duplicate attributes already in files?**  Only early on;
once the harness grows, centralise persistent defaults in
`harness/attributes/` and keep the manifest lean.

**How big before splitting into multiple harnesses?**  If unrelated stacks or
teams evolve at different cadences, create a dedicated harness per concern.

## `harness.path` → Path-Based Development

`workspace.yml` (consumer project):

```yaml
workspace('my-app'):
  harness:
    path: ./local-harness
  attributes:
    namespace: my-app
```

Advantages:

- Zero packaging overhead.
- Fast iteration: edit → `ws harness prepare` → inspect.
- Identical lifecycle semantics to a published harness.

## `confd.yml` Design

Guidelines:

- Group by destination root; use separate blocks for `harness:/` vs
  `workspace:/` when clarity helps.
- Omit `.twig` from `src` values (implicit extension).
- Use explicit `dst:` only when placing outside the mirrored path or switching
  root.
- Decompose complex scripts into separate files rather than giant inline
  templates.

Example minimal dual-root mapping:

```yaml
# local-harness/config/confd.yml
confd('harness:/'):
  - { src: harness/scripts/enable.sh }

confd('workspace:/'):
  - { src: docker-compose.yml }              # if you template it
  - { src: docs/README.partial.md, dst: workspace:/HARNESS-NOTES.md }
```

## Attributes & Configuration Structure

Organise defaults under `attributes/`. Example:

```yaml
# local-harness/attributes/common.yml
namespace: my-app
services:
  web:
    enabled: true
  worker:
    enabled: false

# local-harness/attributes/environment/local.yml
services:
  worker:
    enabled: true
```

Resolution:

1. Core harness attributes (common.yml, etc.).
2. Environment-specific overlays.
3. User/project overrides (e.g. `ws set`).
4. Runtime dynamic evaluation inside templates.

Document required vs optional attributes in a `docs/` note.

## Commands (`commands.yml`)

Provide ergonomic developer operations. Keep early scope tiny
(enable/disable/destroy wrappers) then expand.

Example generic command bridging to script:

```yaml
# local-harness/config/commands.yml
command('enable'):
  env:
    NAMESPACE: = @('namespace')
  exec: |
    #!bash(workspace:/)|@
    source .my127ws/harness/scripts/enable.sh
```

Style points:

- Use `env:` to compute dynamic vars cleanly.
- Keep command names short and composable.
- Avoid leaking implementation details (container names, paths) into consumer
  muscle memory.

## Functions (`functions.yml`)

Only add when templates or commands need reusable logic. Categories:

- Formatting (`to_yaml`, `indent`).
- Data shaping (filtering service maps).
- Utility (slugify, version compare).

Avoid premature addition—each function increases maintenance surface.

## Events (`events.yml`)

Lifecycle hooks allow side effects right after install / refresh. Use
sparingly to avoid hidden magic.

Example minimal pattern:

```yaml
after('harness.install'): |
  #!bash
  ws enable   # chain enabling environment automatically
```

Prefer explicit documented commands over implicit heavy hooks.

## Pipeline & Build (`pipeline.yml`)

Separate *local dev* commands from *CI/publish* logic. Example skeleton:

```yaml
command('app build'):
  exec: |
    #!bash(workspace:/)|@
    docker-compose build
```

Add logic for multi-service dependency order only when necessary.

## External Image / Dependency Helpers

Pattern (optional): generate a transient compose file of upstream images to pre-pull.

Keep this out until you have performance issues or reproducibility needs that
justify complexity.

## Secrets & Security

Guidelines:

- Never commit real credentials; use template placeholders or encrypted blobs.
- Provide commands to *help* users generate or encrypt secrets, not to store
  them unencrypted.
- If integrating sealed secrets / KMS flows, isolate complexity in dedicated
  commands.

## Helm / Deployment Assets (Optional)

If you template Helm charts:

- Keep chart logic minimal; push complex logic into values or templates
  referencing harness attributes.
- Provide preview/stage/production values split only if truly needed.
- Offer a validation command (`helm template`, `helm kubeval`) to catch errors
  early.

## Quality Gates & Testing

| Area | Strategy | Tooling Idea |
|------|----------|--------------|
| Confd outputs | Golden file diff test | `tools/test-golden-confd.sh` |
| Commands | Smoke run (`enable`, `disable`) | Exit codes + key artefacts |
| Templates | Lint (YAML, ShellCheck, Markdown) | Pre-commit hooks / CI stage |
| Functions | Unit test pure helpers | Lightweight test harness |
| Security | Grep for forbidden patterns | CI scanning step |

Automate *minimum viable* first: ensure `ws harness prepare` succeeds in CI
with a clean tree.

Example golden test update run:

```bash
bash tools/test-golden-confd.sh --update
git add tests/golden/confd
```

CI integration example: see `.github/workflows/harness-publish.yml`.

## From Path Harness to Packaged Harness

Steps:

1. Stabilise structure & naming (avoid churn after publication).
2. Add `harness.yml` manifest (see next section).
3. Tag a release or build a tarball (depends on distribution channel).
4. Switch consuming project(s) from `path:` → package reference.
5. Remove local duplicate sources (or keep as overlay briefly).

Rollback strategy: keep the previous path harness branch/tag so you can revert
quickly if issues surface.

## `harness.yml` Manifest

The manifest used by first‑party harnesses is a regular workspace config
fragment. The real `harness-php` file looks structurally like this (sanitised):

```yaml
---
harness('acme/generic'):
  description: A docker based development environment for ACME applications
  require:
    services:
      - proxy        # list only infra services your harness expects to co-exist
      - mail         # (example) auxiliary service requirement
    confd:
      - harness:/    # ensure harness root mapping applies (confd block exists)
---
attributes:
  app:
    services:
      - web          # default enabled app-level services (generic names)
      - worker       # add more as needed
---
import:
  - harness/config/*.yml
  - harness/attributes/*.yml
  - harness/attributes/environment/={env('MY127WS_ENV','local')}.yml
```

Key points:

- Multiple YAML documents separated by `---` – this is intentional and
  supported.
- First document declares the harness identity + requirements.
- Second establishes baseline attributes (these can also live in dedicated
  files under `harness/attributes/`; colocating early can be convenient).
- Third pulls in the wider attribute/config sets with environment conditional import.

You may add further documents (e.g. deprecation metadata) as conventions evolve.

Add fields for: required CLIs, deprecation notices, upgrade notes (once policy formalised).

## Versioning & Changelog

Follow SemVer semantics (adapted to harness context):

- MAJOR: template path removals, command removals/renames, manifest format
  changes.
- MINOR: additive commands, new optional attributes, new templates.
- PATCH: bug fixes, non-breaking tweaks, documentation-only updates.

Maintain `CHANGELOG.md` with Keep-a-Changelog style for consistency.

## Backwards Compatibility Contract

Clarify in README what is *public*: typically

- Published command names & arguments.
- Attribute keys you expect consumers to override.
- Destination file set rendered into workspace root.

What is *internal*:

- Intermediate template naming (`*.overlay`, `.final`), staging script names.
- Internal helper functions not documented.

## Publishing Workflow (Example)

```bash
# 1. Clean & render to validate
ws harness prepare

# 2. Run tests / linters
make test  # (or equivalent)

# 3. Build archive
mkdir -p build
 tar --exclude='*.DS_Store' \
     --exclude='*.git' \
     -czf build/acme-generic-0.1.0.tgz local-harness/

# 4. Push / upload (VCS tag or artifact repository)
git tag v0.1.0 && git push origin v0.1.0
# or
curl -T build/acme-generic-0.1.0.tgz https://artifact.example.com/upload
```

Consumers update:

```yaml
workspace('app'):
  harness: acme/generic:0.1.0
```

## Consumer Upgrade Checklist

1. Read release notes / changelog.
2. Diff rendered root files after `ws harness prepare` (look for unexpected removals).
3. Validate customised attributes still resolve.
4. Run smoke commands (`enable`, `destroy`) in a clean clone.
5. Commit updated generated artefacts (if any are versioned).

## Deprecation Policy

- Mark upcoming removals in CHANGELOG one MINOR version ahead.
- Provide shims (wrapper commands) where viable.
- Avoid silent behavioural change; communicate via README / CHANGELOG.

## Security & Hardening Guidelines

| Concern | Recommendation |
|---------|----------------|
| Secret exposure | Use environment interpolation, not literals |
| Script safety | `set -euo pipefail` in critical scripts |
| Image provenance | Pin base image tags or digest where possible |
| Template injection | Escape dynamic content in YAML/JSON templates |
| Privilege creep | Keep container users non-root if feasible |

## Migrating from Local Harness Pattern

| Step | Action |
|------|--------|
| 1 | Freeze current `local-harness/` (branch/tag) |
| 2 | Introduce `harness.yml` & adjust README to reflect publish intent |
| 3 | Run full QA (render → smoke commands → lint) |
| 4 | Package & release 0.x version |
| 5 | Update consumers to package reference |
| 6 | Remove/trim old path harness or retain as overlay for short grace period |

## FAQ (Focused)

**Q:** Can I publish without Helm content even if I plan to add it later?  
**A:** Yes—start minimal; additions are non-breaking if optional.

**Q:** Do I need `commands.yml` on day one?  
**A:** No—add commands when a repeated manual sequence emerges.

**Q:** How big is too big for a single harness?  
**A:** If unrelated technology stacks or lifecycle timings diverge, split.

**Q:** Can I rename templates later?  
**A:** Treat destination filenames in the workspace root as part of your
public API—rename only in MAJOR releases.

**Q:** Should I template huge binaries?  
**A:** No—keep binaries external or downloaded at enable time.

## See Also

- [Local Harness Pattern](local-harness.md)
- [Harness File Materialisation (confd.yml)](harness-confd-file-mappings.md)
- Any existing published harness READMEs (for style alignment)

---

*Feedback & improvements welcome — iterate before declaring this stable.*
