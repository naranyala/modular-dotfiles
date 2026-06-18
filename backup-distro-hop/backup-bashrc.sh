#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- CONFIGURATION ---
# Change this path to your desired backup directory
BACKUP_DIR="/media/naranyala/Data/projects-remote/naravisuals-dotfiles/"
SOURCE_FILE="$HOME/.bashrc"
# ---------------------

# Get current date and time (Format: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/.bashrc_${TIMESTAMP}.bak"

echo "Starting backup process..."

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file $SOURCE_FILE does not exist." >&2
    exit 1
fi

# Create the backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory at: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Copy the file
cp "$SOURCE_FILE" "$BACKUP_FILE"

# Verify backup success
if [ $? -eq 0 ]; then
    echo "Success! Backup created at: $BACKUP_FILE"
else
    echo "Error: Backup failed." >&2
    exit 1
fi

