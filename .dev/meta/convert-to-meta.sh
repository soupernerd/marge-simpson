#!/usr/bin/env bash
set -euo pipefail

# convert-to-meta.sh - Creates .meta_marge/ for meta-development
# Usage: ./.dev/meta/convert-to-meta.sh [-f|--force] [-h|--help]

FORCE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force) FORCE=true; shift ;;
        -h|--help)
            echo "Usage: $0 [-f|--force] [-h|--help]"
            echo "Creates .meta_marge/ folder for meta-development."
            exit 0 ;;
        *) shift ;;
    esac
done

# Locate source folder - handle both repo and global install structures
# Script is at .dev/meta/ so we need to go up TWO levels to reach repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # .dev/meta
DEV_DIR="$(dirname "$SCRIPT_DIR")"                           # .dev
REPO_ROOT="$(dirname "$DEV_DIR")"                            # marge-simpson (repo root)
DEV_PARENT_NAME="$(basename "$REPO_ROOT")"                   # For global install detection

# Detect if running from global install ($MARGE_HOME/shared/.dev/meta/) vs repo (.dev/meta/)
if [[ "$DEV_PARENT_NAME" == "shared" ]] && [[ -f "$REPO_ROOT/AGENTS.md" ]]; then
    # Global install: source is $MARGE_HOME/shared/
    SOURCE_FOLDER="$REPO_ROOT"
    SOURCE_NAME="marge-simpson"  # Use standard name for display
    TARGET_FOLDER="$(pwd)/.meta_marge"
    IS_GLOBAL_INSTALL=true
else
    # Repo structure: source is repo root (parent of .dev/)
    SOURCE_FOLDER="$REPO_ROOT"
    SOURCE_NAME=$(basename "$SOURCE_FOLDER")
    TARGET_FOLDER="$SOURCE_FOLDER/.meta_marge"
    IS_GLOBAL_INSTALL=false
fi

TARGET_NAME=".meta_marge"

# Validate
[[ "$SOURCE_NAME" == ".meta_marge" ]] && { echo "ERROR: Already in meta folder"; exit 1; }
[[ ! -f "$SOURCE_FOLDER/AGENTS.md" ]] && { echo "ERROR: No AGENTS.md found in $SOURCE_FOLDER"; exit 1; }

echo -e "\n===== Convert $SOURCE_NAME -> $TARGET_NAME =====\n"
[[ "$IS_GLOBAL_INSTALL" == "true" ]] && echo -e "[Global install mode - creating in current directory]\n"

# [1/4] Remove existing / create fresh
if [[ -d "$TARGET_FOLDER" ]]; then
    if [[ "$FORCE" != "true" ]]; then
        read -rp "$TARGET_NAME exists. Overwrite? (y/N) " r
        [[ "$r" != "y" && "$r" != "Y" ]] && { echo "Aborted."; exit 0; }
    fi
    rm -rf "$TARGET_FOLDER"
fi
echo "[1/4] Copying..."

mkdir -p "$TARGET_FOLDER"
# Exclusions: scripts/ excluded - meta_marge uses marge-simpson/scripts/ directly
if command -v rsync &>/dev/null; then
    rsync -a \\
        --exclude='.git' --exclude='node_modules' --exclude='.meta_marge' \
        --exclude='.marge' --exclude='.dev' --exclude='cli' --exclude='meta' \
        --exclude='assets' --exclude='.github' --exclude='scripts' \
        --exclude='README.md' --exclude='CHANGELOG.md' --exclude='VERSION' \
        --exclude='LICENSE' --exclude='.gitignore' --exclude='.gitattributes' \
        "$SOURCE_FOLDER/" "$TARGET_FOLDER/"
else
    cp -r "$SOURCE_FOLDER/." "$TARGET_FOLDER/"
    rm -rf "$TARGET_FOLDER/.git" "$TARGET_FOLDER/node_modules" "$TARGET_FOLDER/.meta_marge" \
           "$TARGET_FOLDER/.marge" "$TARGET_FOLDER/.dev" "$TARGET_FOLDER/cli" "$TARGET_FOLDER/meta" \
           "$TARGET_FOLDER/assets" "$TARGET_FOLDER/.github" "$TARGET_FOLDER/scripts" 2>/dev/null || true
    rm -f "$TARGET_FOLDER/README.md" "$TARGET_FOLDER/CHANGELOG.md" "$TARGET_FOLDER/VERSION" \
          "$TARGET_FOLDER/LICENSE" "$TARGET_FOLDER/.gitignore" "$TARGET_FOLDER/.gitattributes" 2>/dev/null || true
fi

# [2/4] Transform: relative paths (./) -> .meta_marge/ AND explicit verify paths
echo "[2/4] Transforming paths..."
count=0
while IFS= read -r -d '' file; do
    # Check text file
    ext="${file##*.}"
    [[ ! "$ext" =~ ^(md|txt|json|yml|yaml|toml|ps1|sh|py|js|ts)$ ]] && continue
    [[ ! -r "$file" ]] && continue
    
    content=$(cat "$file" 2>/dev/null) || continue
    original="$content"
    
    # Transform AGENTS.md references in prompts
    # "Read the AGENTS.md file in this folder" -> "Read .meta_marge/AGENTS.md"
    content=$(echo "$content" | sed 's/Read the AGENTS\.md file in this folder[^.]*\./Read .meta_marge\/AGENTS.md and follow it./g')
    
    # Transform relative paths to explicit .meta_marge/ paths
    # But NOT ./system/scripts/ - those should point to source (marge-simpson/system/scripts/)
    # Handle both old (./tracking/) and new (./system/tracking/) formats
    content=${content//"./system/tracking/"/".meta_marge/system/tracking/"}
    content=${content//"./system/workflows/"/".meta_marge/system/workflows/"}
    content=${content//"./system/experts/"/".meta_marge/system/experts/"}
    content=${content//"./system/knowledge/"/".meta_marge/system/knowledge/"}
    content=${content//"./tracking/"/".meta_marge/system/tracking/"}
    content=${content//"./workflows/"/".meta_marge/system/workflows/"}
    content=${content//"./experts/"/".meta_marge/system/experts/"}
    content=${content//"./knowledge/"/".meta_marge/system/knowledge/"}
    content=${content//"./system/model_pricing.json"/".meta_marge/model_pricing.json"}
    content=${content//"./model_pricing.json"/".meta_marge/model_pricing.json"}
    
    # Scripts should use source folder for verification (test the source, not meta)
    content=${content//"./system/scripts/"/"${SOURCE_NAME}/system/scripts/"}
    content=${content//"./scripts/"/"${SOURCE_NAME}/system/scripts/"}
    
    # Protect GitHub URLs
    content=$(echo "$content" | sed "s|github\.com/\([^/]*\)/${SOURCE_NAME}|github.com/\1/___GITHUB___|g")
    content=${content//___GITHUB___/"$SOURCE_NAME"}
    
    if [[ "$content" != "$original" ]]; then
        echo "$content" > "$file"
        ((count++)) || true
    fi
done < <(find "$TARGET_FOLDER" -type f -print0)
echo "  $count files transformed"

# [3/4] Reset work queues + rewrite AGENTS.md scope
echo "[3/4] Resetting work queues..."

cat > "$TARGET_FOLDER/system/tracking/assessment.md" << EOF
# $TARGET_NAME Assessment

> Meta-development tracking. AI reads .meta_marge/AGENTS.md, improves marge-simpson/.

**Next ID:** MS-0001

---

## Triage (New Issues)
_None_

## Accepted (Ready to Work)
_None_

## In-Progress
_None_

## Done
_None_
EOF

cat > "$TARGET_FOLDER/system/tracking/tasklist.md" << EOF
# $TARGET_NAME Tasklist

> Work queue for meta-development.

**Next ID:** MS-0001

---

## Backlog
_None_

## In-Progress
_None_

## Done
_None_
EOF

# Rewrite AGENTS.md scope section
AGENTS_PATH="$TARGET_FOLDER/AGENTS.md"
NEW_SCOPE="**Scope (CRITICAL):**
1. This folder (\\\`$TARGET_NAME/\\\`) is the **control plane** for improving \\\`$SOURCE_NAME/\\\`.
2. Audit \\\`$SOURCE_NAME/\\\` (the target). Track findings HERE in \\\`$TARGET_NAME/system/tracking/\\\`.
3. Never create \\\`$TARGET_NAME\\\` files outside this folder.

**Meta-Development Workflow:**
\\\`\\\`\\\`
  $TARGET_NAME/AGENTS.md  ->  AI audits $SOURCE_NAME/  ->  Changes to $SOURCE_NAME/
  Work tracked in $TARGET_NAME/system/tracking/
  Verify using: $SOURCE_NAME/system/scripts/verify.sh fast
  When done: run convert-to-meta again to reset
\\\`\\\`\\\`

**IMPORTANT:** \\\`$TARGET_NAME/\\\` is the control plane, NOT a sandbox."

awk -v new_scope="$NEW_SCOPE" '
    /^\*\*Scope \(CRITICAL\):\*\*/ { print new_scope; getline; getline; getline; next }
    { print }
' "$AGENTS_PATH" > "${AGENTS_PATH}.tmp" && mv "${AGENTS_PATH}.tmp" "$AGENTS_PATH"

echo "  Reset assessment.md, tasklist.md, AGENTS.md"

# [4/4] Verify (uses source scripts, not meta_marge)
echo "[4/4] Verifying..."
VERIFY_SCRIPT="$SOURCE_FOLDER/system/scripts/verify.sh"
if [[ -x "$VERIFY_SCRIPT" ]]; then
    "$VERIFY_SCRIPT" fast
    exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\n===== SUCCESS: $TARGET_NAME created ====="
    else
        echo -e "\n===== WARNING: Verification had issues ====="
    fi
    exit $exit_code
else
    echo -e "\n===== DONE: $TARGET_NAME created ====="
    exit 0
fi
