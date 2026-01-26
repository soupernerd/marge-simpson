#!/usr/bin/env bash
set -euo pipefail

# verify.sh -- Marge Simpson Verification Runner
#
# Runs repo verification commands and writes a timestamped log.
# This script auto-detects its own folder name, so you can rename the folder if needed.
#
# SECURITY NOTE:
#   verify.config.json is TRUSTED CONFIGURATION that specifies commands to execute.
#   The commands in this file are run directly via bash -c from the repository root.
#   Only commit verify.config.json from trusted sources. Treat it as executable code.
#   Malicious entries could execute arbitrary shell commands with user privileges.
#
# Usage:
#   ./system/scripts/verify.sh fast
#   ./system/scripts/verify.sh full
#   ./system/scripts/verify.sh fast --skip-if-no-tests
#
# Options:
#   fast|full (default: fast)
#   --skip-if-no-tests  Exit 0 instead of 2 when no test commands are detected
#
# ============================================================================
# CROSS-PLATFORM PROFILE HANDLING
# ============================================================================
#
# verify.config.json supports platform-specific profiles:
#   - "fast" / "full"       → Primary profiles (typically Windows .ps1 commands)
#   - "fast_sh" / "full_sh" → Unix-native variants (.sh commands)
#
# Profile Selection Logic (in order):
#   1. If a "${profile}_sh" variant exists in config → Use it directly
#   2. Otherwise → Use base profile with command adaptation
#
# Command Adaptation (adapt_command):
#   When Unix-native profiles aren't available, commands are auto-converted:
#   - Backslashes (\) → Forward slashes (/)
#   - .ps1 extensions → .sh (if the .sh file exists)
#   - Leading .\ prefix is normalized
#
# Best Practice:
#   Define both "fast" and "fast_sh" profiles in verify.config.json for
#   guaranteed cross-platform compatibility. Adaptation is a fallback.
#
# Known Limitations:
#   - PowerShell-specific syntax (cmdlets, operators) cannot be auto-adapted
#   - Commands referencing Windows-only tools will fail on Unix
#   - Adaptation only works for simple path-based commands
#   - If .sh equivalent doesn't exist, the original command runs (and fails)
#
# ============================================================================

PROFILE="fast"
SKIP_IF_NO_TESTS=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    fast|full) PROFILE="$arg" ;;
    --skip-if-no-tests) SKIP_IF_NO_TESTS=true ;;
  esac
done

# Dynamic folder detection (scripts are now in system/scripts/ subfolder)
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(dirname "$SCRIPTS_DIR")"
MS_DIR="$(dirname "$SYSTEM_DIR")"
MS_FOLDER_NAME="$(basename "$MS_DIR")"
ROOT_DIR="$(cd "$MS_DIR/.." && pwd)"
CONF="$MS_DIR/verify.config.json"

have() { command -v "$1" >/dev/null 2>&1; }

say() {
  echo "$@"
}

# Cross-platform command adaptation
# Converts Windows PowerShell commands to bash equivalents when running on Unix
# Since run_cmd uses 'bash -c', we always need to convert .ps1 to .sh
#
# Handles:
#   - .ps1 → .sh extension conversion (if .sh file exists)
#   - Backslash → forward slash path conversion  
#   - Leading .\ prefix normalization
#   - Commands already in Unix format (passed through unchanged)
#
# Returns: Adapted command string (or original if no adaptation needed/possible)
adapt_command() {
  local cmd="$1"
  local original_cmd="$cmd"
  
  # Step 1: Convert Windows backslashes to forward slashes
  cmd="${cmd//\\//}"
  
  # Step 2: Normalize leading ./ (handles both .\ and ./ after conversion)
  # This is already handled by backslash conversion above
  
  # Step 3: If command is already Unix-native (.sh), pass through unchanged
  if [[ "$cmd" =~ \.sh(\s|$) ]] && ! [[ "$cmd" =~ \.ps1 ]]; then
    echo "$cmd"
    return 0
  fi
  
  # Step 4: If command references a .ps1 file, convert to .sh equivalent
  # (run_cmd uses bash -c, so we can't run .ps1 directly even if pwsh exists)
  if [[ "$cmd" =~ \.ps1 ]]; then
    # Extract the .ps1 file path (handles paths with or without arguments)
    local ps1_path
    ps1_path=$(echo "$cmd" | grep -oE '[^ ]*\.ps1')
    
    if [[ -n "$ps1_path" ]]; then
      # Convert to .sh path
      local sh_path="${ps1_path%.ps1}.sh"
      
      # Check if the .sh equivalent exists relative to ROOT_DIR (where commands run from)
      # Remove leading ./ for path joining
      local clean_sh_path="${sh_path#./}"
      local sh_full_path="$ROOT_DIR/$clean_sh_path"
      
      if [[ -f "$sh_full_path" ]]; then
        # Replace .ps1 with .sh in the command
        cmd="${cmd//$ps1_path/$sh_path}"
        echo "[cross-platform] Adapted: $original_cmd → $cmd" >&2
      else
        echo "[warning] No bash equivalent found for: $ps1_path" >&2
        echo "[warning]   Looked for: $sh_full_path" >&2
        echo "[warning]   Command will likely fail. Consider adding a _sh profile." >&2
        # Return the converted command anyway - let it fail naturally with clear path
      fi
    fi
  fi
  
  echo "$cmd"
}

run_cmd() {
  local cmd="$1"
  
  # Adapt command for cross-platform compatibility
  cmd=$(adapt_command "$cmd")
  
  say ""
  say "==> $cmd"
  # shellcheck disable=SC2086
  (cd "$ROOT_DIR" && bash -c "$cmd") 2>&1
}

# Check if a profile exists in the config file
# Returns 0 if profile exists, 1 otherwise
profile_exists() {
  local check_profile="$1"
  
  if [[ ! -f "$CONF" ]]; then
    return 1
  fi
  
  if have python; then
    CONF_PATH="$CONF" CHECK_PROFILE="$check_profile" python - <<'PY'
import json, sys, os
conf_path = os.environ.get('CONF_PATH', '')
check_profile = os.environ.get('CHECK_PROFILE', '')
try:
    with open(conf_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    # Profile exists if it's a key with a non-empty list
    if check_profile in data and isinstance(data[check_profile], list) and len(data[check_profile]) > 0:
        sys.exit(0)
    sys.exit(1)
except Exception:
    sys.exit(1)
PY
    return $?
  fi
  
  if have node; then
    CONF_PATH="$CONF" CHECK_PROFILE="$check_profile" node - <<'JS'
const fs = require('fs');
const confPath = process.env.CONF_PATH || '';
const checkProfile = process.env.CHECK_PROFILE || '';
try {
  const raw = fs.readFileSync(confPath, 'utf8');
  const data = JSON.parse(raw);
  if (checkProfile in data && Array.isArray(data[checkProfile]) && data[checkProfile].length > 0) {
    process.exit(0);
  }
  process.exit(1);
} catch (e) {
  process.exit(1);
}
JS
    return $?
  fi
  
  return 1
}

# Auto-select Unix-native profile if available
# On Unix, prefer "fast_sh" over "fast" when it exists
auto_select_profile() {
  local requested="$1"
  local sh_variant="${requested}_sh"
  
  # If already requesting a _sh variant, use as-is
  if [[ "$requested" =~ _sh$ ]]; then
    echo "$requested"
    return 0
  fi
  
  # Check if a _sh variant exists
  if profile_exists "$sh_variant"; then
    echo "[cross-platform] Using native profile: $sh_variant (instead of $requested)" >&2
    echo "$sh_variant"
    return 0
  fi
  
  # Fall back to requested profile (will use adaptation)
  echo "$requested"
}

read_config_commands() {
  # Prints commands, one per line. Returns 0 if successful parse (even if empty).
  # Returns 1 if no suitable parser is available.
  if [[ ! -f "$CONF" ]]; then
    return 1
  fi

  if have python; then
    CONF_PATH="$CONF" PROFILE_NAME="$PROFILE" python - <<'PY'
import json, sys, os
conf_path = os.environ.get('CONF_PATH', '')
profile = os.environ.get('PROFILE_NAME', 'fast')
try:
    with open(conf_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception:
    sys.exit(2)
cmds = data.get(profile, [])
if not isinstance(cmds, list):
    sys.exit(2)
for c in cmds:
    if isinstance(c, str) and c.strip():
        print(c.strip())
PY
    return 0
  fi

  if have node; then
    CONF_PATH="$CONF" PROFILE_NAME="$PROFILE" node - <<'JS'
const fs = require('fs');
const confPath = process.env.CONF_PATH || '';
const profile = process.env.PROFILE_NAME || 'fast';
const raw = fs.readFileSync(confPath, 'utf8');
const data = JSON.parse(raw);
const cmds = (data && data[profile]) || [];
if (!Array.isArray(cmds)) process.exit(2);
for (const c of cmds) {
  if (typeof c === 'string' && c.trim()) console.log(c.trim());
}
JS
    return 0
  fi

  return 1
}

detect_node_commands() {
  [[ -f "$ROOT_DIR/package.json" ]] || return 0
  have npm || return 0

  local has_lint=0
  local has_build=0

  if have node; then
    has_lint=$(cd "$ROOT_DIR" && node -e "const p=require('./package.json'); console.log(!!(p.scripts&&p.scripts.lint));" 2>/dev/null || echo 0)
    has_build=$(cd "$ROOT_DIR" && node -e "const p=require('./package.json'); console.log(!!(p.scripts&&p.scripts.build));" 2>/dev/null || echo 0)
  fi

  echo "npm test"
  if [[ "$has_lint" == "true" || "$has_lint" == "1" ]]; then
    echo "npm run lint"
  fi
  if [[ "$PROFILE" == "full" && ( "$has_build" == "true" || "$has_build" == "1" ) ]]; then
    echo "npm run build"
  fi
}

detect_python_commands() {
  { [[ -f "$ROOT_DIR/pyproject.toml" ]] || [[ -f "$ROOT_DIR/requirements.txt" ]] || [[ -f "$ROOT_DIR/setup.py" ]] || [[ -f "$ROOT_DIR/setup.cfg" ]]; } || return 0
  have python || return 0

  # Only run pytest if there are likely tests.
  if [[ -d "$ROOT_DIR/tests" ]] || (cd "$ROOT_DIR" && ls -1 test_*.py >/dev/null 2>&1) || (cd "$ROOT_DIR" && find . -maxdepth 3 -name "test_*.py" -o -name "*_test.py" | head -n 1 | grep -q .); then
    if [[ "$PROFILE" == "fast" ]]; then
      echo "python -m pytest -q"
    else
      echo "python -m pytest"
    fi
  fi
}

detect_go_commands() {
  [[ -f "$ROOT_DIR/go.mod" ]] || return 0
  have go || return 0
  echo "go test ./..."
}

detect_rust_commands() {
  [[ -f "$ROOT_DIR/Cargo.toml" ]] || return 0
  have cargo || return 0
  echo "cargo test"
}

detect_dotnet_commands() {
  ls "$ROOT_DIR"/*.sln >/dev/null 2>&1 || return 0
  have dotnet || return 0
  echo "dotnet test"
}

detect_java_commands() {
  if [[ -f "$ROOT_DIR/mvnw" ]]; then
    echo "./mvnw -q test"
    return 0
  fi
  if [[ -f "$ROOT_DIR/pom.xml" ]] && have mvn; then
    echo "mvn -q test"
    return 0
  fi
  if [[ -f "$ROOT_DIR/gradlew" ]]; then
    echo "./gradlew test"
    return 0
  fi
  if { [[ -f "$ROOT_DIR/build.gradle" ]] || [[ -f "$ROOT_DIR/build.gradle.kts" ]]; } && have gradle; then
    echo "gradle test"
    return 0
  fi
}

main() {
  # Auto-select Unix-native profile if available
  local original_profile="$PROFILE"
  PROFILE=$(auto_select_profile "$PROFILE")
  
  say "[$MS_FOLDER_NAME] verify profile=$PROFILE"
  if [[ "$PROFILE" != "$original_profile" ]]; then
    say "[$MS_FOLDER_NAME] (auto-selected from: $original_profile)"
  fi
  say "[$MS_FOLDER_NAME] repo_root=$ROOT_DIR"

  local cmds=()

  if [[ -f "$CONF" ]]; then
    # If config exists and parses, prefer it when it has commands.
    if out=$(read_config_commands); then
      if [[ -n "${out//[[:space:]]/}" ]]; then
        while IFS= read -r line; do
          cmds+=("$line")
        done <<< "$out"
      fi
    fi
  fi

  # If no config commands, autodetect.
  if [[ ${#cmds[@]} -eq 0 ]]; then
    while IFS= read -r line; do [[ -n "$line" ]] && cmds+=("$line"); done < <(detect_node_commands)
    while IFS= read -r line; do [[ -n "$line" ]] && cmds+=("$line"); done < <(detect_python_commands)
    while IFS= read -r line; do [[ -n "$line" ]] && cmds+=("$line"); done < <(detect_go_commands)
    while IFS= read -r line; do [[ -n "$line" ]] && cmds+=("$line"); done < <(detect_rust_commands)
    while IFS= read -r line; do [[ -n "$line" ]] && cmds+=("$line"); done < <(detect_dotnet_commands)
    while IFS= read -r line; do [[ -n "$line" ]] && cmds+=("$line"); done < <(detect_java_commands)
  fi

  if [[ ${#cmds[@]} -eq 0 ]]; then
    say ""
    say "No test commands detected."
    say "Create or edit $CONF to specify commands for '$PROFILE'."
    say "Example: {\"fast\": [\"npm test\"], \"full\": [\"npm ci\", \"npm test\"]}"
    if [[ "$SKIP_IF_NO_TESTS" == "true" ]]; then
      say "[skip] No tests to run (--skip-if-no-tests enabled)"
      exit 0
    fi
    exit 2
  fi

  say ""
  say "Commands to run ($PROFILE):"
  for c in "${cmds[@]}"; do
    say "- $c"
  done

  for c in "${cmds[@]}"; do
    run_cmd "$c"
  done

  say ""
  say "PASS: [$MS_FOLDER_NAME] verify ($PROFILE)"
}

main "$@"
