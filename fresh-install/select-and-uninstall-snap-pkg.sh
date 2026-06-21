#!/usr/bin/env bash
set -e

########################################
# Snap Uninstaller Selector
########################################

# Ensure snap is installed
if ! command -v snap >/dev/null 2>&1; then
    echo "❌ Snap is not installed. Please install it first."
    exit 1
fi

# Get list of installed Snap package names
mapfile -t apps < <(snap list | awk 'NR>1 {print $1}')

if [[ ${#apps[@]} -eq 0 ]]; then
    echo "⚠️ No Snap packages installed."
    exit 0
fi

echo "🔎 Installed Snap packages:"
PS3="Enter the number of the Snap you want to uninstall: "
select app_id in "${apps[@]}"; do
    if [[ -n "$app_id" ]]; then
        echo "❗ You selected: $app_id"
        read -rp "Are you sure you want to uninstall $app_id? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            sudo snap remove "$app_id"
            echo "✅ $app_id has been uninstalled."
        else
            echo "🚫 Uninstall cancelled."
        fi
        break
    else
        echo "Invalid choice. Try again."
    fi
done

