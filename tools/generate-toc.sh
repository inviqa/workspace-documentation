#!/usr/bin/env bash
set -euo pipefail

# generate-toc.sh
# Scans markdown files and (re)generates the TOC block between <!-- TOC --> and <!-- /TOC -->.
# Skips CHANGELOG.md and files shorter than a minimum heading count threshold.
# Leaves QUICK-INDEX blocks untouched.
#
# Usage:
#   ./tools/generate-toc.sh          # Mutate files inserting/updating TOC blocks
#   ./tools/generate-toc.sh --check  # Non-mutating; exit 1 if changes would occur

export LC_ALL=C

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIN_HEADINGS=2
MODE="write"

if [[ "${1:-}" == "--check" ]]; then
  MODE="check"
fi

cd "$REPO_ROOT"

mapfile -t FILES < <(grep -rl '^# ' . --include='*.md' | grep -v 'CHANGELOG.md')

slug() {
  # Convert heading text to slug similar to GitHub
  echo "$1" | \
    tr '[:upper:]' '[:lower:]' | \
    sed -E 's/`//g' | \
    sed -E 's/[^a-z0-9 _-]+//g' | \
    sed -E 's/[ ]+/-/g' | \
    sed -E 's/^-|-$//g'
}

process_file() {
  local file="$1"
  local in_code=0
  local headings=()
  while IFS='' read -r line; do
    if [[ $line == \`\`\`* ]]; then
      (( in_code = 1 - in_code ))
    fi
    if (( ! in_code )) && [[ $line =~ ^##[[:space:]]+[^#] ]]; then
      # Skip TOC title itself
      if [[ $line =~ ^##[[:space:]]+Table[[:space:]]of[[:space:]]Contents ]]; then
        continue
      fi
      # Strip the leading '## ' (and any extra spaces) for the heading text
      text=$(echo "$line" | sed -E 's/^##[[:space:]]+//; s/[[:space:]]+$//')
      headings+=("$text")
    fi
  done < "$file"

  (( ${#headings[@]} < MIN_HEADINGS )) && return 0

  local toc="<!-- TOC -->\n## Table of Contents\n\n"
  for h in "${headings[@]}"; do
    local anchor
    anchor="#$(slug "$h")"
    toc+="- [$h]($anchor)\n"
  done
  toc+="\n<!-- /TOC -->"

  if grep -q '<!-- TOC -->' "$file"; then
    # Extract current block for comparison
    current=$(awk '/<!-- TOC -->/{flag=1} /<!-- \/TOC -->/{print;flag=0} flag' "$file")
    if [[ "$current" != "$toc" ]]; then
      if [[ $MODE == check ]]; then
        echo "[toc-drift] $file"
        return 2
      else
        awk -v toc="$toc" '
          BEGIN{inblock=0}
          /<!-- TOC -->/{print toc; inblock=1; next}
          /<!-- \/TOC -->/{inblock=0; next}
          { if(!inblock) print }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      fi
    fi
  else
    if [[ $MODE == check ]]; then
      echo "[toc-missing] $file"
      return 2
    else
      awk -v toc="$toc" '
        BEGIN{inserted=0}
        /^# /{print; if(!inserted){print ""; print toc; print""; inserted=1; next}}
        {print}
      ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
  fi
}

had_drift=0
for f in "${FILES[@]}"; do
  if ! process_file "$f"; then
    rc=$?
    if (( rc == 2 )); then
      had_drift=1
    else
      exit $rc
    fi
  fi
done

if [[ $MODE == check ]]; then
  if (( had_drift )); then
    echo "TOC drift detected." >&2
    exit 1
  else
    echo "All TOCs up to date."
    exit 0
  fi
fi

echo "TOC generation complete."