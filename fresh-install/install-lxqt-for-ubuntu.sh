#!/usr/bin/env bash
set -euo pipefail

########################################
# LXQt + Labwc + Wayland Apps Installer
# With error handling for missing packages
########################################

LOGFILE="$HOME/lxqt_labwc_install.log"

detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    else
        echo "unsupported"
        exit 1
    fi
}

install_packages() {
    local PKG_MANAGER=$1
    shift
    local PACKAGES="$@"

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update
        for pkg in $PACKAGES; do
            echo "➡️ Installing $pkg..."
            if sudo apt install -y "$pkg"; then
                echo "✅ Installed: $pkg" | tee -a "$LOGFILE"
            else
                echo "⚠️ Failed: $pkg (skipped)" | tee -a "$LOGFILE"
            fi
        done
    fi
}

main() {
    PKG_MANAGER=$(detect_package_manager)
    echo "Using package manager: $PKG_MANAGER"

    echo "📦 Installing LXQt desktop + Labwc..."
    install_packages "$PKG_MANAGER" lxqt sddm labwc

    echo "📦 Installing lightweight Wayland-friendly apps..."
    install_packages "$PKG_MANAGER" \
        pcmanfm-qt lximage-qt featherpad qterminal \
        vlc audacious abiword gnumeric \
        xarchiver galculator simple-scan firefox \
        wayfire waybar wlogout swaybg swaylock \
        foot bemenu grim slurp wf-recorder

    echo "🔧 Setting SDDM as default display manager..."
    sudo dpkg-reconfigure sddm || echo "⚠️ Display manager reconfigure skipped" | tee -a "$LOGFILE"

    echo "✅ Installation complete!"
    echo "👉 Check $LOGFILE for skipped packages."
    echo "👉 Reboot and choose LXQt or Labwc session."
}

main "$@"

