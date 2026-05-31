#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

echo "Applying KDE Plasma Wi-Fi drop fixes..."

# 1. Disable Wi-Fi Power Management
WIFI_POWERSAVE_FILE="/etc/NetworkManager/conf.d/default-wifi-powersave-on.conf"
mkdir -p "$(dirname "$WIFI_POWERSAVE_FILE")"
cat << 'EOF' > "$WIFI_POWERSAVE_FILE"
[connection]
wifi.powersave=2
EOF
echo "[✓] Disabled Wi-Fi Power Management."

# 2. Disable MAC Address Randomization (prevents router disconnects)
MAC_RANDOM_FILE="/etc/NetworkManager/conf.d/00-macrandom.conf"
cat << 'EOF' > "$MAC_RANDOM_FILE"
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
EOF
echo "[✓] Set MAC address handling to permanent/hardware mode."

# 3. Disable competing iwd background services if they exist
if systemctl is-active --quiet iwd; then
    systemctl disable --now iwd
    echo "[✓] Stopped and disabled conflicting iwd service."
fi

# 4. Restart NetworkManager to apply configuration changes
echo "Restarting NetworkManager..."
systemctl restart NetworkManager

echo "Done! Test your connection now."

