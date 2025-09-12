#!/usr/bin/env bash
set -euo pipefail

# Golden Outputs Test for Harness confd Materialisation
# -----------------------------------------------------
# Usage:
#   tools/test-golden-confd.sh [--update] [--workspace-yml path]
#
# Behaviour:
# 1. Creates a temp working directory.
# 2. Copies the current repo (or selected subset) into it.
# 3. Runs `ws harness prepare` (or `ws enable` if .my127ws absent).
# 4. Collects a whitelist of generated files (by glob) from project root & .my127ws.
# 5. Normalises non-deterministic content (timestamps, digests) if any future filters exist.
# 6. Diffs against committed golden snapshots under `tests/golden/confd/`.
# 7. Fails if differences are detected (unless --update provided, which refreshes snapshots).
#
# Opinionated & minimal – adjust include patterns for your harness.
#
# Requirements:
#   - workspace CLI (`ws`) available in PATH.
#   - git available (for copying tracked files only when optimising).
#
# Exit codes:
#   0 success (match or updated)
#   1 mismatch
#   2 usage error
#
# Extend NORMALISE() function if you introduce variable content needing scrub.

UPDATE=false
WORKSPACE_FILE="workspace.yml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --update) UPDATE=true; shift ;;
    --workspace-yml) WORKSPACE_FILE="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -f "$WORKSPACE_FILE" ]]; then
  echo "workspace file not found: $WORKSPACE_FILE" >&2
  exit 2
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
TEMP_DIR=$(mktemp -d -t golden-confd-XXXXXX)
SNAPSHOT_DIR="$REPO_ROOT/tests/golden/confd"
COLLECT_DIR="$TEMP_DIR/collected"

mkdir -p "$COLLECT_DIR" "$SNAPSHOT_DIR"

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# Copy repo (tracked files only for speed)
( cd "$REPO_ROOT" && git ls-files ) | cpio -pdm "$TEMP_DIR" >/dev/null 2>&1
cd "$TEMP_DIR"

# Prepare harness (idempotent)
if [[ ! -d .my127ws ]]; then
  ws enable >/dev/null
else
  ws harness prepare >/dev/null
fi

# Selection of generated artefacts to snapshot (adjust patterns)
INCLUDE_PATTERNS=(
  '.env.example'
  'docker-compose.yml'
  'mutagen.yml'
  '.my127ws/harness/config/confd.yml'
  '.my127ws/helm/app/values.yaml'
)

NORMALISE() {
  # Placeholder normalisation: pass-through now.
  # Example future: sed -E 's/BuildDate: .*/BuildDate: <normalised>/'
  cat "$1"
}

for pattern in "${INCLUDE_PATTERNS[@]}"; do
  for f in $(find . -path "./$pattern" -type f 2>/dev/null || true); do
    rel=${f#./}
    dest="$COLLECT_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    NORMALISE "$f" > "$dest"
  done
done

if $UPDATE; then
  rsync -a --delete "$COLLECT_DIR/" "$SNAPSHOT_DIR/"
  echo "Golden snapshots updated in $SNAPSHOT_DIR" >&2
  exit 0
fi

diffExit=0
if ! diff -ruN "$SNAPSHOT_DIR" "$COLLECT_DIR"; then
  diffExit=1
fi

if [[ $diffExit -ne 0 ]]; then
  echo "Golden output mismatch. Re-run with --update to refresh snapshots (after review)." >&2
fi

exit $diffExit
