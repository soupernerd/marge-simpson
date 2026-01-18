<#
verify.ps1 — Marge Simpson Verification Runner

Runs repo verification commands (tests/lint/build) and writes a timestamped log.
This script auto-detects its own folder name, so you can rename the folder if needed.

Usage:
  powershell -ExecutionPolicy Bypass -File .\<folder>\verify.ps1 fast
  powershell -ExecutionPolicy Bypass -File .\<folder>\verify.ps1 full
  powershell -ExecutionPolicy Bypass -File .\<folder>\verify.ps1 fast -SkipIfNoTests

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

# Dynamic folder detection — works regardless of folder name
$MsDir = $PSScriptRoot
$MsFolderName = Split-Path $MsDir -Leaf
$RootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$Conf = Join-Path $MsDir "verify.config.json"
$LogDir = Join-Path $MsDir "verify_logs"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Ts = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $LogDir ("verify_{0}_{1}.log" -f $Profile, $Ts)

function Write-Log([string]$Text) {
  $Text | Tee-Object -FilePath $LogFile -Append
}

function Run-Cmd([string]$Cmd) {
  Write-Log ""
  Write-Log ("==> {0}" -f $Cmd)
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

  if ($stdout) { $stdout.TrimEnd() | Tee-Object -FilePath $LogFile -Append }
  if ($stderr) { $stderr.TrimEnd() | Tee-Object -FilePath $LogFile -Append }

  if ($p.ExitCode -ne 0) {
    throw "Command failed with exit code $($p.ExitCode): $Cmd"
  }
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

Write-Log ("[{0}] verify profile={1}" -f $MsFolderName, $Profile)
Write-Log ("[{0}] repo_root={1}" -f $MsFolderName, $RootDir)
Write-Log ("[{0}] log={1}" -f $MsFolderName, $LogFile)

$cmds = Read-ConfigCommands

if (-not $cmds -or $cmds.Count -eq 0) {
  $cmds = @()
  $cmds += Detect-NodeCommands
  $cmds += Detect-PythonCommands
  $cmds += Detect-GoCommands
  $cmds += Detect-RustCommands
  $cmds += Detect-DotNetCommands
  $cmds += Detect-JavaCommands
}

if (-not $cmds -or $cmds.Count -eq 0) {
  Write-Log ""
  Write-Log "No test commands detected."
  Write-Log ("Create or edit {0} to specify commands for '{1}'." -f $Conf, $Profile)
  Write-Log 'Example: {"fast": ["npm test"], "full": ["npm ci", "npm test"]}'
  if ($SkipIfNoTests) {
    Write-Log "[skip] No tests to run (SkipIfNoTests enabled)"
    exit 0
  }
  exit 2
}

Write-Log ""
Write-Log ("Commands to run ({0}):" -f $Profile)
foreach ($c in $cmds) { Write-Log ("- {0}" -f $c) }

try {
  foreach ($c in $cmds) { Run-Cmd $c }
  Write-Log ""
  Write-Log ("PASS: [{0}] verify ({1})" -f $MsFolderName, $Profile)
  exit 0
}
catch {
  Write-Log ""
  Write-Log ("FAIL: [{0}] verify ({1})" -f $MsFolderName, $Profile)
  Write-Log $_
  exit 1
}
