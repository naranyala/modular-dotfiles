
#!/usr/bin/env bash
set -euo pipefail

# === Configurable Variables ===
DOTFILES_DIR="$HOME/projects-remote/modular-dotfiles"
CONFIG_DIR="$HOME/.config"
WAYBAR_DIR="$DOTFILES_DIR/waybar"
LOG_FILE="$DOTFILES_DIR/waybar-setup.log"
REQUIRED_PROGRAMS=("waybar" "swaymsg" "jq" "date" "uptime")

touch "$LOG_FILE"

# === Helper Functions ===
log() { echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"; }
ensure_dir() { mkdir -p "$1" && log "📁 Created: $1"; }
safe_symlink() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        log "⚠️  Skipped symlink: $dst exists and is not a symlink"
    else
        ln -sf "$src" "$dst" && log "🔗 Linked: $src → $dst"
    fi
}

# === Setup Directories ===
log "🚀 Starting Waybar setup..."
ensure_dir "$WAYBAR_DIR/config"
ensure_dir "$WAYBAR_DIR/style"
ensure_dir "$WAYBAR_DIR/scripts"

# === Check Required Programs ===
log "🔍 Checking required programs..."
for prog in "${REQUIRED_PROGRAMS[@]}"; do
    if ! command -v "$prog" &> /dev/null; then
        log "❌ Missing: $prog — consider installing it"
    else
        log "✅ Found: $prog"
    fi
done

# === Generate Waybar Config ===
cat <<EOF > "$WAYBAR_DIR/config/config.jsonc"
/* Waybar config */
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "modules-left": ["sway/workspaces", "sway/mode"],
  "modules-center": ["clock"],
  "modules-right": ["custom/uptime", "custom/hostname", "battery", "network", "pulseaudio"],
  "custom/uptime": {
    "exec": "$CONFIG_DIR/waybar/scripts/uptime.sh",
    "interval": 60,
    "tooltip": false
  },
  "custom/hostname": {
    "exec": "hostname",
    "interval": 300,
    "tooltip": false
  }
}
EOF
log "📝 Generated Waybar config"

# === Generate Waybar Style ===
cat <<EOF > "$WAYBAR_DIR/style/style.css"
/* Waybar style */
* {
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 13px;
  min-height: 0;
}

window {
  background-color: rgba(0 0 0 0.5);
  border-bottom: 2px solid #89b4fa;
}

#clock {
  color: #cdd6f4;
  padding: 0 10px;
}

#battery {
  color: #a6e3a1;
}

#network {
  color: #f9e2af;
}

#pulseaudio {
  color: #f38ba8;
}
EOF
log "🎨 Generated Waybar style"

# === Generate Custom Script: uptime.sh ===
cat <<'EOF' > "$WAYBAR_DIR/scripts/uptime.sh"
#!/usr/bin/env bash
uptime -p | sed 's/up //'
EOF
chmod +x "$WAYBAR_DIR/scripts/uptime.sh"
log "🔧 Created uptime script"

# === Symlink to ~/.config ===
log "🔗 Linking Waybar config to $CONFIG_DIR..."
safe_symlink "$WAYBAR_DIR" "$CONFIG_DIR/waybar"

# === Final Message ===
log "✅ Waybar setup complete!"
echo -e "\n📂 Configs: $WAYBAR_DIR → $CONFIG_DIR/waybar"
echo "📄 Log: $LOG_FILE"
echo "🚀 Launch Waybar with: waybar &"
