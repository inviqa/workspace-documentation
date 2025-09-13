#!/usr/bin/env bash
set -euo pipefail

# check-anchors.sh
# Validate that every link in each <!-- TOC --> block points to an existing heading.
# Exits non-zero if any mismatch is found. Ignores QUICK-INDEX blocks.

export LC_ALL=C
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

slug() {
  echo "$1" | \
    tr '[:upper:]' '[:lower:]' | \
    sed -E 's/`//g' | \
    sed -E 's/[^a-z0-9 _-]+//g' | \
    sed -E 's/[ ]+/-/g' | \
    sed -E 's/^-|-$//g'
}

fail=0

mapfile -t FILES < <(grep -rl '<!-- TOC -->' . --include='*.md')

for f in "${FILES[@]}"; do
  # collect headings (## and deeper) to match anchors, build slug list (newline separated)
  mapfile -t HEADINGS < <(grep -E '^[#]{2,} ' "$f" | sed -E 's/^#+ //') || true
  HEAD_SLUGS=""
  for h in "${HEADINGS[@]}"; do
    s=$(slug "$h")
    HEAD_SLUGS+="$s\n"
  done

  # extract TOC block
  toc_block=$(awk '/<!-- TOC -->/{flag=1;next}/<!-- \/TOC -->/{flag=0}flag' "$f")
  while IFS= read -r line; do
    # Look for lines containing a markdown link with an in-page anchor: ](#anchor)
    case "$line" in
      *'](#'*)
        anchor_part=${line#*](#}
        anchor=${anchor_part%%)*}
        ;;
      *)
        continue
        ;;
    esac
    [[ -z "$anchor" ]] && continue
    # Exact slug match check (anchor already lowercased by TOC generation)
    if ! printf '%s' "$HEAD_SLUGS" | grep -qx "$anchor"; then
      echo "[anchor-missing] $f -> #$anchor"
      fail=1
    fi
  done <<< "$toc_block"
  unset HEADINGS HEAD_SLUGS toc_block
  # shellcheck disable=SC2034
  true

done

if (( fail )); then
  echo "Anchor validation failed." >&2
  exit 1
fi

echo "All TOC anchors valid."