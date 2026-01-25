#!/usr/bin/env bash
set -euo pipefail

# convert-to-meta.sh - Creates .meta_marge/ for meta-development
# Usage: ./.dev/convert-to-meta.sh [-f|--force] [-h|--help]

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

# Locate source folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FOLDER="$([[ "$(basename "$SCRIPT_DIR")" == ".dev" ]] && dirname "$SCRIPT_DIR" || echo "$SCRIPT_DIR")"
SOURCE_NAME=$(basename "$SOURCE_FOLDER")
TARGET_NAME=".meta_marge"
TARGET_FOLDER="$SOURCE_FOLDER/$TARGET_NAME"

# Validate
[[ "$SOURCE_NAME" == ".meta_marge" ]] && { echo "ERROR: Already in meta folder"; exit 1; }
[[ ! -f "$SOURCE_FOLDER/AGENTS.md" ]] && { echo "ERROR: No AGENTS.md found"; exit 1; }

echo -e "\n===== Convert $SOURCE_NAME -> $TARGET_NAME =====\n"

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
    rsync -a \
        --exclude='.git' --exclude='node_modules' --exclude='.meta_marge' \
        --exclude='.marge' --exclude='cli' --exclude='meta' \
        --exclude='assets' --exclude='.github' --exclude='scripts' \
        --exclude='README.md' --exclude='CHANGELOG.md' --exclude='VERSION' \
        --exclude='LICENSE' --exclude='.gitignore' --exclude='.gitattributes' \
        "$SOURCE_FOLDER/" "$TARGET_FOLDER/"
else
    cp -r "$SOURCE_FOLDER/." "$TARGET_FOLDER/"
    rm -rf "$TARGET_FOLDER/.git" "$TARGET_FOLDER/node_modules" "$TARGET_FOLDER/.meta_marge" \
           "$TARGET_FOLDER/.marge" "$TARGET_FOLDER/cli" "$TARGET_FOLDER/meta" \
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
    
    # Transform relative paths to explicit .meta_marge/ paths
    # But NOT ./scripts/ - those should point to source (marge-simpson/scripts/)
    content=${content//".\/tracking\/"/".meta_marge/tracking/"}
    content=${content//".\/workflows\/"/".meta_marge/workflows/"}
    content=${content//".\/experts\/"/".meta_marge/experts/"}
    content=${content//".\/knowledge\/"/".meta_marge/knowledge/"}
    content=${content//".\/model_pricing.json"/".meta_marge/model_pricing.json"}
    
    # Scripts should use source folder for verification (test the source, not meta)
    content=${content//".\/scripts\/"/"${SOURCE_NAME}/scripts/"}
    
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

cat > "$TARGET_FOLDER/tracking/assessment.md" << EOF
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

cat > "$TARGET_FOLDER/tracking/tasklist.md" << EOF
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
1. The \`$TARGET_NAME/\` folder is **excluded from audits** -- it is the tooling, not the target.
2. Audit the workspace/repo OUTSIDE this folder (e.g., \`$SOURCE_NAME/\`).
3. Track findings HERE in \`$TARGET_NAME/tracking/\` assessment.md and tasklist.md.
4. Never create \`$TARGET_NAME\` files outside this folder.

**Meta-Development Workflow:**
\`\`\`
  $TARGET_NAME/AGENTS.md  ->  AI audits $SOURCE_NAME/  ->  Changes to $SOURCE_NAME/
  Work tracked in $TARGET_NAME/tracking/
  When done: run convert-to-meta again to reset
\`\`\`

**IMPORTANT:** \`$TARGET_NAME/\` is the control plane, NOT a sandbox."

awk -v new_scope="$NEW_SCOPE" '
    /^\*\*Scope \(CRITICAL\):\*\*/ { print new_scope; getline; getline; getline; next }
    { print }
' "$AGENTS_PATH" > "${AGENTS_PATH}.tmp" && mv "${AGENTS_PATH}.tmp" "$AGENTS_PATH"

echo "  Reset assessment.md, tasklist.md, AGENTS.md"

# [4/4] Verify (uses source scripts, not meta_marge)
echo "[4/4] Verifying..."
VERIFY_SCRIPT="$SOURCE_FOLDER/scripts/verify.sh"
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
