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
  # Collect headings (## and deeper) while ignoring fenced code blocks.
  in_code=0
  declare -a HEAD_SLUGS=()
  while IFS='' read -r line; do
    if [[ $line == \`\`\`* ]]; then
      (( in_code = 1 - in_code ))
      continue
    fi
    if (( ! in_code )) && [[ $line =~ ^##[[:space:]]+[^#] ]]; then
      h_text=${line#### } # remove leading '## '
      s=$(slug "$h_text")
      HEAD_SLUGS+=("$s")
    fi
  done < "$f"

  # Extract TOC block (raw) – skip anything inside fenced examples in the TOC block itself
  toc_block=$(awk '/<!-- TOC -->/{flag=1;next}/<!-- \/TOC -->/{flag=0}flag' "$f")
  while IFS= read -r line; do
    # Skip fenced code in TOC example blocks
    if [[ $line == \`\`\`* ]]; then
      continue
    fi
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
    found=0
    for s in "${HEAD_SLUGS[@]}"; do
      if [[ $s == "$anchor" ]]; then
        found=1
        break
      fi
    done
    if (( ! found )); then
      echo "[anchor-missing] $f -> #$anchor"
      fail=1
    fi
  done <<< "$toc_block"
  unset HEAD_SLUGS toc_block
done

if (( fail )); then
  echo "Anchor validation failed." >&2
  exit 1
fi

echo "All TOC anchors valid."