#!/usr/bin/env bash
set -euo pipefail

# install.sh
# Copies the drop-in `marge_simpson` folder into a target repo root.

TARGET="."
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      TARGET="$2"
      shift 2
      ;;
    -f|--force)
      FORCE=1
      shift
      ;;
    *)
      echo "Unknown arg: $1" >&2
      echo "Usage: ./install.sh [-t <target_dir>] [--force]" >&2
      exit 1
      ;;
  esac
done

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SRC_DIR/marge_simpson"

if [[ ! -d "$SRC" ]]; then
  echo "Could not find source folder: $SRC" >&2
  exit 1
fi

DEST="$TARGET/marge_simpson"

if [[ -e "$DEST" ]]; then
  if [[ "$FORCE" -ne 1 ]]; then
    echo "Destination already exists: $DEST" >&2
    echo "Re-run with --force to overwrite." >&2
    exit 1
  fi
  rm -rf "$DEST"
fi

mkdir -p "$TARGET"
cp -R "$SRC" "$DEST"

# Validate installation
# Note: verify.ps1 and verify.sh are in the scripts/ subfolder
REQUIRED_FILES=("AGENTS.md" "scripts/verify.ps1" "scripts/verify.sh" "verify.config.json" "README.md")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$DEST/$file" ]]; then
    MISSING_FILES+=("$file")
  fi
done

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
  echo "WARNING: Installation may be incomplete. Missing files:" >&2
  for f in "${MISSING_FILES[@]}"; do
    echo "  - $f" >&2
  done
  exit 1
fi

echo "Installed: $DEST"
echo "Validated: ${#REQUIRED_FILES[@]} required files present"
