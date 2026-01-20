<#
install.ps1
Copies the drop-in `marge_simpson` folder into the current directory (your project root).

Usage (PowerShell):
  # from inside the cloned repo folder:
  powershell -ExecutionPolicy Bypass -File .\install.ps1

Optional:
  powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target "C:\path\to\project" -Force
#>

param(
  [string]$Target = ".",
  [switch]$Force
)

$src = Join-Path $PSScriptRoot "marge_simpson"
if (-not (Test-Path $src)) {
  Write-Error "Could not find source folder: $src"
  exit 1
}

$resolvedTarget = Resolve-Path $Target -ErrorAction SilentlyContinue
if (-not $resolvedTarget) {
  New-Item -ItemType Directory -Path $Target -Force | Out-Null
  $resolvedTarget = Resolve-Path $Target
}

$dst = Join-Path $resolvedTarget "marge_simpson"

if (Test-Path $dst) {
  if (-not $Force) {
    Write-Host "Destination already exists: $dst"
    Write-Host "Re-run with -Force to overwrite."
    exit 1
  }
  Remove-Item -Recurse -Force $dst
}

Copy-Item -Recurse -Force $src $dst

# Validate installation
# Note: verify.ps1 and verify.sh are in the scripts/ subfolder
$requiredFiles = @(
  "AGENTS.md",
  "scripts/verify.ps1",
  "scripts/verify.sh",
  "verify.config.json",
  "README.md"
)
$missingFiles = @()

foreach ($file in $requiredFiles) {
  $filePath = Join-Path $dst $file
  if (-not (Test-Path $filePath)) {
    $missingFiles += $file
  }
}

if ($missingFiles.Count -gt 0) {
  Write-Host "WARNING: Installation may be incomplete. Missing files:" -ForegroundColor Yellow
  foreach ($f in $missingFiles) {
    Write-Host "  - $f" -ForegroundColor Yellow
  }
  exit 1
}

Write-Host "Installed: $dst" -ForegroundColor Green
Write-Host "Validated: $($requiredFiles.Count) required files present" -ForegroundColor Green
