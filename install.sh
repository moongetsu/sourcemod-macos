#!/usr/bin/env bash
set -e

INSTALL_DIR="${1:-$HOME/.sourcemod-mac}"

echo "=================================================="
echo " SourceMod Compiler (macOS Universal) Installer"
echo "=================================================="
echo "Installing to: $INSTALL_DIR"

mkdir -p "$INSTALL_DIR"

# Download latest release
TAR_URL="https://github.com/YOUR_USERNAME/sourcemod-macos/releases/latest/download/sourcemod-compiler-macos-universal.tar.gz"

echo "Downloading compiler package..."
if curl -fSL "$TAR_URL" -o "$INSTALL_DIR/sm-mac.tar.gz" 2>/dev/null; then
    tar -xzf "$INSTALL_DIR/sm-mac.tar.gz" -C "$INSTALL_DIR"
    rm "$INSTALL_DIR/sm-mac.tar.gz"
    chmod +x "$INSTALL_DIR/bin/spcomp"
    
    echo "Adding $INSTALL_DIR/bin to PATH in ~/.zshrc..."
    if ! grep -q "$INSTALL_DIR/bin" "$HOME/.zshrc" 2>/dev/null; then
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.zshrc"
    fi
    
    echo "✅ Installation complete!"
    echo "Run: source ~/.zshrc"
    echo "Then use 'spcomp' from anywhere!"
else
    echo "Note: Release package not yet published on GitHub."
    echo "Please publish a release or build locally with: ./scripts/build-spcomp-macos.sh"
fi
