#!/usr/bin/env bash

# Script to set up git hooks for automatic backend management

echo "Setting up git hooks..."
gROOT_DIR="$(cd -- "$(dirname -- "$BASH_SOURCE")/.." && pwd)"

# Check Go installation and version
for bin in go tflint tfsec checkov; do
    if ! command -v $bin &> /dev/null; then
        echo "ERROR: $bin is not installed, reconfiguring the entire environment..."
        $gROOT_DIR/scripts/setup.sh
    fi
done

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy our pre-commit hook
cp .githooks/pre-commit .git/hooks/pre-commit

# Make scripts executable
for script in .git/hooks/pre-commit backend-toggle.sh setup.sh setup-git-hooks.sh setup-python-env-uv.sh validate.sh; do
    chmod +x scripts/$script
done

echo "Git hooks set up successfully."
