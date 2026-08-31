#!/usr/bin/env bash
# Mount NTFS partition safely on Arch Linux

PARTITION="/dev/nvme0n1p4"
MOUNTPOINT="/media/naranyala/Data"

# Ensure mount point exists
if [ ! -d "$MOUNTPOINT" ]; then
    echo "📂 Creating mount point at $MOUNTPOINT..."
    sudo mkdir -p "$MOUNTPOINT"
fi

# Check if ntfs-3g is installed
if ! command -v ntfs-3g &> /dev/null; then
    echo "⚠️ ntfs-3g not found. Installing..."
    sudo pacman -Sy --noconfirm ntfs-3g
fi

# Attempt to mount
echo "🔄 Mounting $PARTITION to $MOUNTPOINT..."
sudo mount -t ntfs-3g "$PARTITION" "$MOUNTPOINT"

# Verify success
if mountpoint -q "$MOUNTPOINT"; then
    echo "✅ Successfully mounted $PARTITION at $MOUNTPOINT"
else
    echo "❌ Failed to mount. Try running 'sudo ntfsfix $PARTITION' or chkdsk in Windows."
fi
