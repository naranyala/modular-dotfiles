#!/usr/bin/bash

target="$HOME/.config/nvim"
source="$HOME/modular-dotfiles/nvim"

# Confirm before deletion
read -p "This will delete '$target'. Proceed? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$target"
    ln -s "$source" "$target"
    echo "Symlink created: '$target' → '$source'"
else
    echo "Operation cancelled."
fi
