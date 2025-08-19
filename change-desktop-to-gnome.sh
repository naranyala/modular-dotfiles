#!/usr/bin/env bash
set -euo pipefail

LOGFILE="${HOME}/.desktop-switch.log"
DESKTOP_TARGET="gnome"
DESKTOP_CURRENT="$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | tr '[:upper:]' '[:lower:]')"

GNOME_APPS=(
  org.gnome.Nautilus
  org.gnome.Calendar
  org.gnome.Weather
  org.gnome.Maps
  org.gnome.Characters
  org.gnome.Calculator
  org.gnome.TextEditor
  org.gnome.Extensions
  org.gnome.Tweaks
)

log() { echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"; }

detect_distro() {
  if command -v apt &>/dev/null; then echo "debian"
  elif command -v dnf &>/dev/null; then echo "fedora"
  elif command -v pacman &>/dev/null; then echo "arch"
  else echo "unknown"
  fi
}

ensure_flatpak() {
  if ! command -v flatpak &>/dev/null; then
    log "Flatpak not found. Installing..."
    case "$(detect_distro)" in
      debian) sudo apt update && sudo apt install -y flatpak ;;
      fedora) sudo dnf install -y flatpak ;;
      arch) sudo pacman -Syu --noconfirm flatpak ;;
      *) log "Unsupported distro. Manual Flatpak install required."; return 1 ;;
    esac
  fi

  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  log "Flatpak and Flathub ready."
}

install_gnome_flatpak() {
  log "Installing GNOME platform and apps via Flatpak..."
  flatpak install -y flathub org.gnome.Platform//stable || log "GNOME Platform already installed or failed."

  for app in "${GNOME_APPS[@]}"; do
    if flatpak list | grep -q "$app"; then
      log "Already installed: $app"
    else
      log "Installing: $app"
      flatpak install -y flathub "$app" || log "Failed to install: $app"
    fi
  done
  log "GNOME Flatpak components installed."
}

ensure_gnome_session() {
  if command -v gnome-session &>/dev/null; then
    log "GNOME session binary found."
    return 0
  fi

  log "GNOME session not found. Installing via system package manager..."
  case "$(detect_distro)" in
    debian) sudo apt install -y gnome-session gdm3 ;;
    fedora) sudo dnf install -y @gnome-desktop ;;
    arch) sudo pacman -Syu --noconfirm gnome gdm ;;
    *) log "Unsupported distro. Manual GNOME session install required."; return 1 ;;
  esac
  log "GNOME session installed."
}

switch_session_manager() {
  log "Switching session manager to GDM..."
  sudo systemctl disable sddm.service || log "SDDM not found or already disabled."
  sudo systemctl enable gdm.service
  sudo systemctl set-default graphical.target
  log "Session manager switched to GDM."
}

main() {
  log "Current desktop: $DESKTOP_CURRENT"
  if [[ "$DESKTOP_CURRENT" == "$DESKTOP_TARGET" ]]; then
    log "Already running GNOME. No action taken."
    exit 0
  fi

  ensure_flatpak || exit 1
  install_gnome_flatpak || exit 1
  ensure_gnome_session || exit 1
  switch_session_manager
  log "Switch complete. Please reboot to enter GNOME session."
}

main "$@"

