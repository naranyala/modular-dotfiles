#!/usr/bin/env bash
set -euo pipefail

### CONFIG ###
declare -A DMs=(
    ["lightdm"]="lightdm"
    ["sddm"]="sddm"
    ["gdm"]="gdm3"  # Use 'gdm3' for Debian/Ubuntu; adjust for other distros if needed
)

### DETECT PACKAGE MANAGER ###
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    else
        echo "❌ No supported package manager found (apt, dnf, pacman)." >&2
        exit 1
    fi
}

### INSTALL PACKAGE ###
install_package() {
    local pkg="$1"
    local pkg_manager="$2"
    case "$pkg_manager" in
        apt)
            sudo apt update
            sudo apt install -y "$pkg" || {
                echo "⚠️ Failed to install $pkg" >&2
                return 1
            }
            ;;
        dnf)
            sudo dnf install -y "$pkg" || {
                echo "⚠️ Failed to install $pkg" >&2
                return 1
            }
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg" || {
                echo "⚠️ Failed to install $pkg" >&2
                return 1
            }
            ;;
    esac
}

### CHECK SYSTEMCTL ###
check_systemctl() {
    if ! command -v systemctl >/dev/null 2>&1; then
        echo "❌ systemctl not found. This script requires a systemd-based system." >&2
        exit 1
    fi
}

### MAIN ###
main() {
    # Check for systemctl
    check_systemctl

    # Detect package manager
    pkg_manager=$(detect_package_manager)
    echo "📦 Detected package manager: $pkg_manager"

    # Install all display managers
    echo "📦 Installing all display managers..."
    for dm in "${!DMs[@]}"; do
        pkg="${DMs[$dm]}"
        echo "  ➜ Installing $dm ($pkg)"
        install_package "$pkg" "$pkg_manager"
    done

    # Interactive selection
    echo
    echo "Please choose a display manager to activate:"
    select choice in "${!DMs[@]}"; do
        if [[ -n "$choice" ]]; then
            pkg="${DMs[$choice]}"
            echo "🔁 Activating: $choice"
            # Enable the display manager service
            if sudo systemctl enable "$pkg.service" 2>/dev/null; then
                echo "✅ $choice has been set as the default display manager."
                echo "ℹ️ You may need to reboot for changes to take effect."
            else
                echo "⚠️ Failed to enable $choice. Check if $pkg.service exists." >&2
            fi
            break
        else
            echo "❌ Invalid choice. Try again."
        fi
    done
}

main
