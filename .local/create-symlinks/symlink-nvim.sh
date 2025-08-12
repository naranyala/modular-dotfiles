#!/usr/bin/bash

# set -a
# source .env
# set +a
# echo "$DOT_PATH"
DOT_PATH="$HOME/project-remote/modular-dotfiles"


# ln -s ~/projects-remote/modular-dotfiles/.config/nvim ~/.config/nvim

target="$HOME/.config/nvim"
source="$DOT_PATH/.config/nvim"

# Confirm before deletion
read -p "This will delete '$target'. Proceed? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$target"
    ln -s "$source" "$target"
    echo "Symlink created: '$target' → '$source'"
else
    echo "Operation cancelled."
fi
