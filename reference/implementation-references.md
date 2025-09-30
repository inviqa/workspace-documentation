# Implementation References

<!-- TOC -->
## Table of Contents

- [Conventions](#conventions)
- [Proxy Service (`ws global service proxy <enable|disable|restart>`)](#proxy-service-ws-global-service-proxy-enabledisablerestart)
- [Confd Processing](#confd-processing)
- [Overlay Directory](#overlay-directory)
- [Events (Selected)](#events-selected)
- [Adding New Command References](#adding-new-command-references)

<!-- /TOC -->
# Implementation References

Purpose: Quick map from user-facing `ws` commands and documented features to
their underlying source files for faster maintenance and onboarding.

## Conventions

- Source paths are relative to the repository root unless otherwise noted.
- Command registration usually: `workspace/src/Types/Workspace/Builder.php`.
- Harness installer step logic: `workspace/src/Types/Workspace/Installer.php`.
- Service style commands often delegate to
  `workspace/home/service/<name>/` scripts.

### Workspace / Harness Lifecycle

| Concern | Command(s) | Primary Source | Supporting | Notes |
|---------|------------|----------------|-----------|-------|
| Download | s1 | `Installer.php` DWN | `Builder.php` | Skip if present. |
| Overlay | s2 | `Installer.php` OVR | `Builder.php` | Rsync overlay. |
| Validate | s3 | `Installer.php` VAL | – | Prompt attrs. |
| Templates | s4 | `Installer.php` PREP | Confd doc | Render files. |
| Services | s5 | `Installer.php` DEPS | Scripts | Start svc. |
| Installed | s6 | `Installer.php` INST | – | Final event. |

### Harness Preparation (`ws harness prepare`)

- Registration: `workspace/src/Types/Workspace/Builder.php` (section `harness prepare`).
- Actions: sequentially runs `install --step=overlay` then `install --step=prepare`.
- Steps Implemented: `Installer.php` (`STEP_OVERLAY`, `STEP_PREPARE`).
- Use Case: Rapid iteration on overlay directory or templates without full reinstall.

## Proxy Service (`ws global service proxy <enable|disable|restart>`)

- Script: `workspace/home/service/proxy/init.sh`.
- Behaviour (`restart`): disables, re-fetches TLS cert/key (via config),
  rebuilds & starts Traefik.
- Related Docs: `reference/workspace-commands-functions-index.md` (Proxy
  restart section).

## Confd Processing

- Factory / Application: `workspace/src/Types/Confd/Factory.php` (creation),
  `workspace/src/Types/Workspace/Installer.php` (invoked in `STEP_PREPARE`).
- Definition Parsing: `workspace/src/Types/Confd/DefinitionFactory.php` (parses `confd.yml`).
- Workspace Integration: `Installer.php` calls `$this->confd->create(...)->apply()`.
- Detailed Doc: `reference/harness-confd-file-mappings.md`.

## Overlay Directory

- Configuration Source: `workspace.yml` (`overlay:` key in workspace definition block).
- Retrieval: `workspace/src/Types/Workspace/Definition.php` (`getOverlayPath()`).
- Execution: `Installer.php::applyOverlayDirectory()` (rsync into `harness:/`).

## Events (Selected)

| Event | Emitted From | Step Context | Purpose |
|-------|--------------|--------------|---------|
| Event | Source | Step | Purpose |
|-------|--------|------|---------|
| `before.harness.install` | `Installer.php` | 1 | Pre-download hooks. |
| `before.harness.overlay` | `Installer.php` | 2 | Overlay instrumentation. |
| `after.harness.overlay` | `Installer.php` | 2 | Overlay instrumentation. |
| `before.harness.prepare` | `Installer.php` | 4 | Template instrumentation. |
| `after.harness.prepare` | `Installer.php` | 4 | Template instrumentation. |
| `after.harness.install` | `Installer.php` | 5 | Post-install actions. |
| `harness.installed` | `Installer.php` | 6 | Final completion signal. |

## Adding New Command References

1. Add command registration location (file + section usage string).
2. Add execution / logic file(s) (PHP class, installer step, or shell script).
3. Link to any deep dive documentation pages.
4. Note idempotency / side-effects if non-obvious.

### Change Log

- Initial version: Added mapping tables (installer lifecycle, harness prepare,
  proxy service, confd, overlay, events).

---

See also:

- `reference/workspace-commands-functions-index.md` (user-facing overview)
- `reference/harness-confd-file-mappings.md` (template & file materialisation
  deep dive)
