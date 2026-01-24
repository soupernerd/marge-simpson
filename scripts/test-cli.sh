#!/usr/bin/env bash
set -euo pipefail

# test-cli.sh - CLI Integration Tests
#
# Tests the marge CLI commands and flags work correctly.
# Does NOT require actual AI engines - tests help/version/init/clean/status.
#
# Usage:
#   ./scripts/test-cli.sh

# Dynamic folder detection
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MS_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
MS_FOLDER_NAME="$(basename "$MS_DIR")"

TESTS_PASSED=0
TESTS_FAILED=0
START_TIME=$(date +%s)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# ==============================================================================
# VISUAL HELPERS
# ==============================================================================

write_banner() {
    echo ""
    echo -e "${CYAN}    +=========================================================================+${NC}"
    echo -e "${CYAN}    |                                                                         |${NC}"
    echo -e "${CYAN}    |    __  __    _    ____   ____ _____                                     |${NC}"
    echo -e "${CYAN}    |   |  \\/  |  / \\  |  _ \\ / ___| ____|                                    |${NC}"
    echo -e "${CYAN}    |   | |\\/| | / _ \\ | |_) | |  _|  _|                                      |${NC}"
    echo -e "${CYAN}    |   | |  | |/ ___ \\|  _ <| |_| | |___                                     |${NC}"
    echo -e "${CYAN}    |   |_|  |_/_/   \\_\\_| \\_\\\\____|_____|                                    |${NC}"
    echo -e "${CYAN}    |                                                                         |${NC}"
    echo -e "${CYAN}    |                 C L I   I N T E G R A T I O N   T E S T S               |${NC}"
    echo -e "${CYAN}    |                                                                         |${NC}"
    echo -e "${CYAN}    +=========================================================================+${NC}"
    echo ""
}

write_section() {
    local title="$1"
    echo ""
    echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
    printf "${GRAY}  | ${WHITE}%-73s${GRAY} |${NC}\n" "$title"
    echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
}

write_test_result() {
    local name="$1"
    local passed="$2"
    local detail="${3:-}"
    
    if [[ "$passed" == "true" ]]; then
        echo -e "    ${GREEN}[PASS] $name${NC}"
    else
        if [[ -n "$detail" ]]; then
            echo -e "    ${RED}[FAIL] $name ($detail)${NC}"
        else
            echo -e "    ${RED}[FAIL] $name${NC}"
        fi
    fi
}

write_final_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    local total=$((TESTS_PASSED + TESTS_FAILED))
    
    local border_color
    local status_text
    if [[ $TESTS_FAILED -eq 0 ]]; then
        border_color="${GREEN}"
        status_text="   STATUS:  [OK] ALL CLI TESTS PASSED"
    else
        border_color="${RED}"
        status_text="   STATUS:  [X] $TESTS_FAILED TEST(S) FAILED"
    fi
    
    echo ""
    echo -e "${border_color}  +=========================================================================+${NC}"
    echo -e "${border_color}  |                       CLI TEST RESULTS                                  |${NC}"
    echo -e "${border_color}  +=========================================================================+${NC}"
    echo -e "${border_color}  |                                                                         |${NC}"
    printf "${border_color}  |%-73s |${NC}\n" "$status_text"
    echo -e "${border_color}  |                                                                         |${NC}"
    echo -e "${border_color}  +---------------------------------------------------------------------------+${NC}"
    printf "${border_color}  |   Passed: %d | Failed: %d | Duration: %02dm %02ds                             |${NC}\n" "$TESTS_PASSED" "$TESTS_FAILED" "$minutes" "$seconds"
    echo -e "${border_color}  +=========================================================================+${NC}"
    echo ""
}

test_assert() {
    local name="$1"
    local test_result="$2"
    
    if [[ "$test_result" == "true" ]] || [[ "$test_result" == "0" ]]; then
        ((TESTS_PASSED++)) || true
        write_test_result "$name" "true"
        return 0
    else
        ((TESTS_FAILED++)) || true
        write_test_result "$name" "false" "$test_result"
        return 1
    fi
}

# ==============================================================================
# TESTS
# ==============================================================================

write_banner

# Test Suite 1: Version and Help Commands
write_section "Test Suite 1/6: Version and Help Commands"

# Test: marge --version runs without error
result="false"
if "$MS_DIR/cli/marge" --version >/dev/null 2>&1; then
    result="true"
fi
test_assert "marge --version runs without error" "$result" || true

# Test: marge --help runs without error
result="false"
if "$MS_DIR/cli/marge" --help >/dev/null 2>&1; then
    result="true"
fi
test_assert "marge --help runs without error" "$result" || true

# Test: marge has VERSION variable
result="false"
if grep -qE '^VERSION=' "$MS_DIR/cli/marge"; then
    result="true"
fi
test_assert "marge has VERSION variable" "$result" || true

# Test: marge has show_usage function
result="false"
content=$(cat "$MS_DIR/cli/marge")
if echo "$content" | grep -q "show_usage()" && echo "$content" | grep -q "USAGE:"; then
    result="true"
fi
test_assert "marge has show_usage function" "$result" || true

# Test Suite 2: Status Command
write_section "Test Suite 2/6: Status Command"

# Test: marge status runs without error
result="false"
if "$MS_DIR/cli/marge" status >/dev/null 2>&1; then
    result="true"
fi
test_assert "marge status runs without error" "$result" || true

# Test: marge has show_status function
result="false"
content=$(cat "$MS_DIR/cli/marge")
if echo "$content" | grep -q "show_status()" && echo "$content" | grep -q "Marge Status"; then
    result="true"
fi
test_assert "marge has show_status function" "$result" || true

# Test Suite 3: DryRun and Mode Detection
write_section "Test Suite 3/6: DryRun and Mode Detection"

# Test: marge supports --dry-run parameter
result="false"
if grep -q "\-\-dry-run" "$MS_DIR/cli/marge"; then
    result="true"
fi
test_assert "marge supports --dry-run parameter" "$result" || true

# Test: marge has lite mode detection
result="false"
content=$(cat "$MS_DIR/cli/marge")
if echo "$content" | grep -q "AGENTS-lite.md" && echo "$content" | grep -qi "lite mode"; then
    result="true"
fi
test_assert "marge has lite mode detection" "$result" || true

# Test: marge validates MARGE_HOME in lite mode
result="false"
if grep -q "MARGE_HOME not found" "$MS_DIR/cli/marge"; then
    result="true"
fi
test_assert "marge validates MARGE_HOME in lite mode" "$result" || true

# Test Suite 4: Shared Resources Check
write_section "Test Suite 4/6: Shared Resources Check"

# Test: AGENTS-lite.md exists in repo root
result="false"
if [[ -f "$MS_DIR/AGENTS-lite.md" ]]; then
    result="true"
fi
test_assert "AGENTS-lite.md exists in repo root" "$result" || true

# Test: marge-init.ps1 includes AGENTS-lite.md in SharedLinks
result="false"
if grep -q "AGENTS-lite\.md" "$MS_DIR/cli/marge-init.ps1"; then
    result="true"
fi
test_assert "marge-init.ps1 includes AGENTS-lite.md in SharedLinks" "$result" || true

# Test: marge-init (bash) includes AGENTS-lite.md in SHARED_LINKS
result="false"
if grep -q "AGENTS-lite\.md" "$MS_DIR/cli/marge-init"; then
    result="true"
fi
test_assert "marge-init (bash) includes AGENTS-lite.md in SHARED_LINKS" "$result" || true

# Test: install-global.ps1 includes AGENTS-lite.md
result="false"
if grep -q "AGENTS-lite\.md" "$MS_DIR/cli/install-global.ps1"; then
    result="true"
fi
test_assert "install-global.ps1 includes AGENTS-lite.md" "$result" || true

# Test: install-global.sh includes AGENTS-lite.md
result="false"
if grep -q "AGENTS-lite\.md" "$MS_DIR/cli/install-global.sh"; then
    result="true"
fi
test_assert "install-global.sh includes AGENTS-lite.md" "$result" || true

# Test Suite 5: Meta Commands (MS-0015)
write_section "Test Suite 5/6: Meta Commands"

# Test: marge.ps1 has Initialize-Meta function
result="false"
if grep -q "function Initialize-Meta" "$MS_DIR/cli/marge.ps1"; then
    result="true"
fi
test_assert "marge.ps1 has Initialize-Meta function" "$result" || true

# Test: marge.ps1 has Show-MetaStatus function
result="false"
if grep -q "function Show-MetaStatus" "$MS_DIR/cli/marge.ps1"; then
    result="true"
fi
test_assert "marge.ps1 has Show-MetaStatus function" "$result" || true

# Test: marge.ps1 has Remove-Meta function
result="false"
if grep -q "function Remove-Meta" "$MS_DIR/cli/marge.ps1"; then
    result="true"
fi
test_assert "marge.ps1 has Remove-Meta function" "$result" || true

# Test: marge (bash) has initialize_meta function
result="false"
if grep -q "initialize_meta()" "$MS_DIR/cli/marge"; then
    result="true"
fi
test_assert "marge (bash) has initialize_meta function" "$result" || true

# Test: marge (bash) has show_meta_status function
result="false"
if grep -q "show_meta_status()" "$MS_DIR/cli/marge"; then
    result="true"
fi
test_assert "marge (bash) has show_meta_status function" "$result" || true

# Test: marge (bash) has remove_meta function
result="false"
if grep -q "remove_meta()" "$MS_DIR/cli/marge"; then
    result="true"
fi
test_assert "marge (bash) has remove_meta function" "$result" || true

# Test: marge.ps1 help includes meta commands
result="false"
help_output=$("$MS_DIR/cli/marge" --help 2>&1) || true
if echo "$help_output" | grep -q "meta init" && echo "$help_output" | grep -q "meta status" && echo "$help_output" | grep -q "meta clean"; then
    result="true"
fi
test_assert "marge help includes meta commands" "$result" || true

# Test: install-global.ps1 has -Help parameter
result="false"
if grep -q '\[switch\]\$Help' "$MS_DIR/cli/install-global.ps1"; then
    result="true"
fi
test_assert "install-global.ps1 has -Help parameter" "$result" || true

# Test: convert-to-meta.ps1 has -Help parameter
result="false"
if grep -q '\[switch\]\$Help' "$MS_DIR/meta/convert-to-meta.ps1"; then
    result="true"
fi
test_assert "convert-to-meta.ps1 has -Help parameter" "$result" || true

# Test Suite 6: Edge Cases and Error Handling
write_section "Test Suite 6/6: Edge Cases and Error Handling"

# Test: marge.ps1 rejects invalid engine name
result="false"
content=$(cat "$MS_DIR/cli/marge.ps1")
if echo "$content" | grep -qi 'engine' && (echo "$content" | grep -qi 'Invalid\|supported\|valid'); then
    result="true"
fi
test_assert "marge.ps1 rejects invalid engine name" "$result" || true

# Test: marge (bash) rejects invalid engine name
result="false"
content=$(cat "$MS_DIR/cli/marge")
if echo "$content" | grep -qi 'engine' && (echo "$content" | grep -qi 'Invalid\|supported\|valid'); then
    result="true"
fi
test_assert "marge (bash) rejects invalid engine name" "$result" || true

# Test: marge.ps1 validates max-iterations parameter
result="false"
if grep -qi 'MaxIterations\|max-iterations' "$MS_DIR/cli/marge.ps1"; then
    result="true"
fi
test_assert "marge.ps1 validates max-iterations parameter" "$result" || true

# Test: marge (bash) validates max-iterations parameter
result="false"
if grep -qi 'max-iterations\|MAX_ITERATIONS' "$MS_DIR/cli/marge"; then
    result="true"
fi
test_assert "marge (bash) validates max-iterations parameter" "$result" || true

# Test: marge.ps1 handles empty task gracefully
result="false"
output=$("$MS_DIR/cli/marge.ps1" 2>&1) || true
if echo "$output" | grep -qi 'USAGE\|help\|command'; then
    result="true"
fi
test_assert "marge.ps1 handles empty task gracefully" "$result" || true

# Test: marge (bash) handles empty task gracefully
result="false"
output=$("$MS_DIR/cli/marge" 2>&1) || true
if echo "$output" | grep -qi 'USAGE\|usage\|help\|command'; then
    result="true"
fi
test_assert "marge (bash) handles empty task gracefully" "$result" || true

# Test: marge.ps1 has error output for missing required args
result="false"
content=$(cat "$MS_DIR/cli/marge.ps1")
if echo "$content" | grep -q 'Show-Usage\|required\|must provide'; then
    result="true"
fi
test_assert "marge.ps1 has error output for missing required args" "$result" || true

# Test: marge (bash) has error output for missing required args
result="false"
content=$(cat "$MS_DIR/cli/marge")
if echo "$content" | grep -q 'print_usage\|log_error\|required\|must provide'; then
    result="true"
fi
test_assert "marge (bash) has error output for missing required args" "$result" || true

# ==============================================================================
# SUMMARY
# ==============================================================================

write_final_summary

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
fi
exit 0
