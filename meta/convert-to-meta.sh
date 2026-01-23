#!/usr/bin/env bash
set -euo pipefail

# convert-to-meta.sh -- Creates .meta_marge/ for meta-development
#
# This script copies the current Marge folder to a .meta_marge/ subfolder
# inside the workspace for meta-development (improving Marge itself).
#
# Run this from inside a Marge folder or repo root.
# The .meta_marge/ folder is gitignored by default.
#
# Usage:
#   ./meta/convert-to-meta.sh              # From repo root
#   ./meta/convert-to-meta.sh -f           # Force overwrite

# Defaults
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force) FORCE=true; shift ;;
    -h|--help)
      echo "Usage: $0 [-f|--force]"
      echo ""
      echo "Creates .meta_marge/ folder for meta-development."
      echo "Run from within a Marge folder or repo root."
      echo ""
      echo "Options:"
      echo "  -f, --force     Overwrite existing .meta_marge/ without prompting"
      exit 0
      ;;
    *) shift ;;
  esac
done

# Determine source folder (where the Marge files are)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If script is in meta/, go up one level to find the Marge root
if [[ "$(basename "$SCRIPT_DIR")" == "meta" ]]; then
  SOURCE_FOLDER="$(dirname "$SCRIPT_DIR")"
else
  SOURCE_FOLDER="$SCRIPT_DIR"
fi

# Detect source folder name
SOURCE_NAME=$(basename "$SOURCE_FOLDER")

# Always use .meta_marge as the target name (standardized)
TARGET_NAME=".meta_marge"

# Check if we're already in a meta folder
if [[ "$SOURCE_NAME" == ".meta_marge" ]] || [[ "$SOURCE_NAME" == ".marge_meta" ]] || [[ "$SOURCE_NAME" == "meta_marge" ]]; then
  echo "ERROR: Already in a meta-development folder ($SOURCE_NAME)"
  echo "This script creates the meta folder - you're already in one."
  exit 1
fi

# Target is INSIDE the source folder (not a sibling)
TARGET_FOLDER="$SOURCE_FOLDER/$TARGET_NAME"

echo ""
echo "============================================================"
echo " Convert $SOURCE_NAME -> $TARGET_NAME"
echo "============================================================"
echo ""
echo "Source: $SOURCE_FOLDER"
echo "Target: $TARGET_FOLDER"
echo ""

# Validate source has AGENTS.md (confirms it's a Marge folder)
if [[ ! -f "$SOURCE_FOLDER/AGENTS.md" ]]; then
  echo "ERROR: Not a valid Marge folder (no AGENTS.md found)"
  echo "Run this script from inside a Marge folder or repo root."
  exit 1
fi

# Check if target exists
if [[ -d "$TARGET_FOLDER" ]]; then
  if [[ "$FORCE" != "true" ]]; then
    read -rp "$TARGET_NAME already exists. Overwrite? (y/N) " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
      echo "Aborted."
      exit 0
    fi
  fi
  echo "[1/5] Removing existing $TARGET_NAME..."
  rm -rf "$TARGET_FOLDER"
else
  echo "[1/5] Target folder does not exist, will create fresh."
fi

# Copy folder (excluding .git, node_modules, etc.)
echo "[2/5] Copying $SOURCE_NAME -> $TARGET_NAME..."
mkdir -p "$TARGET_FOLDER"

# Use rsync if available for better exclusion, otherwise cp
if command -v rsync &>/dev/null; then
  rsync -a --exclude='.git' --exclude='node_modules' --exclude='.meta_marge' --exclude='.marge_meta' --exclude='meta_marge' "$SOURCE_FOLDER/" "$TARGET_FOLDER/"
else
  cp -r "$SOURCE_FOLDER/." "$TARGET_FOLDER/"
  # Remove any nested meta folders that got copied
  rm -rf "$TARGET_FOLDER/.git" "$TARGET_FOLDER/node_modules" "$TARGET_FOLDER/.meta_marge" "$TARGET_FOLDER/.marge_meta" "$TARGET_FOLDER/meta_marge" 2>/dev/null || true
fi

# Text file extensions to transform
TEXT_EXTENSIONS="md|txt|json|yml|yaml|toml|ps1|sh|bash|zsh|py|js|ts|jsx|tsx|html|css|scss|less|xml|config|cfg|ini|env|gitignore|dockerignore|sql|graphql|prisma"

# Names to rewrite inside files (support repo-root runs where SOURCE_NAME isn't .marge)
CONTENT_SOURCE_NAMES=()
CONTENT_SOURCE_NAMES+=("$SOURCE_NAME")
if [[ "$SOURCE_NAME" != ".marge" ]]; then
  CONTENT_SOURCE_NAMES+=(".marge")
fi

echo "[3/5] Transforming file contents..."

TRANSFORMED_COUNT=0
SKIPPED_COUNT=0

# Find all files and transform them
while IFS= read -r -d '' file; do
  # Check if it's a text file by extension or known filename
  filename=$(basename "$file")
  ext="${filename##*.}"
  
  is_text=false
  if [[ "$ext" =~ ^($TEXT_EXTENSIONS)$ ]]; then
    is_text=true
  elif [[ "$filename" =~ ^(Makefile|Dockerfile|Jenkinsfile|Procfile|LICENSE|README|CHANGELOG|CONTRIBUTING|VERSION)$ ]]; then
    is_text=true
  elif [[ "$ext" == "$filename" ]]; then
    # No extension - check if it's text
    if file "$file" 2>/dev/null | grep -q "text"; then
      is_text=true
    fi
  fi
  
  if [[ "$is_text" != "true" ]]; then
    ((SKIPPED_COUNT++)) || true
    continue
  fi
  
  # Read file content
  if [[ ! -r "$file" ]]; then
    ((SKIPPED_COUNT++)) || true
    continue
  fi
  
  original_content=$(cat "$file" 2>/dev/null) || continue
  content="$original_content"

  for name in "${CONTENT_SOURCE_NAMES[@]}"; do
    # Apply replacements
    content=${content//"$name/"/"$TARGET_NAME/"}
    content=${content//"[$name]"/"[$TARGET_NAME]"}
    content=${content//"'$name'"/"'$TARGET_NAME'"}
    content=${content//"\"$name\""/"\"$TARGET_NAME\""}
    content=${content//"\`$name\`"/"\`$TARGET_NAME\`"}
    content=${content//" $name "/" $TARGET_NAME "}
    content=${content//" $name."/" $TARGET_NAME."}
    content=${content//" $name,"/" $TARGET_NAME,"}
    content=${content//" $name:"/" $TARGET_NAME:"}
    content=${content//"($name)"/"($TARGET_NAME)"}
    content=${content//": $name"/": $TARGET_NAME"}
    content=${content//"# $name"/"# $TARGET_NAME"}
    content=${content//"=$name"/"=$TARGET_NAME"}
    
    # Final word-boundary replacement for any remaining instances
    # shellcheck disable=SC2001  # sed needed for regex word boundaries
    content=$(echo "$content" | sed -E "s/(^|[^[:alnum:]_])${name}([^[:alnum:]_]|$)/\\1${TARGET_NAME}\\2/g")
  done
  
  if [[ "$content" != "$original_content" ]]; then
    echo "$content" > "$file"
    rel_path="${file#"$TARGET_FOLDER"/}"
    echo "  Transformed: $rel_path"
    ((TRANSFORMED_COUNT++)) || true
  fi
done < <(find "$TARGET_FOLDER" -type f -print0)

echo "  $TRANSFORMED_COUNT files transformed, $SKIPPED_COUNT skipped (binary/non-text)"

# Reset work queues for fresh meta-development
echo "[4/5] Resetting work queues..."

# Reset planning_docs/assessment.md
ASSESSMENT_PATH="$TARGET_FOLDER/planning_docs/assessment.md"
if [[ -f "$ASSESSMENT_PATH" ]]; then
  cat > "$ASSESSMENT_PATH" << EOF
# $TARGET_NAME Assessment

> This file tracks issues found in the Marge system itself (meta-development).
> Use this to improve the production Marge before copying changes back.

**Next ID:** MS-0001

---

## Triage (New Issues)

_None_

---

## Accepted (Ready to Work)

_None_

---

## In-Progress

_None_

---

## Done

_None_
EOF
  echo "  Reset: planning_docs/assessment.md"
fi

# Reset planning_docs/tasklist.md
TASKLIST_PATH="$TARGET_FOLDER/planning_docs/tasklist.md"
if [[ -f "$TASKLIST_PATH" ]]; then
  cat > "$TASKLIST_PATH" << EOF
# $TARGET_NAME Tasklist

> Work queue for meta-development tasks (improving Marge itself).

**Next ID:** MS-0001

---

## Backlog

_None_

---

## In-Progress

_None_

---

## Done

_None_
EOF
  echo "  Reset: planning_docs/tasklist.md"
fi

# Rewrite the AGENTS.md Scope section for meta-development
AGENTS_PATH="$TARGET_FOLDER/AGENTS.md"
if [[ -f "$AGENTS_PATH" ]]; then
  # Create the new scope section for .meta_marge
  NEW_SCOPE="**Scope (CRITICAL):**
1. The \`$TARGET_NAME/\` folder is **excluded from audits** -- it is the tooling, not the target, and exists to update Marge.
2. Audit the workspace/repo OUTSIDE this folder. Track findings HERE in \`$TARGET_NAME/planning_docs/\` assessment.md and tasklist.md.
3. Never create \`$TARGET_NAME\` files outside this folder."

  # Read the file, replace the scope section, write back
  # Using awk for multi-line replacement
  awk -v new_scope="$NEW_SCOPE" '
    /^\*\*Scope \(CRITICAL\):\*\*/ {
      print new_scope
      # Skip the next 3 lines (the old scope lines)
      getline; getline; getline
      next
    }
    { print }
  ' "$AGENTS_PATH" > "${AGENTS_PATH}.tmp" && mv "${AGENTS_PATH}.tmp" "$AGENTS_PATH"
  
  echo "  Updated: AGENTS.md (scope section for meta-development)"
fi

# Verify the conversion
echo "[5/5] Verifying conversion..."

# Check for any remaining source name references
REMAINING_REFS=0
while IFS= read -r -d '' file; do
  for name in "${CONTENT_SOURCE_NAMES[@]}"; do
    if grep -q "\\b${name}\\b" "$file" 2>/dev/null; then
      rel_path="${file#"$TARGET_FOLDER"/}"
      echo "  Note: '$name' still found in: $rel_path (may be intentional)"
      ((REMAINING_REFS++)) || true
      break
    fi
  done
done < <(find "$TARGET_FOLDER" -type f -print0)

# Run verification if verify script exists
VERIFY_SCRIPT="$TARGET_FOLDER/scripts/verify.sh"
if [[ -x "$VERIFY_SCRIPT" ]]; then
  echo ""
  VERIFY_EXIT=0
  "$VERIFY_SCRIPT" fast || VERIFY_EXIT=$?
  
  if [[ $VERIFY_EXIT -eq 0 ]]; then
    echo ""
    echo "============================================================"
    echo " SUCCESS: $TARGET_NAME created and verified!"
    echo "============================================================"
    echo ""
    echo "You can now use $TARGET_NAME for meta-development."
    echo "Changes made there can be tested before copying back to $SOURCE_NAME."
  else
    echo ""
    echo "============================================================"
    echo " WARNING: Conversion complete but verification had issues"
    echo "============================================================"
  fi
  
  exit $VERIFY_EXIT
else
  echo ""
  echo "============================================================"
  echo " DONE: $TARGET_NAME created"
  echo "============================================================"
  echo ""
  echo "Run: $TARGET_NAME/scripts/verify.sh fast"
  exit 0
fi
