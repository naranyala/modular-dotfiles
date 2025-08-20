#!/usr/bin/env bash
set -e

# Helper to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🔍 Checking dependencies..."

# Install Zsh if not present
if ! command_exists zsh; then
    echo "📦 Installing Zsh..."
    sudo apt update && sudo apt install -y zsh
else
    echo "✅ Zsh already installed."
fi

# Install Git and Curl if missing
for pkg in git curl; do
    if ! command_exists "$pkg"; then
        echo "📦 Installing $pkg..."
        sudo apt install -y "$pkg"
    else
        echo "✅ $pkg already installed."
    fi
done

# Install fonts-powerline for better visuals
if ! fc-list | grep -iq "Powerline"; then
    echo "🎨 Installing Powerline fonts..."
    sudo apt install -y fonts-powerline
else
    echo "✅ Powerline fonts already installed."
fi

# Change default shell to Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🌟 Installing Oh My Zsh..."
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh already installed."
fi

# Install Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
declare -A plugins=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
)

for name in "${!plugins[@]}"; do
    path="$ZSH_CUSTOM/plugins/$name"
    if [ ! -d "$path" ]; then
        echo "🔌 Installing $name..."
        git clone "${plugins[$name]}" "$path"
    else
        echo "✅ $name already installed."
    fi
done

# Update .zshrc plugins
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Install Starship
if ! command_exists starship; then
    echo "🚀 Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
else
    echo "✅ Starship already installed."
fi

# Add Starship init to .zshrc
if ! grep -q 'starship init zsh' ~/.zshrc; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# Create Starship config
mkdir -p ~/.config
cat <<EOF > ~/.config/starship.toml
add_newline = false

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[✗](bold red)"
EOF

echo "🎉 Setup complete! Restart your terminal or run: exec zsh"

