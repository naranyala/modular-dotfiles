#!/bin/bash

# Naravisuals Dotfiles Setup Script
# This script provides a unified way to bootstrap the development environment.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Naravisuals Dotfiles Setup...${NC}"

# 1. Define paths
DOTFILES_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"

# 2. Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# 3. Symlink Configurations
# Add your configurations here
declare -A configs=(
    ["dot-config-nvim"]="$CONFIG_DIR/nvim"
)

echo -e "${GREEN}🔗 Symlinking configurations...${NC}"
for src in "${!configs[@]}"; do
    dest="${configs[$src]}"
    if [ -L "$dest" ] || [ -d "$dest" ]; then
        echo "⚠️  $dest already exists, skipping..."
    else
        ln -s "$DOTFILES_DIR/$src" "$dest"
        echo "✅ Linked $src -> $dest"
    fi
done

# 4. Run System Scripts (Example: SSH Key Setup)
if [ -f "$DOTFILES_DIR/setup-local-ssh-key.sh" ]; then
    echo -e "${GREEN}🔑 Setting up SSH keys...${NC}"
    bash "$DOTFILES_DIR/setup-local-ssh-key.sh"
fi

echo -e "${BLUE}✨ Setup complete! Please restart your shell or source your config files.${NC}"
