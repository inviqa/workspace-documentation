#!/usr/bin/env bash
set -euo pipefail

# Detect duplicate command listing lines across markdown files while allowing
# a canonical source file to contain the authoritative version.
# Heuristic: lines starting with a dash and a backticked command pattern.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANONICAL_INDEX="workspace-commands-functions-index.md"

tmpfile="$(mktemp)"
trap 'rm -f "$tmpfile"' EXIT

grep -R --no-color -n -E '^- `ws [^`]+`' "$ROOT_DIR"/*.md \
  | sed 's#^./##' \
  | grep -v "$CANONICAL_INDEX" > "$tmpfile" || true

declare -A seen
declare -A first_location
duplicate_found=0

while IFS= read -r line; do
  # Parse components (currently unused; keep simple pipeline)
  # Extract the backticked command token (literal backticks escaped for grep)
  cmd=$(echo "$line" | grep -o '\`ws [^\`]*\`' || true)
  [ -z "$cmd" ] && continue
  key="$cmd"
  if [[ -z "${seen[$key]:-}" ]]; then
    seen[$key]=1
    first_location[$key]="$line"
  else
    echo "Duplicate command listing detected: $cmd" >&2
    echo "  First: ${first_location[$key]}" >&2
    echo "  Also:  $line" >&2
    duplicate_found=1
  fi
done < <(cat "$tmpfile")

if [[ $duplicate_found -eq 1 ]]; then
  echo "\nERROR: Duplicate command listings found outside $CANONICAL_INDEX" >&2
  exit 1
fi

echo "No duplicate command listings found (non-canonical)."