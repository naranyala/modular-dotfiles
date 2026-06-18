#!/bin/bash
set -e

# 1. Fetch the latest stable Go version number
echo "Checking for the latest Go version..."
LATEST_VERSION=$(curl -s https://go.dev | head -n 1)
echo "Found version: $LATEST_VERSION"

# 2. Define filenames and download URL
ARCHIVE="${LATEST_VERSION}.linux-amd64.tar.gz"
DOWNLOAD_URL="https://google.com{ARCHIVE}"

# 3. Remove old installations safely
echo "Removing any existing Go installations at /usr/local/go..."
sudo rm -rf /usr/local/go

# 4. Download the latest release tarball
echo "Downloading ${ARCHIVE}..."
wget -q --show-progress "$DOWNLOAD_URL"

# 5. Extract files to destination folder
echo "Extracting archive to /usr/local..."
sudo tar -C /usr/local -xzf "$ARCHIVE"

# 6. Clean up the downloaded file
rm "$ARCHIVE"

# 7. Configure global environment variables in .bashrc if not already present
echo "Configuring environment paths in ~/.bashrc..."
if ! grep -q "export GOROOT=/usr/local/go" ~/.bashrc; then
    cat << 'EOF' >> ~/.bashrc

# Go Language Environment Variables
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
EOF
fi

echo "===================================================="
echo "Go installation script completed successfully!"
echo "Please run the following command to refresh your current terminal window:"
echo "source ~/.bashrc"
echo "===================================================="

