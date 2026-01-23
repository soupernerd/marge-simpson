#!/usr/bin/env bash
# test-marge-cli.sh - Test suite for Marge CLI and modular structure
#
# Usage: ./test-marge-cli.sh
#
# Tests:
# 1. File structure validation
# 2. CLI command tests
# 3. Symlink validation
# 4. Content validation

set -e

MARGE_HOME="${MARGE_HOME:-$HOME/.marge}"
SHARED_DIR="$MARGE_HOME/shared"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

# shellcheck disable=SC2317  # Function defined for future use / API completeness
test_skip() {
    echo -e "${YELLOW}○${NC} $1 (skipped)"
    TESTS_RUN=$((TESTS_RUN + 1))
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Marge CLI & Modular Structure Test Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================================
# Test 1: Core workflow files exist
# ============================================================
echo -e "${BLUE}Test Group: Workflow Files${NC}"

if [[ -f "$SHARED_DIR/workflows/_index.md" ]]; then
    test_pass "workflows/_index.md exists"
else
    test_fail "workflows/_index.md missing"
fi

if [[ -f "$SHARED_DIR/workflows/work.md" ]]; then
    test_pass "workflows/work.md exists"
else
    test_fail "workflows/work.md missing"
fi

if [[ -f "$SHARED_DIR/workflows/audit.md" ]]; then
    test_pass "workflows/audit.md exists"
else
    test_fail "workflows/audit.md missing"
fi

if [[ -f "$SHARED_DIR/workflows/loop.md" ]]; then
    test_pass "workflows/loop.md exists"
else
    test_fail "workflows/loop.md missing"
fi

if [[ -f "$SHARED_DIR/workflows/planning.md" ]]; then
    test_pass "workflows/planning.md exists"
else
    test_fail "workflows/planning.md missing"
fi

if [[ -f "$SHARED_DIR/workflows/session_start.md" ]]; then
    test_pass "workflows/session_start.md exists"
else
    test_fail "workflows/session_start.md missing"
fi

if [[ -f "$SHARED_DIR/workflows/session_end.md" ]]; then
    test_pass "workflows/session_end.md exists"
else
    test_fail "workflows/session_end.md missing"
fi

echo ""

# ============================================================
# Test 2: Historical backup exists
# ============================================================
echo -e "${BLUE}Test Group: Historical Backup${NC}"

if [[ -f "$SHARED_DIR/bak/OLD_AGENTS.md" ]]; then
    test_pass "bak/OLD_AGENTS.md exists"
else
    test_fail "bak/OLD_AGENTS.md missing"
fi

if [[ -f "$SHARED_DIR/bak/OLD_AGENTS.md" ]] && grep -q "Historical Reference" "$SHARED_DIR/bak/OLD_AGENTS.md"; then
    test_pass "OLD_AGENTS.md contains historical reference note"
else
    test_fail "OLD_AGENTS.md missing historical reference note"
fi

echo ""

# ============================================================
# Test 3: CLI scripts exist
# ============================================================
echo -e "${BLUE}Test Group: CLI Scripts${NC}"

if [[ -f "$SHARED_DIR/scripts/marge" ]]; then
    test_pass "marge CLI script exists"
else
    test_fail "marge CLI script missing"
fi

if [[ -x "$SHARED_DIR/scripts/marge" ]]; then
    test_pass "marge CLI is executable"
else
    test_fail "marge CLI is not executable"
fi

if [[ -f "$SHARED_DIR/scripts/marge.ps1" ]]; then
    test_pass "marge.ps1 exists"
else
    test_fail "marge.ps1 missing"
fi

if [[ -f "$SHARED_DIR/scripts/marge-init" ]]; then
    test_pass "marge-init script exists"
else
    test_fail "marge-init script missing"
fi

if [[ -x "$SHARED_DIR/scripts/marge-init" ]]; then
    test_pass "marge-init is executable"
else
    test_fail "marge-init is not executable"
fi

if [[ -f "$SHARED_DIR/scripts/marge-init.ps1" ]]; then
    test_pass "marge-init.ps1 exists"
else
    test_fail "marge-init.ps1 missing"
fi

echo ""

# ============================================================
# Test 4: Install scripts exist
# ============================================================
echo -e "${BLUE}Test Group: Install Scripts${NC}"

if [[ -f "$SHARED_DIR/scripts/install-global.sh" ]]; then
    test_pass "install-global.sh exists"
else
    test_fail "install-global.sh missing"
fi

if [[ -x "$SHARED_DIR/scripts/install-global.sh" ]]; then
    test_pass "install-global.sh is executable"
else
    test_fail "install-global.sh is not executable"
fi

if [[ -f "$SHARED_DIR/scripts/install-global.ps1" ]]; then
    test_pass "install-global.ps1 exists"
else
    test_fail "install-global.ps1 missing"
fi

echo ""

# ============================================================
# Test 5: CLI command output tests
# ============================================================
echo -e "${BLUE}Test Group: CLI Command Output${NC}"

# Test help command
if "$SHARED_DIR/scripts/marge" help 2>&1 | grep -q "Usage:"; then
    test_pass "marge help shows usage"
else
    test_fail "marge help doesn't show usage"
fi

# Test fix command output
if "$SHARED_DIR/scripts/marge" fix "test bug" 2>&1 | grep -q "Bug Report:"; then
    test_pass "marge fix shows bug report"
else
    test_fail "marge fix doesn't show bug report"
fi

# Test add command output
if "$SHARED_DIR/scripts/marge" add "test feature" 2>&1 | grep -q "Feature Request:"; then
    test_pass "marge add shows feature request"
else
    test_fail "marge add doesn't show feature request"
fi

# Test audit command output
if "$SHARED_DIR/scripts/marge" audit 2>&1 | grep -q "Audit Request"; then
    test_pass "marge audit shows audit request"
else
    test_fail "marge audit doesn't show audit request"
fi

# Test unknown command
if "$SHARED_DIR/scripts/marge" unknown_command 2>&1 | grep -q "Unknown command"; then
    test_pass "marge handles unknown commands"
else
    test_fail "marge doesn't handle unknown commands"
fi

echo ""

# ============================================================
# Test 6: Content validation
# ============================================================
echo -e "${BLUE}Test Group: Content Validation${NC}"

# Check loop.md has required sections
if grep -q "Activation Triggers" "$SHARED_DIR/workflows/loop.md"; then
    test_pass "loop.md has Activation Triggers section"
else
    test_fail "loop.md missing Activation Triggers section"
fi

if grep -q "Loop Process" "$SHARED_DIR/workflows/loop.md"; then
    test_pass "loop.md has Loop Process section"
else
    test_fail "loop.md missing Loop Process section"
fi

# Check planning.md has required sections
if grep -q "Planning Mode Rules" "$SHARED_DIR/workflows/planning.md"; then
    test_pass "planning.md has Planning Mode Rules section"
else
    test_fail "planning.md missing Planning Mode Rules section"
fi

if grep -q "No Code Changes" "$SHARED_DIR/workflows/planning.md"; then
    test_pass "planning.md mentions no code changes"
else
    test_fail "planning.md doesn't mention no code changes"
fi

# Check _index.md references new workflows
if grep -q "loop.md" "$SHARED_DIR/workflows/_index.md"; then
    test_pass "_index.md references loop.md"
else
    test_fail "_index.md doesn't reference loop.md"
fi

if grep -q "planning.md" "$SHARED_DIR/workflows/_index.md"; then
    test_pass "_index.md references planning.md"
else
    test_fail "_index.md doesn't reference planning.md"
fi

echo ""

# ============================================================
# Test 7: AGENTS.md is modular (not monolithic)
# ============================================================
echo -e "${BLUE}Test Group: Modular Structure${NC}"

if grep -q "workflows/_index.md" "$SHARED_DIR/AGENTS.md"; then
    test_pass "AGENTS.md routes to workflows/_index.md"
else
    test_fail "AGENTS.md doesn't route to workflows/_index.md"
fi

# Check AGENTS.md is reasonably sized (not monolithic)
AGENTS_LINES=$(wc -l < "$SHARED_DIR/AGENTS.md")
if [[ $AGENTS_LINES -lt 500 ]]; then
    test_pass "AGENTS.md is compact (<500 lines: $AGENTS_LINES)"
else
    test_fail "AGENTS.md is too large ($AGENTS_LINES lines, expected <500)"
fi

echo ""

# ============================================================
# Summary
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Total:  $TESTS_RUN"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
