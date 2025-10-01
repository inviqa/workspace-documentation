#!/usr/bin/env bash
set -euo pipefail

# check-quick-index-anchors.sh
# Verifies that each anchor referenced inside an allowed QUICK-INDEX block exists
# as a real heading in the same file. Relies on the same slug algorithm used in
# generate-toc.sh. Only examines files that contain <!-- QUICK-INDEX -->.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

slug() {
  echo "$1" | \
    tr '[:upper:]' '[:lower:]' | \
    sed -E 's/`//g' | \
    sed -E 's/[^a-z0-9 _-]+//g' | \
    sed -E 's/[ ]+/-/g' | \
    sed -E 's/^-|-$//g'
}

fail=0

mapfile -t FILES < <(grep -rl '<!-- QUICK-INDEX -->' . --include='*.md' || true)

for f in "${FILES[@]}"; do
  # Collect headings (## and deeper) ignoring code fences
  in_code=0
  declare -a HEAD_SLUGS=()
  while IFS='' read -r line; do
    if [[ $line == \`\`\`* ]]; then
      (( in_code = 1 - in_code ))
      continue
    fi
    if (( ! in_code )) && [[ $line =~ ^##[[:space:]]+[^#] ]]; then
      text=${line#### }
      HEAD_SLUGS+=("$(slug "$text")")
    fi
  done < "$f"

  qi_block=$(awk '/<!-- QUICK-INDEX -->/{flag=1;next}/<!-- \/QUICK-INDEX -->/{flag=0}flag' "$f")
  while IFS= read -r line; do
    case "$line" in
      *'](#'*)
        anchor_part=${line#*](#}
        anchor=${anchor_part%%)*}
        ;;
      *) continue ;;
    esac
    [[ -z "$anchor" ]] && continue
    found=0
    for s in "${HEAD_SLUGS[@]}"; do
      if [[ $s == "$anchor" ]]; then
        found=1; break
      fi
    done
    if (( ! found )); then
      echo "[quick-index-anchor-missing] $f -> #$anchor" >&2
      fail=1
    fi
  done <<< "$qi_block"
  unset HEAD_SLUGS qi_block
 done

if (( fail )); then
  echo "Quick Index anchor validation failed." >&2
  exit 1
fi

echo "All Quick Index anchors valid."
