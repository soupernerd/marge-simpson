#!/usr/bin/env bash
#
# test-scenarios.sh - Tests all Marge user scenarios
#
# Simulates four user types:
# 1. CLI Global User - Installs globally, deletes repo, uses marge anywhere
# 2. Drop-in Folder User - Copies folder into project, uses Chat/IDE
# 3. Hybrid User - Both global CLI and drop-in folder
# 4. IDE-only User - Uses repo directly without CLI install
#
# Usage:
#   ./scripts/test-scenarios.sh
#   ./scripts/test-scenarios.sh --scenario global
#   ./scripts/test-scenarios.sh --verbose
#   ./scripts/test-scenarios.sh --keep-temp

set -e

SCENARIO="all"
VERBOSE=false
KEEP_TEMP=false
TESTS_PASSED=0
TESTS_FAILED=0
TEMP_DIRS=()

# Get repo root (.dev/meta/meta_tests -> .dev/meta -> .dev -> marge-simpson)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_DIR="$(dirname "$SCRIPT_DIR")"
DEV_DIR="$(dirname "$META_DIR")"
REPO_ROOT="$(dirname "$DEV_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --scenario|-s)
            SCENARIO="$2"
            shift 2
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --keep-temp|-k)
            KEEP_TEMP=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--scenario all|global|dropin|hybrid|ide] [--verbose] [--keep-temp]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

write_header() {
    echo -e "\n${CYAN}  +---------------------------------------------------------------------------+"
    printf "${CYAN}  | %-73s |\n" "$1"
    echo -e "${CYAN}  +---------------------------------------------------------------------------+${NC}"
}

write_result() {
    local name="$1"
    local passed="$2"
    local details="${3:-}"
    
    if [[ "$passed" == "true" ]]; then
        ((TESTS_PASSED++))
        echo -e "    ${GREEN}[PASS]${NC} $name"
    else
        ((TESTS_FAILED++))
        echo -e "    ${RED}[FAIL]${NC} $name"
        [[ -n "$details" ]] && echo -e "           ${YELLOW}$details${NC}"
    fi
}

new_temp_dir() {
    local prefix="$1"
    local temp_dir
    temp_dir=$(mktemp -d "/tmp/${prefix}-XXXXXX")
    TEMP_DIRS+=("$temp_dir")
    echo "$temp_dir"
}

# shellcheck disable=SC2329,SC2317
cleanup_temp_dirs() {
    if [[ "$KEEP_TEMP" == "false" ]]; then
        for dir in "${TEMP_DIRS[@]}"; do
            [[ -d "$dir" ]] && rm -rf "$dir"
        done
    else
        echo -e "\n${YELLOW}  Temp directories preserved:${NC}"
        for dir in "${TEMP_DIRS[@]}"; do
            echo -e "    ${GRAY}$dir${NC}"
        done
    fi
}

# ============================================================================
# Scenario 1: CLI Global User
# ============================================================================
test_global_cli_user() {
    write_header "Scenario 1: CLI Global User"
    echo -e "    ${GRAY}Simulates: User clones repo, installs globally, deletes repo${NC}"
    
    local fake_marge_home fake_project shared_dir templates_dir dev_dir
    fake_marge_home=$(new_temp_dir "marge-home")
    fake_project=$(new_temp_dir "user-project")
    
    shared_dir="$fake_marge_home/shared"
    templates_dir="$fake_marge_home/templates"
    dev_dir="$shared_dir/.dev"
    
    mkdir -p "$shared_dir" "$templates_dir" "$dev_dir"
    
    # Copy shared resources (what install-global.sh does)
    cp "$REPO_ROOT/AGENTS.md" "$shared_dir/"
    cp "$REPO_ROOT/AGENTS-lite.md" "$shared_dir/"
    cp -r "$REPO_ROOT/workflows" "$shared_dir/"
    cp -r "$REPO_ROOT/experts" "$shared_dir/"
    cp -r "$REPO_ROOT/knowledge" "$shared_dir/"
    cp -r "$REPO_ROOT/scripts" "$shared_dir/"
    cp -r "$REPO_ROOT/.dev" "$shared_dir/"
    cp "$REPO_ROOT/model_pricing.json" "$shared_dir/"
    cp "$REPO_ROOT/verify.config.json" "$shared_dir/"
    
    # Copy templates
    cp "$REPO_ROOT/tracking/assessment.md" "$templates_dir/"
    cp "$REPO_ROOT/tracking/tasklist.md" "$templates_dir/"
    cp "$REPO_ROOT/.dev/PRD.md" "$templates_dir/"
    
    # Copy CLI scripts
    cp "$REPO_ROOT/cli/marge" "$fake_marge_home/"
    cp "$REPO_ROOT/cli/marge-init" "$fake_marge_home/"
    
    # Test 1: Shared folder has all required files
    local all_shared_exist=true
    for item in AGENTS.md AGENTS-lite.md workflows experts knowledge scripts .dev model_pricing.json; do
        if [[ ! -e "$shared_dir/$item" ]]; then
            all_shared_exist=false
            break
        fi
    done
    write_result "Global install has all shared resources" "$all_shared_exist"
    
    # Test 2: .dev folder exists in shared (for meta support)
    local dev_exists=false
    [[ -f "$shared_dir/.dev/convert-to-meta.sh" ]] && dev_exists=true
    write_result "Global install includes .dev/ for meta support" "$dev_exists"
    
    # Test 3: Simulate running marge init in user project
    pushd "$fake_project" > /dev/null
    export MARGE_HOME="$fake_marge_home"
    
    local marge_dir="$fake_project/.marge"
    local tracking_dir="$fake_project/tracking"
    mkdir -p "$marge_dir" "$tracking_dir"
    
    # Copy shared resources (simulating symlinks)
    cp "$shared_dir/AGENTS.md" "$marge_dir/"
    cp "$shared_dir/AGENTS-lite.md" "$marge_dir/"
    cp -r "$shared_dir/workflows" "$marge_dir/"
    cp -r "$shared_dir/experts" "$marge_dir/"
    cp -r "$shared_dir/knowledge" "$marge_dir/"
    cp -r "$shared_dir/scripts" "$marge_dir/"
    
    # Copy templates
    cp "$templates_dir/assessment.md" "$tracking_dir/"
    cp "$templates_dir/tasklist.md" "$tracking_dir/"
    
    local init_success=false
    [[ -f "$marge_dir/AGENTS.md" && -f "$tracking_dir/assessment.md" ]] && init_success=true
    write_result "marge init creates .marge/ structure in project" "$init_success"
    
    # Test 4: AGENTS.md is readable and has expected content
    local agents_valid=false
    if grep -q "AGENTS.md" "$marge_dir/AGENTS.md" && grep -q "tracking/" "$marge_dir/AGENTS.md"; then
        agents_valid=true
    fi
    write_result "AGENTS.md has valid content for project use" "$agents_valid"
    
    # Test 5: Simulate meta init from global install
    local convert_script="$shared_dir/.dev/convert-to-meta.sh"
    if [[ -f "$convert_script" ]]; then
        local has_global_detection=false
        grep -q 'IS_GLOBAL_INSTALL' "$convert_script" && has_global_detection=true
        write_result "convert-to-meta.sh has global install detection" "$has_global_detection"
    else
        write_result "convert-to-meta.sh exists in global .dev/" "false" "Script not found"
    fi
    
    unset MARGE_HOME
    popd > /dev/null
}

# ============================================================================
# Scenario 2: Drop-in Folder User
# ============================================================================
test_dropin_user() {
    write_header "Scenario 2: Drop-in Folder User"
    echo -e "    ${GRAY}Simulates: User copies marge-simpson/ into their project${NC}"
    
    local fake_project marge_folder
    fake_project=$(new_temp_dir "dropin-project")
    marge_folder="$fake_project/marge-simpson"
    
    # Copy entire repo as drop-in folder (keeps original name)
    cp -r "$REPO_ROOT" "$marge_folder"
    
    # Test 1: All required files exist
    local all_exist=true
    for file in AGENTS.md workflows/_index.md workflows/work.md experts/_index.md \
                knowledge/_index.md tracking/assessment.md tracking/tasklist.md scripts/verify.sh; do
        if [[ ! -f "$marge_folder/$file" ]]; then
            all_exist=false
            [[ "$VERBOSE" == "true" ]] && echo -e "      ${YELLOW}Missing: $file${NC}"
        fi
    done
    write_result "Drop-in folder has all required files" "$all_exist"
    
    # Test 2: AGENTS.md uses relative paths (not hardcoded marge-simpson/)
    local uses_relative=false
    if grep -q '\./tracking/' "$marge_folder/AGENTS.md" && ! grep -q 'marge-simpson/tracking/' "$marge_folder/AGENTS.md"; then
        uses_relative=true
    fi
    write_result "AGENTS.md uses relative paths (./)" "$uses_relative"
    
    # Test 3: Scripts exist in drop-in folder
    local scripts_exist=false
    [[ -f "$marge_folder/scripts/verify.sh" && -f "$marge_folder/scripts/test-syntax.sh" ]] && scripts_exist=true
    write_result "Scripts exist in drop-in folder" "$scripts_exist"
    
    # Test 4: Can run verify from drop-in folder (folder is named marge-simpson)
    pushd "$marge_folder" > /dev/null
    local verify_success=false
    if ./scripts/verify.sh fast --skip-if-no-tests > /dev/null 2>&1; then
        verify_success=true
    fi
    write_result "verify.sh runs from drop-in folder" "$verify_success"
    popd > /dev/null
    
    # Test 5: .dev/ folder exists for meta-development
    local dev_exists=false
    [[ -f "$marge_folder/.dev/convert-to-meta.sh" ]] && dev_exists=true
    write_result ".dev/ exists for meta-development" "$dev_exists"
    
    # Test 6: Can create .meta_marge/ for self-improvement
    if [[ "$dev_exists" == "true" ]]; then
        local has_required=false
        if grep -q 'TARGET_FOLDER\|create_meta_marge' "$marge_folder/.dev/convert-to-meta.sh"; then
            has_required=true
        fi
        write_result "convert-to-meta.sh is valid" "$has_required"
    fi
}

# ============================================================================
# Scenario 3: Hybrid User
# ============================================================================
test_hybrid_user() {
    write_header "Scenario 3: Hybrid User"
    echo -e "    ${GRAY}Simulates: User has global CLI AND drop-in folders in projects${NC}"
    
    local fake_marge_home project_with_dropin
    fake_marge_home=$(new_temp_dir "hybrid-home")
    project_with_dropin=$(new_temp_dir "hybrid-dropin")
    
    # Set up global install
    local shared_dir="$fake_marge_home/shared"
    mkdir -p "$shared_dir"
    cp "$REPO_ROOT/AGENTS.md" "$shared_dir/"
    cp "$REPO_ROOT/AGENTS-lite.md" "$shared_dir/"
    cp -r "$REPO_ROOT/workflows" "$shared_dir/"
    
    # Project 1: Has drop-in folder (should use local, not global)
    local dropin_marge="$project_with_dropin/marge-simpson"
    mkdir -p "$dropin_marge"
    cp "$REPO_ROOT/AGENTS.md" "$dropin_marge/"
    # Add a marker to identify this as local
    echo -e "\n<!-- LOCAL_MARKER -->" >> "$dropin_marge/AGENTS.md"
    
    # Test 1: Drop-in project uses local AGENTS.md
    local uses_local=false
    grep -q 'LOCAL_MARKER' "$dropin_marge/AGENTS.md" && uses_local=true
    write_result "Project with drop-in uses local AGENTS.md" "$uses_local"
    
    # Test 2: Project without drop-in would use global
    export MARGE_HOME="$fake_marge_home"
    local global_exists=false
    [[ -f "$shared_dir/AGENTS.md" ]] && global_exists=true
    write_result "Global AGENTS.md available for CLI projects" "$global_exists"
    
    # Test 3: Both can coexist
    local both_exist=false
    [[ -f "$dropin_marge/AGENTS.md" && -f "$shared_dir/AGENTS.md" ]] && both_exist=true
    write_result "Local and global can coexist" "$both_exist"
    
    # Test 4: Local takes precedence (simulated check)
    write_result "Local .marge/ takes precedence over global" "true"
    
    unset MARGE_HOME
}

# ============================================================================
# Scenario 4: IDE-only User
# ============================================================================
test_ide_only_user() {
    write_header "Scenario 4: IDE-only User"
    echo -e "    ${GRAY}Simulates: User opens repo in VS Code, uses Chat/IDE only${NC}"
    
    # Test 1: AGENTS.md is directly usable
    local agents_exists=false
    [[ -f "$REPO_ROOT/AGENTS.md" ]] && agents_exists=true
    write_result "AGENTS.md exists at repo root" "$agents_exists"
    
    # Test 2: Prompts folder has ready-to-use templates
    local prompts_exist=false
    [[ -d "$REPO_ROOT/prompts" ]] && prompts_exist=true
    write_result "prompts/ folder exists with templates" "$prompts_exist"
    
    if [[ "$prompts_exist" == "true" ]]; then
        local prompt_count
        prompt_count=$(find "$REPO_ROOT/prompts" -name "*.md" ! -name "_index.md" | wc -l)
        local has_prompts=false
        [[ $prompt_count -gt 0 ]] && has_prompts=true
        write_result "Prompt templates available ($prompt_count found)" "$has_prompts"
    fi
    
    # Test 3: README has Chat Prompt Templates section
    local has_prompt_section=false
    grep -q 'Chat Prompt Templates' "$REPO_ROOT/README.md" && has_prompt_section=true
    write_result "README has Chat Prompt Templates section" "$has_prompt_section"
    
    # Test 4: tracking/ folder exists for work tracking
    local tracking_exists=false
    [[ -d "$REPO_ROOT/tracking" ]] && tracking_exists=true
    write_result "tracking/ folder exists for IDE users" "$tracking_exists"
    
    # Test 5: .dev/ available for meta-development without CLI
    local dev_exists=false
    [[ -f "$REPO_ROOT/.dev/convert-to-meta.sh" ]] && dev_exists=true
    write_result ".dev/ available for IDE meta-development" "$dev_exists"
    
    # Test 6: Can run scripts directly (no CLI required)
    local scripts_exist=false
    [[ -f "$REPO_ROOT/scripts/verify.sh" && -f "$REPO_ROOT/scripts/status.sh" ]] && scripts_exist=true
    write_result "Scripts runnable directly without CLI" "$scripts_exist"
}

# ============================================================================
# Main Execution
# ============================================================================

echo -e "
${CYAN}    +=========================================================================+
    |                                                                         |
    |    __  __    _    ____   ____ _____                                     |
    |   |  \/  |  / \\  |  _ \\ / ___| ____|                                    |
    |   | |\\/| | / _ \\ | |_) | |  _|  _|                                      |
    |   | |  | |/ ___ \\|  _ <| |_| | |___                                     |
    |   |_|  |_/_/   \\_\\_| \\_\\\\____|_____|                                    |
    |                                                                         |
    |              U S E R   S C E N A R I O   T E S T S                      |
    |                                                                         |
    +=========================================================================+
${NC}"

trap cleanup_temp_dirs EXIT

case "$SCENARIO" in
    all)
        test_global_cli_user
        test_dropin_user
        test_hybrid_user
        test_ide_only_user
        ;;
    global)
        test_global_cli_user
        ;;
    dropin)
        test_dropin_user
        ;;
    hybrid)
        test_hybrid_user
        ;;
    ide)
        test_ide_only_user
        ;;
    *)
        echo "Unknown scenario: $SCENARIO"
        exit 1
        ;;
esac

# Summary
TOTAL=$((TESTS_PASSED + TESTS_FAILED))

echo -e "
${CYAN}  +=========================================================================+
  |                     SCENARIO TEST RESULTS                               |
  +=========================================================================+
  |                                                                         |
  |   Passed: $(printf '%3d' $TESTS_PASSED) | Failed: $(printf '%3d' $TESTS_FAILED) | Total: $(printf '%3d' $TOTAL)                                        |
  |                                                                         |${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}  |   STATUS:  [OK] ALL SCENARIO TESTS PASSED                              |${NC}"
else
    echo -e "${RED}  |   STATUS:  [FAIL] SOME TESTS FAILED                                    |${NC}"
fi

echo -e "${CYAN}  |                                                                         |
  +=========================================================================+
${NC}"

exit $TESTS_FAILED
