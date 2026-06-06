#!/usr/bin/env bash
set -euo pipefail

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
  echo "❌ Error: Do not run this script as root."
  echo "👉 Please run it as a normal user."
  exit 1
fi

# Ensure cargo exists
if ! command -v cargo >/dev/null 2>&1; then
  echo "⚠️ Cargo not found. Please install Rust first:"
  echo "   https://www.rust-lang.org/tools/install"
  exit 1
fi

# List of cargo-based utilities to install
CARGO_PACKAGES=(
  "skim --locked"
  "jj --locked --bin jj jj-cli"        # Jujutsu VCS
  "ripgrep --locked"                   # Fast grep alternative
  "exa --locked"                       # Modern ls replacement
  "bat --locked"                       # Syntax-highlighted cat
  "fd-find --locked"                   # Fast find alternative
  "cargo-edit --locked"                # Manage Cargo.toml deps
  "cargo-watch --locked"               # Auto-rebuild on changes
  "hyperfine --locked"                 # Benchmarking tool
  "procs --locked"                     # Modern ps replacement
  "dust --locked"                      # Disk usage analyzer
  "tokei --locked"                     # Count lines of code
  "bottom --locked"                    # System monitor (like htop)
  "zoxide --locked"                    # Smarter cd command
  "starship --locked"                  # Cross-shell prompt
  "git-delta --locked"                 # Better git diff pager
)

# Install each package
for pkg in "${CARGO_PACKAGES[@]}"; do
  echo "📦 Installing: cargo install $pkg"
  if ! cargo install $pkg; then
    echo "❌ Failed to install: $pkg"
  else
    echo "✅ Installed: $pkg"
  fi
done

echo "🎉 All requested Cargo utilities processed!"

