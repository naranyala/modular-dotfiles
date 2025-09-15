#!/usr/bin/env bash
# install_spotify_fedora.sh
# Bash script to install Spotify on Fedora Linux using Snap

set -e

echo "=== Updating system packages ==="
sudo dnf -y update

echo "=== Installing Snap support ==="
sudo dnf -y install snapd
sudo ln -s /var/lib/snapd/snap /snap || true

echo "=== Enabling snapd socket ==="
sudo systemctl enable --now snapd.socket

echo "=== Installing Spotify via Snap ==="
sudo snap install spotify

echo "=== Installation complete! ==="
echo "You can now launch Spotify from your app menu or by running: spotify"

