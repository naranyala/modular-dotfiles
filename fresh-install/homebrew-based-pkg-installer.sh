#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Initializing Homebrew package installation..."

# 1. Verify Homebrew is installed and accessible
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed or not in your PATH."
    echo "Please ensure Homebrew is configured in your ~/.bashrc."
    exit 1
fi

# 2. Update Homebrew to ensure we fetch the latest formulas
echo "==> Updating Homebrew..."
brew update

# 3. Define the package array
# Grouped logically for maintainability
PACKAGES=(
    # --- Build & Workspace ---
    cmake           # Modern build system generator
    ninja           # Lightning-fast build system (pairs with CMake)
    tmux            # Terminal multiplexer for managing multiple sessions
    neovim          # Extensible, high-performance text editor

    # --- Code Navigation & Search ---
    ripgrep         # Extremely fast grep alternative (rg)
    fd              # Fast, user-friendly find alternative
    fzf             # General-purpose command-line fuzzy finder

    # --- System Profiling & Analysis ---
    btop            # Visually rich, low-overhead resource monitor
    hexyl           # Command-line hex viewer (essential for binary inspection)
    hyperfine       # Command-line benchmarking tool

    # --- Modern Core Utilities ---
    bat             # Cat clone with syntax highlighting (from prior setup)
    eza             # Modern replacement for ls with git integration
    git-delta       # Syntax-highlighting pager for git, diff, and grep
)

# 4. Execute the batch installation
echo "==> Installing packages..."
# Expanding the array to pass all packages to brew at once is faster
# than looping through them individually.
brew install "${PACKAGES[@]}"

# 5. Cleanup outdated downloads
echo "==> Cleaning up cache..."
brew cleanup

echo "=========================================="
echo "All system development tools installed successfully!"
echo "=========================================="
