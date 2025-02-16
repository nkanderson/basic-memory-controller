#!/bin/bash

# Exit on error
set -e

# Get the latest Verible version tag
VERIBLE_VERSION=$(curl -s https://api.github.com/repos/chipsalliance/verible/releases/latest | grep "tag_name" | cut -d '"' -f 4)

# Define the download URL
VERIBLE_TARBALL="verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz"
DOWNLOAD_URL="https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/${VERIBLE_TARBALL}"

echo "Downloading Verible version: ${VERIBLE_VERSION}"
wget -q --show-progress "$DOWNLOAD_URL"

# Extract the tarball
echo "Extracting ${VERIBLE_TARBALL}..."
tar -xvzf "$VERIBLE_TARBALL"

# Create ~/bin directory if it doesn't exist
mkdir -p ~/bin

# Move binaries to ~/bin
mv verible-${VERIBLE_VERSION}/bin/* ~/bin/

# Cleanup: Remove the tar.gz file and extracted folder
rm -rf "$VERIBLE_TARBALL" "verible-${VERIBLE_VERSION}"

# Ensure ~/bin is in PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.zshrc
fi
export PATH=$HOME/bin:$PATH

# Source the appropriate shell configuration if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
elif [ -f ~/.zshrc ]; then
    source ~/.zshrc
fi

# Verify installation
echo "Verifying Verible installation..."
if command -v verible-verilog-lint &> /dev/null; then
    verible-verilog-lint --version
    echo "Verible successfully installed!"
else
    echo "Error: Verible installation failed."
    exit 1
fi

