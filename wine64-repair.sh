#!/usr/bin/env bash
set -euo pipefail

echo "=== Wine Deep Repair Script ==="

# Step 1: Enable i386 multiarch
sudo dpkg --add-architecture i386 || true

# Step 2: Remove broken package info files
echo "[*] Cleaning broken dpkg info..."
sudo rm -f /var/lib/dpkg/info/libwine:amd64.*
sudo rm -f /var/lib/dpkg/info/libwine:i386.*

# Step 3: Purge Wine packages
echo "[*] Purging Wine packages..."
sudo apt purge --remove -y wine wine64 wine32 libwine libwine:i386 || true
sudo apt autoremove --purge -y
sudo apt clean

# Step 4: Recreate directories so dpkg scripts don’t choke
echo "[*] Recreating Wine directories..."
sudo mkdir -p /usr/lib/x86_64-linux-gnu/wine/i386-windows
sudo mkdir -p /usr/lib/i386-linux-gnu/wine/i386-windows

# Step 5: Fix dpkg state
echo "[*] Running dpkg --configure -a..."
sudo dpkg --configure -a || true

# Step 6: Update package lists
echo "[*] Updating package lists..."
sudo apt update

# Step 7: Reinstall Wine if requested
if [[ "${1:-}" == "install" ]]; then
    echo "[*] Reinstalling Wine..."
    sudo apt install -y wine64 libwine libwine:i386
    echo "[+] Wine reinstalled successfully."
elif [[ "${1:-}" == "remove" ]]; then
    echo "[*] Wine removed. No reinstall performed."
else
    echo "[?] Usage: ./wine-deep-repair.sh [install|remove]"
    echo "    install → purge then reinstall Wine"
    echo "    remove  → purge Wine only"
fi

echo "=== Done ==="

