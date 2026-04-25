#!/bin/bash

# Initialize and fetch all git submodules
# Usage: bash scripts/init-submodules.sh
#
# This script:
# - Initializes submodules if they don't exist locally
# - Fetches the latest commits from each submodule repository
# - Updates submodules to their tracked commits

set -e

echo -e "\033[1;36mInitializing and updating git submodules...\033[0m"

# Check if .gitmodules exists
if [ ! -f ".gitmodules" ]; then
    echo -e "\033[1;33mNo .gitmodules file found. No submodules to initialize.\033[0m"
    exit 0
fi

# Initialize submodules if they haven't been initialized yet
echo -e "\033[1;32mInitializing submodules...\033[0m"
git submodule update --init --recursive

# Fetch latest from all submodule remotes
echo -e "\033[1;32mFetching latest commits from submodules...\033[0m"
git submodule foreach --recursive 'git fetch origin' || echo -e "\033[1;33mWarning: Some submodule fetches failed\033[0m"

# Update submodules to their tracked commits
echo -e "\033[1;32mUpdating submodules to tracked commits...\033[0m"
git submodule update --recursive

if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to update submodules\033[0m"
    exit 1
fi

echo -e "\033[1;32mSubmodules successfully initialized and updated!\033[0m"

# Display submodule status
echo -e "\n\033[1;36mSubmodule Status:\033[0m"
git submodule status --recursive
