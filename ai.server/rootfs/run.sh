#!/bin/bash
CONFIG_PATH=/data/options.json

# Ensure persistent storage exists
mkdir -p /app/modules
mkdir -p /etc/codeproject/ai

# Give full write access to the AI server
chmod -R 777 /app/modules
chmod -R 777 /etc/codeproject/ai

# Debug output
echo "DATA_DIR is now mapped to: /etc/codeproject/ai"
echo "MODULES_PATH is now mapped to: /app/modules"
ls -la /etc/codeproject/ai
ls -la /app/modules

# Start AI Server
cd /app/server && dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="/etc/codeproject/ai"
