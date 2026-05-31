#!/usr/bin/env bash
set -euo pipefail

########################################
# GNOME Boxes, Wine, QEMU Installation
# Supports Ubuntu/Debian (apt) & Fedora/RHEL (dnf)
########################################

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
        echo "📦 Installing GNOME Boxes..."
        install_packages "$PKG_MANAGER" gnome-boxes

        echo "📦 Installing Wine..."
        sudo dpkg --add-architecture i386
        sudo apt update
        install_packages "$PKG_MANAGER" wine64 libwine libwine:i386 fonts-wine

        echo "📦 Installing QEMU/KVM stack..."
        install_packages "$PKG_MANAGER" qemu-system-x86 libvirt-daemon-system libvirt-clients bridge-utils virt-manager

    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        echo "📦 Installing GNOME Boxes..."
        install_packages "$PKG_MANAGER" gnome-boxes

        echo "📦 Installing Wine..."
        install_packages "$PKG_MANAGER" wine

        echo "📦 Installing QEMU/KVM stack..."
        install_packages "$PKG_MANAGER" qemu qemu-kvm libvirt virt-install bridge-utils virt-manager
    fi

    echo "🎉 Installation complete!"
    echo "👉 Add your user to libvirt/kvm groups for virtualization:"
    echo "   sudo usermod -aG libvirt,kvm \$USER"
    echo "   Then log out and back in."
}

main "$@"

