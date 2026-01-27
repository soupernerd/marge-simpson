<#
.SYNOPSIS
    Creates .meta_marge/ for meta-development.
.DESCRIPTION
    Copies marge-simpson/ to .meta_marge/ with path transformations.
.EXAMPLE
    .\.dev\meta\convert-to-meta.ps1
    .\.dev\meta\convert-to-meta.ps1 -Force
#>

param([switch]$Force, [switch]$Help)

if ($Help) {
    Write-Host @"
convert-to-meta - Create .meta_marge/ for meta-development

USAGE:  .\.dev\meta\convert-to-meta.ps1 [-Force] [-Help]

Creates .meta_marge/ folder. AI reads .meta_marge/AGENTS.md and
makes changes directly to marge-simpson/ (the target).
"@
    exit 0
}

$ErrorActionPreference = "Stop"

# Locate source folder - handle both repo and global install structures
# Script is at: .dev/meta/convert-to-meta.ps1 (repo) or $MARGE_HOME/shared/.dev/meta/ (global)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path  # .dev/meta
$DevDir = Split-Path -Parent $ScriptDir                       # .dev
$RepoRoot = Split-Path -Parent $DevDir                        # marge-simpson (repo root)
$DevDirParentName = Split-Path -Leaf $RepoRoot
$TargetName = ".meta_marge"

# Detect if running from global install ($MARGE_HOME/shared/.dev/meta/) vs repo (.dev/meta/)
if ($DevDirParentName -eq "shared" -and (Test-Path (Join-Path $RepoRoot "AGENTS.md"))) {
    # Global install: source is $MARGE_HOME/shared/
    $SourceFolder = $RepoRoot
    $SourceName = "marge-simpson"  # Use standard name for display
    $TargetFolder = Join-Path (Get-Location) ".meta_marge"
    $IsGlobalInstall = $true
} else {
    # Repo structure: source is repo root (two levels up from .dev/meta/)
    $SourceFolder = $RepoRoot
    $SourceName = Split-Path -Leaf $SourceFolder
    $TargetFolder = Join-Path $SourceFolder $TargetName
    $IsGlobalInstall = $false
}

# Validate
if ($SourceName -eq ".meta_marge") { Write-Host "ERROR: Already in meta folder" -ForegroundColor Red; exit 1 }
if (-not (Test-Path (Join-Path $SourceFolder "AGENTS.md"))) { Write-Host "ERROR: No AGENTS.md found in $SourceFolder" -ForegroundColor Red; exit 1 }

Write-Host "`n===== Convert $SourceName -> $TargetName =====`n" -ForegroundColor Cyan
if ($IsGlobalInstall) { Write-Host "[Global install mode - creating in current directory]`n" -ForegroundColor Yellow }

# [1/4] Remove existing / create fresh
if (Test-Path $TargetFolder) {
    if (-not $Force) {
        $r = Read-Host "$TargetName exists. Overwrite? (y/N)"
        if ($r -ne "y" -and $r -ne "Y") { Write-Host "Aborted."; exit 0 }
    }
    Remove-Item -Path $TargetFolder -Recurse -Force
}
Write-Host "[1/4] Copying..."

# Exclusions (scripts/ excluded - meta_marge uses marge-simpson/scripts/ directly)
$excludeDirs = @('.git', 'node_modules', '.meta_marge', '.marge', '.dev', 'cli', 'meta', 'assets', '.github', 'scripts')
$excludeFiles = @('README.md', 'CHANGELOG.md', 'VERSION', 'LICENSE', '.gitignore', '.gitattributes')

# Copy with exclusions
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
Get-ChildItem -Path $SourceFolder -Recurse -Force | Where-Object {
    $dominated = $false
    foreach ($d in $excludeDirs) { if ($_.FullName -like "*\$d\*" -or $_.FullName -like "*\$d") { $dominated = $true; break } }
    if (-not $dominated -and -not $_.PSIsContainer) {
        $rel = $_.FullName.Substring($SourceFolder.Length + 1)
        if ($rel -in $excludeFiles) { $dominated = $true }
    }
    -not $dominated
} | ForEach-Object {
    $rel = $_.FullName.Substring($SourceFolder.Length + 1)
    $tgt = Join-Path $TargetFolder $rel
    if ($_.PSIsContainer) { New-Item -ItemType Directory -Path $tgt -Force | Out-Null }
    else {
        $dir = Split-Path -Parent $tgt
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item -Path $_.FullName -Destination $tgt -Force
    }
}

# [2/4] Transform: relative paths (./) -> .meta_marge/ AND explicit verify paths
Write-Host "[2/4] Transforming paths..."
$TextExt = @('md','txt','json','yml','yaml','toml','ps1','sh','py','js','ts')
$count = 0

Get-ChildItem -Path $TargetFolder -Recurse -File -Force | ForEach-Object {
    $ext = $_.Extension.TrimStart('.')
    if ($ext -notin $TextExt -and $_.Name -notmatch '^(Makefile|Dockerfile)$') { return }
    
    try {
        $content = Get-Content -Path $_.FullName -Raw -ErrorAction Stop
        if (-not $content) { return }
        $original = $content
        
        # Transform AGENTS.md references in prompts
        # "Read the AGENTS.md file in the marge-simpson folder" -> "Read the AGENTS.md file in the .meta_marge folder"
        $content = $content -replace 'Read the AGENTS\.md file in the marge-simpson folder', 'Read the AGENTS.md file in the .meta_marge folder'
        # Also handle "this folder" pattern used in orig_prompts
        $content = $content -replace 'Read the AGENTS\.md file in this folder', 'Read the AGENTS.md file in the .meta_marge folder'
        
        # Transform relative paths to explicit .meta_marge/ paths
        # ./system/tracking/ -> .meta_marge/system/tracking/
        # ./system/workflows/ -> .meta_marge/system/workflows/
        # ./system/experts/ -> .meta_marge/system/experts/
        # ./system/knowledge/ -> .meta_marge/system/knowledge/
        # But NOT ./system/scripts/ - those should point to source (marge-simpson/system/scripts/)
        $content = $content -replace '\./(system/)?tracking/', '.meta_marge/system/tracking/'
        $content = $content -replace '\./(system/)?workflows/', '.meta_marge/system/workflows/'
        $content = $content -replace '\./(system/)?experts/', '.meta_marge/system/experts/'
        $content = $content -replace '\./(system/)?knowledge/', '.meta_marge/system/knowledge/'
        $content = $content -replace '\./(system/)?model_pricing\.json', '.meta_marge/model_pricing.json'
        
        # Scripts should use source folder for verification (test the source, not meta)
        $content = $content -replace '\./(system/)?scripts/', "$SourceName/system/scripts/"
        
        # Legacy: also handle any remaining explicit source folder references
        # Protect GitHub URLs first
        $content = $content -replace "(github\.com/[^/]+/)$([regex]::Escape($SourceName))", '$1___GITHUB___'
        
        # Restore GitHub URLs
        $content = $content -replace '___GITHUB___', $SourceName
        
        if ($content -ne $original) {
            Set-Content -Path $_.FullName -Value $content -NoNewline
            $count++
        }
    } catch {}
}
Write-Host "  $count files transformed"

# [3/4] Reset work queues + rewrite AGENTS.md scope + add meta-only scripts
Write-Host "[3/4] Resetting work queues and adding meta-only scripts..."

@"
# $TargetName Assessment

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
"@ | Set-Content -Path (Join-Path $TargetFolder "system\tracking\assessment.md")

@"
# $TargetName Tasklist

> Work queue for meta-development.

**Next ID:** MS-0001

---

## Backlog
_None_

## In-Progress
_None_

## Done
_None_
"@ | Set-Content -Path (Join-Path $TargetFolder "system\tracking\tasklist.md")

# Rewrite AGENTS.md scope section for meta-development
$AgentsPath = Join-Path $TargetFolder "AGENTS.md"
$agentsContent = Get-Content -Path $AgentsPath -Raw

$newScope = @"
## Scope (Critical) (Hard)

**This is the control plane for improving ``$SourceName/``.**
- **Track findings** → ``.meta_marge/system/tracking/``
- **Make changes** → ``$SourceName/`` (the target, NOT .meta_marge/)
- **Never** create ``.meta_marge`` files outside this folder

**Meta-Development Workflow:**
``````
  .meta_marge/AGENTS.md  ->  AI audits $SourceName/  ->  Changes to $SourceName/
  Work tracked in .meta_marge/system/tracking/
  Verify using: $SourceName/system/scripts/verify.ps1 fast
  When done: run convert-to-meta again to reset
``````
"@

# Match the actual AGENTS.md format: ## Scope (Critical) (Hard) followed by content until next ##
$agentsContent = $agentsContent -replace '(?s)## Scope \(Critical\) \(Hard\).*?(?=\r?\n---)', $newScope
Set-Content -Path $AgentsPath -Value $agentsContent -NoNewline
Write-Host "  Reset assessment.md, tasklist.md, AGENTS.md"

# Copy verify scripts to meta_marge (so it can use its own verify.config.json)
$MetaScriptsDir = Join-Path $TargetFolder "system\scripts"
New-Item -ItemType Directory -Path $MetaScriptsDir -Force | Out-Null
Copy-Item -Path (Join-Path $SourceFolder "system\scripts\verify.ps1") -Destination $MetaScriptsDir -Force
Copy-Item -Path (Join-Path $SourceFolder "system\scripts\verify.sh") -Destination $MetaScriptsDir -Force

# Create test-templates.ps1 (meta-only template pollution guard)
@'
<#
.SYNOPSIS
    Meta-Marge Template Pollution Test
.DESCRIPTION
    Validates that template files in marge-simpson/ remain pristine.
    This test ONLY exists in .meta_marge/ - regular users won't have it.
    
    IMPORTANT: This test checks REGULAR marge-simpson/ templates, NOT .meta_marge/ copies.
#>

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Script is at .meta_marge/system/scripts/ - go up 3 levels to reach marge-simpson/
$margeRoot = (Get-Item "$scriptDir\..\..\..").FullName

# Verify we're checking the RIGHT folder (marge-simpson, not .meta_marge)
$folderName = Split-Path -Leaf $margeRoot
if ($folderName -eq ".meta_marge") {
    Write-Host "ERROR: Test is checking .meta_marge/ instead of marge-simpson/!" -ForegroundColor Red
    exit 1
}

Write-Host "`n============================================================"
Write-Host " Template Pollution Tests (Meta-Marge Only)"
Write-Host " Checking: $margeRoot"
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

if ($failed -gt 0) {
    Write-Host "TEMPLATE POLLUTION DETECTED!" -ForegroundColor Red
    Write-Host "Template files in marge-simpson/ must remain pristine." -ForegroundColor Yellow
    exit 1
}
Write-Host "All template pollution tests passed!" -ForegroundColor Green
exit 0
'@ | Set-Content -Path (Join-Path $MetaScriptsDir "test-templates.ps1")

# Create test-templates.sh (bash version)
@'
#!/bin/bash
# Meta-Marge Template Pollution Test - validates marge-simpson/ templates are pristine
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARGE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo ""; echo "============================================================"
echo " Template Pollution Tests (Meta-Marge Only)"
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
'@ | Set-Content -Path (Join-Path $MetaScriptsDir "test-templates.sh")

# Update verify.config.json with meta-specific paths including template test
$MetaVerifyConfig = @"
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
"@
Set-Content -Path (Join-Path $TargetFolder "verify.config.json") -Value $MetaVerifyConfig
Write-Host "  Added verify scripts and test-templates to .meta_marge/system/scripts/"

# [4/4] Verify (uses meta_marge scripts which include template test)
Write-Host "[4/4] Verifying..."
$VerifyScript = Join-Path $TargetFolder "system\scripts\verify.ps1"
if (Test-Path $VerifyScript) {
    & $VerifyScript fast
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Host "`n===== SUCCESS: $TargetName created =====" -ForegroundColor Green
    } else {
        Write-Host "`n===== WARNING: Verification had issues =====" -ForegroundColor Yellow
    }
    exit $exitCode
} else {
    Write-Host "`n===== DONE: $TargetName created =====" -ForegroundColor Green
    exit 0
}
