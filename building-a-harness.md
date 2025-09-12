# Building a Reusable Workspace Harness

> Status: Draft – end-to-end guide for creating, iterating, and publishing a
> new harness.
>
> Goal: Provide a canonical process from **local path-based incubation** →
> **packaged, versioned harness** resembling existing first-party harnesses,
> using `harness-php` as a structural reference (language specifics omitted).

## 1. Should You Create a New Harness?

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

## 2. Prerequisites

- Current Workspace CLI (ensure contributors share a baseline version).
- Familiarity with: `confd.yml` mappings, `workspace.yml` structure, attributes
  & expressions.
- Optional: container tooling (Docker), Helm (if you ship charts), or any
  domain-specific orchestrations you include.

## 3. Authoritative Layout (Incubation Phase)

During incubation you keep sources inside the consuming repository via
`harness.path`. Suggested starting skeleton (derived from `harness-php`):

```text
local-harness/
  config/
    confd.yml
    commands.yml          # workspace command definitions (optional initially)
    functions.yml         # custom expression/command functions (optional)
    events.yml            # installer lifecycle hooks (optional)
    pipeline.yml          # build/publish workflows (optional)
    external-images.yml   # helper commands (example pattern)
    secrets.yml           # secret related commands (optional)
  attributes/
    common.yml            # default attribute values
    environment/
      local.yml           # env-specific overrides
  docker/                 # docker image build contexts (if any)
    image/
      base/Dockerfile.twig
  helm/                   # helm charts (optional)
    app/
      values.yaml.twig
      Chart.yaml.twig
  harness/
    scripts/
      enable.sh.twig
      disable.sh
  docs/
    README.partial.md.twig
  LICENSE (if planning to publish)
```

Keep only what you will actually use. Everything above is optional except `config/confd.yml`.

## 4. `harness.path` → Path-Based Development

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

## 5. `confd.yml` Design

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

## 6. Attributes & Configuration Structure

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

## 7. Commands (`commands.yml`)

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

## 8. Functions (`functions.yml`)

Only add when templates or commands need reusable logic. Categories:

- Formatting (`to_yaml`, `indent`).
- Data shaping (filtering service maps).
- Utility (slugify, version compare).

Avoid premature addition—each function increases maintenance surface.

## 9. Events (`events.yml`)

Lifecycle hooks allow side effects right after install / refresh. Use
sparingly to avoid hidden magic.

Example minimal pattern:

```yaml
after('harness.install'): |
  #!bash
  ws enable   # chain enabling environment automatically
```

Prefer explicit documented commands over implicit heavy hooks.

## 10. Pipeline & Build (`pipeline.yml`)

Separate *local dev* commands from *CI/publish* logic. Example skeleton:

```yaml
command('app build'):
  exec: |
    #!bash(workspace:/)|@
    docker-compose build
```

Add logic for multi-service dependency order only when necessary.

## 11. External Image / Dependency Helpers

Pattern (optional): generate a transient compose file of upstream images to pre-pull.

Keep this out until you have performance issues or reproducibility needs that
justify complexity.

## 12. Secrets & Security

Guidelines:

- Never commit real credentials; use template placeholders or encrypted blobs.
- Provide commands to *help* users generate or encrypt secrets, not to store
  them unencrypted.
- If integrating sealed secrets / KMS flows, isolate complexity in dedicated
  commands.

## 13. Helm / Deployment Assets (Optional)

If you template Helm charts:

- Keep chart logic minimal; push complex logic into values or templates
  referencing harness attributes.
- Provide preview/stage/production values split only if truly needed.
- Offer a validation command (`helm template`, `helm kubeval`) to catch errors
  early.

## 14. Quality Gates & Testing

| Area | Strategy | Tooling Idea |
|------|----------|--------------|
| Confd outputs | Golden file diff test | Temp render + compare snapshot |
| Commands | Smoke run (`enable`, `disable`) | Exit codes + key artefacts |
| Templates | Lint (YAML, ShellCheck, Markdown) | Pre-commit hooks / CI stage |
| Functions | Unit test pure helpers | Lightweight test harness |
| Security | Grep for forbidden patterns | CI scanning step |

Automate *minimum viable* first: ensure `ws harness prepare` succeeds in CI
with a clean tree.

## 15. From Path Harness to Packaged Harness

Steps:

1. Stabilise structure & naming (avoid churn after publication).
2. Add `harness.yml` manifest (see next section).
3. Tag a release or build a tarball (depends on distribution channel).
4. Switch consuming project(s) from `path:` → package reference.
5. Remove local duplicate sources (or keep as overlay briefly).

Rollback strategy: keep the previous path harness branch/tag so you can revert
quickly if issues surface.

## 16. `harness.yml` Manifest

Example generic manifest:

```yaml
name: acme/generic
version: 0.1.0
summary: Generic container + scripts harness for internal applications.
maintainers:
  - name: Platform Team
    email: platform@example.com
license: MIT
compatibility:
  workspace: ">=1.0 <2.0"
  docker: ">=24"
```

Add fields for: required CLIs, deprecation notices, upgrade notes (if policy emerges).

## 17. Versioning & Changelog

Follow SemVer semantics (adapted to harness context):

- MAJOR: template path removals, command removals/renames, manifest format
  changes.
- MINOR: additive commands, new optional attributes, new templates.
- PATCH: bug fixes, non-breaking tweaks, documentation-only updates.

Maintain `CHANGELOG.md` with Keep-a-Changelog style for consistency.

## 18. Backwards Compatibility Contract

Clarify in README what is *public*: typically

- Published command names & arguments.
- Attribute keys you expect consumers to override.
- Destination file set rendered into workspace root.

What is *internal*:

- Intermediate template naming (`*.overlay`, `.final`), staging script names.
- Internal helper functions not documented.

## 19. Publishing Workflow (Example)

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

## 20. Consumer Upgrade Checklist

1. Read release notes / changelog.
2. Diff rendered root files after `ws harness prepare` (look for unexpected removals).
3. Validate customised attributes still resolve.
4. Run smoke commands (`enable`, `destroy`) in a clean clone.
5. Commit updated generated artefacts (if any are versioned).

## 21. Deprecation Policy

- Mark upcoming removals in CHANGELOG one MINOR version ahead.
- Provide shims (wrapper commands) where viable.
- Avoid silent behavioural change; communicate via README / CHANGELOG.

## 22. Security & Hardening Guidelines

| Concern | Recommendation |
|---------|----------------|
| Secret exposure | Use environment interpolation, not literals |
| Script safety | `set -euo pipefail` in critical scripts |
| Image provenance | Pin base image tags or digest where possible |
| Template injection | Escape dynamic content in YAML/JSON templates |
| Privilege creep | Keep container users non-root if feasible |

## 23. Migrating from Local Harness Pattern

| Step | Action |
|------|--------|
| 1 | Freeze current `local-harness/` (branch/tag) |
| 2 | Introduce `harness.yml` & adjust README to reflect publish intent |
| 3 | Run full QA (render → smoke commands → lint) |
| 4 | Package & release 0.x version |
| 5 | Update consumers to package reference |
| 6 | Remove/trim old path harness or retain as overlay for short grace period |

## 24. FAQ (Focused)

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

## 25. See Also

- [Local Harness Pattern](local-harness.md)
- [Harness File Materialisation (confd.yml)](harness-confd-file-mappings.md)
- Any existing published harness READMEs (for style alignment)

---

*Feedback & improvements welcome — iterate before declaring this stable.*
