#!/usr/bin/env bash
set -e

########################################
# Flatpak Uninstaller Selector
########################################

# Ensure flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    echo "❌ Flatpak is not installed. Please install it first."
    exit 1
fi

# Get list of installed Flatpak app IDs
mapfile -t apps < <(flatpak list --app --columns=application)

if [[ ${#apps[@]} -eq 0 ]]; then
    echo "⚠️ No Flatpak apps installed."
    exit 0
fi

echo "🔎 Installed Flatpak applications:"
PS3="Enter the number of the app you want to uninstall: "
select app_id in "${apps[@]}"; do
    if [[ -n "$app_id" ]]; then
        echo "❗ You selected: $app_id"
        read -rp "Are you sure you want to uninstall $app_id? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            flatpak uninstall -y "$app_id"
            echo "✅ $app_id has been uninstalled."
        else
            echo "🚫 Uninstall cancelled."
        fi
        break
    else
        echo "Invalid choice. Try again."
    fi
done

