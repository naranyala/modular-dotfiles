#!/usr/bin/env bash
# universal-suspend.sh
# A script to suspend Linux systems using the best available method.

set -euo pipefail

echo "Attempting to suspend the system..."

# Check for pm-utils (older distros)
if command -v pm-suspend >/dev/null 2>&1; then
    echo "Using pm-suspend..."
    pm-suspend
    exit 0
fi

# Check for loginctl (alternative systemd interface)
# if command -v loginctl >/dev/null 2>&1; then
#     echo "Using loginctl suspend..."
#     loginctl suspend
#     exit 0
# fi

# Fallback: try /sys/power/state (low-level kernel interface)
if [ -w /sys/power/state ]; then
    echo "Using /sys/power/state..."
    echo mem | sudo tee /sys/power/state
    exit 0
fi

# Finally, try systemctl (most modern distros)
if command -v systemctl >/dev/null 2>&1; then
    echo "Using systemctl suspend..."
    systemctl suspend
    exit 0
fi

echo "Error: No suspend method found on this system."
exit 1

