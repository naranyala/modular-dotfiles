#!/bin/bash

# Ensure script is run with sudo directly
if [ "$EUID" -eq 0 ] 2>/dev/null; then
    echo "Running with administrative privileges..."
else
    echo "Please launch this script manually using: sudo ./manage_wine.sh"
    exit 1
fi

delete_wine() {
    # echo "=== Stopping Running Wine Processes ==="
    # pkill -9 -f wine
    # wineserver -k 2>/dev/null

    echo "=== Force Removing All Wine & Distro Packages ==="
    apt-get remove --purge -y wine wine32 wine64 wine-stable wine-development wine-staging winetricks libwine libwine:i386 wine64-tools winehq-stable winehq-staging winehq-devel
    apt-get autoremove -y
    apt-get clean

    echo "=== Erasing Corrupted Path Layouts & Stray Binaries ==="
    rm -f /usr/bin/wine /usr/bin/wine64 /usr/local/bin/wine /usr/local/bin/wine64
    rm -rf /usr/share/wine /usr/lib/wine /usr/lib64/wine /etc/wine
    rm -rf /usr/lib/x86_64-linux-gnu/wine /usr/lib/i386-linux-gnu/wine

    echo "WARNING: Deleting the ~/.wine folder will erase all installed Windows applications."
    read -p "Do you want to delete user data folders (~/.wine)? (y/n): " chk
    if [[ "$chk" =~ ^[Yy]$ ]]; then
        rm -rf ~/.wine ~/.local/share/applications/wine* ~/.local/share/desktop-directories/wine* ~/.config/menus/applications-merged/wine*
        echo "User data cleared."
    fi
    echo "=== Wine Removal Complete ==="
}

install_winehq_official() {
    echo "=== Forcing 32-bit Architecture Enablement ==="
    dpkg --add-architecture i386
    apt-get update

    echo "=== Downloading & Setting Up Official WineHQ Repositories ==="
    mkdir -pm755 /etc/apt/keyrings
    # Remove stale old keys if any exist
    rm -f /etc/apt/keyrings/winehq-archive.key
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

    # Dynamically discover distro name (Ubuntu/Debian/Mint) to fetch correct source map
    local distro_codename=$(lsb_release -sc)
    rm -f /etc/apt/sources.list.d/winehq*.sources
    wget -NP /etc/apt/sources.list.d/ https://winehq.org{distro_codename}/winehq-${distro_codename}.sources 2>/dev/null

    # Fallback pattern if sources list naming formats diverge on older systems
    if [ ! -f "/etc/apt/sources.list.d/winehq-${distro_codename}.sources" ]; then
        wget -NP /etc/apt/sources.list.d/ https://winehq.org{distro_codename}/winehq-${distro_codename}.sources 2>/dev/null
    fi

    apt-get update
    echo "=== Installing Self-Contained WineHQ Stable Bundle ==="
    # This bundle natively isolates all ntdll.so structures into proper locations
    apt-get install -y --install-recommends winehq-stable winetricks

    echo "=== Re-linking Loader Path Targets ==="
    # Safety fallback symlink if any absolute app paths still trigger the old directory layout
    mkdir -p /usr/lib/x86_64-linux-gnu/wine/x86_64-unix
    ln -sf /opt/wine-stable/lib64/wine/x86_64-unix/ntdll.so /usr/lib/x86_64-linux-gnu/wine/x86_64-unix/ntdll.so
    ln -sf /opt/wine-stable/bin/wine /usr/bin/wine
    ln -sf /opt/wine-stable/bin/wine64 /usr/bin/wine64

    echo "=== Verifying Resolution ==="
    wine --version
    echo "=== Official WineHQ Installation Complete ==="
}

fix_wine() {
    echo "=== Running Hard Purge of Current Broken Build Mappings ==="
    # The ntdll.so error cannot be bypassed without completely wiping the existing bad build layout
    delete_wine
    echo "=== Deploying Known-Good Official Configuration ==="
    install_winehq_official
    echo "=== Wine Repair Complete ==="
}

echo "====================================="
echo "      WINE MANAGEMENT SCRIPT         "
echo "====================================="
echo "1) Fix Wine (Complete wipe & migrate to official WineHQ layout)"
echo "2) Delete Wine (Completely purge Wine files)"
echo "3) Install Wine (Fresh Official WineHQ installation)"
echo "4) Exit"
echo "====================================="
read -p "Select an option (1-4): " option

case $option in
    1) fix_wine ;;
    2) delete_wine ;;
    3) install_winehq_official ;;
    4) echo "Exiting script."; exit 0 ;;
    *) echo "Invalid selection."; exit 1 ;;
esac

