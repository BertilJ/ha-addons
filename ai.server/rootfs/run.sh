#!/bin/bash

CONFIG_PATH=/data/options.json

# Ensure internal storage directories exist
mkdir -p /etc/codeproject/ai
mkdir -p /app/modules

# Debug output to confirm internal storage
# echo "DATA_DIR is: /etc/codeproject/ai"
# echo "MODULES_PATH is: /app/modules"
# ls -la /etc/codeproject/ai
# ls -la /app/modules

# Start the AI server normally
cd /app/server && dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="/etc/codeproject/ai"
