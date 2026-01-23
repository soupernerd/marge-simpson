<#
.SYNOPSIS
    Creates .marge_meta/ for meta-development.

.DESCRIPTION
    This script copies the current Marge folder to a sibling .marge_meta/ folder
    and transforms internal references from .marge to .marge_meta.
    
    Run this from inside a .marge folder (or any Marge folder at repo root).
    It creates a meta-development copy for testing changes to Marge itself.

.PARAMETER Force
    Overwrite existing .marge_meta/ folder without prompting.

.EXAMPLE
    .\meta\convert-to-meta.ps1
    
.EXAMPLE
    .\meta\convert-to-meta.ps1 -Force
#>

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Determine source folder (where the Marge files are)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# If script is in meta/, go up one level to find the Marge root
if ((Split-Path -Leaf $ScriptDir) -eq "meta") {
    $SourceFolder = Split-Path -Parent $ScriptDir
} else {
    $SourceFolder = $ScriptDir
}

# Detect source folder name
$SourceName = Split-Path -Leaf $SourceFolder

# Handle common folder names
if ($SourceName -eq ".marge") {
    $TargetName = ".marge_meta"
} elseif ($SourceName -eq "marge_simpson") {
    $TargetName = "meta_marge"
} elseif ($SourceName -eq ".marge_meta" -or $SourceName -eq "meta_marge") {
    Write-Host "ERROR: Already in a meta-development folder ($SourceName)" -ForegroundColor Red
    Write-Host "This script creates the meta folder - you're already in one."
    exit 1
} else {
    # Generic case: append _meta
    $TargetName = "${SourceName}_meta"
}

# Target is a sibling folder
$TargetFolder = Join-Path (Split-Path -Parent $SourceFolder) $TargetName

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Convert $SourceName -> $TargetName" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Source: $SourceFolder"
Write-Host "Target: $TargetFolder"
Write-Host ""

# Validate source has AGENTS.md (confirms it's a Marge folder)
if (-not (Test-Path (Join-Path $SourceFolder "AGENTS.md"))) {
    Write-Host "ERROR: Not a valid Marge folder (no AGENTS.md found)" -ForegroundColor Red
    Write-Host "Run this script from inside a Marge folder or repo root."
    exit 1
}

# Check if target exists
if (Test-Path $TargetFolder) {
    if (-not $Force) {
        $response = Read-Host "$TargetName already exists. Overwrite? (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Host "Aborted."
            exit 0
        }
    }
    Write-Host "[1/5] Removing existing $TargetName..."
    Remove-Item -Path $TargetFolder -Recurse -Force
} else {
    Write-Host "[1/5] Target folder does not exist, will create fresh."
}

# Copy folder (excluding .git, node_modules, etc.)
Write-Host "[2/5] Copying $SourceName -> $TargetName..."

# Get all items excluding certain folders
$excludeDirs = @('.git', 'node_modules', '.marge_meta', 'meta_marge')
$items = Get-ChildItem -Path $SourceFolder -Recurse -Force | Where-Object {
    $exclude = $false
    foreach ($dir in $excludeDirs) {
        if ($_.FullName -like "*\$dir\*" -or $_.FullName -like "*\$dir") {
            $exclude = $true
            break
        }
    }
    -not $exclude
}

# Create target folder
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

# Copy structure
foreach ($item in $items) {
    $relativePath = $item.FullName.Substring($SourceFolder.Length + 1)
    $targetPath = Join-Path $TargetFolder $relativePath
    
    if ($item.PSIsContainer) {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    } else {
        $targetDir = Split-Path -Parent $targetPath
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        Copy-Item -Path $item.FullName -Destination $targetPath -Force
    }
}

# Text file extensions to transform
$TextExtensions = @('md', 'txt', 'json', 'yml', 'yaml', 'toml', 'ps1', 'sh', 'bash', 'zsh', 'py', 'js', 'ts', 'jsx', 'tsx', 'html', 'css', 'scss', 'less', 'xml', 'config', 'cfg', 'ini', 'env', 'gitignore', 'dockerignore', 'sql', 'graphql', 'prisma')
$TextFilenames = @('Makefile', 'Dockerfile', 'Jenkinsfile', 'Procfile', 'LICENSE', 'README', 'CHANGELOG', 'CONTRIBUTING', 'VERSION')

Write-Host "[3/5] Transforming file contents..."

$TransformedCount = 0
$SkippedCount = 0

# Get all files in target folder
$files = Get-ChildItem -Path $TargetFolder -Recurse -File -Force

foreach ($file in $files) {
    $ext = $file.Extension.TrimStart('.')
    $filename = $file.Name
    
    $isText = $false
    if ($ext -in $TextExtensions) {
        $isText = $true
    } elseif ($filename -in $TextFilenames) {
        $isText = $true
    } elseif ([string]::IsNullOrEmpty($ext)) {
        # No extension - assume text for known files
        $isText = $true
    }
    
    if (-not $isText) {
        $SkippedCount++
        continue
    }
    
    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
        if ($null -eq $content) {
            $SkippedCount++
            continue
        }
        
        $originalContent = $content
        
        # Apply replacements
        $content = $content -replace [regex]::Escape("$SourceName/"), "$TargetName/"
        $content = $content -replace [regex]::Escape("[$SourceName]"), "[$TargetName]"
        $content = $content -replace [regex]::Escape("'$SourceName'"), "'$TargetName'"
        $content = $content -replace [regex]::Escape("`"$SourceName`""), "`"$TargetName`""
        $content = $content -replace [regex]::Escape("``$SourceName``"), "``$TargetName``"
        $content = $content -replace " $([regex]::Escape($SourceName)) ", " $TargetName "
        $content = $content -replace " $([regex]::Escape($SourceName))\.", " $TargetName."
        $content = $content -replace " $([regex]::Escape($SourceName)),", " $TargetName,"
        $content = $content -replace " $([regex]::Escape($SourceName)):", " $TargetName:"
        $content = $content -replace "\($([regex]::Escape($SourceName))\)", "($TargetName)"
        $content = $content -replace ": $([regex]::Escape($SourceName))", ": $TargetName"
        $content = $content -replace "# $([regex]::Escape($SourceName))", "# $TargetName"
        $content = $content -replace "=$([regex]::Escape($SourceName))", "=$TargetName"
        
        # Word boundary replacement
        $content = $content -replace "(?<![a-zA-Z0-9_])$([regex]::Escape($SourceName))(?![a-zA-Z0-9_])", $TargetName
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $relativePath = $file.FullName.Substring($TargetFolder.Length + 1)
            Write-Host "  Transformed: $relativePath"
            $TransformedCount++
        }
    } catch {
        $SkippedCount++
    }
}

Write-Host "  $TransformedCount files transformed, $SkippedCount skipped (binary/non-text)"

# Reset work queues for fresh meta-development
Write-Host "[4/5] Resetting work queues..."

# Reset assessment.md
$AssessmentPath = Join-Path $TargetFolder "assessment.md"
if (Test-Path $AssessmentPath) {
    $assessmentContent = @"
# $TargetName Assessment

> This file tracks issues found in the Marge system itself (meta-development).
> Use this to improve the production Marge before copying changes back.

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
"@
    Set-Content -Path $AssessmentPath -Value $assessmentContent
    Write-Host "  Reset: assessment.md"
}

# Reset tasklist.md
$TasklistPath = Join-Path $TargetFolder "tasklist.md"
if (Test-Path $TasklistPath) {
    $tasklistContent = @"
# $TargetName Tasklist

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
"@
    Set-Content -Path $TasklistPath -Value $tasklistContent
    Write-Host "  Reset: tasklist.md"
}

# Remove the conditional clause from AGENTS.md if present
$AgentsPath = Join-Path $TargetFolder "AGENTS.md"
if (Test-Path $AgentsPath) {
    $agentsContent = Get-Content -Path $AgentsPath -Raw
    $conditionalPattern = ", unless ``$TargetName/`` exists and is being used to update Marge"
    if ($agentsContent -match [regex]::Escape($conditionalPattern)) {
        $agentsContent = $agentsContent -replace [regex]::Escape($conditionalPattern), ""
        Set-Content -Path $AgentsPath -Value $agentsContent -NoNewline
        Write-Host "  Updated: AGENTS.md (removed conditional clause)"
    }
}

# Verify the conversion
Write-Host "[5/5] Verifying conversion..."

# Check for any remaining source name references
$RemainingRefs = 0
foreach ($file in (Get-ChildItem -Path $TargetFolder -Recurse -File -Force)) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match "\b$([regex]::Escape($SourceName))\b") {
            $relativePath = $file.FullName.Substring($TargetFolder.Length + 1)
            Write-Host "  Note: '$SourceName' still found in: $relativePath (may be intentional)"
            $RemainingRefs++
        }
    } catch {
        # Skip binary files
    }
}

# Run verification if verify script exists
$VerifyScript = Join-Path $TargetFolder "scripts\verify.ps1"
if (Test-Path $VerifyScript) {
    Write-Host ""
    try {
        & $VerifyScript fast
        $VerifyExit = $LASTEXITCODE
    } catch {
        $VerifyExit = 1
    }
    
    if ($VerifyExit -eq 0) {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host " SUCCESS: $TargetName created and verified!" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now use $TargetName for meta-development."
        Write-Host "Changes made there can be tested before copying back to $SourceName."
    } else {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host " WARNING: Conversion complete but verification had issues" -ForegroundColor Yellow
        Write-Host "============================================================" -ForegroundColor Yellow
    }
    
    exit $VerifyExit
} else {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " DONE: $TargetName created" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run: $TargetName\scripts\verify.ps1 fast"
    exit 0
}
