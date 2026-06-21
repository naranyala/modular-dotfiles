#!/usr/bin/env bash
set -e

########################################
# Cinnamon Desktop + Login Manager Setup
########################################

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
            sudo apt install -y "$pkg" || echo "⚠️ Skipping missing package: $pkg"
        done
    fi
}

choose_login_manager() {
    echo "🔑 Choose a login manager:"
    echo "1) gdm3 (GNOME default)"
    echo "2) lightdm (lightweight, popular with Cinnamon/Xfce)"
    echo "3) sddm (KDE-style, modern)"
    read -rp "Enter choice [1-3]: " choice

    case $choice in
        1) sudo apt install -y gdm3 ;;
        2) sudo apt install -y lightdm ;;
        3) sudo apt install -y sddm ;;
        *) echo "Invalid choice, skipping login manager install." ;;
    esac

    # Reconfigure default display manager
    if [[ "$choice" =~ ^[1-3]$ ]]; then
        sudo dpkg-reconfigure ${choice==1 ? "gdm3" : choice==2 ? "lightdm" : "sddm"}
    fi
}

main() {
    PKG_MANAGER=$(detect_package_manager)
    echo "Using package manager: $PKG_MANAGER"

    echo "📦 Installing Cinnamon desktop environment..."
    install_packages "$PKG_MANAGER" cinnamon-desktop-environment cinnamon

    echo "📦 Installing Cinnamon core apps..."
    install_packages "$PKG_MANAGER" \
        nemo cinnamon-control-center cinnamon-screensaver \
        cinnamon-session cinnamon-settings-daemon cinnamon-common cinnamon-core

    echo "📦 Installing useful extras..."
    install_packages "$PKG_MANAGER" \
        gnome-terminal gedit evince gnome-system-monitor gnome-calculator gnome-disk-utility

    choose_login_manager

    echo "✅ Installation complete!"
    echo "👉 Reboot your system to start Cinnamon with your chosen login manager."
}

main "$@"

