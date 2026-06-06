#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://codeberg.org/dnkl/foot"
RELEASES_API="https://codeberg.org/api/v1/repos/dnkl/foot/releases/latest"
WORKDIR="/tmp/foot-install"

# Ensure dependencies
echo "[INFO] Installing build dependencies..."
sudo apt update
sudo apt install -y build-essential meson ninja-build pkg-config \
    libpixman-1-dev libwayland-dev libxkbcommon-dev libfcft-dev \
    libutf8proc-dev libharfbuzz-dev libtllist-dev scdoc curl git

# Fetch latest release tarball URL
echo "[INFO] Fetching latest release info..."
LATEST_TARBALL_URL=$(curl -s "$RELEASES_API" | grep -oP '"tarball_url":"\K[^"]+')

if [[ -z "$LATEST_TARBALL_URL" ]]; then
    echo "[ERROR] Could not fetch latest release tarball URL."
    exit 1
fi

echo "[INFO] Latest tarball: $LATEST_TARBALL_URL"

# Prepare workspace
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Download and extract
echo "[INFO] Downloading and extracting Foot..."
curl -L "$LATEST_TARBALL_URL" -o foot.tar.gz
tar -xzf foot.tar.gz --strip-components=1

# Build and install
echo "[INFO] Building Foot..."
meson setup build
ninja -C build
sudo ninja -C build install

echo "[SUCCESS] Foot terminal installed globally!"

