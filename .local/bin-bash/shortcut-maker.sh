#!/bin/bash

# App Launcher Maker Script

read -p "Enter the name of the application: " app_name
read -p "Enter the path to the executable binary: " exec_path
read -p "Enter the path to the icon (PNG/SVG/etc): " icon_path

# Define output launcher filename
desktop_file="$HOME/.local/share/applications/${app_name}.desktop"

# Create the .desktop file
cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$app_name
Exec=$exec_path
Icon=$icon_path
Type=Application
Terminal=false
Categories=Utility;
EOF

# Make the launcher executable
chmod +x "$desktop_file"

echo "Launcher created at $desktop_file ✅"

