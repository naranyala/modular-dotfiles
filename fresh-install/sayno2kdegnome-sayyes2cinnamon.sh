#!/usr/bin/env bash
set -e

########################################
# Remove KDE & GNOME Desktop Environments
# Keeps login manager and system apps
########################################

# Detect package manager (Ubuntu uses apt)
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    else
        echo "unsupported"
        exit 1
    fi
}

remove_packages() {
    local PKG_MANAGER=$1
    shift
    local PACKAGES="$@"

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update
        for pkg in $PACKAGES; do
            sudo apt purge -y "$pkg" || echo "⚠️ Skipping missing package: $pkg"
        done
        sudo apt autoremove -y
    fi
}

main() {
    PKG_MANAGER=$(detect_package_manager)
    echo "Using package manager: $PKG_MANAGER"

    echo "❌ Removing GNOME desktop meta-packages..."
    remove_packages "$PKG_MANAGER" ubuntu-gnome-desktop gnome-shell gnome-session gnome-core

    echo "❌ Removing KDE desktop meta-packages..."
    remove_packages "$PKG_MANAGER" kubuntu-desktop kde-standard kde-full kde-plasma-desktop plasma-desktop

    echo "✅ KDE and GNOME desktops removed."
    echo "👉 Login manager and system apps remain installed."
}

main "$@"

