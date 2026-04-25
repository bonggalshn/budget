# Run Backend Script
# Usage: .\scripts\run-backend.ps1

$ErrorActionPreference = "Stop"

$BackendDir = Join-Path $PSScriptRoot "..\budget-be"

if (-not (Test-Path (Join-Path $BackendDir "go.mod"))) {
    Write-Error "Backend directory not found or missing go.mod: $BackendDir"
    exit 1
}

Set-Location $BackendDir

Write-Host "Starting backend server..."
Write-Host "Press Ctrl+C to stop"
Write-Host ""

go run .\cmd\api\main.go