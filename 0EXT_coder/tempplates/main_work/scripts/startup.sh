#!/bin/bash
# Main startup script - orchestrates all initialization tasks
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Starting workspace initialization..."
echo "=========================================="

# Step 1: Initialize home directory
echo ""
echo "[1/3] Initializing home directory..."
"$SCRIPT_DIR/init_home.sh"

# Step 2: Setup Python environment
echo ""
echo "[2/3] Setting up Python environment..."
"$SCRIPT_DIR/setup_python.sh"

# Step 3: Install additional tools
echo ""
echo "[3/3] Installing development tools..."
"$SCRIPT_DIR/install_tools.sh"

echo ""
echo "=========================================="
echo "Workspace initialization complete!"
echo "=========================================="
