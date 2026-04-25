@echo off
REM Run Backend Script
REM Usage: scripts\run-backend.bat

cd /d "%~dp0..\budget-be"

echo Starting backend server...
echo Press Ctrl+C to stop
echo.

go run .\cmd\api\main.go