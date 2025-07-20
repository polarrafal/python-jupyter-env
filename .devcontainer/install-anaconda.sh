#!/bin/bash

set -e

# Base URL for Anaconda Linux installers repository
ANACONDA_REPO="https://repo.anaconda.com/archive/"

# Temporary directory to work in
TMP_DIR="/tmp/anaconda_install"
mkdir -p $TMP_DIR
cd $TMP_DIR

echo "Fetching latest Anaconda installer name..."

# Retrieve the latest stable Anaconda3 Linux x86_64 installer filename
LATEST_INSTALLER=$(curl -s $ANACONDA_REPO | \
  grep -o 'Anaconda3-[0-9]\{4\}\.[0-9]\+-[0-9]\+-Linux-x86_64\.sh' | \
  sort -V | tail -n 1)

if [ -z "$LATEST_INSTALLER" ]; then
  echo "Failed to find the latest Anaconda installer. Exiting."
  exit 1
fi

echo "Latest installer found: $LATEST_INSTALLER"

# Download the latest installer
wget "${ANACONDA_REPO}${LATEST_INSTALLER}" -O anaconda.sh

echo "Running Anaconda installer silently..."

# Install location (default to $HOME/anaconda3)
INSTALL_DIR="$HOME/anaconda3"

# Run the installer silently with default options
bash anaconda.sh -b -p "$INSTALL_DIR"

echo "Cleaning up..."
rm anaconda.sh

# Add Anaconda to PATH in .bashrc if not already present
if ! grep -q "$INSTALL_DIR/bin" "$HOME/.bashrc"; then
  echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
  echo "Added Anaconda bin to PATH in ~/.bashrc"
fi

# Initialize conda in current shell session
eval "$($INSTALL_DIR/bin/conda shell.bash hook)"

# Update conda to latest version
conda update -n base -c defaults conda -y

echo "Anaconda installation completed successfully."
echo "Please restart your terminal or run 'source ~/.bashrc' to use conda."
