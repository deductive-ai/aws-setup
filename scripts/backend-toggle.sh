#!/usr/bin/env bash
set -e

# Wrapper script for hclwrite-based backend toggling
# Usage: ./scripts/backend-toggle.sh [local|s3]

MODE=${1:-local}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ "$MODE" != "local" ] && [ "$MODE" != "s3" ]; then
    echo "Usage: $0 [local|s3]"
    echo "  local  - Use local backend"
    echo "  s3     - Use S3 backend"
    exit 1
fi

echo "Switching to $MODE backend using hclwrite..."

# Change to scripts directory and run the Go program
cd "$SCRIPT_DIR"

# Download dependencies if needed
if [ ! -f "go.sum" ]; then
    echo "Downloading Go dependencies..."
    go mod tidy
fi

# Run the Go program
go run backend-toggle.go "$PROJECT_ROOT/providers.tf" "$MODE"

echo "Backend toggle complete."
