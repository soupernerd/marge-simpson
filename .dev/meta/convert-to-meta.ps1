<#
.SYNOPSIS
    Creates .meta_marge/ for meta-development.
.DESCRIPTION
    Copies marge-simpson/ to .meta_marge/ with path transformations.
.EXAMPLE
    .\.dev\meta\convert-to-meta.ps1
    .\.dev\meta\convert-to-meta.ps1 -Force
#>

param([switch]$Force, [switch]$Update, [switch]$Help)

if ($Help) {
    Write-Host @"
convert-to-meta - Create .meta_marge/ for meta-development

USAGE:  .\.dev\meta\convert-to-meta.ps1 [-Force] [-Update] [-Help]

Creates .meta_marge/ folder. AI reads .meta_marge/AGENTS.md and
makes changes directly to marge-simpson/ (the target).

-Update preserves .meta_marge/system/tracking and .meta_marge/system/knowledge.
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

# [1/4] Remove existing / create fresh (or update)
$preserveRoot = $null
if (Test-Path $TargetFolder) {
    if ($Update) {
        $preserveRoot = Join-Path $env:TEMP ("meta_marge_preserve_" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $preserveRoot -Force | Out-Null
        $preserveTracking = Join-Path $TargetFolder "system\tracking"
        $preserveKnowledge = Join-Path $TargetFolder "system\knowledge"
        if (Test-Path $preserveTracking) {
            Copy-Item -Path $preserveTracking -Destination (Join-Path $preserveRoot "tracking") -Recurse -Force
        }
        if (Test-Path $preserveKnowledge) {
            Copy-Item -Path $preserveKnowledge -Destination (Join-Path $preserveRoot "knowledge") -Recurse -Force
        }
        Remove-Item -Path $TargetFolder -Recurse -Force
    } else {
        if (-not $Force) {
            $r = Read-Host "$TargetName exists. Overwrite? (y/N)"
            if ($r -ne "y" -and $r -ne "Y") { Write-Host "Aborted."; exit 0 }
        }
        Remove-Item -Path $TargetFolder -Recurse -Force
    }
} elseif ($Update) {
    Write-Host "[Update] Target not found; creating fresh .meta_marge/" -ForegroundColor Yellow
}
Write-Host "[1/4] Copying..."

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
$includeFiles = @('AGENTS.md')
$includeDirs = @('prompts', 'system\tracking', 'system\workflows', 'system\knowledge')

# Copy only included items
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

# Copy included files from root
foreach ($file in $includeFiles) {
    $src = Join-Path $SourceFolder $file
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination (Join-Path $TargetFolder $file) -Force
    }
}

# Copy included directories
foreach ($dir in $includeDirs) {
    $src = Join-Path $SourceFolder $dir
    if (Test-Path $src) {
        $tgt = Join-Path $TargetFolder $dir
        New-Item -ItemType Directory -Path $tgt -Force | Out-Null
        Copy-Item -Path "$src\*" -Destination $tgt -Recurse -Force
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
        # "Read marge-simpson/AGENTS.md" -> "Read .meta_marge/AGENTS.md"
        $content = $content -replace 'Read marge-simpson/AGENTS\.md', 'Read .meta_marge/AGENTS.md'
        # "Output using Response Format from marge-simpson/AGENTS.md" -> ".meta_marge/AGENTS.md"
        $content = $content -replace 'from marge-simpson/AGENTS\.md', 'from .meta_marge/AGENTS.md'
        
        # Transform tracking, workflow, and knowledge paths to .meta_marge/
        # marge-simpson/system/tracking/ -> .meta_marge/system/tracking/ (meta work is tracked here)
        # marge-simpson/system/workflows/ -> .meta_marge/system/workflows/ (meta-specific workflow copies)
        # marge-simpson/system/knowledge/ -> .meta_marge/system/knowledge/ (user data stored here)
        # BUT keep experts pointing to source (AI loads source expert files)
        $content = $content -replace 'marge-simpson/system/tracking/', '.meta_marge/system/tracking/'
        $content = $content -replace 'marge-simpson/system/workflows/', '.meta_marge/system/workflows/'
        $content = $content -replace 'marge-simpson/system/knowledge/', '.meta_marge/system/knowledge/'
        $content = $content -replace 'marge-simpson/system/scripts/verify\.ps1 fast', '.meta_marge/system/scripts/verify.ps1 fast'
        $content = $content -replace 'marge-simpson/system/scripts/verify\.sh fast', '.meta_marge/system/scripts/verify.sh fast'
        # NOTE: NOT transforming marge-simpson/system/experts/
        # Those should stay pointing to source so AI loads actual expert files
        
        # Restore explicit base tracking path markers
        $content = $content -replace '__BASE_TRACKING__', 'marge-simpson/system/tracking/'

        # Protect GitHub URLs
        $content = $content -replace "(github\.com/[^/]+/)$([regex]::Escape($SourceName))", '$1___GITHUB___'
        $content = $content -replace '___GITHUB___', $SourceName
        
        if ($content -ne $original) {
            Set-Content -Path $_.FullName -Value $content -NoNewline
            $count++
        }
    } catch {}
}
Write-Host "  $count files transformed"

# [3/4] Reset tracking files (preserve structure, just reset IDs) + rewrite AGENTS.md scope
Write-Host "[3/4] Resetting tracking IDs and configuring AGENTS.md..."

# Read source templates and reset IDs only
$assessmentSource = Get-Content -Path (Join-Path $SourceFolder "system\tracking\assessment.md") -Raw
$assessmentSource = $assessmentSource -replace '\*\*Next ID:\*\*\s*MS-\d{4}', '**Next ID:** MS-0001'
# Transform tracking paths for meta context
$assessmentSource = $assessmentSource -replace 'marge-simpson/system/tracking/', '.meta_marge/system/tracking/'
$assessmentSource = $assessmentSource -replace 'marge-simpson/system/scripts/', "$SourceName/system/scripts/"
Set-Content -Path (Join-Path $TargetFolder "system\tracking\assessment.md") -Value $assessmentSource -NoNewline

$tasklistSource = Get-Content -Path (Join-Path $SourceFolder "system\tracking\tasklist.md") -Raw
# Transform tracking paths for meta context  
$tasklistSource = $tasklistSource -replace 'marge-simpson/system/tracking/', '.meta_marge/system/tracking/'
$tasklistSource = $tasklistSource -replace 'marge-simpson/system/scripts/', "$SourceName/system/scripts/"
Set-Content -Path (Join-Path $TargetFolder "system\tracking\tasklist.md") -Value $tasklistSource -NoNewline

# Rewrite AGENTS.md scope section for meta-development
$AgentsPath = Join-Path $TargetFolder "AGENTS.md"
$agentsContent = Get-Content -Path $AgentsPath -Raw

# The source AGENTS.md has "## Scope" section - replace it with meta-specific scope
$newScope = @"
## Scope

``.meta_marge/`` is tooling, not the target. It exists to work on/improve marge itself. Work/auditing happens OUTSIDE this folder.
- **Track findings** → ``.meta_marge/system/tracking/``
- **Never** create files from this folder elsewhere

**Workflow:**
``````
.meta_marge/AGENTS.md  →  AI audits/improves $SourceName/  →  Changes go to $SourceName/
Work tracked in .meta_marge/system/tracking/
Verify: .meta_marge/system/scripts/verify.ps1 fast (Windows) / .meta_marge/system/scripts/verify.sh fast (macOS/Linux)
Reset: run convert-to-meta again
``````
"@

# Match "## Scope" followed by content until next "---"
$agentsContent = $agentsContent -replace '(?s)## Scope\r?\n.*?(?=\r?\n---)', $newScope

Set-Content -Path $AgentsPath -Value $agentsContent -NoNewline
Write-Host "  Reset tracking IDs, configured AGENTS.md scope"

if ($preserveRoot) {
    $metaTracking = Join-Path $TargetFolder "system\tracking"
    $metaKnowledge = Join-Path $TargetFolder "system\knowledge"
    if (Test-Path $metaTracking) { Remove-Item -Path $metaTracking -Recurse -Force }
    if (Test-Path $metaKnowledge) { Remove-Item -Path $metaKnowledge -Recurse -Force }
    if (Test-Path (Join-Path $preserveRoot "tracking")) {
        Copy-Item -Path (Join-Path $preserveRoot "tracking") -Destination $metaTracking -Recurse -Force
    }
    if (Test-Path (Join-Path $preserveRoot "knowledge")) {
        Copy-Item -Path (Join-Path $preserveRoot "knowledge") -Destination $metaKnowledge -Recurse -Force
    }
    Remove-Item -Path $preserveRoot -Recurse -Force
    Write-Host "  Preserved tracking and knowledge from existing .meta_marge/"
}

# Copy ONLY verify scripts to meta_marge (so it can use its own verify.config.json)
# The test-templates scripts live in marge-simpson/system/scripts/ - we create trigger wrappers in .meta_marge root
$MetaScriptsDir = Join-Path $TargetFolder "system\scripts"
New-Item -ItemType Directory -Path $MetaScriptsDir -Force | Out-Null
Copy-Item -Path (Join-Path $SourceFolder "system\scripts\verify.ps1") -Destination $MetaScriptsDir -Force
Copy-Item -Path (Join-Path $SourceFolder "system\scripts\verify.sh") -Destination $MetaScriptsDir -Force

# Create trigger wrappers in .meta_marge root that call the source test-templates scripts
# This keeps .meta_marge cleaner (no need for full test scripts copied in)
@'
# Trigger wrapper - calls the real test-templates.ps1 in marge-simpson/system/scripts/
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$margeRoot = (Get-Item "$scriptDir\..").FullName
& "$margeRoot\system\scripts\test-templates.ps1" -MargeRoot $margeRoot
exit $LASTEXITCODE
'@ | Set-Content -Path (Join-Path $TargetFolder "run-template-tests.ps1")

@'
#!/bin/bash
# Trigger wrapper - calls the real test-templates.sh in marge-simpson/system/scripts/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
exec "$MARGE_ROOT/system/scripts/test-templates.sh" "$MARGE_ROOT"
'@ | Set-Content -Path (Join-Path $TargetFolder "run-template-tests.sh")

# Update verify.config.json with meta-specific paths - trigger wrappers in .meta_marge root
$MetaVerifyConfig = @"
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
"@
Set-Content -Path (Join-Path $TargetFolder "verify.config.json") -Value $MetaVerifyConfig
Write-Host "  Added verify scripts and trigger wrappers for template tests"

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
