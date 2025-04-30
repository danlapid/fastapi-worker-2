#!/bin/bash
set -e

# Check if apt-get is available (Debian/Ubuntu)
apt_available=false
if command -v apt-get &> /dev/null; then
    sudo apt-get install -y python3.12 python3.12-venv
fi

# Check if Python 3.12 is installed
if ! command -v python3.12 &> /dev/null; then
    echo "Error: Python 3.12 is required but not installed."
    exit 1
fi

# Create and activate virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment (.venv)..."
    python3.12 -m venv .venv
else
    echo "Using existing Python virtual environment (.venv)..."
fi

# Make sure to activate the virtual environment
source .venv/bin/activate

# Install pyodide CLI if needed
if ! .venv/bin/pip show pyodide-build &> /dev/null; then
    echo "Installing pyodide-build..."
    .venv/bin/pip install pyodide-build
else
    echo "pyodide-build already installed."
fi

# Create pyodide virtual environment if it doesn't exist
if [ ! -d ".venv-pyodide" ]; then
    echo "Creating pyodide virtual environment (.venv-pyodide)..."
    .venv/bin/pyodide venv .venv-pyodide
else
    echo "Using existing pyodide virtual environment (.venv-pyodide)..."
fi

# Download vendored packages
echo "Installing vendored packages from vendor.txt..."
.venv-pyodide/bin/pip install -t src/vendor -r vendor.txt

echo "Build completed successfully!"
