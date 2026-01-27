#!/usr/bin/env bash
set -euo pipefail

# install-global.sh
# Installs marge globally with shared resources and per-project initialization.
#
# Usage: ./install-global.sh [OPTIONS]
#
# Options:
#   -d, --dir DIR     Install directory (default: ~/.marge)
#   -f, --force       Overwrite existing installation
#   -h, --help        Show this help message
#
# After installation, use 'marge-init' in any project directory to set up
# .marge/ with symlinks to shared resources and local tracking files.

INSTALL_DIR="${HOME}/.marge"
FORCE=0

print_usage() {
    sed -n '3,12p' "$0" | sed 's/^# //' | sed 's/^#//'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=1
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            print_usage
            exit 1
            ;;
    esac
done

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SRC_DIR/.." && pwd)"

if [[ ! -f "$REPO_ROOT/AGENTS.md" ]]; then
    echo "Error: AGENTS.md not found in $REPO_ROOT" >&2
    exit 1
fi

# MS-0005: Reject symlinked INSTALL_DIR to prevent symlink attacks
if [[ -L "$INSTALL_DIR" ]]; then
    echo "Error: $INSTALL_DIR is a symlink. Refusing to proceed for security." >&2
    echo "Remove the symlink manually if you want to install here." >&2
    exit 1
fi

if [[ -d "$INSTALL_DIR" ]]; then
    if [[ "$FORCE" -ne 1 ]]; then
        echo "Error: $INSTALL_DIR already exists. Use --force to overwrite." >&2
        exit 1
    fi
    # MS-0005: Check again after --force in case it became a symlink
    if [[ -L "$INSTALL_DIR" ]]; then
        echo "Error: $INSTALL_DIR is a symlink. Refusing to rm -rf for security." >&2
        exit 1
    fi
    echo "Removing existing installation..."
    rm -rf "$INSTALL_DIR"
fi

echo "Installing marge globally to $INSTALL_DIR..."

# Create directory structure
mkdir -p "$INSTALL_DIR/shared" "$INSTALL_DIR/templates"

# Copy shared resources (symlinked to projects)
SHARED_FILES=(
    ".dev"
    "AGENTS.md"
    "AGENTS-lite.md"
    "experts"
    "knowledge"
    "prompts"
    "README.md"
    "scripts"
    "VERSION"
    "workflows"
)

for item in "${SHARED_FILES[@]}"; do
    if [[ -e "$REPO_ROOT/$item" ]]; then
        cp -R "$REPO_ROOT/$item" "$INSTALL_DIR/shared/"
    fi
done

# Copy system files (model_pricing.json, LICENSE, CHANGELOG.md)
for item in "model_pricing.json" "LICENSE" "CHANGELOG.md"; do
    if [[ -e "$REPO_ROOT/system/$item" ]]; then
        cp "$REPO_ROOT/system/$item" "$INSTALL_DIR/shared/"
    fi
done

# Copy per-project templates (from system/tracking/)
# MS-0010: Fixed path from tracking/ to system/tracking/
TEMPLATE_FILES=(
    "assessment.md"
    "tasklist.md"
    "PRD.md"
)

for item in "${TEMPLATE_FILES[@]}"; do
    if [[ -e "$REPO_ROOT/system/tracking/$item" ]]; then
        cp "$REPO_ROOT/system/tracking/$item" "$INSTALL_DIR/templates/"
    fi
done

# Copy verify.config.json from root
if [[ -e "$REPO_ROOT/verify.config.json" ]]; then
    cp "$REPO_ROOT/verify.config.json" "$INSTALL_DIR/templates/"
fi

# Install marge-init script
cp "$SRC_DIR/marge-init" "$INSTALL_DIR/marge-init"
chmod +x "$INSTALL_DIR/marge-init"

# Install marge CLI wrapper (bash)
cp "$SRC_DIR/marge" "$INSTALL_DIR/marge"
chmod +x "$INSTALL_DIR/marge"

# Install marge CLI wrapper (PowerShell - for Windows/WSL users)
if [[ -e "$SRC_DIR/marge.ps1" ]]; then
    cp "$SRC_DIR/marge.ps1" "$INSTALL_DIR/marge.ps1"
fi

# Create convenience symlinks in ~/.local/bin if it exists or can be created
LOCAL_BIN="${HOME}/.local/bin"
if [[ -d "$LOCAL_BIN" ]] || mkdir -p "$LOCAL_BIN" 2>/dev/null; then
    ln -sf "$INSTALL_DIR/marge" "$LOCAL_BIN/marge"
    ln -sf "$INSTALL_DIR/marge-init" "$LOCAL_BIN/marge-init"
    ADDED_TO_PATH=1
else
    ADDED_TO_PATH=0
fi

# Validate installation
echo "Validating installation..."
REQUIRED=(
    "$INSTALL_DIR/shared/AGENTS.md"
    "$INSTALL_DIR/shared/scripts/verify.sh"
    "$INSTALL_DIR/shared/workflows"
    "$INSTALL_DIR/shared/experts"
    "$INSTALL_DIR/templates/assessment.md"
    "$INSTALL_DIR/templates/tasklist.md"
    "$INSTALL_DIR/marge-init"
    "$INSTALL_DIR/marge"
)

MISSING=()
for file in "${REQUIRED[@]}"; do
    if [[ ! -e "$file" ]]; then
        MISSING+=("$file")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "Warning: Installation may be incomplete. Missing:" >&2
    for f in "${MISSING[@]}"; do
        echo "  - $f" >&2
    done
fi

echo ""
echo "✓ Marge installed globally to $INSTALL_DIR"
echo ""
echo "Structure:"
echo "  $INSTALL_DIR/"
echo "  ├── shared/        # Shared resources (symlinked to projects)"
echo "  │   ├── AGENTS.md"
echo "  │   ├── experts/"
echo "  │   ├── workflows/"
echo "  │   ├── scripts/"
echo "  │   └── knowledge/"
echo "  ├── templates/     # Per-project templates"
echo "  │   ├── assessment.md      (goes into tracking/)"
echo "  │   ├── tasklist.md        (goes into tracking/)"
echo "  │   └── verify.config.json"
echo "  ├── marge          # CLI wrapper"
echo "  └── marge-init     # Project initialization script"
echo ""

if [[ "$ADDED_TO_PATH" -eq 1 ]]; then
    echo "marge and marge-init have been added to $LOCAL_BIN"
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
        echo ""
        echo "Add to your PATH (if not already):"
        echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
        echo "  source ~/.bashrc"
    fi
else
    echo "To use marge from anywhere, add to your PATH:"
    echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.bashrc"
    echo "  source ~/.bashrc"
fi

echo ""
echo "Usage:"
echo "  marge \"fix the bug\"              # Run task directly"
echo "  marge \"refactor\" --model opus    # Use specific model"
echo "  marge \"audit\" --dry-run          # Preview prompt"
echo "  marge \"cleanup\" --loop           # Iterate until done"
echo "  marge \"hotfix\" --fast            # Skip verification"
echo "  marge init                        # Initialize .marge/"
echo "  marge status                      # Show marge status"
echo "  marge --help                      # Show all commands"
