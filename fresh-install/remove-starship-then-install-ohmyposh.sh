#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting the transition from Starship to Oh My Posh..."

# 1. Uninstall Starship Binary
echo "==> Step 1: Removing Starship..."
if command -v starship &> /dev/null; then
    STARSHIP_PATH=$(which starship)
    echo "Found Starship at $STARSHIP_PATH."

    # Check if we have write permissions, otherwise use sudo
    if [ -w "$(dirname "$STARSHIP_PATH")" ]; then
        rm "$STARSHIP_PATH"
    else
        echo "Elevated permissions required to remove $STARSHIP_PATH."
        sudo rm "$STARSHIP_PATH"
    fi
    echo "Starship binary successfully removed."
else
    echo "Starship binary not found in PATH. Skipping removal."
fi

# 2. Clean up Starship configuration in ~/.bashrc
echo "==> Step 2: Cleaning ~/.bashrc..."
if grep -q 'starship init bash' ~/.bashrc; then
    # Create a backup of the original bashrc just in case
    cp ~/.bashrc ~/.bashrc.bak
    # Remove the starship initialization line
    sed -i '/starship init bash/d' ~/.bashrc
    echo "Removed Starship initialization from ~/.bashrc (backup saved as ~/.bashrc.bak)."
else
    echo "No Starship initialization found in ~/.bashrc."
fi

# 3. Install Oh My Posh
echo "==> Step 3: Installing Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s

# 4. Create Minimal Custom Configuration
echo "==> Step 4: Generating custom minimal configuration..."
mkdir -p ~/.config/oh-my-posh

# Write the JSON payload directly into the target file
cat << 'EOF' > ~/.config/oh-my-posh/minimal.json
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 2,
  "final_space": true,
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "path",
          "style": "plain",
          "foreground": "cyan",
          "template": "{{ .Path }} ",
          "properties": {
            "style": "agnoster_short",
            "max_depth": 2
          }
        },
        {
          "type": "git",
          "style": "plain",
          "foreground": "green",
          "foreground_templates": [
            "{{ if or (.Working.Changed) (.Staging.Changed) }}yellow{{ end }}",
            "{{ if and (gt .Ahead 0) (gt .Behind 0) }}red{{ end }}"
          ],
          "template": "{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} *{{ end }} ",
          "properties": {
            "fetch_status": true
          }
        },
        {
          "type": "executiontime",
          "style": "plain",
          "foreground": "magenta",
          "template": "took {{ .FormattedMs }} ",
          "properties": {
            "threshold": 2000,
            "style": "round"
          }
        },
        {
          "type": "text",
          "style": "plain",
          "foreground": "green",
          "foreground_templates": [
            "{{ if gt .Code 0 }}red{{ end }}"
          ],
          "template": "❯"
        }
      ]
    }
  ]
}
EOF
echo "Custom theme saved to ~/.config/oh-my-posh/minimal.json."

# 5. Configure ~/.bashrc for Oh My Posh
echo "==> Step 5: Configuring ~/.bashrc..."
# Ensure any old Oh My Posh init lines are removed before appending the new one
if grep -q 'oh-my-posh init bash' ~/.bashrc; then
    sed -i '/oh-my-posh init bash/d' ~/.bashrc
    echo "Cleaned up previous Oh My Posh initialization."
fi

# Append the initialization string pointing to the custom config
echo '' >> ~/.bashrc
echo '# Initialize Oh My Posh' >> ~/.bashrc
echo 'eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/minimal.json)"' >> ~/.bashrc
echo "Added new Oh My Posh initialization to ~/.bashrc."

echo "=========================================="
echo "Migration complete!"
echo "To apply the changes, restart your terminal or run:"
echo "source ~/.bashrc"
echo "=========================================="
