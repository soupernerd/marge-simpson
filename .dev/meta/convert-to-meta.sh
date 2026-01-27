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
    rsync -a \
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
    # "Read the AGENTS.md file in the marge-simpson folder" -> "Read the AGENTS.md file in the .meta_marge folder"
    content=${content//"Read the AGENTS.md file in the marge-simpson folder"/"Read the AGENTS.md file in the .meta_marge folder"}
    
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

# [3/4] Reset work queues + rewrite AGENTS.md scope + add meta-only scripts
echo "[3/4] Resetting work queues and adding meta-only scripts..."

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

# Copy verify scripts to meta_marge (so it can use its own verify.config.json)
META_SCRIPTS_DIR="$TARGET_FOLDER/system/scripts"
mkdir -p "$META_SCRIPTS_DIR"
cp "$SOURCE_FOLDER/system/scripts/verify.ps1" "$META_SCRIPTS_DIR/"
cp "$SOURCE_FOLDER/system/scripts/verify.sh" "$META_SCRIPTS_DIR/"
chmod +x "$META_SCRIPTS_DIR/verify.sh"

# Create test-templates.sh (meta-only template pollution guard)
cat > "$META_SCRIPTS_DIR/test-templates.sh" << 'TESTSCRIPT'
#!/bin/bash
# Meta-Marge Template Pollution Test - validates marge-simpson/ templates are pristine
# IMPORTANT: This test checks REGULAR marge-simpson/ templates, NOT .meta_marge/ copies.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Script is at .meta_marge/system/scripts/ - go up 3 levels to reach marge-simpson/
MARGE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Verify we're checking the RIGHT folder (marge-simpson, not .meta_marge)
FOLDER_NAME="$(basename "$MARGE_ROOT")"
if [[ "$FOLDER_NAME" == ".meta_marge" ]]; then
    echo "ERROR: Test is checking .meta_marge/ instead of marge-simpson/!"
    exit 1
fi

echo ""; echo "============================================================"
echo " Template Pollution Tests (Meta-Marge Only)"
echo " Checking: $MARGE_ROOT"
echo "============================================================"; echo ""

passed=0; failed=0

test_template_clean() {
    local file_path="$1" pattern="$2" description="$3"
    local full_path="$MARGE_ROOT/$file_path"
    [[ ! -f "$full_path" ]] && { echo "  [SKIP] $description - file not found"; return 0; }
    local content_no_comments=$(perl -0777 -pe 's/<!--.*?-->//gs' "$full_path" 2>/dev/null || cat "$full_path")
    if echo "$content_no_comments" | grep -qE "$pattern" 2>/dev/null; then
        echo "  [FAIL] $description"; echo "         Found prohibited pattern: $pattern"; return 1
    fi
    echo "  [PASS] $description"; return 0
}

echo "[1/4] Checking system/tracking/assessment.md..."
test_template_clean "system/tracking/assessment.md" '### \[MS-[0-9]{4}\]' "No real MS-#### entries" && ((passed++)) || ((failed++))
[[ -f "$MARGE_ROOT/system/tracking/assessment.md" ]] && {
    grep -qE "Next ID:\*{0,2}.*MS-0001" "$MARGE_ROOT/system/tracking/assessment.md" 2>/dev/null && { echo "  [PASS] Pristine Next ID"; ((passed++)); } || { echo "  [FAIL] Next ID incremented"; ((failed++)); }
}

echo ""; echo "[2/4] Checking system/tracking/tasklist.md..."
test_template_clean "system/tracking/tasklist.md" '- \[x\] \*\*MS-[0-9]{4}' "No completed MS-#### items" && ((passed++)) || ((failed++))

echo ""; echo "[3/4] Checking system/knowledge/decisions.md..."
test_template_clean "system/knowledge/decisions.md" '### \[D-[0-9]{3}\]' "No real D-### entries" && ((passed++)) || ((failed++))

echo ""; echo "[4/4] Checking system/knowledge/ other files..."
test_template_clean "system/knowledge/patterns.md" '### \[P-[0-9]{3}\]' "No real P-### entries" && ((passed++)) || ((failed++))
test_template_clean "system/knowledge/insights.md" '### \[I-[0-9]{3}\]' "No real I-### entries" && ((passed++)) || ((failed++))
test_template_clean "system/knowledge/preferences.md" '### \[PR-[0-9]{3}\]' "No real PR-### entries" && ((passed++)) || ((failed++))

echo ""; echo "============================================================"
echo " Summary: Passed=$passed Failed=$failed"
echo "============================================================"; echo ""

[[ $failed -gt 0 ]] && { echo -e "\033[31mTEMPLATE POLLUTION DETECTED!\033[0m"; exit 1; }
echo -e "\033[32mAll template pollution tests passed!\033[0m"; exit 0
TESTSCRIPT
chmod +x "$META_SCRIPTS_DIR/test-templates.sh"

# Create test-templates.ps1 (PowerShell version)
cat > "$META_SCRIPTS_DIR/test-templates.ps1" << 'TESTSCRIPT'
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$margeRoot = (Get-Item "$scriptDir\..\..\..").FullName

Write-Host "`n============================================================"
Write-Host " Template Pollution Tests (Meta-Marge Only)"
Write-Host "============================================================`n"

$passed = 0; $failed = 0

function Test-TemplateClean {
    param([string]$FilePath, [string]$MustNotContain, [string]$Description)
    $fullPath = Join-Path $margeRoot $FilePath
    if (-not (Test-Path $fullPath)) { Write-Host "  [SKIP] $Description - file not found"; return $true }
    $content = Get-Content $fullPath -Raw
    $contentNoComments = $content -replace '(?s)<!--.*?-->', ''
    if ($contentNoComments -match $MustNotContain) {
        Write-Host "  [FAIL] $Description"
        Write-Host "         Found prohibited pattern: $MustNotContain"
        return $false
    }
    Write-Host "  [PASS] $Description"
    return $true
}

Write-Host "[1/4] Checking system/tracking/assessment.md..."
if (Test-TemplateClean -FilePath "system\tracking\assessment.md" -MustNotContain "### \[MS-\d{4}\]" -Description "No real MS-#### entries") { $passed++ } else { $failed++ }
$ap = Join-Path $margeRoot "system\tracking\assessment.md"
if (Test-Path $ap) {
    $c = Get-Content $ap -Raw
    if ($c -match "Next ID:\*{0,2}\s*MS-0001") { Write-Host "  [PASS] Pristine Next ID (MS-0001)"; $passed++ }
    else { Write-Host "  [FAIL] Next ID incremented (should be MS-0001)"; $failed++ }
}

Write-Host "`n[2/4] Checking system/tracking/tasklist.md..."
if (Test-TemplateClean -FilePath "system\tracking\tasklist.md" -MustNotContain "- \[x\] \*\*MS-\d{4}" -Description "No completed MS-#### items") { $passed++ } else { $failed++ }

Write-Host "`n[3/4] Checking system/knowledge/decisions.md..."
if (Test-TemplateClean -FilePath "system\knowledge\decisions.md" -MustNotContain "### \[D-\d{3}\]" -Description "No real D-### entries") { $passed++ } else { $failed++ }

Write-Host "`n[4/4] Checking system/knowledge/ other files..."
if (Test-TemplateClean -FilePath "system\knowledge\patterns.md" -MustNotContain "### \[P-\d{3}\]" -Description "No real P-### entries") { $passed++ } else { $failed++ }
if (Test-TemplateClean -FilePath "system\knowledge\insights.md" -MustNotContain "### \[I-\d{3}\]" -Description "No real I-### entries") { $passed++ } else { $failed++ }
if (Test-TemplateClean -FilePath "system\knowledge\preferences.md" -MustNotContain "### \[PR-\d{3}\]" -Description "No real PR-### entries") { $passed++ } else { $failed++ }

Write-Host "`n============================================================"
Write-Host " Summary: Passed=$passed Failed=$failed"
Write-Host "============================================================`n"

if ($failed -gt 0) { Write-Host "TEMPLATE POLLUTION DETECTED!" -ForegroundColor Red; exit 1 }
Write-Host "All template pollution tests passed!" -ForegroundColor Green; exit 0
TESTSCRIPT

# Update verify.config.json with meta-specific paths including template test
cat > "$TARGET_FOLDER/verify.config.json" << 'CONFIGJSON'
{
  "fast": [
    ".\\system\\scripts\\test-syntax.ps1",
    ".\\system\\scripts\\test-general.ps1",
    ".\\system\\scripts\\test-marge.ps1",
    ".\\system\\scripts\\test-cli.ps1",
    ".\\.meta_marge\\system\\scripts\\test-templates.ps1"
  ],
  "full": [
    ".\\system\\scripts\\test-syntax.ps1",
    ".\\system\\scripts\\test-general.ps1",
    ".\\system\\scripts\\test-marge.ps1",
    ".\\system\\scripts\\test-cli.ps1",
    ".\\.meta_marge\\system\\scripts\\test-templates.ps1"
  ],
  "fast_sh": [
    "./system/scripts/test-syntax.sh",
    "./system/scripts/test-general.sh",
    "./system/scripts/test-marge.sh",
    "./system/scripts/test-cli.sh",
    "./.meta_marge/system/scripts/test-templates.sh"
  ],
  "full_sh": [
    "./system/scripts/test-syntax.sh",
    "./system/scripts/test-general.sh",
    "./system/scripts/test-marge.sh",
    "./system/scripts/test-cli.sh",
    "./.meta_marge/system/scripts/test-templates.sh"
  ],
  "_comment": ".meta_marge verify config. Paths relative to marge-simpson/ (repo root).",
  "_meta_note": "test-templates only exists in .meta_marge/ - guards against AI polluting template files."
}
CONFIGJSON

echo "  Added verify scripts and test-templates to .meta_marge/system/scripts/"

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
