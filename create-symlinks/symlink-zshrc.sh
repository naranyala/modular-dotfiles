

#!/usr/bin/bash

target="$HOME/.zshrc"
source="$HOME/modular-dotfiles/.zshrc"

# Confirm before deletion
read -p "This will delete '$target'. Proceed? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$target"
    ln -s "$source" "$target"
    echo "Symlink created: '$target' → '$source'"
else
    echo "Operation cancelled."
fi
