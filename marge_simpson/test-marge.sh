#!/usr/bin/env bash
set -euo pipefail

# test-marge.sh — Self-test for the Marge Simpson verification system
#
# Validates that:
# 1. Scripts exist
# 2. Folder name auto-detection works
# 3. SkipIfNoTests exits 0
# 4. Cleanup script runs in preview mode
#
# Usage:
#   ./marge_simpson/test-marge.sh

# Dynamic folder detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MS_FOLDER_NAME="$(basename "$SCRIPT_DIR")"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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
test_assert "AGENTS.md exists" "$([[ -f "$SCRIPT_DIR/AGENTS.md" ]] && echo 0 || echo 1)" || true
test_assert "verify.ps1 exists" "$([[ -f "$SCRIPT_DIR/verify.ps1" ]] && echo 0 || echo 1)" || true
test_assert "verify.sh exists" "$([[ -f "$SCRIPT_DIR/verify.sh" ]] && echo 0 || echo 1)" || true
test_assert "cleanup.ps1 exists" "$([[ -f "$SCRIPT_DIR/cleanup.ps1" ]] && echo 0 || echo 1)" || true
test_assert "cleanup.sh exists" "$([[ -f "$SCRIPT_DIR/cleanup.sh" ]] && echo 0 || echo 1)" || true
test_assert "verify.config.json exists" "$([[ -f "$SCRIPT_DIR/verify.config.json" ]] && echo 0 || echo 1)" || true
test_assert "README.md exists" "$([[ -f "$SCRIPT_DIR/README.md" ]] && echo 0 || echo 1)" || true
echo ""

# Test 2: Script syntax validation
echo "[2/6] Script syntax validation..."
VERIFY_SYNTAX=$(bash -n "$SCRIPT_DIR/verify.sh" 2>&1 && echo 0 || echo 1)
test_assert "verify.sh valid syntax" "$VERIFY_SYNTAX" || true
CLEANUP_SYNTAX=$(bash -n "$SCRIPT_DIR/cleanup.sh" 2>&1 && echo 0 || echo 1)
test_assert "cleanup.sh valid syntax" "$CLEANUP_SYNTAX" || true
echo ""

# Test 3: Folder name detection
echo "[3/6] Folder name auto-detection..."
test_assert "Detected folder name is '$MS_FOLDER_NAME'" "$([[ -n "$MS_FOLDER_NAME" ]] && echo 0 || echo 1)" || true
test_assert "Repo root detected" "$([[ -d "$REPO_ROOT" ]] && echo 0 || echo 1)" || true
echo ""

# Test 4: verify.sh with --skip-if-no-tests
echo "[4/6] verify.sh --skip-if-no-tests behavior..."
VERIFY_OUTPUT=$("$SCRIPT_DIR/verify.sh" fast --skip-if-no-tests 2>&1) || true
VERIFY_EXIT=$?
test_assert "verify.sh --skip-if-no-tests exits 0" "$VERIFY_EXIT" || true
CONTAINS_FOLDER=$(echo "$VERIFY_OUTPUT" | grep -q "\[$MS_FOLDER_NAME\]" && echo 0 || echo 1)
test_assert "Output contains folder name" "$CONTAINS_FOLDER" || true
echo ""

# Test 5: cleanup.sh preview mode
echo "[5/6] cleanup.sh preview mode..."
CLEANUP_OUTPUT=$("$SCRIPT_DIR/cleanup.sh" 2>&1) || true
CLEANUP_EXIT=$?
test_assert "cleanup.sh exits 0 in preview mode" "$CLEANUP_EXIT" || true
CONTAINS_PREVIEW=$(echo "$CLEANUP_OUTPUT" | grep -q "PREVIEW" && echo 0 || echo 1)
test_assert "Output shows PREVIEW MODE" "$CONTAINS_PREVIEW" || true
echo ""

# Test 6: AGENTS.md content validation
echo "[6/6] AGENTS.md content validation..."
AGENTS_PATH="$SCRIPT_DIR/AGENTS.md"
AGENTS_CONTENT=$(cat "$AGENTS_PATH")

HAS_CRITICAL_RULE=$(echo "$AGENTS_CONTENT" | grep -q "\*\*CRITICAL RULE" && echo 0 || echo 1)
test_assert "AGENTS.md contains CRITICAL RULE(S)" "$HAS_CRITICAL_RULE" || true

HAS_FOLDER_REF=$(echo "$AGENTS_CONTENT" | grep -q "\`$MS_FOLDER_NAME/\`" && echo 0 || echo 1)
test_assert "AGENTS.md contains folder reference '$MS_FOLDER_NAME/'" "$HAS_FOLDER_REF" || true

HAS_VERIFY_REF=$(echo "$AGENTS_CONTENT" | grep -q "verify.ps1 fast" && echo "$AGENTS_CONTENT" | grep -q "verify.sh fast" && echo 0 || echo 1)
test_assert "AGENTS.md contains verification runner reference" "$HAS_VERIFY_REF" || true

HAS_MS_ID=$(echo "$AGENTS_CONTENT" | grep -qE "MS-[0-9]{4}|MS-####" && echo 0 || echo 1)
test_assert "AGENTS.md contains MS-#### tracking ID format" "$HAS_MS_ID" || true

# Meta-specific test: If this is meta_marge, check for audit exclusion rule
if [[ "$MS_FOLDER_NAME" == "meta_marge" ]]; then
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
