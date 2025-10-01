#!/usr/bin/env bash
set -euo pipefail

# check-quick-index.sh
# Enforces that only files listed in tools/quick-index-allowlist.txt contain a live QUICK-INDEX block.
# Exits non-zero if any other markdown file includes <!-- QUICK-INDEX -->.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALLOWLIST_FILE="$ROOT_DIR/tools/quick-index-allowlist.txt"

if [[ ! -f "$ALLOWLIST_FILE" ]]; then
  echo "Allowlist file missing: $ALLOWLIST_FILE" >&2
  exit 2
fi

mapfile -t allow_raw < <(grep -v '^#' "$ALLOWLIST_FILE" | sed '/^$/d')
declare -a allow_patterns=()
declare -A allowed_exact
for entry in "${allow_raw[@]}"; do
  if [[ "$entry" == *'*'* || "$entry" == *'?'* || "$entry" == *'['* ]]; then
    allow_patterns+=("$entry")
  else
    allowed_exact[$entry]=1
  fi
done

violations=0
while IFS= read -r -d '' file; do
  rel=${file#"$ROOT_DIR/"}
  if grep -q '<!-- QUICK-INDEX -->' "$file"; then
    if [[ -n "${allowed_exact[$rel]:-}" ]]; then
      continue
    fi
    matched_pattern=0
    # Pattern list matching: convert glob to regex for precise match to appease shellcheck.
    for pat in "${allow_patterns[@]}"; do
      # Escape regex special chars then restore glob wildcards
      regex=${pat//\/\\}
      regex=${regex//./\\.}
      regex=${regex//+/\\+}
      regex=${regex//\?/[^/]}
      regex=${regex//\*/[^/]*}
      if [[ $rel =~ ^$regex$ ]]; then
        matched_pattern=1
        break
      fi
    done
    if (( ! matched_pattern )); then
      echo "[quick-index-violation] $rel" >&2
      violations=1
    fi
  fi
done < <(find "$ROOT_DIR" -name '*.md' -print0)

if (( violations )); then
  echo "Quick Index present in non-allowlisted files." >&2
  exit 1
fi

echo "Quick Index usage compliant."
