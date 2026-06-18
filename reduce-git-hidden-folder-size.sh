#!/usr/bin/env bash

# chmod +x reduce-dot-git-folder-size.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Check if a path argument was provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a path to the Git repository."
    echo "Usage: $0 /path/to/your/repo"
    exit 1
fi

TARGET_DIR="$1"

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Change to the target directory
cd "$TARGET_DIR"

# Verify if the directory is actually a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ Error: '$TARGET_DIR' is not a valid Git repository."
    exit 1
fi

# Print progress and repository name
echo "🚀 Starting Git reduction on: $(pwd)"
echo "🧹 Expiring reflogs..."
git reflog expire --all --expire=now

echo "📦 Running aggressive garbage collection (this may take a moment)..."
git gc --prune=now --aggressive

echo "✅ Done! Your .git folder size has been reduced."

