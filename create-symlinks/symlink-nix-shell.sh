
#!/usr/bin/bash

set -a
source .env
set +a


# echo "$DOT_PATH"

target="$HOME/shell.nix"
# source="$DOT_PATH/shell.nix"
source="$HOME/projects-remote/modular-dotfiles/shell.nix"

# Confirm before deletion
read -p "This will delete '$target'. Proceed? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$target"
    ln -s "$source" "$target"
    echo "Symlink created: '$target' → '$source'"
else
    echo "Operation cancelled."
fi

