#!/bin/bash
# Install additional development tools (ffuf, etc.)
set -e

MARKER_FILE="$HOME/.tools_setup_done"

if [ -f "$MARKER_FILE" ]; then
    echo "Development tools already installed."
    exit 0
fi

echo "Installing development tools..."

# Install ffuf (web fuzzer)
FFUF_VERSION="2.1.0"
FFUF_ARCH="arm64"
FFUF_URL="https://github.com/ffuf/ffuf/releases/download/v$FFUF_VERSION/ffuf_"$FFUF_VERSION"_linux_$FFUF_ARCH.tar.gz"

echo "Installing ffuf v$FFUF_VERSION..."
wget -q "$FFUF_URL" -O /tmp/ffuf.tar.gz
tar -xzf /tmp/ffuf.tar.gz -C /tmp
sudo mv /tmp/ffuf /usr/local/bin/
sudo chmod +x /usr/local/bin/ffuf
rm -f /tmp/ffuf.tar.gz

# Verify installation
ffuf -V

touch "$MARKER_FILE"
echo "Development tools installation complete!"
