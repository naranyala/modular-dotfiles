#!/bin/bash

set -e

echo "🔧 Installing required packages..."
sudo apt update
sudo apt install -y build-essential curl file git

echo "📁 Cloning Homebrew..."
mkdir -p ~/.linuxbrew
git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew --depth=1
mkdir -p ~/.linuxbrew/bin
ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin/

echo "🔧 Configuring shell environment..."
BREW_ENV='eval "$($HOME/.linuxbrew/bin/brew shellenv)"'
PROFILE="$HOME/.bashrc"

if [ -n "$ZSH_VERSION" ]; then
  PROFILE="$HOME/.zshrc"
fi

if ! grep -Fxq "$BREW_ENV" "$PROFILE"; then
  echo "$BREW_ENV" >> "$PROFILE"
fi

eval "$($HOME/.linuxbrew/bin/brew shellenv)"

echo "🔄 Updating Homebrew..."
brew update

echo "✅ Homebrew installed successfully!"
brew doctor

