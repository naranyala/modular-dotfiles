
#!/usr/bin/env bash

set -euo pipefail

# Default PNPM global binary path
PNPM_HOME="$HOME/.local/share/pnpm"
EXPORT_LINE="export PNPM_HOME=\"$PNPM_HOME\""
PATH_LINE="export PATH=\"\$PNPM_HOME:\$PATH\""

# Detect shell and config file
detect_shell() {
  local shell_name
  shell_name="$(basename "$SHELL")"
  case "$shell_name" in
    bash) echo "$HOME/.bashrc" ;;
    zsh) echo "$HOME/.zshrc" ;;
    *) echo "Unsupported shell: $shell_name" >&2; exit 1 ;;
  esac
}

CONFIG_FILE="$(detect_shell)"

# Append lines if not already present
append_if_missing() {
  local line="$1"
  local file="$2"
  if ! grep -Fxq "$line" "$file"; then
    echo "$line" >> "$file"
    echo "✅ Added to $file: $line"
  else
    echo "ℹ️ Already present in $file: $line"
  fi
}

append_if_missing "$EXPORT_LINE" "$CONFIG_FILE"
append_if_missing "$PATH_LINE" "$CONFIG_FILE"

# Reload shell config
echo "🔄 Reloading $CONFIG_FILE..."
# shellcheck disable=SC1090
source "$CONFIG_FILE"

echo "🎉 PNPM_HOME configured and PATH updated!"
