#!/usr/bin/env bash
set -euo pipefail
# Collapse multiple consecutive blank lines to a single one for given markdown files.
# Usage: tools/fix-blank-lines.sh <files...>

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <file> [file...]" >&2
  exit 2
fi

for f in "$@"; do
  tmp="$f.tmp$$"
  awk 'BEGIN{blank=0} {
    if ($0 ~ /^\s*$/) {blank++} else {blank=0}
    if (blank < 2) print $0
  }' "$f" > "$tmp" && mv "$tmp" "$f"
 done

echo "Blank line normalization complete."