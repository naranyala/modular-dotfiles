# Initialize Homebrew (Linuxbrew) in non-login shells
if command -v brew >/dev/null 2>&1; then eval "$(brew shellenv)"; fi
# Initialize starship prompt
eval "$(starship init zsh)"


# Created by `pipx` on 2025-07-15 16:10:52
export PATH="$PATH:/home/naranyala/.local/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PKG_CONFIG_PATH=/path/to/pkgconfig:$PKG_CONFIG_PATH
