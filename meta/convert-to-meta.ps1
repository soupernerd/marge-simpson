<#
.SYNOPSIS
    Creates .meta_marge/ for meta-development.
.DESCRIPTION
    Copies marge-simpson/ to .meta_marge/ with path transformations.
.EXAMPLE
    .\meta\convert-to-meta.ps1
    .\meta\convert-to-meta.ps1 -Force
#>

param([switch]$Force, [switch]$Help)

if ($Help) {
    Write-Host @"
convert-to-meta - Create .meta_marge/ for meta-development

USAGE:  .\meta\convert-to-meta.ps1 [-Force] [-Help]

Creates .meta_marge/ folder. AI reads .meta_marge/AGENTS.md and
makes changes directly to marge-simpson/ (the target).
"@
    exit 0
}

$ErrorActionPreference = "Stop"

# Locate source folder
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceFolder = if ((Split-Path -Leaf $ScriptDir) -eq "meta") { Split-Path -Parent $ScriptDir } else { $ScriptDir }
$SourceName = Split-Path -Leaf $SourceFolder
$TargetName = ".meta_marge"
$TargetFolder = Join-Path $SourceFolder $TargetName

# Validate
if ($SourceName -eq ".meta_marge") { Write-Host "ERROR: Already in meta folder" -ForegroundColor Red; exit 1 }
if (-not (Test-Path (Join-Path $SourceFolder "AGENTS.md"))) { Write-Host "ERROR: No AGENTS.md found" -ForegroundColor Red; exit 1 }

Write-Host "`n===== Convert $SourceName -> $TargetName =====`n" -ForegroundColor Cyan

# [1/4] Remove existing / create fresh
if (Test-Path $TargetFolder) {
    if (-not $Force) {
        $r = Read-Host "$TargetName exists. Overwrite? (y/N)"
        if ($r -ne "y" -and $r -ne "Y") { Write-Host "Aborted."; exit 0 }
    }
    Remove-Item -Path $TargetFolder -Recurse -Force
}
Write-Host "[1/4] Copying..."

# Exclusions
$excludeDirs = @('.git', 'node_modules', '.meta_marge', '.marge', 'cli', 'meta', 'assets', '.github')
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

# [2/4] Transform: marge-simpson/ -> .meta_marge/
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
        
        # Protect GitHub URLs
        $content = $content -replace "(github\.com/[^/]+/)$([regex]::Escape($SourceName))", '$1___GITHUB___'
        
        # Single word-boundary replacement for folder name
        $content = $content -replace "(?<![a-zA-Z0-9_./])$([regex]::Escape($SourceName))(?![a-zA-Z0-9_])", $TargetName
        
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
"@ | Set-Content -Path (Join-Path $TargetFolder "planning_docs\assessment.md")

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
"@ | Set-Content -Path (Join-Path $TargetFolder "planning_docs\tasklist.md")

# Rewrite AGENTS.md scope section
$AgentsPath = Join-Path $TargetFolder "AGENTS.md"
$agentsContent = Get-Content -Path $AgentsPath -Raw

$newScope = @"
**Scope (CRITICAL):**
1. The ``$TargetName/`` folder is **excluded from audits** -- it is the tooling, not the target.
2. Audit the workspace/repo OUTSIDE this folder (e.g., ``marge-simpson/``).
3. Track findings HERE in ``$TargetName/planning_docs/`` assessment.md and tasklist.md.
4. Never create ``$TargetName`` files outside this folder.

**Meta-Development Workflow:**
``````
  .meta_marge/AGENTS.md  ->  AI audits marge-simpson/  ->  Changes to marge-simpson/
  Work tracked in .meta_marge/planning_docs/
  When done: run convert-to-meta again to reset
``````

**IMPORTANT:** ``.meta_marge/`` is the control plane, NOT a sandbox.
"@

$agentsContent = $agentsContent -replace '\*\*Scope \(CRITICAL\):\*\*\r?\n1\.[^\r\n]+\r?\n2\.[^\r\n]+\r?\n3\.[^\r\n]+', $newScope
Set-Content -Path $AgentsPath -Value $agentsContent -NoNewline
Write-Host "  Reset assessment.md, tasklist.md, AGENTS.md"

# [4/4] Verify
Write-Host "[4/4] Verifying..."
$VerifyScript = Join-Path $TargetFolder "scripts\verify.ps1"
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
