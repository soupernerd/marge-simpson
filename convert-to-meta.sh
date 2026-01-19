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
  # Skip verify_logs
  if [[ "$file" == *"/verify_logs/"* ]]; then
    continue
  fi
  
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
  PLACEHOLDER4="###WORKING_COPY###"
  PLACEHOLDER5="###READ_SOURCE_AGENTS###"
  PLACEHOLDER6="###IDS_SOURCE_TASKLIST###"
  
  content=${content//"both \`$SOURCE_NAME/\` and \`$TARGET_NAME/\`"/"$PLACEHOLDER1"}
  content=${content//"both \`$TARGET_NAME/\` and \`$SOURCE_NAME/\`"/"$PLACEHOLDER2"}
  content=${content//"$SOURCE_NAME/\` (source of truth)"/"$PLACEHOLDER3"}
  content=${content//"Read \`$SOURCE_NAME/AGENTS.md\`"/"$PLACEHOLDER5"}
  content=${content//"IDs in \`$SOURCE_NAME/tasklist.md\`"/"$PLACEHOLDER6"}

  # Replace Windows-style backslash paths
  content=${content//".\\$SOURCE_NAME\\"/".\\$TARGET_NAME\\"}
  content=${content//"$SOURCE_NAME\\"/"$TARGET_NAME\\"}
  
  # Apply replacements using sed
  # We use a temp variable approach to avoid issues with special characters
  content=$(echo "$content" | sed "s|\\./$SOURCE_NAME/|./$TARGET_NAME/|g")
  content=$(echo "$content" | sed "s|$SOURCE_NAME/|$TARGET_NAME/|g")
  content=$(echo "$content" | sed "s|\\[$SOURCE_NAME\\]|[$TARGET_NAME]|g")
  content=$(echo "$content" | sed "s|'$SOURCE_NAME'|'$TARGET_NAME'|g")
  content=$(echo "$content" | sed "s|\"$SOURCE_NAME\"|\"$TARGET_NAME\"|g")
  content=$(echo "$content" | sed "s|\`$SOURCE_NAME\`|\`$TARGET_NAME\`|g")
  content=$(echo "$content" | sed "s| $SOURCE_NAME | $TARGET_NAME |g")
  content=$(echo "$content" | sed "s| $SOURCE_NAME\\.| $TARGET_NAME.|g")
  content=$(echo "$content" | sed "s| $SOURCE_NAME,| $TARGET_NAME,|g")
  content=$(echo "$content" | sed "s| $SOURCE_NAME:| $TARGET_NAME:|g")
  content=$(echo "$content" | sed "s|($SOURCE_NAME)|($TARGET_NAME)|g")
  content=$(echo "$content" | sed "s|: $SOURCE_NAME|: $TARGET_NAME|g")
  content=$(echo "$content" | sed "s|# $SOURCE_NAME|# $TARGET_NAME|g")
  content=$(echo "$content" | sed "s|=$SOURCE_NAME|=$TARGET_NAME|g")
  
  # Final word-boundary replacement for any remaining instances (portable sed)
  content=$(echo "$content" | sed -E "s/(^|[^[:alnum:]_])$SOURCE_NAME([^[:alnum:]_]|$)/\\1$TARGET_NAME\\2/g")
  
  # Restore protected contextual patterns
  content=${content//"$PLACEHOLDER1"/"both \`$SOURCE_NAME/\` and \`$TARGET_NAME/\`"}
  content=${content//"$PLACEHOLDER2"/"both \`$TARGET_NAME/\` and \`$SOURCE_NAME/\`"}
  content=${content//"$PLACEHOLDER3"/"$SOURCE_NAME/\` (source of truth)"}
  content=${content//"$PLACEHOLDER5"/"Read \`$SOURCE_NAME/AGENTS.md\`"}
  content=${content//"$PLACEHOLDER6"/"IDs in \`$SOURCE_NAME/tasklist.md\`"}
  
  if [[ "$content" != "$original_content" ]]; then
    echo "$content" > "$file"
    rel_path="${file#$TARGET_FOLDER/}"
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

# Reset instructions_log.md
INSTRUCTIONS_PATH="$TARGET_FOLDER/instructions_log.md"
if [[ -f "$INSTRUCTIONS_PATH" ]]; then
  cat > "$INSTRUCTIONS_PATH" << EOF
# $TARGET_NAME Instructions Log

> Log of instructions and decisions during meta-development.

---

_No entries yet._
EOF
  echo "  Reset: instructions_log.md"
fi

# Clear verify_logs
VERIFY_LOGS_PATH="$TARGET_FOLDER/verify_logs"
if [[ -d "$VERIFY_LOGS_PATH" ]]; then
  find "$VERIFY_LOGS_PATH" -type f -name "*.log" -delete 2>/dev/null || true
  echo "  Cleared: verify_logs/"
fi

# Add meta-specific AGENTS.md rule (exclude self from audits)
AGENTS_PATH="$TARGET_FOLDER/AGENTS.md"
if [[ -f "$AGENTS_PATH" ]]; then
  # Check if it has the single CRITICAL RULE (one-line format) and transform it
  if grep -q "\*\*CRITICAL RULE:\*\* Marge NEVER creates files outside its own folder" "$AGENTS_PATH"; then
    # Use sed for single-line replacement
    sed -i "s/\*\*CRITICAL RULE:\*\* Marge NEVER creates files outside its own folder\. All tracking docs, logs, and artifacts stay within \`$TARGET_NAME\/\`\./**CRITICAL RULES:**\\n1. Marge NEVER creates files outside its own folder. All tracking docs, logs, and artifacts stay within \`$TARGET_NAME\/\`.\\n2. The \`$TARGET_NAME\/\` folder itself is excluded from audits and issue scans - it is the tooling, not the target./g" "$AGENTS_PATH"
    echo "  Updated: AGENTS.md (added meta exclusion rule)"
  fi
fi

# Verify the conversion
echo "[5/5] Verifying conversion..."

# Check for any remaining source name references
REMAINING_REFS=0
while IFS= read -r -d '' file; do
  if [[ "$file" == *"/verify_logs/"* ]]; then
    continue
  fi
  if grep -q "\\b$SOURCE_NAME\\b" "$file" 2>/dev/null; then
    rel_path="${file#$TARGET_FOLDER/}"
    echo "  WARNING: '$SOURCE_NAME' still found in: $rel_path"
    ((REMAINING_REFS++)) || true
  fi
done < <(find "$TARGET_FOLDER" -type f -print0)

if [[ $REMAINING_REFS -gt 0 ]]; then
  echo "  $REMAINING_REFS file(s) still contain '$SOURCE_NAME' references"
fi

# Run verification if verify script exists
VERIFY_SCRIPT="$TARGET_FOLDER/verify.sh"
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
