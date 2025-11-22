#!/bin/bash
# Initialize home directory with default files on first start
set -e

MARKER_FILE="$HOME/.init_done"

if [ -f "$MARKER_FILE" ]; then
    echo "Home directory already initialized."
    exit 0
fi

echo "Initializing home directory with default files..."
cp -rT /etc/skel ~
touch "$MARKER_FILE"
echo "Home directory initialization complete!"
