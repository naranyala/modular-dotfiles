#!/usr/bin/env bash
set -euo pipefail

# wine-build.sh — clone, build, and install Wine from source

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_INSTALL="sudo apt-get install -y"
    sudo apt-get update
elif command -v dnf >/dev/null 2>&1; then
    PKG_INSTALL="sudo dnf install -y"
elif command -v pacman >/dev/null 2>&1; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
else
    echo "Unsupported package manager. Install dependencies manually."
    exit 1
fi

# Install build dependencies
$PKG_INSTALL git build-essential gcc make flex bison \
    libx11-dev libfreetype6-dev libxcursor-dev libxi-dev \
    libxrandr-dev libxinerama-dev libxext-dev libxcomposite-dev \
    libxdamage-dev libxfixes-dev libxrender-dev libxkbcommon-dev \
    libwayland-dev libvulkan-dev libudev-dev libdbus-1-dev \
    libglib2.0-dev libgnutls28-dev libjpeg-dev libpng-dev \
    libtiff-dev libgsm1-dev libmpg123-dev libosmesa6-dev \
    libfontconfig1-dev libncurses5-dev libncursesw5-dev

# Clone Wine source (shallow)
if [ ! -d wine ]; then
    git clone --depth=1 https://gitlab.winehq.org/wine/wine.git
fi

cd wine

# Create build directory
mkdir -p build && cd build

# Configure
../configure --enable-win64

# Build
make -j"$(nproc)"

# Install
sudo make install

# Verify
wine --version

