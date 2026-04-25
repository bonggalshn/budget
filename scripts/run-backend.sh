#!/bin/bash
# Run Backend Script
# Usage: bash scripts/run-backend.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")/budget-be"

if [ ! -f "$BACKEND_DIR/go.mod" ]; then
    echo "Error: Backend directory not found or missing go.mod: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

echo "Starting backend server..."
echo "Press Ctrl+C to stop"
echo ""

go run ./cmd/api/main.go