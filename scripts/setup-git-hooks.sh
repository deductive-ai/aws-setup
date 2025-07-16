#!/usr/bin/env bash

# Script to set up git hooks for automatic backend management

echo "Setting up git hooks..."

# Check Go installation and version
if ! command -v go &> /dev/null; then
    echo "ERROR: Go is not installed"
    echo "Please install Go 1.24.5 from https://golang.org/dl/"
    echo "Or on macOS: brew install go"
    exit 1
fi

GO_VERSION=$(go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/go//')
REQUIRED_VERSION="1.24.5"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "ERROR: Go $GO_VERSION found, but Go $REQUIRED_VERSION+ is required"
    echo "Please upgrade Go: https://golang.org/dl/"
    echo "Or on macOS: brew upgrade go"
    exit 1
fi

echo "Go $GO_VERSION detected (required: $REQUIRED_VERSION+)"

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy our pre-commit hook
cp .githooks/pre-commit .git/hooks/pre-commit

# Make scripts executable
chmod +x .git/hooks/pre-commit
chmod +x scripts/validate.sh
chmod +x scripts/backend-toggle.sh

echo "Git hooks set up successfully."