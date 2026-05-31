#!/usr/bin/env bash
set -euo pipefail

########################################
# GNOME Desktop Installation Script
# Supports Ubuntu/Debian (apt) & Fedora/RHEL (dnf)
########################################

# Detect package manager
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    else
        echo "unsupported"
        exit 1
    fi
}

# Install packages safely
install_packages() {
    local PKG_MANAGER=$1
    shift
    local PACKAGES=("$@")

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update
        sudo apt install -y "${PACKAGES[@]}"
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y "${PACKAGES[@]}"
    fi
}

main() {
    PKG_MANAGER=$(detect_package_manager)
    echo "✅ Using package manager: $PKG_MANAGER"

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        echo "📦 Installing GNOME desktop (Ubuntu/Debian)..."
        install_packages "$PKG_MANAGER" ubuntu-gnome-desktop gnome-shell gnome-session gdm3 \
            gnome-terminal nautilus gedit gnome-control-center gnome-system-monitor gnome-calculator gnome-disk-utility

        echo "🔧 Setting GDM as default display manager..."
        sudo dpkg-reconfigure gdm3

    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        echo "📦 Installing GNOME desktop (Fedora/RHEL)..."
        install_packages "$PKG_MANAGER" @gnome-desktop gdm \
            gnome-terminal nautilus gedit gnome-control-center gnome-system-monitor gnome-calculator gnome-disk-utility

        echo "🔧 Enabling GDM as default display manager..."
        sudo systemctl disable lightdm || true
        sudo systemctl enable gdm
        sudo systemctl set-default graphical.target
    fi

    echo "🎉 GNOME installation complete!"
    echo "👉 Reboot your system to start GNOME with GDM."
}

main "$@"

