#!/usr/bin/env bash

# Script: expose_node_modules.sh
# Usage: ./expose_node_modules.sh /path/to/search

SEARCH_PATH="$1"

if [ -z "$SEARCH_PATH" ]; then
  echo "Usage: $0 <path>"
  exit 1
fi
if [ ! -d "$SEARCH_PATH" ]; then
  echo "Error: Path '$SEARCH_PATH' does not exist."
  exit 1
fi

# Choose fd or rg
if command -v rg >/dev/null 2>&1; then
  echo "Scanning with ripgrep..."
  SEARCH_CMD="rg --files --glob 'node_modules/' $SEARCH_PATH | xargs -n1 dirname | sort -u"
elif command -v fd >/dev/null 2>&1; then
  echo "Scanning with fd..."
  SEARCH_CMD="fd -t d node_modules $SEARCH_PATH"
else
  echo "Neither fd nor ripgrep installed."
  echo "Install with:"
  echo "  Ubuntu/Debian: sudo apt install fd-find ripgrep"
  echo "  Fedora/RHEL:   sudo dnf install fd-find ripgrep"
  exit 1
fi

# Stream results as they are found
eval "$SEARCH_CMD" | while read -r dir; do
  echo "Found: $dir"
  echo "Delete this directory? (y/n)"
  read -r answer
  case "$answer" in
    [Yy]* )
      rm -rf "$dir"
      echo "Deleted: $dir"
      ;;
    [Nn]* )
      echo "Skipped: $dir"
      ;;
    * )
      echo "Invalid input, skipped: $dir"
      ;;
  esac
done

echo "Scan complete."

