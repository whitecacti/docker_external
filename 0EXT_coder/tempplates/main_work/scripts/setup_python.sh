#!/bin/bash
# Setup Python development environment with pyenv
set -e

MARKER_FILE="$HOME/.python_setup_done"
PYTHON_VERSION="3.11.10"
VENV_NAME="main_env"

# Source pyenv if it exists (for subsequent runs)
init_pyenv() {
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv &> /dev/null; then
        eval "$(pyenv init -)"
    fi
}

if [ -f "$MARKER_FILE" ]; then
    echo "Python development environment already set up."
    init_pyenv
    exit 0
fi

echo "Setting up Python development environment..."

# Update package list
echo "Updating package list..."
sudo apt update

# Install Python build dependencies
echo "Installing Python build dependencies..."
sudo apt install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    net-tools

# Upgrade all packages
echo "Upgrading packages..."
sudo apt upgrade -y

# Install pyenv
echo "Installing pyenv..."
curl -fsSL https://pyenv.run | bash

# Configure pyenv in bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Initialize pyenv for current session
init_pyenv

# Install Python version
echo "Installing Python $PYTHON_VERSION..."
pyenv install "$PYTHON_VERSION"
pyenv global "$PYTHON_VERSION"

# Create virtual environment
echo "Creating virtual environment '$VENV_NAME'..."
pyenv virtualenv "$PYTHON_VERSION" "$VENV_NAME"
pyenv global "$VENV_NAME"

# Verify installation
echo "Verifying Python installation..."
python --version
pip --version

# Install essential Python packages
echo "Installing essential Python packages..."
pip3 install boto3

touch "$MARKER_FILE"
echo "Python development environment setup complete!"
