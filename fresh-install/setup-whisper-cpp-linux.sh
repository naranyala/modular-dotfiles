#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/ggml-org/whisper.cpp"
INSTALL_DIR="/usr/local/whisper.cpp"
BIN_DIR="/usr/local/bin"

trap 'echo "❌ Error at line $LINENO"; exit 1' ERR

# Detect package manager
if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
else
    echo "❌ No supported package manager found (apt or dnf)."
    exit 1
fi

echo "📦 Using package manager: $PKG_MANAGER"

# Install dependencies
if [[ "$PKG_MANAGER" == "apt" ]]; then
    sudo apt-get update || echo "⚠️ Some repos failed to update, continuing..."
    sudo apt-get install -y git build-essential cmake || { echo "❌ Dependency install failed"; exit 1; }
elif [[ "$PKG_MANAGER" == "dnf" ]]; then
    sudo dnf install -y git gcc gcc-c++ make cmake || { echo "❌ Dependency install failed"; exit 1; }
fi

# Clone or update repo
if [[ -d "$INSTALL_DIR" ]]; then
    echo "🔄 Updating whisper.cpp..."
    sudo git -C "$INSTALL_DIR" pull
else
    echo "⬇️ Cloning whisper.cpp..."
    sudo git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

# Build
cd "$INSTALL_DIR"
sudo cmake -B build -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build -j"$(nproc)"

# Symlink binaries globally
echo "📂 Linking binaries to $BIN_DIR..."
for bin in build/bin/*; do
    if [[ -x "$bin" ]]; then
        sudo install -m 755 "$bin" "$BIN_DIR/$(basename "$bin")"
    fi
done

# Verify PATH
if ! command -v whisper-cli &>/dev/null; then
    echo "❌ whisper-cli not found in PATH. Check $BIN_DIR permissions."
    exit 1
fi

echo "✅ whisper.cpp installed globally!"
echo "Run: whisper-cli --help"

