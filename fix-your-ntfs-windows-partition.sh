#!/bin/bash
# Interactive NTFS repair script using ntfsfix

# Find all NTFS partitions
partitions=$(lsblk -o NAME,FSTYPE -nr | awk '$2=="ntfs"{print "/dev/"$1}')

if [ -z "$partitions" ]; then
  echo "❌ No NTFS partitions detected."
  exit 1
fi

echo "🔍 Detected NTFS partitions:"
i=1
declare -A part_map
for part in $partitions; do
  echo "  [$i] $part"
  part_map[$i]=$part
  ((i++))
done

# Ask user which partition to fix
read -p "👉 Enter the number of the partition to fix: " choice

selected=${part_map[$choice]}

if [ -z "$selected" ]; then
  echo "❌ Invalid choice."
  exit 1
fi

echo "⚙️ Running ntfsfix on $selected..."
sudo ntfsfix -d "$selected"

echo "✅ Finished repairing $selected."

