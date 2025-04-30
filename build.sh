#!/bin/bash
set -e

# Check if apt-get is available (Debian/Ubuntu)
apt_available=false
if command -v apt-get &> /dev/null; then
    apt_available=true
fi

# Check if Python 3.12 is installed
python_installed=false
if command -v python3.12 &> /dev/null; then
    python_installed=true
else
    echo "Python 3.12 not found. Attempting to install..."
    
    if $apt_available; then
        echo "Detected Debian/Ubuntu system. Installing Python 3.12 with apt..."
        sudo apt-get update
        sudo apt-get install -y python3.12
    else
        echo "Error: Python 3.12 is required but not installed."
        echo "Please install Python 3.12 manually for your system."
        exit 1
    fi
fi

# Check if python3.12-venv is available
if $python_installed && ! python3.12 -m venv --help &> /dev/null; then
    echo "Python 3.12 venv module not found. Attempting to install..."
    
    if $apt_available; then
        echo "Installing python3.12-venv with apt..."
        sudo apt-get update
        sudo apt-get install -y python3.12-venv
    else
        echo "Error: Python 3.12 venv module is required but not installed."
        echo "Please install python3.12-venv manually for your system."
        exit 1
    fi
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