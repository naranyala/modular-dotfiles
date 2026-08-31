#!/usr/bin/env bash
# wine-repair.sh
# Script to remove and reinstall Wine on Ubuntu/Debian

set -euo pipefail

echo "=== Wine Repair Script ==="

# Step 1: Enable i386 architecture
echo "[1/5] Enabling i386 architecture..."
sudo dpkg --add-architecture i386

# Step 2: Purge existing Wine packages
echo "[2/5] Purging old Wine packages..."
sudo apt purge -y wine64 wine32 libwine libwine:i386 || true

# Step 3: Clean dpkg state (remove broken info files)
echo "[3/5] Cleaning dpkg state..."
sudo rm -f /var/lib/dpkg/info/libwine:amd64.*
sudo rm -f /var/lib/dpkg/info/libwine:i386.*

# Step 4: Update and reinstall Wine
echo "[4/5] Updating package lists..."
sudo apt update

echo "[4/5] Installing Wine packages..."
sudo apt install -y wine64 wine32 libwine libwine:i386

# Step 5: Reset Wine prefix
echo "[5/5] Resetting Wine prefix..."
rm -rf ~/.wine
winecfg || true

echo "=== Wine reinstall complete! ==="
wine --version

