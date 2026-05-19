#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Updating package lists ==="
sudo apt update

echo "=== Installing system build dependencies ==="
sudo apt install -y curl build-essential

# Check if cargo is already installed
if ! command -v cargo &> /dev/null; then
    echo "=== Rust/Cargo not found. Installing via rustup ==="
    # Run the official rustup installer in silent/non-interactive mode
    curl --proto '=https' --tlsv1.2 -sSf https://rustup.rs | sh -s -- -y

    # Source the cargo environment for the current script session
    source "$HOME/.cargo/env"
else
    echo "=== Cargo is already installed ==="
fi

echo "=== Installing bat via Cargo (this may take a few minutes) ==="
cargo install --locked bat

# Ensure Cargo's bin directory is in the current user PATH
if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    echo "=== Adding Cargo bin to bashrc PATH ==="
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.cargo/bin:$PATH"
fi

echo "=== Installation complete! ==="
echo "=== Verifying version: ==="
bat --version

echo "=== Note: If 'bat' doesn't work, run 'source ~/.bashrc' or restart your terminal ==="

