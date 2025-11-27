#!/usr/bin/env bash

# Generic Python Environment Setup Script with uv
# Creates a virtual environment using uv and installs dependencies for any project
# Usage: ./setup-python-env-uv.sh <project_directory>

# Fail fast on any error
set -euo pipefail

# Check if project directory argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <project_directory>" >&2
  exit 1
fi

PROJECT_DIR="$1"

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Project directory '$PROJECT_DIR' does not exist" >&2
  exit 1
fi

# Convert to absolute path for safety
echo "Changing to project directory: $PROJECT_DIR"
PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)

echo "Setting up Python Environment for project: $PROJECT_DIR"
echo "Working directory: $PROJECT_DIR"

# Navigate to the project directory
cd "$PROJECT_DIR"

# Check if uv is installed or at expected version
UV_VERSION="0.9.13"
if ! command -v uv &>/dev/null || [ "$(uv --version | awk '{print $2}')" != "$UV_VERSION" ]; then
  if ! command -v uv &>/dev/null; then
    echo "uv not found. Installing uv..."
  else
    echo "uv version mismatch. Currently you have $(uv --version), expected $UV_VERSION. Refreshing uv to $UV_VERSION..."
  fi
  curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh
  # Add to PATH for current session
  export PATH="$HOME/.local/bin:$PATH"
fi

PYTHON_VERSION="3.13.9"

# Create virtual environment and install dependencies using uv
# uv venv will automatically download Python if not available
echo "Creating virtual environment with uv (Python $PYTHON_VERSION)..."
uv venv --python $PYTHON_VERSION .venv --clear --allow-existing

# Check if requirements.txt exists in the project directory
if [ ! -f "requirements.txt" ]; then
  echo "ERROR: requirements.txt not found in $PROJECT_DIR" >&2
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
echo "Project: $PROJECT_DIR"
echo "Virtual environment: $PROJECT_DIR/.venv"
echo "Python version: $PYTHON_VERSION"
echo "To activate the environment, run:"
echo "source $PROJECT_DIR/.venv/bin/activate"
