# 🌌 Naravisuals Dotfiles & Toolbox

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux/Windows](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-blue)](https://github.com/your-username/your-repo)

A sophisticated ecosystem of system configurations, automation scripts, and a polyglot systems programming laboratory. This repository serves as both a personalized development environment and a benchmark for language ergonomics.

---

## 🏛️ Core Pillars

### 🛠️ The Development Environment (Dotfiles)
A curated set of configurations for a high-performance, keyboard-centric workflow.
- **Window Management:** Sway & Niri (Wayland)
- **Interface:** Waybar, Fuzzel, and customized UI components.
- **Terminal & Shell:** Kitty, Tmux, Bash, Zsh, and Starship prompt.
- **Editor:** Neovim (`dot-config-nvim`) configured for maximum productivity.

### 🧪 The Polyglot Toolbox (`/packages`)
The heart of the experimental side of this project. I implement the same CLI utilities (e.g., `dirnav`) across multiple languages to analyze binary size, execution speed, and developer experience:
- **Low-Level:** C, C3, Zig
- **Memory Safe:** Rust
- **High-Level:** TypeScript

### ⚙️ System Automation
- **Windows Ecosystem:** A comprehensive suite of PowerShell scripts for zero-to-hero setup (Scoop, Winget, Choco, User management).
- **Python Utilities:** TUI/GUI tools for system maintenance and specialized package installation.
- **Deployment:** Custom `fpm` templates and `latte-dock` builds for rapid system provisioning via `/fresh-install`.

---

## 📂 Repository Map

```text
.
├── dot-config-nvim/    # Neovim configuration
├── packages/           # Polyglot CLI experiments (C, C3, Rust, Zig, TS)
├── powershell_scripts/ # Windows automation & provisioning
├── script-python/      # System utility scripts in Python
├── fresh-install/      # System deployment & package templates
└── [root]              # Shell configs (.bashrc, .zshrc) & system scripts
```

---

## 🚀 Quick Start

### Linux (Manual)
```bash
# Clone the repository
git clone https://github.com/your-username/dotfiles.git
cd dotfiles

# Symlink specific configurations (Example: Neovim)
ln -s $(pwd)/dot-config-nvim ~/.config/nvim
```

### Windows (Automation)
Navigate to `/powershell_scripts` and execute the bootstrap scripts for your package manager of choice (e.g., `install-scoop-pkg-manager.ps1`).

---

## 🗺️ Evolution Roadmap

- [ ] **Configuration Management:** Transition from manual symlinking to [GNU Stow](https://www.gnu.org/software/stow/) or [Chezmoi](https://www.chezmoi.io/).
- [ ] **Architecture:** Decouple large third-party source code (e.g., `latte-dock`) into Git submodules.
- [ ] **Bootstrapping:** Implement a unified `setup.sh` (Linux) and `setup.ps1` (Windows) for one-command environment builds.
- [ ] **Benchmarking:** Add a `benchmarks/` folder in `/packages` to quantify the performance differences between the polyglot implementations.
- [ ] **Entropy Reduction:** Archive legacy `.bak` files into a dedicated `/archive` directory.
