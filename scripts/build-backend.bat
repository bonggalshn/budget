@echo off
REM Build Backend Script
REM Usage: scripts\build-backend.bat

cd /d "%~dp0..\budget-be"

echo Building backend...
echo.

go build -o api.exe ./cmd/api

if %errorlevel% neq 0 (
    echo Build failed
    exit /b 1
)

echo.
echo Build successful: api.exe