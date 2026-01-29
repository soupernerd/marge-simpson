#!/usr/bin/env bash
set -euo pipefail

# convert-to-meta.sh - Creates .meta_marge/ for meta-development
# Usage: ./.dev/meta/convert-to-meta.sh [-f|--force] [-u|--update] [-h|--help]

FORCE=false
UPDATE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force) FORCE=true; shift ;;
        -u|--update) UPDATE=true; shift ;;
        -h|--help)
            echo "Usage: $0 [-f|--force] [-h|--help]"
            echo "Creates .meta_marge/ folder for meta-development."
            echo "  --update preserves .meta_marge/system/tracking and .meta_marge/system/knowledge"
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

# [1/4] Remove existing / create fresh (or update)
PRESERVE_ROOT=""
if [[ -d "$TARGET_FOLDER" ]]; then
    if [[ "$UPDATE" == "true" ]]; then
        PRESERVE_ROOT="$(mktemp -d 2>/dev/null || mktemp -d -t meta_marge_preserve)"
        [[ -d "$TARGET_FOLDER/system/tracking" ]] && cp -r "$TARGET_FOLDER/system/tracking" "$PRESERVE_ROOT/"
        [[ -d "$TARGET_FOLDER/system/knowledge" ]] && cp -r "$TARGET_FOLDER/system/knowledge" "$PRESERVE_ROOT/"
        rm -rf "$TARGET_FOLDER"
    else
        if [[ "$FORCE" != "true" ]]; then
            read -rp "$TARGET_NAME exists. Overwrite? (y/N) " r
            [[ "$r" != "y" && "$r" != "Y" ]] && { echo "Aborted."; exit 0; }
        fi
        rm -rf "$TARGET_FOLDER"
    fi
elif [[ "$UPDATE" == "true" ]]; then
    echo "[Update] Target not found; creating fresh .meta_marge/"
fi
echo "[1/4] Copying..."

mkdir -p "$TARGET_FOLDER"
# =============================================================================
# INCLUSIONS - Only these get copied to .meta_marge/
# =============================================================================
#   AGENTS.md             - Transformed for meta-development scope
#   prompts/              - All prompts (AGENTS.md references transformed)
#   system/tracking/      - assessment.md, tasklist.md (ID reset, paths transformed)
#   system/workflows/     - All workflows (paths transformed to .meta_marge/)
#   system/knowledge/     - Meta knowledge store (decisions, patterns, preferences, insights)
#
# Everything else stays in source and is referenced directly:
#   - system/scripts/     - AI runs marge-simpson/system/scripts/ directly
#   - system/experts/     - AI loads from marge-simpson/system/experts/
#   - cli/, .dev/, etc.   - Dev tooling stays in source
# =============================================================================

# Copy only included items
[[ -f "$SOURCE_FOLDER/AGENTS.md" ]] && cp "$SOURCE_FOLDER/AGENTS.md" "$TARGET_FOLDER/"
[[ -d "$SOURCE_FOLDER/prompts" ]] && cp -r "$SOURCE_FOLDER/prompts" "$TARGET_FOLDER/"
mkdir -p "$TARGET_FOLDER/system"
[[ -d "$SOURCE_FOLDER/system/tracking" ]] && cp -r "$SOURCE_FOLDER/system/tracking" "$TARGET_FOLDER/system/"
[[ -d "$SOURCE_FOLDER/system/workflows" ]] && cp -r "$SOURCE_FOLDER/system/workflows" "$TARGET_FOLDER/system/"
[[ -d "$SOURCE_FOLDER/system/knowledge" ]] && cp -r "$SOURCE_FOLDER/system/knowledge" "$TARGET_FOLDER/system/"

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
    # "Read marge-simpson/AGENTS.md" -> "Read .meta_marge/AGENTS.md"
    content=${content//"Read marge-simpson/AGENTS.md"/"Read .meta_marge/AGENTS.md"}
    # "from marge-simpson/AGENTS.md" -> "from .meta_marge/AGENTS.md"
    content=${content//"from marge-simpson/AGENTS.md"/"from .meta_marge/AGENTS.md"}
    
    # Transform tracking, workflow, and knowledge paths to .meta_marge/
    # tracking/ -> meta work is tracked here
    # workflows/ -> meta-specific workflow copies
    # knowledge/ -> user data stored here (decisions, patterns, preferences, insights)
    # BUT keep experts pointing to source (AI loads source expert files)
    content=${content//"marge-simpson/system/tracking/"/".meta_marge/system/tracking/"}
    content=${content//"marge-simpson/system/workflows/"/".meta_marge/system/workflows/"}
    content=${content//"marge-simpson/system/knowledge/"/".meta_marge/system/knowledge/"}
    content=${content//"marge-simpson/system/scripts/verify.ps1 fast"/".meta_marge/system/scripts/verify.ps1 fast"}
    content=${content//"marge-simpson/system/scripts/verify.sh fast"/".meta_marge/system/scripts/verify.sh fast"}
    # NOTE: NOT transforming marge-simpson/system/experts/
    # Those should stay pointing to source so AI loads actual expert files
    
    # Restore explicit base tracking path markers
    content=${content//"__BASE_TRACKING__"/"marge-simpson/system/tracking/"}

    # Protect GitHub URLs (using sed because this requires capture groups)
    # shellcheck disable=SC2001
    content=$(echo "$content" | sed "s|github\.com/\([^/]*\)/${SOURCE_NAME}|github.com/\1/___GITHUB___|g")
    content=${content//___GITHUB___/"$SOURCE_NAME"}
    
    if [[ "$content" != "$original" ]]; then
        echo "$content" > "$file"
        ((count++)) || true
    fi
done < <(find "$TARGET_FOLDER" -type f -print0)
echo "  $count files transformed"

# [3/4] Reset tracking files (preserve structure, just reset IDs) + configure AGENTS.md
echo "[3/4] Resetting tracking IDs and configuring AGENTS.md..."

# Read source templates and reset IDs, transform tracking paths only
sed -e 's/\*\*Next ID:\*\* MS-[0-9]*/\*\*Next ID:\*\* MS-0001/' \
    -e 's|marge-simpson/system/tracking/|.meta_marge/system/tracking/|g' \
    -e "s|marge-simpson/system/scripts/|${SOURCE_NAME}/system/scripts/|g" \
    "$SOURCE_FOLDER/system/tracking/assessment.md" > "$TARGET_FOLDER/system/tracking/assessment.md"

sed -e 's|marge-simpson/system/tracking/|.meta_marge/system/tracking/|g' \
    -e "s|marge-simpson/system/scripts/|${SOURCE_NAME}/system/scripts/|g" \
    "$SOURCE_FOLDER/system/tracking/tasklist.md" > "$TARGET_FOLDER/system/tracking/tasklist.md"

# Rewrite AGENTS.md scope section - the source has "## Scope" section
AGENTS_PATH="$TARGET_FOLDER/AGENTS.md"

# Create the new scope content
NEW_SCOPE="## Scope

\`.meta_marge/\` is tooling, not the target. It exists to work on/improve marge itself. Work/auditing happens OUTSIDE this folder.
- **Track findings** → \`.meta_marge/system/tracking/\`
- **Never** create files from this folder elsewhere

**Workflow:**
\`\`\`
.meta_marge/AGENTS.md  →  AI audits/improves $SOURCE_NAME/  →  Changes go to $SOURCE_NAME/
Work tracked in .meta_marge/system/tracking/
Verify: .meta_marge/system/scripts/verify.ps1 fast (Windows) / .meta_marge/system/scripts/verify.sh fast (macOS/Linux)
Reset: run convert-to-meta again
\`\`\`"

# Use awk to replace from "## Scope" until the next "---"
awk -v new_scope="$NEW_SCOPE" '
    /^## Scope$/ { 
        print new_scope
        # Skip until we hit ---
        while ((getline line) > 0) {
            if (line ~ /^---/) {
                print ""
                break
            }
        }
        next
    }
    { print }
' "$AGENTS_PATH" > "${AGENTS_PATH}.tmp" && mv "${AGENTS_PATH}.tmp" "$AGENTS_PATH"

echo "  Reset tracking IDs, configured AGENTS.md scope"

if [[ -n "$PRESERVE_ROOT" ]]; then
    rm -rf "$TARGET_FOLDER/system/tracking" "$TARGET_FOLDER/system/knowledge"
    [[ -d "$PRESERVE_ROOT/tracking" ]] && cp -r "$PRESERVE_ROOT/tracking" "$TARGET_FOLDER/system/"
    [[ -d "$PRESERVE_ROOT/knowledge" ]] && cp -r "$PRESERVE_ROOT/knowledge" "$TARGET_FOLDER/system/"
    rm -rf "$PRESERVE_ROOT"
    echo "  Preserved tracking and knowledge from existing .meta_marge/"
fi

# Copy ONLY verify scripts to meta_marge (so it can use its own verify.config.json)
# The test-templates scripts live in marge-simpson/system/scripts/ - we create trigger wrappers in .meta_marge root
META_SCRIPTS_DIR="$TARGET_FOLDER/system/scripts"
mkdir -p "$META_SCRIPTS_DIR"
cp "$SOURCE_FOLDER/system/scripts/verify.ps1" "$META_SCRIPTS_DIR/"
cp "$SOURCE_FOLDER/system/scripts/verify.sh" "$META_SCRIPTS_DIR/"
chmod +x "$META_SCRIPTS_DIR/verify.sh"

# Create trigger wrappers in .meta_marge root that call the source test-templates scripts
# This keeps .meta_marge cleaner (no need for full test scripts copied in)
cat > "$TARGET_FOLDER/run-template-tests.ps1" << 'TRIGGERWRAPPER'
# Trigger wrapper - calls the real test-templates.ps1 in marge-simpson/system/scripts/
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$margeRoot = (Get-Item "$scriptDir\..").FullName
& "$margeRoot\system\scripts\test-templates.ps1" -MargeRoot $margeRoot
exit $LASTEXITCODE
TRIGGERWRAPPER

cat > "$TARGET_FOLDER/run-template-tests.sh" << 'TRIGGERWRAPPER'
#!/bin/bash
# Trigger wrapper - calls the real test-templates.sh in marge-simpson/system/scripts/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
exec "$MARGE_ROOT/system/scripts/test-templates.sh" "$MARGE_ROOT"
TRIGGERWRAPPER
chmod +x "$TARGET_FOLDER/run-template-tests.sh"

# Update verify.config.json with meta-specific paths - trigger wrappers in .meta_marge root
cat > "$TARGET_FOLDER/verify.config.json" << 'CONFIGJSON'
{
  "fast": [
    ".\\system\\scripts\\test-syntax.ps1",
    ".\\system\\scripts\\test-general.ps1",
    ".\\system\\scripts\\test-marge.ps1",
    ".\\system\\scripts\\test-cli.ps1",
    ".\\.meta_marge\\run-template-tests.ps1"
  ],
  "full": [
    ".\\system\\scripts\\test-syntax.ps1",
    ".\\system\\scripts\\test-general.ps1",
    ".\\system\\scripts\\test-marge.ps1",
    ".\\system\\scripts\\test-cli.ps1",
    ".\\.meta_marge\\run-template-tests.ps1"
  ],
  "fast_sh": [
    "marge-simpson/system/scripts/test-syntax.sh",
    "marge-simpson/system/scripts/test-general.sh",
    "marge-simpson/system/scripts/test-marge.sh",
    "marge-simpson/system/scripts/test-cli.sh",
    "./.meta_marge/run-template-tests.sh"
  ],
  "full_sh": [
    "marge-simpson/system/scripts/test-syntax.sh",
    "marge-simpson/system/scripts/test-general.sh",
    "marge-simpson/system/scripts/test-marge.sh",
    "marge-simpson/system/scripts/test-cli.sh",
    "./.meta_marge/run-template-tests.sh"
  ],
  "_comment": ".meta_marge verify config. Trigger wrappers call marge-simpson/system/scripts/test-templates.*"
}
CONFIGJSON
echo "  Added verify scripts and trigger wrappers for template tests"

# [4/4] Verify (uses meta_marge scripts which include template test)
echo "[4/4] Verifying..."
VERIFY_SCRIPT="$TARGET_FOLDER/system/scripts/verify.sh"
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
