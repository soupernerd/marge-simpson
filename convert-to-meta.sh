#!/usr/bin/env bash
set -euo pipefail

# convert-to-meta.sh — Converts marge_simpson folder into meta_marge for meta-development
#
# This script copies marge_simpson to meta_marge (or updates existing meta_marge)
# and transforms ALL internal paths and references from marge_simpson to meta_marge.
#
# It dynamically discovers all files in the source folder - no hardcoded file lists.
# This ensures the script works even when marge_simpson changes (files added, removed, renamed).
#
# Usage:
#   ./convert-to-meta.sh
#   ./convert-to-meta.sh -f                    # Force overwrite
#   ./convert-to-meta.sh -s marge_simpson -t my_meta_marge

# Defaults
SOURCE_NAME="marge_simpson"
TARGET_NAME="meta_marge"
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force) FORCE=true; shift ;;
    -s|--source) SOURCE_NAME="$2"; shift 2 ;;
    -t|--target) TARGET_NAME="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [-f|--force] [-s|--source NAME] [-t|--target NAME]"
      echo ""
      echo "Options:"
      echo "  -f, --force     Overwrite existing target folder without prompting"
      echo "  -s, --source    Source folder name (default: marge_simpson)"
      echo "  -t, --target    Target folder name (default: meta_marge)"
      exit 0
      ;;
    *) shift ;;
  esac
done

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
SOURCE_FOLDER="$REPO_ROOT/$SOURCE_NAME"
TARGET_FOLDER="$REPO_ROOT/$TARGET_NAME"

echo ""
echo "============================================================"
echo " Convert $SOURCE_NAME -> $TARGET_NAME"
echo "============================================================"
echo ""

# Validate source exists
if [[ ! -d "$SOURCE_FOLDER" ]]; then
  echo "ERROR: Source folder not found: $SOURCE_FOLDER"
  exit 1
fi

# Prevent converting to itself
if [[ "$SOURCE_NAME" == "$TARGET_NAME" ]]; then
  echo "ERROR: Source and target names cannot be the same."
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

# Copy folder
echo "[2/5] Copying $SOURCE_NAME -> $TARGET_NAME..."
cp -r "$SOURCE_FOLDER" "$TARGET_FOLDER"

# Text file extensions to transform
TEXT_EXTENSIONS="md|txt|json|yml|yaml|toml|ps1|sh|bash|zsh|py|js|ts|jsx|tsx|html|css|scss|less|xml|config|cfg|ini|env|gitignore|dockerignore|sql|graphql|prisma"

echo "[3/5] Transforming file contents (dynamic discovery)..."

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

  # Protect contextual patterns where both folder names should appear together
  # (documentation explaining the dual-folder architecture)
  PLACEHOLDER1="###BOTH_FOLDERS_1###"
  PLACEHOLDER2="###BOTH_FOLDERS_2###"
  PLACEHOLDER3="###SOURCE_TRUTH###"
  PLACEHOLDER5="###READ_SOURCE_AGENTS###"
  PLACEHOLDER6="###IDS_SOURCE_TASKLIST###"
  # README.md Repository Architecture section placeholders
  PLACEHOLDER7="###README_PROD_TEMPLATE###"
  PLACEHOLDER8="###README_SOURCE_TRUTH###"
  PLACEHOLDER9="###README_CREATE_FROM###"
  PLACEHOLDER10="###README_CHANGES_FLOW###"
  PLACEHOLDER11="###README_CONTRIB_TEMPLATE###"
  PLACEHOLDER12="###README_COPY_BACK###"
  PLACEHOLDER13="###README_VERSION_SOURCE###"
  
  content=${content//"both \`$SOURCE_NAME/\` and \`$TARGET_NAME/\`"/"$PLACEHOLDER1"}
  content=${content//"both \`$TARGET_NAME/\` and \`$SOURCE_NAME/\`"/"$PLACEHOLDER2"}
  content=${content//"$SOURCE_NAME/\` (source of truth)"/"$PLACEHOLDER3"}
  content=${content//"Read \`$SOURCE_NAME/AGENTS.md\`"/"$PLACEHOLDER5"}
  content=${content//"IDs in \`$SOURCE_NAME/tasklist.md\`"/"$PLACEHOLDER6"}
  # README.md Repository Architecture section protections
  content=${content//"| \`$SOURCE_NAME/\` | **Production template**"/"$PLACEHOLDER7"}
  content=${content//"- \`$SOURCE_NAME/\` is the **source of truth**"/"$PLACEHOLDER8"}
  content=${content//"create \`$TARGET_NAME/\` from \`$SOURCE_NAME/\`"/"$PLACEHOLDER9"}
  content=${content//"Changes flow: \`$SOURCE_NAME/\`"/"$PLACEHOLDER10"}
  content=${content//"| \`$SOURCE_NAME/\` | Template for end users"/"$PLACEHOLDER11"}
  content=${content//"Copy changes back to \`$SOURCE_NAME/\`"/"$PLACEHOLDER12"}
  content=${content//"\`$SOURCE_NAME/VERSION\`"/"$PLACEHOLDER13"}

  # Replace Windows-style backslash paths
  content=${content//".\\$SOURCE_NAME\\"/".\\$TARGET_NAME\\"}
  content=${content//"$SOURCE_NAME\\"/"$TARGET_NAME\\"}
  
  # Apply replacements - using bash parameter expansion where possible
  # shellcheck disable=SC2001  # sed needed for complex pattern escaping
  content=$(echo "$content" | sed "s|\\./$SOURCE_NAME/|./$TARGET_NAME/|g")
  content=${content//"$SOURCE_NAME/"/"$TARGET_NAME/"}
  content=${content//"[$SOURCE_NAME]"/"[$TARGET_NAME]"}
  content=${content//"'$SOURCE_NAME'"/"'$TARGET_NAME'"}
  content=${content//"\"$SOURCE_NAME\""/"\"$TARGET_NAME\""}
  content=${content//"\`$SOURCE_NAME\`"/"\`$TARGET_NAME\`"}
  content=${content//" $SOURCE_NAME "/" $TARGET_NAME "}
  content=${content//" $SOURCE_NAME."/" $TARGET_NAME."}
  content=${content//" $SOURCE_NAME,"/" $TARGET_NAME,"}
  content=${content//" $SOURCE_NAME:"/" $TARGET_NAME:"}
  content=${content//"($SOURCE_NAME)"/"($TARGET_NAME)"}
  content=${content//": $SOURCE_NAME"/": $TARGET_NAME"}
  content=${content//"# $SOURCE_NAME"/"# $TARGET_NAME"}
  content=${content//"=$SOURCE_NAME"/"=$TARGET_NAME"}
  
  # Final word-boundary replacement for any remaining instances (portable sed)
  # shellcheck disable=SC2001  # sed needed for regex word boundaries
  content=$(echo "$content" | sed -E "s/(^|[^[:alnum:]_])$SOURCE_NAME([^[:alnum:]_]|$)/\\1$TARGET_NAME\\2/g")
  
  # Restore protected contextual patterns
  content=${content//"$PLACEHOLDER1"/"both \`$SOURCE_NAME/\` and \`$TARGET_NAME/\`"}
  content=${content//"$PLACEHOLDER2"/"both \`$TARGET_NAME/\` and \`$SOURCE_NAME/\`"}
  content=${content//"$PLACEHOLDER3"/"$SOURCE_NAME/\` (source of truth)"}
  content=${content//"$PLACEHOLDER5"/"Read \`$SOURCE_NAME/AGENTS.md\`"}
  content=${content//"$PLACEHOLDER6"/"IDs in \`$SOURCE_NAME/tasklist.md\`"}
  # Restore README.md Repository Architecture section
  content=${content//"$PLACEHOLDER7"/"| \`$SOURCE_NAME/\` | **Production template**"}
  content=${content//"$PLACEHOLDER8"/"- \`$SOURCE_NAME/\` is the **source of truth**"}
  content=${content//"$PLACEHOLDER9"/"create \`$TARGET_NAME/\` from \`$SOURCE_NAME/\`"}
  content=${content//"$PLACEHOLDER10"/"Changes flow: \`$SOURCE_NAME/\`"}
  content=${content//"$PLACEHOLDER11"/"| \`$SOURCE_NAME/\` | Template for end users"}
  content=${content//"$PLACEHOLDER12"/"Copy changes back to \`$SOURCE_NAME/\`"}
  content=${content//"$PLACEHOLDER13"/"\`$SOURCE_NAME/VERSION\`"}
  
  if [[ "$content" != "$original_content" ]]; then
    echo "$content" > "$file"
    rel_path="${file#"$TARGET_FOLDER"/}"
    echo "  Transformed: $rel_path"
    ((TRANSFORMED_COUNT++)) || true
  fi
done < <(find "$TARGET_FOLDER" -type f -print0)

echo "  $TRANSFORMED_COUNT files transformed, $SKIPPED_COUNT skipped (binary/non-text)"

# Reset work queues for fresh meta-development
echo "[4/5] Resetting work queues for meta-development..."

# Reset assessment.md
ASSESSMENT_PATH="$TARGET_FOLDER/assessment.md"
if [[ -f "$ASSESSMENT_PATH" ]]; then
  cat > "$ASSESSMENT_PATH" << EOF
# $TARGET_NAME Assessment

> This file tracks issues found in the Marge system itself (meta-development).
> Use this to improve the production Marge before copying it to other repos.

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
  echo "  Reset: assessment.md"
fi

# Reset tasklist.md
TASKLIST_PATH="$TARGET_FOLDER/tasklist.md"
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
  echo "  Reset: tasklist.md"
fi

# Transform AGENTS.md for meta_marge (remove conditional clause)
AGENTS_PATH="$TARGET_FOLDER/AGENTS.md"
if [[ -f "$AGENTS_PATH" ]]; then
  # The source marge_simpson has a conditional clause "unless meta_marge exists..."
  # For meta_marge, we want the simpler rule without the conditional
  if grep -q "unless \`${TARGET_NAME}/\` exists and is being used to update Marge" "$AGENTS_PATH"; then
    # Remove the conditional clause using sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS BSD sed
      sed -i '' "s/, unless \`${TARGET_NAME}\/\` exists and is being used to update Marge//g" "$AGENTS_PATH"
    else
      # GNU sed
      sed -i "s/, unless \`${TARGET_NAME}\/\` exists and is being used to update Marge//g" "$AGENTS_PATH"
    fi
    echo "  Updated: AGENTS.md (removed conditional clause for meta_marge)"
  elif grep -q "\*\*excluded from audits\*\*.*it is the tooling, not the target\." "$AGENTS_PATH"; then
    echo "  AGENTS.md has correct audit exclusion rule (no conditional needed for meta_marge)"
  else
    echo "  WARNING: AGENTS.md has unexpected format - check manually"
  fi
fi

# Verify the conversion
echo "[5/5] Verifying conversion..."

# Check for any remaining source name references
REMAINING_REFS=0
while IFS= read -r -d '' file; do
  if grep -q "\\b$SOURCE_NAME\\b" "$file" 2>/dev/null; then
    rel_path="${file#"$TARGET_FOLDER"/}"
    echo "  WARNING: '$SOURCE_NAME' still found in: $rel_path"
    ((REMAINING_REFS++)) || true
  fi
done < <(find "$TARGET_FOLDER" -type f -print0)

if [[ $REMAINING_REFS -gt 0 ]]; then
  echo "  $REMAINING_REFS file(s) still contain '$SOURCE_NAME' references"
fi

# Run verification if verify script exists (scripts are in scripts/ subfolder)
VERIFY_SCRIPT="$TARGET_FOLDER/scripts/verify.sh"
if [[ -x "$VERIFY_SCRIPT" ]]; then
  VERIFY_EXIT=0
  "$VERIFY_SCRIPT" fast || VERIFY_EXIT=$?
  
  if [[ $VERIFY_EXIT -eq 0 && $REMAINING_REFS -eq 0 ]]; then
    echo ""
    echo "============================================================"
    echo " SUCCESS: $TARGET_NAME created and verified!"
    echo "============================================================"
    echo ""
    echo "You can now use $TARGET_NAME for meta-development."
    echo "Run: ./$TARGET_NAME/verify.sh fast"
  elif [[ $VERIFY_EXIT -eq 0 ]]; then
    echo ""
    echo "============================================================"
    echo " PARTIAL: $TARGET_NAME created but has residual references"
    echo "============================================================"
    echo "Review the warnings above and manually fix remaining references."
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
  echo " DONE: $TARGET_NAME created (no verify.sh found to run)"
  echo "============================================================"
  exit 0
fi
