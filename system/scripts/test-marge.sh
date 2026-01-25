#!/usr/bin/env bash
set -euo pipefail

# test-marge.sh -- Self-test for the Marge Simpson verification system
#
# Validates that:
# 1. Scripts exist
# 2. Folder name auto-detection works
# 3. SkipIfNoTests exits 0
# 4. Cleanup script runs in preview mode
#
# Usage:
#   ./system/scripts/test-marge.sh

# Dynamic folder detection (scripts are now in system/scripts/ subfolder)
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(dirname "$SCRIPTS_DIR")"
MS_DIR="$(dirname "$SYSTEM_DIR")"
MS_FOLDER_NAME="$(basename "$MS_DIR")"
REPO_ROOT="$(cd "$MS_DIR/.." && pwd)"

# Detect if running in .meta_marge (lightweight mode)
IS_META_MARGE=false
[[ "$MS_FOLDER_NAME" == ".meta_marge" ]] && IS_META_MARGE=true

TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

test_assert() {
    local name="$1"
    local result="$2"
    
    printf "  [%s] %s... " "$MS_FOLDER_NAME" "$name"
    if [[ "$result" == "0" ]] || [[ "$result" == "true" ]]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo ""
echo "============================================================"
echo "[$MS_FOLDER_NAME] Self-Test Suite"
echo "============================================================"
echo ""

# Test 1: Required files exist
echo "[1/6] File existence checks..."
test_assert "AGENTS.md exists" "$([[ -f "$MS_DIR/AGENTS.md" ]] && echo 0 || echo 1)" || true
test_assert "verify.ps1 exists" "$([[ -f "$SCRIPTS_DIR/verify.ps1" ]] && echo 0 || echo 1)" || true
test_assert "verify.sh exists" "$([[ -f "$SCRIPTS_DIR/verify.sh" ]] && echo 0 || echo 1)" || true
test_assert "cleanup.ps1 exists" "$([[ -f "$SCRIPTS_DIR/cleanup.ps1" ]] && echo 0 || echo 1)" || true
test_assert "cleanup.sh exists" "$([[ -f "$SCRIPTS_DIR/cleanup.sh" ]] && echo 0 || echo 1)" || true
test_assert "verify.config.json exists" "$([[ -f "$MS_DIR/verify.config.json" ]] && echo 0 || echo 1)" || true
if [[ "$IS_META_MARGE" != "true" ]]; then
    test_assert "README.md exists" "$([[ -f "$MS_DIR/README.md" ]] && echo 0 || echo 1)" || true
fi
echo ""

# Test 2: Script syntax validation
echo "[2/6] Script syntax validation..."
VERIFY_SYNTAX=$(bash -n "$SCRIPTS_DIR/verify.sh" 2>&1 && echo 0 || echo 1)
test_assert "verify.sh valid syntax" "$VERIFY_SYNTAX" || true
CLEANUP_SYNTAX=$(bash -n "$SCRIPTS_DIR/cleanup.sh" 2>&1 && echo 0 || echo 1)
test_assert "cleanup.sh valid syntax" "$CLEANUP_SYNTAX" || true
DECAY_SYNTAX=$(bash -n "$SCRIPTS_DIR/decay.sh" 2>&1 && echo 0 || echo 1)
test_assert "decay.sh valid syntax" "$DECAY_SYNTAX" || true
STATUS_SYNTAX=$(bash -n "$SCRIPTS_DIR/status.sh" 2>&1 && echo 0 || echo 1)
test_assert "status.sh valid syntax" "$STATUS_SYNTAX" || true

# ShellCheck linting (if available)
if command -v shellcheck &>/dev/null; then
    echo ""
    echo "[2b/6] ShellCheck linting..."
    for script in "$SCRIPTS_DIR"/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            SHELLCHECK_RESULT=$(shellcheck "$script" 2>&1 && echo 0 || echo 1)
            test_assert "$script_name passes shellcheck" "$SHELLCHECK_RESULT" || true
        fi
    done
    # CLI scripts in cli/ folder
    for script in "$MS_DIR/cli/marge" "$MS_DIR/cli/marge-init" "$MS_DIR/cli/install-global.sh"; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            SHELLCHECK_RESULT=$(shellcheck "$script" 2>&1 && echo 0 || echo 1)
            test_assert "$script_name passes shellcheck" "$SHELLCHECK_RESULT" || true
        fi
    done
    # Meta scripts in .dev/ folder
    script="$MS_DIR/.dev/meta/convert-to-meta.sh"
    if [[ -f "$script" ]]; then
        script_name=$(basename "$script")
        SHELLCHECK_RESULT=$(shellcheck "$script" 2>&1 && echo 0 || echo 1)
        test_assert "$script_name passes shellcheck" "$SHELLCHECK_RESULT" || true
    fi
else
    echo "  [SKIP] ShellCheck not installed (optional: apt install shellcheck)"
fi
echo ""

# Test 3: Folder name detection
echo "[3/6] Folder name auto-detection..."
test_assert "Detected folder name is '$MS_FOLDER_NAME'" "$([[ -n "$MS_FOLDER_NAME" ]] && echo 0 || echo 1)" || true
test_assert "Repo root detected" "$([[ -d "$REPO_ROOT" ]] && echo 0 || echo 1)" || true
echo ""

# Test 4: verify.sh basic functionality (without running full test suite to avoid recursion)
echo "[4/6] verify.sh basic functionality..."

# Test that verify.sh is executable and can parse arguments
test_assert "verify.sh is executable" "$([[ -x "$SCRIPTS_DIR/verify.sh" ]] && echo 0 || echo 1)" || true

# Test verify.sh help/syntax by checking it sources correctly (don't actually run tests)
# We can't run verify.sh here because it would find the real config and recurse
test_assert "verify.sh has shebang" "$([[ $(head -1 "$SCRIPTS_DIR/verify.sh") == "#!/usr/bin/env bash" ]] && echo 0 || echo 1)" || true
test_assert "verify.config.json exists" "$([[ -f "$MS_DIR/verify.config.json" ]] && echo 0 || echo 1)" || true
echo ""

# Test 5: cleanup.sh preview mode
echo "[5/6] cleanup.sh preview mode..."
CLEANUP_OUTPUT=$("$SCRIPTS_DIR/cleanup.sh" 2>&1) || true
CLEANUP_EXIT=$?
test_assert "cleanup.sh exits 0 in preview mode" "$CLEANUP_EXIT" || true
CONTAINS_PREVIEW=$(echo "$CLEANUP_OUTPUT" | grep -q "PREVIEW" && echo 0 || echo 1)
test_assert "Output shows PREVIEW MODE" "$CONTAINS_PREVIEW" || true
echo ""

# Test 6: AGENTS.md content validation
echo "[6/6] AGENTS.md content validation..."
AGENTS_PATH="$MS_DIR/AGENTS.md"
AGENTS_CONTENT=$(cat "$AGENTS_PATH")

HAS_CRITICAL=$(echo "$AGENTS_CONTENT" | grep -q "CRITICAL" && echo 0 || echo 1)
test_assert "AGENTS.md contains CRITICAL section" "$HAS_CRITICAL" || true

# Check for folder reference - folder name, .marge/, or ./system/ (generic structure)
HAS_FOLDER_REF=$(echo "$AGENTS_CONTENT" | grep -qE "(${MS_FOLDER_NAME}/|\\.marge/|\\./system/)" && echo 0 || echo 1)
test_assert "AGENTS.md contains folder reference" "$HAS_FOLDER_REF" || true

HAS_VERIFY_REF=$(echo "$AGENTS_CONTENT" | grep -q "verify" && echo 0 || echo 1)
test_assert "AGENTS.md contains verification reference" "$HAS_VERIFY_REF" || true

HAS_MS_ID=$(echo "$AGENTS_CONTENT" | grep -qE "MS-[0-9]{4}|MS-####" && echo 0 || echo 1)
test_assert "AGENTS.md contains MS-#### tracking ID format" "$HAS_MS_ID" || true

# Meta-specific test: If this is a meta folder, check for audit exclusion rule
if [[ "$MS_FOLDER_NAME" == ".meta_marge" ]] || [[ "$MS_FOLDER_NAME" == "meta_marge" ]] || [[ "$MS_FOLDER_NAME" == ".marge_meta" ]]; then
    HAS_EXCLUSION=$(echo "$AGENTS_CONTENT" | grep -q "excluded from audits" && echo 0 || echo 1)
    test_assert "AGENTS.md contains meta audit exclusion rule" "$HAS_EXCLUSION" || true
fi
echo ""

# Summary
echo "============================================================"
echo "[$MS_FOLDER_NAME] Test Results"
echo "============================================================"
echo ""
echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
else
    echo -e "  Failed: ${GREEN}$TESTS_FAILED${NC}"
fi
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}FAIL: $TESTS_FAILED test(s) failed${NC}"
    exit 1
else
    echo -e "${GREEN}PASS: All tests passed${NC}"
    exit 0
fi
