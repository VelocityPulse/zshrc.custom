#!/bin/zsh

# eza install - download prebuilt binary from GitHub

EZA_DIR="$HOME/.local/bin"
mkdir -p "$EZA_DIR"

if command -v eza &> /dev/null; then
    echo "eza already installed: $(eza --version | head -1)"
    exit 0
fi

echo "Installing eza..."

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="x86_64" ;;
    aarch64) ARCH="aarch64" ;;
    arm64)   ARCH="aarch64" ;;
    *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    linux)  OS="linux" ;;
    darwin) OS="macos" ;;
    *)      echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Get latest release
LATEST=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
echo "Latest version: $LATEST"

# Download
URL="https://github.com/eza-community/eza/releases/download/${LATEST}/eza_${ARCH}-unknown-${OS}-gnu.tar.gz"
echo "Downloading from $URL"

curl -L "$URL" | tar xz -C "$EZA_DIR"

# Add to PATH if needed
if [[ ":$PATH:" != *":$EZA_DIR:"* ]]; then
    echo "export PATH=\"$EZA_DIR:\$PATH\"" >> ~/.zshrc
    echo "Added $EZA_DIR to PATH in ~/.zshrc"
fi

echo "Done! Restart your shell or run: export PATH=\"$EZA_DIR:\$PATH\""
