#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Installation script to set up environment and symlinks.
# Author: CeleroLab
# License: MIT
# ==============================================================================

# Installation Script for Video Tools

echo "Installing Video Tools..."

# Resolve project root
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_PATH="$DIR/bin/video-tools"

# Make executable
chmod +x "$BIN_PATH"

# Ask user where to install
echo "Where do you want to install 'video-tools' symlink?"
echo "1) ~/bin (User local, recommended)"
echo "2) /usr/local/bin (System wide, requires sudo)"
echo "3) Do not create symlink (I will manage PATH manually)"

read -rp "Choice [1]: " choice
choice=${choice:-1}

case $choice in
  1)
    TARGET_DIR="$HOME/bin"
    mkdir -p "$TARGET_DIR"
    TARGET_LINK="$TARGET_DIR/video-tools"
    ln -sf "$BIN_PATH" "$TARGET_LINK"
    echo "âœ… Symlink created at $TARGET_LINK"
    
    # Check if in PATH
    if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
        echo "âš ï¸  $TARGET_DIR is not in your PATH."
        echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
        echo "export PATH=\"\$HOME/bin:\$PATH\""
    fi
    ;;
  2)
    TARGET_LINK="/usr/local/bin/video-tools"
    echo "Creating symlink at $TARGET_LINK (may ask for password)..."
    sudo ln -sf "$BIN_PATH" "$TARGET_LINK"
    if [ $? -eq 0 ]; then
        echo "âœ… Symlink created at $TARGET_LINK"
    else
        echo "âŒ Failed to create symlink."
    fi
    ;;
  3)
    echo "Skipping symlink creation."
    echo "You can run the tool using: $BIN_PATH"
    ;;
  *)
    echo "Invalid choice."
    ;;
esac

echo "âœ… Installation complete!"
