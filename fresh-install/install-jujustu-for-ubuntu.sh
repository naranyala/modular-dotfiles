#!/usr/bin/env bash

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
  echo "❌ Do not run this script as root. Please run as a normal user."
  exit 1
fi

cargo install --locked --bin jj jj-cli

