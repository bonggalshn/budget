# Build Backend Script
# Usage: .\scripts\build-backend.ps1

$ErrorActionPreference = "Stop"

$BackendDir = Join-Path $PSScriptRoot "..\budget-be"
$OutputDir = Join-Path $BackendDir "api"

if (-not (Test-Path (Join-Path $BackendDir "go.mod"))) {
    Write-Error "Backend directory not found or missing go.mod: $BackendDir"
    exit 1
}

Set-Location $BackendDir

Write-Host "Building backend..."
Write-Host ""

$env:GOOS = "linux"
$env:GOARCH = "amd64"

Write-Host "Building for Linux amd64..."
go build -o api.exe ./cmd/api

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed"
    exit 1
}

Write-Host ""
Write-Host "Build successful: $BackendDir\api.exe" -ForegroundColor Green