#!/usr/bin/env bash
set -euo pipefail

# test-general.sh - General validation tests for Marge project quality
#
# Catches common issues before they become problems:
# - Encoding issues (non-ASCII characters that cause parsing errors)
# - Version mismatches across files
# - Missing required files
# - PS1/SH parity (ensures both platforms have equivalent scripts)
# - Documentation consistency (README references match actual files)
#
# These tests run against ALL applicable files, not specific ones.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Find repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
declare -a ERRORS=()

test_check() {
    local name="$1"
    local result="$2"
    local detail="${3:-}"
    
    ((TOTAL_TESTS++)) || true
    
    if [[ "$result" == "true" ]]; then
        ((PASSED_TESTS++)) || true
        echo -e "  ${GREEN}[PASS]${NC} $name"
        return 0
    else
        ((FAILED_TESTS++)) || true
        local msg="  [FAIL] $name"
        [[ -n "$detail" ]] && msg="$msg ($detail)"
        echo -e "  ${RED}$msg${NC}"
        ERRORS+=("$msg")
        return 1
    fi
}

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN} General Validation Tests${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# ==============================================================================
# Test 1: Encoding Validation (catches Unicode issues in scripts)
# ==============================================================================
echo -e "${YELLOW}[1/6] Checking file encoding for problematic characters...${NC}"

# Check for problematic Unicode characters in script files
encoding_issues=""
while IFS= read -r -d '' file; do
    # Skip .meta_marge and node_modules
    if [[ "$file" == *"/.meta_marge/"* ]] || [[ "$file" == *"/node_modules/"* ]]; then
        continue
    fi
    
    rel_path="${file#"$REPO_ROOT"/}"
    
    # Check for em-dash, en-dash, curly quotes
    if grep -qP '[\x{2014}\x{2013}\x{2018}\x{2019}\x{201C}\x{201D}]' "$file" 2>/dev/null; then
        encoding_issues="${encoding_issues}${rel_path} contains problematic Unicode; "
    fi
done < <(find "$REPO_ROOT" \( -name "*.ps1" -o -name "*.sh" \) -type f -print0)

if [[ -z "$encoding_issues" ]]; then
    test_check "No problematic Unicode in scripts" "true"
else
    test_check "No problematic Unicode in scripts" "false" "${encoding_issues%%; }"
fi

# Check for UTF-8 BOM in shell scripts
bom_issues=""
while IFS= read -r -d '' file; do
    if [[ "$file" == *"/.meta_marge/"* ]] || [[ "$file" == *"/node_modules/"* ]]; then
        continue
    fi
    
    # Check first 3 bytes for BOM
    if head -c 3 "$file" | grep -q $'\xef\xbb\xbf' 2>/dev/null; then
        rel_path="${file#"$REPO_ROOT"/}"
        bom_issues="${bom_issues}${rel_path}; "
    fi
done < <(find "$REPO_ROOT" -name "*.sh" -type f -print0)

if [[ -z "$bom_issues" ]]; then
    test_check "No UTF-8 BOM in shell scripts" "true"
else
    test_check "No UTF-8 BOM in shell scripts" "false" "has BOM: ${bom_issues%%; }"
fi

# ==============================================================================
# Test 2: Version Consistency
# ==============================================================================
echo ""
echo -e "${YELLOW}[2/6] Checking version consistency across files...${NC}"

VERSION_FILE="$REPO_ROOT/VERSION"
if [[ -f "$VERSION_FILE" ]]; then
    EXPECTED_VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")
    test_check "VERSION file exists and is valid" "true"
    
    # Check cli/marge
    if [[ -f "$REPO_ROOT/cli/marge" ]]; then
        MARGE_VERSION=$(grep -oP 'VERSION="[^"]+"' "$REPO_ROOT/cli/marge" | grep -oP '[\d.]+' | head -1)
        if [[ "$MARGE_VERSION" == "$EXPECTED_VERSION" ]]; then
            test_check "cli/marge version matches VERSION file ($EXPECTED_VERSION)" "true"
        else
            test_check "cli/marge version matches VERSION file ($EXPECTED_VERSION)" "false" "found $MARGE_VERSION"
        fi
    fi
else
    test_check "VERSION file exists and is valid" "false"
fi

# ==============================================================================
# Test 3: PS1/SH Script Parity
# ==============================================================================
echo ""
echo -e "${YELLOW}[3/6] Checking PS1/SH script parity...${NC}"

script_pairs=(
    "scripts/verify"
    "scripts/cleanup"
    "scripts/decay"
    "scripts/status"
    "scripts/test-marge"
    "scripts/test-syntax"
    "cli/install-global"
    "meta/convert-to-meta"
)

for base in "${script_pairs[@]}"; do
    base_name=$(basename "$base")
    ps1_exists=false
    sh_exists=false
    
    [[ -f "$REPO_ROOT/${base}.ps1" ]] && ps1_exists=true
    [[ -f "$REPO_ROOT/${base}.sh" ]] && sh_exists=true
    
    if $ps1_exists && $sh_exists; then
        test_check "Script pair exists: $base_name (.ps1 and .sh)" "true"
    else
        missing=""
        $ps1_exists || missing="${missing}.ps1 "
        $sh_exists || missing="${missing}.sh "
        test_check "Script pair exists: $base_name (.ps1 and .sh)" "false" "missing: $missing"
    fi
done

# ==============================================================================
# Test 4: Required Files Exist
# ==============================================================================
echo ""
echo -e "${YELLOW}[4/6] Checking required files exist...${NC}"

required_files=(
    "AGENTS.md"
    "README.md"
    "CHANGELOG.md"
    "VERSION"
    "LICENSE"
    "verify.config.json"
    "model_pricing.json"
    "workflows/_index.md"
    "workflows/work.md"
    "workflows/audit.md"
    "workflows/loop.md"
    "workflows/planning.md"
    "workflows/session_start.md"
    "workflows/session_end.md"
    "experts/_index.md"
    "knowledge/_index.md"
    "scripts/_index.md"
    "planning_docs/assessment.md"
    "planning_docs/tasklist.md"
    "cli/marge"
    "cli/marge.ps1"
    "cli/marge-init"
    "cli/marge-init.ps1"
)

for file in "${required_files[@]}"; do
    if [[ -f "$REPO_ROOT/$file" ]]; then
        test_check "Required file: $file" "true"
    else
        test_check "Required file: $file" "false"
    fi
done

# ==============================================================================
# Test 5: README Documentation Consistency
# ==============================================================================
echo ""
echo -e "${YELLOW}[5/6] Checking README references match actual files...${NC}"

README_PATH="$REPO_ROOT/README.md"

# Check documented folders exist
documented_folders=("cli" "scripts" "workflows" "experts" "knowledge" "planning_docs" "prompt_examples" "meta")
for folder in "${documented_folders[@]}"; do
    if [[ -d "$REPO_ROOT/$folder" ]]; then
        test_check "Documented folder exists: $folder/" "true"
    else
        test_check "Documented folder exists: $folder/" "false"
    fi
done

# Check CLI flags are documented and implemented
MARGE_PATH="$REPO_ROOT/cli/marge"
documented_flags=("--folder" "--dry-run" "--model" "--loop" "--engine" "--parallel" "--branch-per-task" "--create-pr" "--verbose")

for flag in "${documented_flags[@]}"; do
    in_readme=$(grep -q -- "$flag" "$README_PATH" 2>/dev/null && echo "true" || echo "false")
    in_marge=$(grep -q -- "$flag" "$MARGE_PATH" 2>/dev/null && echo "true" || echo "false")
    
    if [[ "$in_readme" == "true" ]] && [[ "$in_marge" == "true" ]]; then
        test_check "CLI flag documented and implemented: $flag" "true"
    else
        test_check "CLI flag documented and implemented: $flag" "false" "readme=$in_readme, marge=$in_marge"
    fi
done

# ==============================================================================
# Test 6: Workflow Connectivity
# ==============================================================================
echo ""
echo -e "${YELLOW}[6/6] Checking workflow file connectivity...${NC}"

WORKFLOW_INDEX="$REPO_ROOT/workflows/_index.md"

workflow_files=("work.md" "audit.md" "loop.md" "planning.md" "session_start.md" "session_end.md")
for wf in "${workflow_files[@]}"; do
    if grep -q "$wf" "$WORKFLOW_INDEX" 2>/dev/null; then
        test_check "Workflow $wf referenced in _index.md" "true"
    else
        test_check "Workflow $wf referenced in _index.md" "false"
    fi
    
    wf_path="$REPO_ROOT/workflows/$wf"
    if [[ -f "$wf_path" ]]; then
        if [[ "$wf" == "work.md" ]]; then
            if grep -qi "verify" "$wf_path" 2>/dev/null; then
                test_check "work.md references verification" "true"
            else
                test_check "work.md references verification" "false"
            fi
        fi
        
        if [[ "$wf" == "audit.md" ]]; then
            if grep -q "work.md" "$wf_path" 2>/dev/null; then
                test_check "audit.md references work.md" "true"
            else
                test_check "audit.md references work.md" "false"
            fi
        fi
    fi
done

# ==============================================================================
# Summary
# ==============================================================================
echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN} Summary${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo "  Total tests: $TOTAL_TESTS"
echo -e "  Passed: ${GREEN}$PASSED_TESTS${NC}"
if [[ $FAILED_TESTS -gt 0 ]]; then
    echo -e "  Failed: ${RED}$FAILED_TESTS${NC}"
else
    echo -e "  Failed: ${GREEN}$FAILED_TESTS${NC}"
fi
echo ""

if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo -e "${RED}Errors:${NC}"
    for err in "${ERRORS[@]}"; do
        echo -e "${RED}$err${NC}"
    done
    echo ""
    exit 1
fi

echo -e "${GREEN}All general validation tests passed!${NC}"
exit 0
