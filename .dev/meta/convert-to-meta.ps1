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

# [3/4] Reset work queues + rewrite AGENTS.md scope
Write-Host "[3/4] Resetting work queues..."

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
**Scope (CRITICAL):**
1. This folder (``.meta_marge/``) is the **control plane** for improving ``$SourceName/``.
2. Audit ``$SourceName/`` (the target). Track findings HERE in ``.meta_marge/system/tracking/``.
3. Never create ``.meta_marge`` files outside this folder.

**Meta-Development Workflow:**
``````
  .meta_marge/AGENTS.md  ->  AI audits $SourceName/  ->  Changes to $SourceName/
  Work tracked in .meta_marge/system/tracking/
  Verify using: $SourceName/system/scripts/verify.ps1 fast
  When done: run convert-to-meta again to reset
``````

**IMPORTANT:** ``.meta_marge/`` is the control plane, NOT a sandbox.
"@

$agentsContent = $agentsContent -replace '\*\*Scope \(CRITICAL\):\*\*\r?\n1\.[^\r\n]+\r?\n2\.[^\r\n]+\r?\n3\.[^\r\n]+', $newScope
Set-Content -Path $AgentsPath -Value $agentsContent -NoNewline
Write-Host "  Reset assessment.md, tasklist.md, AGENTS.md"

# [4/4] Verify (uses source scripts, not meta_marge)
Write-Host "[4/4] Verifying..."
$VerifyScript = Join-Path $SourceFolder "system\scripts\verify.ps1"
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
