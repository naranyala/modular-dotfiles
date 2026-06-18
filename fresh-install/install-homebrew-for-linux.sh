#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Homebrew installation for Linux..."

# 1. Prevent execution as root
# Homebrew strictly forbids being installed or run by the root user for security reasons.
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: Homebrew must not be installed as root. Please run this script as a standard user."
    exit 1
fi

# 2. Install required system dependencies
echo "==> Step 1: Installing compiler tools and dependencies..."
if command -v apt-get &> /dev/null; then
    echo "Detected Debian/Ubuntu-based system."
    sudo apt-get update
    sudo apt-get install -y build-essential procps curl file git
elif command -v dnf &> /dev/null; then
    echo "Detected Fedora/RHEL-based system."
    sudo dnf groupinstall -y 'Development Tools'
    sudo dnf install -y procps-ng curl file git
elif command -v pacman &> /dev/null; then
    echo "Detected Arch-based system."
    sudo pacman -Sy --noconfirm base-devel procps-ng curl file git
else
    echo "Warning: Could not determine the package manager. Ensure gcc, make, curl, file, and git are installed manually."
fi

# 3. Execute the official Homebrew installation script
echo "==> Step 2: Downloading and installing Homebrew..."
# NONINTERACTIVE=1 prevents the script from pausing to ask you to press 'Enter'
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. Configure ~/.bashrc
echo "==> Step 3: Configuring environment variables..."
# Identify where Homebrew was installed (system-wide vs local user)
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
else
    BREW_PREFIX="$HOME/.linuxbrew"
fi

if ! grep -q 'brew shellenv' ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Initialize Homebrew' >> ~/.bashrc
    echo 'eval "$('"$BREW_PREFIX"'/bin/brew shellenv)"' >> ~/.bashrc
    echo "Homebrew environment variables appended to ~/.bashrc."
else
    echo "Homebrew is already initialized in ~/.bashrc."
fi

echo "=========================================="
echo "Installation complete!"
echo "To apply the changes and start using brew, run:"
echo "source ~/.bashrc"
echo "=========================================="
