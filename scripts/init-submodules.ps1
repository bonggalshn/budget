# Initialize and fetch all git submodules
# Usage: .\scripts\init-submodules.ps1
# 
# This script:
# - Initializes submodules if they don't exist locally
# - Fetches the latest commits from each submodule repository
# - Updates submodules to their tracked commits

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Initializing and updating git submodules..." -ForegroundColor Cyan

# Check if .gitmodules exists
if (-not (Test-Path ".gitmodules")) {
    Write-Host "No .gitmodules file found. No submodules to initialize." -ForegroundColor Yellow
    exit 0
}

# Initialize submodules if they haven't been initialized yet
Write-Host "Initializing submodules..." -ForegroundColor Green
git submodule update --init --recursive

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to initialize submodules" -ForegroundColor Red
    exit 1
}

# Fetch latest from all submodule remotes
Write-Host "Fetching latest commits from submodules..." -ForegroundColor Green
git submodule foreach --recursive 'git fetch origin'

if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Some submodule fetches failed" -ForegroundColor Yellow
}

# Update submodules to their tracked commits
Write-Host "Updating submodules to tracked commits..." -ForegroundColor Green
git submodule update --recursive

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to update submodules" -ForegroundColor Red
    exit 1
}

Write-Host "Submodules successfully initialized and updated!" -ForegroundColor Green

# Display submodule status
Write-Host "`nSubmodule Status:" -ForegroundColor Cyan
git submodule status --recursive
