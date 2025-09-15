#!/usr/bin/env bash

set -e

# Ensure flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Installing Flatpak..."
    sudo dnf -y install flatpak
fi

# Enable Flathub if not already
if ! flatpak remote-list | grep -q flathub; then
    echo "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

declare -A apps=(
    ["org.libreoffice.LibreOffice"]="Office suite"
    ["org.onlyoffice.desktopeditors"]="MS Office-compatible editors"
    ["org.standardnotes.standardnotes"]="Encrypted notes"
    ["com.visualstudio.code"]="VS Code IDE"
    ["com.jetbrains.PyCharm-Community"]="Python IDE"
    ["com.getpostman.Postman"]="API testing"
    ["org.gnome.Builder"]="GNOME IDE"
    ["org.gimp.GIMP"]="Image editor"
    ["org.inkscape.Inkscape"]="Vector graphics"
    ["org.blender.Blender"]="3D modeling"
    ["org.kde.krita"]="Digital painting"
    ["org.darktable.Darktable"]="RAW photo editing"
    ["org.kde.kdenlive"]="Video editing"
    ["net.scribus.Scribus"]="Desktop publishing"
    ["org.videolan.VLC"]="Media player"
    ["org.audacityteam.Audacity"]="Audio editing"
    ["io.github.celluloid_player.Celluloid"]="Video player"
    ["org.gnome.Lollypop"]="Music player"
    ["org.telegram.desktop"]="Messaging"
    ["org.signal.Signal"]="Secure messaging"
    ["im.riot.Riot"]="Matrix client"
    ["org.chromium.Chromium"]="Web browser"
    ["com.brave.Browser"]="Privacy browser"
    ["com.obsproject.Studio"]="Streaming & recording"
    ["com.bitwarden.desktop"]="Password manager"
    ["org.keepassxc.KeePassXC"]="Local password vault"
    ["com.github.tchx84.Flatseal"]="Flatpak permissions manager"
    ["org.gnome.tweaks"]="GNOME customization"
    ["org.filezillaproject.Filezilla"]="FTP client"
    ["com.spotify.Client"]="Music Streaming"
)


echo "Select apps to install (space to select, enter to confirm):"

choices=()
for app in "${!apps[@]}"; do
    choices+=("$app" "${apps[$app]}" off)
done

if ! command -v whiptail &>/dev/null; then
    echo "Installing whiptail..."
    sudo dnf -y install newt
fi

selected=$(whiptail --title "Verified Flathub App Picker" \
    --checklist "Choose apps to install:" 25 78 15 \
    "${choices[@]}" 3>&1 1>&2 2>&3)

for app in $selected; do
    clean_app=$(echo "$app" | tr -d '"')
    echo "Installing $clean_app..."
    flatpak install -y flathub "$clean_app"
done

echo "=== All selected verified apps installed! ==="

