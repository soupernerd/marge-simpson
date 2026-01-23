<#
verify.ps1 - Marge Simpson Verification Runner

Runs repo verification commands (tests/lint/build) and writes a timestamped log.
This script auto-detects its own folder name, so you can rename the folder if needed.

Usage:
  powershell -ExecutionPolicy Bypass -File .\marge_simpson\scripts\verify.ps1 fast
  powershell -ExecutionPolicy Bypass -File .\marge_simpson\scripts\verify.ps1 full
  powershell -ExecutionPolicy Bypass -File .\marge_simpson\scripts\verify.ps1 fast -SkipIfNoTests

Options:
  -Profile       fast|full (default: fast)
  -SkipIfNoTests Exit 0 instead of 2 when no test commands are detected

Behavior:
  - If `verify.config.json` exists in this folder and has non-empty commands, those run in order.
  - Otherwise, the script attempts to autodetect common stacks (Node, Python, Go, Rust, .NET, Java).
  - Fails on first failing command.
#>

param(
  [ValidateSet("fast", "full")]
  [string]$Profile = "fast",
  [switch]$SkipIfNoTests = $false
)

# ==============================================================================
# VISUAL HELPERS
# ==============================================================================

$script:StartTime = Get-Date
$script:CommandsRun = 0
$script:CommandsPassed = 0
$script:CommandsFailed = 0

function Write-Banner {
    Write-Host ""
    Write-Host "    +=========================================================================+" -ForegroundColor Cyan
    Write-Host "    |                                                                         |" -ForegroundColor Cyan
    Write-Host "    |    __  __    _    ____   ____ _____                                     |" -ForegroundColor Cyan
    Write-Host "    |   |  \/  |  / \  |  _ \ / ___| ____|                                    |" -ForegroundColor Cyan
    Write-Host "    |   | |\/| | / _ \ | |_) | |  _|  _|                                      |" -ForegroundColor Cyan
    Write-Host "    |   | |  | |/ ___ \|  _ <| |_| | |___                                     |" -ForegroundColor Cyan
    Write-Host "    |   |_|  |_/_/   \_\_| \_\\____|_____|                                    |" -ForegroundColor Cyan
    Write-Host "    |                                                                         |" -ForegroundColor Cyan
    Write-Host "    |              V E R I F I C A T I O N   R U N N E R                      |" -ForegroundColor Cyan
    Write-Host "    |                                                                         |" -ForegroundColor Cyan
    Write-Host "    +=========================================================================+" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Section([string]$Title) {
    Write-Host ""
    Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host "  | " -NoNewline -ForegroundColor DarkGray
    Write-Host "$Title".PadRight(73) -NoNewline -ForegroundColor White
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor DarkGray
}

function Write-Info([string]$Text) {
    Write-Host "    [i] " -NoNewline -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Gray
}

function Write-Success([string]$Text) {
    Write-Host "    [OK] " -NoNewline -ForegroundColor Green
    Write-Host $Text -ForegroundColor Green
}

function Write-Failure([string]$Text) {
    Write-Host "    [X] " -NoNewline -ForegroundColor Red
    Write-Host $Text -ForegroundColor Red
}

function Write-Warning([string]$Text) {
    Write-Host "    [!] " -NoNewline -ForegroundColor Yellow
    Write-Host $Text -ForegroundColor Yellow
}

function Write-FinalSummary {
    param(
        [bool]$Success,
        [string]$FolderName,
        [string]$ProfileName
    )
    
    $elapsed = (Get-Date) - $script:StartTime
    $duration = "{0:mm}m {0:ss}s" -f $elapsed
    $borderColor = if ($Success) { "Green" } else { "Red" }
    
    Write-Host ""
    Write-Host "  +=========================================================================+" -ForegroundColor $borderColor
    Write-Host "  |                       VERIFICATION SUMMARY                              |" -ForegroundColor $borderColor
    Write-Host "  +=========================================================================+" -ForegroundColor $borderColor
    Write-Host "  |                                                                         |" -ForegroundColor $borderColor
    
    # Status row
    $statusText = if ($Success) { "   STATUS:  [OK] ALL CHECKS PASSED" } else { "   STATUS:  [X] VERIFICATION FAILED" }
    Write-Host "  |" -NoNewline -ForegroundColor $borderColor
    Write-Host $statusText.PadRight(73) -NoNewline -ForegroundColor $borderColor
    Write-Host " |" -ForegroundColor $borderColor
    
    Write-Host "  |                                                                         |" -ForegroundColor $borderColor
    Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor $borderColor
    
    # Stats table
    $stats = @(
        @{ Label = "Folder"; Value = $FolderName },
        @{ Label = "Profile"; Value = $ProfileName },
        @{ Label = "Commands"; Value = "$($script:CommandsPassed)/$($script:CommandsRun) passed" },
        @{ Label = "Duration"; Value = $duration },
        @{ Label = "Timestamp"; Value = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    )
    
    foreach ($stat in $stats) {
        $line = "   {0,-12} | {1}" -f $stat.Label, $stat.Value
        Write-Host "  |" -NoNewline -ForegroundColor $borderColor
        Write-Host $line.PadRight(73) -NoNewline -ForegroundColor White
        Write-Host " |" -ForegroundColor $borderColor
    }
    
    Write-Host "  |                                                                         |" -ForegroundColor $borderColor
    Write-Host "  +=========================================================================+" -ForegroundColor $borderColor
    Write-Host ""
}

# ==============================================================================
# CORE LOGIC
# ==============================================================================

# Dynamic folder detection (scripts are now in scripts/ subfolder)
$ScriptsDir = $PSScriptRoot
$MsDir = (Get-Item $ScriptsDir).Parent.FullName
$MsFolderName = Split-Path $MsDir -Leaf
$RootDir = (Get-Item $MsDir).Parent.FullName
$Conf = Join-Path $MsDir "verify.config.json"

function Run-Cmd([string]$Cmd) {
  $script:CommandsRun++
  Write-Host ""
  Write-Host "==> $Cmd"
  Write-Host "    [>] " -NoNewline -ForegroundColor Cyan
  Write-Host "Running: " -NoNewline -ForegroundColor Gray
  Write-Host $Cmd -ForegroundColor White
  
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell"
  $escapedCmd = $Cmd -replace '"', '\"'
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$RootDir'; $escapedCmd`""
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true

  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $psi
  [void]$p.Start()
  $stdout = $p.StandardOutput.ReadToEnd()
  $stderr = $p.StandardError.ReadToEnd()
  $p.WaitForExit()

  if ($stdout) { Write-Host $stdout.TrimEnd() }
  if ($stderr) { Write-Host $stderr.TrimEnd() }

  if ($p.ExitCode -ne 0) {
    $script:CommandsFailed++
    Write-Failure "Command failed (exit code $($p.ExitCode))"
    throw "Command failed with exit code $($p.ExitCode): $Cmd"
  }
  
  $script:CommandsPassed++
  Write-Success "Command completed successfully"
}

function Read-ConfigCommands() {
  if (-not (Test-Path $Conf)) { return @() }
  try {
    $json = Get-Content $Conf -Raw | ConvertFrom-Json
  }
  catch {
    return @()
  }
  $cmds = $json.$Profile
  if ($null -eq $cmds) { return @() }
  if ($cmds -is [string]) { return @($cmds) }
  if ($cmds -is [System.Array]) { return @($cmds | Where-Object { $_ -and $_.ToString().Trim().Length -gt 0 }) }
  return @()
}

function Detect-NodeCommands() {
  $pkg = Join-Path $RootDir "package.json"
  if (-not (Test-Path $pkg)) { return @() }
  if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { return @() }

  $hasLint = $false
  $hasBuild = $false
  if (Get-Command node -ErrorAction SilentlyContinue) {
    try {
      $p = Get-Content $pkg -Raw | ConvertFrom-Json
      $hasLint = $null -ne $p.scripts.lint
      $hasBuild = $null -ne $p.scripts.build
    }
    catch {}
  }

  $cmds = @("npm test")
  if ($hasLint) { $cmds += "npm run lint" }
  if ($Profile -eq "full" -and $hasBuild) { $cmds += "npm run build" }
  return $cmds
}

function Detect-PythonCommands() {
  if (-not (Get-Command python -ErrorAction SilentlyContinue)) { return @() }

  $markers = @("pyproject.toml", "requirements.txt", "setup.py", "setup.cfg") | ForEach-Object { Join-Path $RootDir $_ }
  if (-not ($markers | Where-Object { Test-Path $_ })) { return @() }

  $hasTests = (Test-Path (Join-Path $RootDir "tests"))
  if (-not $hasTests) {
    $hasTests = @(Get-ChildItem -Path $RootDir -Recurse -Depth 3 -ErrorAction SilentlyContinue -File | Where-Object {
        $_.Name -like "test_*.py" -or $_.Name -like "*_test.py"
      }).Count -gt 0
  }

  if ($hasTests) {
    if ($Profile -eq "fast") { return @("python -m pytest -q") }
    return @("python -m pytest")
  }
  return @()
}

function Detect-GoCommands() {
  if (-not (Test-Path (Join-Path $RootDir "go.mod"))) { return @() }
  if (-not (Get-Command go -ErrorAction SilentlyContinue)) { return @() }
  return @("go test ./...")
}

function Detect-RustCommands() {
  if (-not (Test-Path (Join-Path $RootDir "Cargo.toml"))) { return @() }
  if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) { return @() }
  return @("cargo test")
}

function Detect-DotNetCommands() {
  if (-not (Get-ChildItem -Path $RootDir -Filter "*.sln" -File -ErrorAction SilentlyContinue)) { return @() }
  if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) { return @() }
  return @("dotnet test")
}

function Detect-JavaCommands() {
  $cmds = @()
  if (Test-Path (Join-Path $RootDir "mvnw")) { return @("./mvnw -q test") }
  $hasPom = Test-Path (Join-Path $RootDir "pom.xml")
  $hasMvn = Get-Command mvn -ErrorAction SilentlyContinue
  if ($hasPom -and $hasMvn) { return @("mvn -q test") }
  if (Test-Path (Join-Path $RootDir "gradlew")) { return @("./gradlew test") }
  $hasGradle = (Test-Path (Join-Path $RootDir "build.gradle")) -or (Test-Path (Join-Path $RootDir "build.gradle.kts"))
  $hasGradleCmd = Get-Command gradle -ErrorAction SilentlyContinue
  if ($hasGradle -and $hasGradleCmd) { return @("gradle test") }
  return @()
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

Write-Banner

Write-Section "Configuration"
Write-Info "Folder: $MsFolderName"
Write-Info "Profile: $Profile"
Write-Info "Repo Root: $RootDir"

Write-Host "[$MsFolderName] verify profile=$Profile"
Write-Host "[$MsFolderName] repo_root=$RootDir"

$cmds = Read-ConfigCommands

if (-not $cmds -or $cmds.Count -eq 0) {
  Write-Section "Auto-Detection"
  Write-Info "No config found, detecting test stacks..."
  $cmds = @()
  $cmds += Detect-NodeCommands
  $cmds += Detect-PythonCommands
  $cmds += Detect-GoCommands
  $cmds += Detect-RustCommands
  $cmds += Detect-DotNetCommands
  $cmds += Detect-JavaCommands
}

if (-not $cmds -or $cmds.Count -eq 0) {
  Write-Section "No Tests Found"
  Write-Host ""
  Write-Host "No test commands detected."
  Write-Host ("Create or edit {0} to specify commands for '{1}'." -f $Conf, $Profile)
  Write-Host 'Example: {"fast": ["npm test"], "full": ["npm ci", "npm test"]}'
  
  Write-Warning "No test commands detected"
  Write-Info "Create or edit verify.config.json to specify commands"
  Write-Info 'Example: {"fast": ["npm test"], "full": ["npm ci", "npm test"]}'
  
  if ($SkipIfNoTests) {
    Write-Host "[skip] No tests to run (SkipIfNoTests enabled)"
    Write-Warning "Skipping - no tests to run (SkipIfNoTests enabled)"
    Write-FinalSummary -Success $true -FolderName $MsFolderName -ProfileName $Profile
    exit 0
  }
  Write-FinalSummary -Success $false -FolderName $MsFolderName -ProfileName $Profile
  exit 2
}

Write-Section "Commands Queue ($Profile)"
Write-Host ""
Write-Host ("Commands to run ({0}):" -f $Profile)
$cmdNum = 1
foreach ($c in $cmds) { 
  Write-Host ("- {0}" -f $c)
  Write-Host "    " -NoNewline
  Write-Host "[$cmdNum]" -NoNewline -ForegroundColor DarkGray
  Write-Host " $c" -ForegroundColor White
  $cmdNum++
}

Write-Section "Execution"

try {
  foreach ($c in $cmds) { Run-Cmd $c }
  Write-Host ""
  Write-Host ("PASS: [{0}] verify ({1})" -f $MsFolderName, $Profile)
  Write-FinalSummary -Success $true -FolderName $MsFolderName -ProfileName $Profile
  exit 0
}
catch {
  Write-Host ""
  Write-Host ("FAIL: [{0}] verify ({1})" -f $MsFolderName, $Profile)
  Write-Host $_
  Write-FinalSummary -Success $false -FolderName $MsFolderName -ProfileName $Profile
  exit 1
}
