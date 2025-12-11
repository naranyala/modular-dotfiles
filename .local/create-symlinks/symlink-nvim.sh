
#!/usr/bin/bash

USER=$(whoami)

# DOT_PATH="/run/media/naranyala/Data/projects-remote/modular-dotfiles"
DOT_PATH="D:\projects-remote\modular-dotfiles"

# target="$HOME/.config/nvim"
target="/c/Users/Administrator/AppData/Local/nvim"

source="$DOT_PATH/.config/nvim"
# source="$DOT_PATH"


backup="$target.bak"

# Check if target exists
if [ -e "$target" ]; then
    echo "📦 Backing up existing '$target' to '$backup'..."
    cp -a "$target" "$backup"
else
    echo "ℹ️ No existing '$target' found. Skipping backup."
fi

# Confirm before deletion
read -p "⚠️ This will delete '$target' and create a symlink. Proceed? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🗑 Removing '$target'..."
    rm -rf "$target"

    echo "🔗 Creating symlink: '$target' → '$source'"
    ln -s "$source" "$target"

    echo "✅ Done!"
else
    echo "❌ Operation cancelled."
fi

