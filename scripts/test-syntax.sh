#!/usr/bin/env bash
set -euo pipefail

# test-syntax.sh - Validates PowerShell and Bash script syntax
#
# Parses all .ps1 and .sh files in the repository to catch syntax errors
# before they cause runtime failures. This prevents issues like:
# - Escaped quote problems in here-strings
# - Invalid variable references
# - Encoding issues with special characters (em-dashes, etc.)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Find repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN} Syntax Validation${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

TOTAL_FILES=0
PASSED_FILES=0
FAILED_FILES=0
declare -a ERRORS=()

# Validate Bash files
echo -e "${YELLOW}[1/2] Checking Bash (.sh) files...${NC}"

while IFS= read -r -d '' file; do
    # Skip .meta_marge and node_modules
    if [[ "$file" == *"/.meta_marge/"* ]] || [[ "$file" == *"/node_modules/"* ]]; then
        continue
    fi
    
    ((TOTAL_FILES++)) || true
    rel_path="${file#"$REPO_ROOT"/}"
    
    if bash -n "$file" 2>/dev/null; then
        ((PASSED_FILES++)) || true
        echo -e "  ${GREEN}[PASS]${NC} $rel_path"
    else
        ((FAILED_FILES++)) || true
        error_msg=$(bash -n "$file" 2>&1 || true)
        ERRORS+=("  [FAIL] $rel_path : $error_msg")
        echo -e "  ${RED}[FAIL]${NC} $rel_path"
    fi
done < <(find "$REPO_ROOT" -name "*.sh" -type f -print0)

# Also check files without extension that have bash shebang
while IFS= read -r -d '' file; do
    # Skip .meta_marge, node_modules, and .git
    if [[ "$file" == *"/.meta_marge/"* ]] || [[ "$file" == *"/node_modules/"* ]] || [[ "$file" == *"/.git/"* ]]; then
        continue
    fi
    
    # Check if file has bash shebang
    first_line=$(head -n 1 "$file" 2>/dev/null || true)
    if [[ "$first_line" =~ ^#!.*bash ]]; then
        ((TOTAL_FILES++)) || true
        rel_path="${file#"$REPO_ROOT"/}"
        
        if bash -n "$file" 2>/dev/null; then
            ((PASSED_FILES++)) || true
            echo -e "  ${GREEN}[PASS]${NC} $rel_path"
        else
            ((FAILED_FILES++)) || true
            error_msg=$(bash -n "$file" 2>&1 || true)
            ERRORS+=("  [FAIL] $rel_path : $error_msg")
            echo -e "  ${RED}[FAIL]${NC} $rel_path"
        fi
    fi
done < <(find "$REPO_ROOT" -type f ! -name "*.*" -print0)

# Validate PowerShell files (if pwsh is available)
echo ""
echo -e "${YELLOW}[2/2] Checking PowerShell (.ps1) files...${NC}"

if ! command -v pwsh &>/dev/null; then
    echo -e "  ${YELLOW}[SKIP]${NC} pwsh not available on this system"
else
    while IFS= read -r -d '' file; do
        # Skip .meta_marge and node_modules
        if [[ "$file" == *"/.meta_marge/"* ]] || [[ "$file" == *"/node_modules/"* ]]; then
            continue
        fi
        
        ((TOTAL_FILES++)) || true
        rel_path="${file#"$REPO_ROOT"/}"
        
        # Use pwsh to parse and check for errors
        if pwsh -NoProfile -Command "[System.Management.Automation.Language.Parser]::ParseFile('$file', [ref]\$null, [ref]\$errors); if (\$errors.Count -gt 0) { exit 1 }" 2>/dev/null; then
            ((PASSED_FILES++)) || true
            echo -e "  ${GREEN}[PASS]${NC} $rel_path"
        else
            ((FAILED_FILES++)) || true
            ERRORS+=("  [FAIL] $rel_path : PowerShell parse error")
            echo -e "  ${RED}[FAIL]${NC} $rel_path"
        fi
    done < <(find "$REPO_ROOT" -name "*.ps1" -type f -print0)
fi

# Summary
echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN} Summary${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo "  Total files: $TOTAL_FILES"
echo -e "  Passed: ${GREEN}$PASSED_FILES${NC}"
if [[ $FAILED_FILES -gt 0 ]]; then
    echo -e "  Failed: ${RED}$FAILED_FILES${NC}"
else
    echo -e "  Failed: ${GREEN}$FAILED_FILES${NC}"
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

echo -e "${GREEN}All syntax checks passed!${NC}"
exit 0
