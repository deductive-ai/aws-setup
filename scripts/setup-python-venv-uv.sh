#!/usr/bin/env bash

# Generic Python Environment Setup Script with uv
# Creates a virtual environment using uv and installs dependencies
# Usage: `scripts/setup-python-venv-uv.sh`

# Fail fast on any error
set -euo pipefail

# Get root directory
gROOT_DIR="$(cd -- "$(dirname -- "$BASH_SOURCE")/.." && pwd)"

echo "Setting up Python Environment for $gROOT_DIR"
echo "Working directory: $gROOT_DIR"

# Navigate to the project directory
cd "$gROOT_DIR"

# Check if uv is installed, if not install it
if ! command -v uv &>/dev/null; then
  echo "uv not found. Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# Check uv version
echo "Using uv: $(uv --version)"

# Install Python 3.13.3 if not available
# This matches the infra setup and ensures compatibility
echo "Ensuring Python 3.13.3 is available..."
uv python install 3.13.3

# Create virtual environment and install dependencies using uv
echo "Creating virtual environment with uv (Python 3.13.3)..."
uv venv --python 3.13.3 .venv --clear

# Check if requirements.txt exists in the project directory
if [ ! -f "requirements.txt" ]; then
  echo "ERROR: requirements.txt not found in $gROOT_DIR" >&2
  echo "Please create a requirements.txt file in the project directory" >&2
  exit 1
fi

# Install dependencies using uv with explicit venv targeting
echo "Installing dependencies from requirements.txt..."
uv pip install -p .venv -r requirements.txt

# Check virtual environment was created successfully
if [ ! -x ".venv/bin/python" ]; then
  echo "ERROR: Virtual environment not created successfully" >&2
  echo "Expected .venv/bin/python to exist and be executable" >&2
  exit 1
fi

# Check Python version
PYTHON_VERSION=$(.venv/bin/python --version)
echo "Python version: $PYTHON_VERSION"

echo "Python environment setup completed successfully!"
echo "Virtual environment: $gROOT_DIR/.venv"
echo "Python version: $PYTHON_VERSION"
echo "To activate the environment, run:"
echo "source $gROOT_DIR/.venv/bin/activate"
