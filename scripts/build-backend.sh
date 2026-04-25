#!/bin/bash
# Build Backend Script
# Usage: bash scripts/build-backend.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")/budget-be"

if [ ! -f "$BACKEND_DIR/go.mod" ]; then
    echo "Error: Backend directory not found or missing go.mod: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

echo "Building backend..."
echo ""

GOOS=linux GOARCH=amd64 go build -o api.exe ./cmd/api

if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

echo ""
echo "Build successful: $BACKEND_DIR/api.exe"