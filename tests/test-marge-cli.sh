#!/usr/bin/env bash
set -euo pipefail

# test-marge-cli.sh — Unit tests for the marge CLI
#
# Tests the marge CLI argument parsing and behavior, including:
# - --auto flag functionality
# - --dry-run output
# - --verbose output
# - Option combinations
#
# Usage:
#   ./tests/test-marge-cli.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARGE_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"
MARGE_CLI="$MARGE_HOME/marge"

TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

test_assert() {
    local name="$1"
    local result="$2"

    printf "  %s... " "$name"
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

# Create a temp directory for testing
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo ""
echo "============================================================"
echo "Marge CLI Test Suite"
echo "============================================================"
echo ""

# Test 1: Script exists and is executable
echo "[1/7] Basic file checks..."
test_assert "marge script exists" "$([[ -f "$MARGE_CLI" ]] && echo 0 || echo 1)" || true
test_assert "marge script is executable" "$([[ -x "$MARGE_CLI" ]] && echo 0 || echo 1)" || true
echo ""

# Test 2: Syntax validation
echo "[2/7] Syntax validation..."
SYNTAX_CHECK=$(bash -n "$MARGE_CLI" 2>&1 && echo 0 || echo 1)
test_assert "marge has valid bash syntax" "$SYNTAX_CHECK" || true
echo ""

# Test 3: Help output
echo "[3/7] Help output..."
HELP_OUTPUT=$("$MARGE_CLI" --help 2>&1) || true
HAS_USAGE=$(echo "$HELP_OUTPUT" | grep -q "Usage:" && echo 0 || echo 1)
test_assert "--help shows usage" "$HAS_USAGE" || true
HAS_AUTO_OPTION=$(echo "$HELP_OUTPUT" | grep -q "\--auto" && echo 0 || echo 1)
test_assert "--help shows --auto option" "$HAS_AUTO_OPTION" || true
HAS_AUTO_DESC=$(echo "$HELP_OUTPUT" | grep -q "Run without user input" && echo 0 || echo 1)
test_assert "--help describes --auto correctly" "$HAS_AUTO_DESC" || true
echo ""

# Test 4: Version output
echo "[4/7] Version output..."
VERSION_OUTPUT=$("$MARGE_CLI" --version 2>&1) || true
HAS_VERSION=$(echo "$VERSION_OUTPUT" | grep -q "marge" && echo 0 || echo 1)
test_assert "--version shows marge version" "$HAS_VERSION" || true
echo ""

# Test 5: Dry-run without --auto flag
echo "[5/7] Dry-run output (no --auto)..."
cd "$TEMP_DIR"
mkdir -p marge_simpson
touch marge_simpson/AGENTS.md
DRY_OUTPUT=$("$MARGE_CLI" "test task" --dry-run 2>&1) || true
HAS_DRY_RUN_HEADER=$(echo "$DRY_OUTPUT" | grep -q "DRY RUN" && echo 0 || echo 1)
test_assert "--dry-run shows DRY RUN header" "$HAS_DRY_RUN_HEADER" || true
NO_DANGEROUSLY_FLAG=$(echo "$DRY_OUTPUT" | grep "Would launch:" | grep -qv "\--dangerously-skip-permissions" && echo 0 || echo 1)
test_assert "--dry-run (no --auto) does not include --dangerously-skip-permissions" "$NO_DANGEROUSLY_FLAG" || true
echo ""

# Test 6: Dry-run WITH --auto flag
echo "[6/7] Dry-run output (with --auto)..."
DRY_AUTO_OUTPUT=$("$MARGE_CLI" "test task" --dry-run --auto 2>&1) || true
HAS_DANGEROUS_FLAG=$(echo "$DRY_AUTO_OUTPUT" | grep "Would launch:" | grep -q "\--dangerously-skip-permissions" && echo 0 || echo 1)
test_assert "--dry-run --auto includes --dangerously-skip-permissions" "$HAS_DANGEROUS_FLAG" || true
echo ""

# Test 7: Verbose mode with --auto
echo "[7/7] Verbose mode with --auto..."
VERBOSE_OUTPUT=$("$MARGE_CLI" "test task" --dry-run --auto --verbose 2>&1) || true
HAS_AUTO_MODE_LOG=$(echo "$VERBOSE_OUTPUT" | grep -q "Auto mode: 1" && echo 0 || echo 1)
test_assert "--verbose shows Auto mode: 1 when --auto is used" "$HAS_AUTO_MODE_LOG" || true
echo ""

# Test: Dry-run with --auto and --model combination
echo "[Bonus] Option combinations..."
COMBO_OUTPUT=$("$MARGE_CLI" "test task" --dry-run --auto --model opus 2>&1) || true
HAS_BOTH_FLAGS=$(echo "$COMBO_OUTPUT" | grep "Would launch:" | grep -q "\--dangerously-skip-permissions" && echo "$COMBO_OUTPUT" | grep "Would launch:" | grep -q "\--model opus" && echo 0 || echo 1)
test_assert "--auto --model opus shows both flags" "$HAS_BOTH_FLAGS" || true
echo ""

# Summary
echo "============================================================"
echo "Marge CLI Test Results"
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
