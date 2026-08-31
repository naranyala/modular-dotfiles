#!/bin/bash

# Pastikan skrip dijalankan dengan hak akses root/sudo jika diperlukan
#if [ "$EUID" -ne 0 ]; then
#  echo "⚠️ Harap jalankan skrip ini menggunakan sudo."
#  exit 1
#fi

echo "🔍 Memeriksa metode suspend yang tersedia..."

# 1. Pendekatan Modern: Systemd (Standar distro modern)
if command -v systemctl &> /dev/null; then
    echo "🚀 Menggunakan Systemd untuk masuk ke mode suspend..."
    systemctl suspend
    exit 0
fi

# 2. Pendekatan Tradisional: Pm-utils (Distro lama atau non-systemd)
if command -v pm-suspend &> /dev/null; then
    echo "📦 Menggunakan pm-utils (pm-suspend)..."
    pm-suspend
    exit 0
fi

# 3. Pendekatan kernel langsung: Sysfs interface
if [ -f /sys/power/state ]; then
    echo "⚙️ Menggunakan Sysfs kernel interface..."
    # Memeriksa apakah mode 'mem' (suspend to RAM) didukung
    if grep -q "mem" /sys/power/state; then
        echo mem > /sys/power/state
        exit 0
    fi
fi

# 4. Pendekatan Desktop Environment (Upower)
if command -v dbus-send &> /dev/null; then
    echo "🌐 Menggunakan D-Bus / UPower..."
    dbus-send --system --print-reply --dest="org.freedesktop.UPower" \
        /org/freedesktop/UPower org.freedesktop.UPower.Suspend
    exit 0
fi

# Jika semua metode gagal
echo "❌ Gagal: Tidak ada metode suspend yang didukung atau terpasang di sistem ini."
exit 1

