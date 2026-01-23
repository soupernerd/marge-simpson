#!/usr/bin/env bash
# install-global.sh - Install Marge CLI globally
#
# This script installs the marge command globally so it can be
# invoked from any directory.
#
# Usage: ./install-global.sh [--uninstall]
#
# The script will:
# 1. Create symlink in /usr/local/bin (or ~/bin if no sudo)
# 2. Ensure MARGE_HOME is set up
# 3. Optionally add shell completion

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARGE_HOME="${MARGE_HOME:-$HOME/.marge}"
SHARED_DIR="$MARGE_HOME/shared"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "  __  __    _    ____   ____ _____   "
    echo " |  \/  |  / \  |  _ \ / ___| ____|  "
    echo " | |\/| | / _ \ | |_) | |  _|  _|    "
    echo " | |  | |/ ___ \|  _ <| |_| | |___   "
    echo " |_|  |_/_/   \_\_| \_\\\\____|_____|  "
    echo "        Global Installation          "
    echo -e "${NC}"
}

uninstall() {
    echo -e "${BLUE}Uninstalling Marge CLI...${NC}"

    local removed=0

    # Remove from /usr/local/bin
    if [[ -L "/usr/local/bin/marge" ]]; then
        sudo rm -f "/usr/local/bin/marge" && echo -e "${GREEN}✓${NC} Removed /usr/local/bin/marge" && ((removed++))
    fi

    if [[ -L "/usr/local/bin/marge-init" ]]; then
        sudo rm -f "/usr/local/bin/marge-init" && echo -e "${GREEN}✓${NC} Removed /usr/local/bin/marge-init" && ((removed++))
    fi

    # Remove from ~/bin
    if [[ -L "$HOME/bin/marge" ]]; then
        rm -f "$HOME/bin/marge" && echo -e "${GREEN}✓${NC} Removed ~/bin/marge" && ((removed++))
    fi

    if [[ -L "$HOME/bin/marge-init" ]]; then
        rm -f "$HOME/bin/marge-init" && echo -e "${GREEN}✓${NC} Removed ~/bin/marge-init" && ((removed++))
    fi

    # Remove from ~/.local/bin
    if [[ -L "$HOME/.local/bin/marge" ]]; then
        rm -f "$HOME/.local/bin/marge" && echo -e "${GREEN}✓${NC} Removed ~/.local/bin/marge" && ((removed++))
    fi

    if [[ -L "$HOME/.local/bin/marge-init" ]]; then
        rm -f "$HOME/.local/bin/marge-init" && echo -e "${GREEN}✓${NC} Removed ~/.local/bin/marge-init" && ((removed++))
    fi

    if [[ $removed -eq 0 ]]; then
        echo -e "${YELLOW}No Marge CLI installations found.${NC}"
    else
        echo -e "${GREEN}Marge CLI uninstalled successfully.${NC}"
    fi
}

install() {
    print_banner

    # Check if marge script exists
    local marge_script="$SHARED_DIR/scripts/marge"
    local marge_init_script="$SHARED_DIR/scripts/marge-init"

    if [[ ! -f "$marge_script" ]]; then
        echo -e "${RED}Error: marge script not found at $marge_script${NC}"
        echo "Please ensure Marge is properly installed in $MARGE_HOME"
        exit 1
    fi

    # Make scripts executable
    chmod +x "$marge_script" 2>/dev/null || true
    chmod +x "$marge_init_script" 2>/dev/null || true

    # Determine install location
    local install_dir=""
    local use_sudo=false

    if [[ -w "/usr/local/bin" ]]; then
        install_dir="/usr/local/bin"
    elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        install_dir="/usr/local/bin"
        use_sudo=true
    elif [[ -d "$HOME/.local/bin" && ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
        install_dir="$HOME/.local/bin"
    elif [[ -d "$HOME/bin" && ":$PATH:" == *":$HOME/bin:"* ]]; then
        install_dir="$HOME/bin"
    else
        # Create ~/.local/bin if it doesn't exist
        install_dir="$HOME/.local/bin"
        mkdir -p "$install_dir"
        echo -e "${YELLOW}Note: You may need to add ~/.local/bin to your PATH${NC}"
    fi

    echo -e "${BLUE}Installing to $install_dir...${NC}"

    # Create symlinks
    if [[ "$use_sudo" == true ]]; then
        sudo ln -sf "$marge_script" "$install_dir/marge"
        sudo ln -sf "$marge_init_script" "$install_dir/marge-init"
    else
        ln -sf "$marge_script" "$install_dir/marge"
        ln -sf "$marge_init_script" "$install_dir/marge-init"
    fi

    echo -e "${GREEN}✓${NC} Installed marge -> $install_dir/marge"
    echo -e "${GREEN}✓${NC} Installed marge-init -> $install_dir/marge-init"

    # Verify installation
    echo ""
    if command -v marge &>/dev/null; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  Marge CLI installed successfully!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Usage:"
        echo "  marge help              Show help"
        echo "  marge init              Initialize marge_simpson in a project"
        echo "  marge fix \"bug desc\"    Create a bug fix task"
        echo "  marge add \"feature\"     Create a feature task"
        echo "  marge audit             Run a codebase audit"
        echo "  marge verify            Run verification"
        echo ""
    else
        echo -e "${YELLOW}Warning: marge command not found in PATH${NC}"
        echo ""
        echo "You may need to:"
        echo "  1. Add $install_dir to your PATH"
        echo "  2. Restart your terminal"
        echo ""
        echo "Add to your shell profile (~/.bashrc or ~/.zshrc):"
        echo "  export PATH=\"\$PATH:$install_dir\""
    fi
}

# Parse arguments
case "${1:-}" in
    --uninstall|-u)
        uninstall
        ;;
    --help|-h)
        echo "Usage: $0 [--uninstall]"
        echo ""
        echo "Options:"
        echo "  --uninstall, -u    Remove marge from global path"
        echo "  --help, -h         Show this help"
        ;;
    *)
        install
        ;;
esac
