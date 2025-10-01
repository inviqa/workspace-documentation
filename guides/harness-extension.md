# Harness extension & customisation guide

<!-- TOC -->
## Table of Contents

- [Purpose](#purpose)
- [Extension spectrum](#extension-spectrum)
- [Choosing an approach](#choosing-an-approach)
- [Overlay vs template override](#overlay-vs-template-override)
- [Adding commands safely](#adding-commands-safely)
- [Attribute strategy](#attribute-strategy)
- [Creating a variant harness](#creating-a-variant-harness)
- [Upstream contribution workflow](#upstream-contribution-workflow)
- [Testing extensions](#testing-extensions)
- [Deprecation & forward compatibility](#deprecation-and-forward-compatibility)
- [Common pitfalls](#common-pitfalls)
- [Checklist](#checklist)
- [See also](#see-also)

<!-- /TOC -->

## Purpose

Document practical patterns for extending an existing harness **without**
unnecessary fork/maintenance burden.

## Extension spectrum

| Level | Technique | When |
|-------|----------|------|
| 0 | Pure attributes | Simple behavioural switches |
| 1 | Overlay managed files | Add policy / CI / auth artefacts |
| 2 | Add commands (`commands.yml`) | New workflows, shortcuts |
| 3 | Template overrides (minimal) | Narrow unavoidable divergence |
| 4 | Local harness path layering | Heavy custom logic incubated locally |
| 5 | Full variant harness repo | Shared across multiple projects |

## Choosing an approach

Start at the lowest level solving the need. Escalate only when duplication or
complexity justify it (e.g. >2 projects using the same local path harness ⇒
promote to variant repo).

## Overlay vs template override

Prefer overlay + attributes over direct template replacement. A replacement
template severs automatic improvements upstream and increases merge friction.

Use a template override only if:

- Attribute hooks / conditionals cannot express the change
- The upstream file would become unreasonably complex with further options

## Adding commands safely

Place custom commands in `harness/config/commands.yml` (path harness or local
path). Name them with a logical namespace if many (e.g. `cron sync-assets`).

Avoid reusing existing canonical command names unless deliberately extending
behaviour with flags.

## Attribute strategy

- Group related attributes by prefix: `deploy.*`, `ci.*`, `feature.xdebug.*`
- Provide sane defaults; avoid secrets in versioned files
- Use `attribute.override()` sparingly—prefer normal precedence + explicit
  override file (`workspace.override.yml`)

## Creating a variant harness

1. Start from a proven local harness path
2. Extract into new repository (`harness-myvariant`)
3. Establish build script if layering on a base
4. Add `CHANGELOG.md` + version tags
5. Publish and update consuming projects to reference `<vendor>/harness-myvariant:1.0.0`

## Upstream contribution workflow

When you discover repeated overrides:

1. Open an issue in the upstream harness repository
2. Propose attribute / conditional to remove need for override
3. Implement behind non-breaking default
4. Add documentation + changelog entry
5. Remove local override after release

## Testing extensions

- Run `ws rebuild && ws enable` after changes
- Add smoke scripts (lint, unit, application checks) executed via a command
- For variant harness repos, add CI verifying build + sample project bootstrap

## Deprecation and forward compatibility

- Avoid hard-coding version-specific resource names
- Use feature flags (`attribute('feature.x')`) that default to safe values
- Track pending deprecations in harness release notes

## Common pitfalls

| Pitfall | Impact | Mitigation |
|---------|--------|------------|
| Massive overrides | Drift & missed upstream fixes | Contribute upstream |
| Secrets in templates | Leakage risk | Use CI secret store / env injection |
| Unscoped commands | Name collisions | Prefix or group logically |
| Copy-paste harness logic | Divergence | Abstract & contribute |

## Checklist

- [ ] Change solved at lowest viable level
- [ ] No unnecessary template overrides
- [ ] Attributes documented / named consistently
- [ ] Commands linted and namespaced
- [ ] Tested via `ws enable` workflow
- [ ] Evaluated upstream contribution opportunity

## See also

- Building a Harness (`building-a-harness.md`)
- Local Harness Pattern (`local-harness.md`)
- Application Overlay (`application-overlay.md`)

---
*Iterate with real-world extension case studies.*
