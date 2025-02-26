#!/bin/bash
CONFIG_PATH=/data/options.json

# Load paths from options.json (or use default locations)
export MODULES_PATH=$(jq --raw-output '.MODULES_PATH // "/app/modules"' $CONFIG_PATH)
export DATA_DIR=$(jq --raw-output '.DATA_DIR // "/etc/codeproject/ai"' $CONFIG_PATH)

# Ensure Home Assistant's mapped /share folder exists
mkdir -p /share/ai-server/data
mkdir -p /share/ai-server/modules

# Bind /etc/codeproject/ai to /share/ai-server/data
if [ ! -L "/etc/codeproject/ai" ]; then
    rm -rf /etc/codeproject/ai
    ln -s /share/ai-server/data /etc/codeproject/ai
fi

# Bind /app/modules to /share/ai-server/modules
if [ ! -L "/app/modules" ]; then
    rm -rf /app/modules
    ln -s /share/ai-server/modules /app/modules
fi

# Debug output to check if mapping works
echo "DATA_DIR is mapped to: $DATA_DIR"
echo "MODULES_PATH is mapped to: $MODULES_PATH"
ls -la /etc/codeproject/ai
ls -la /app/modules
ls -la /share/ai-server

mkdir -p "$MODULES_PATH"
mkdir -p "$DATA_DIR"

# Fix appsettings.json to use the correct modules path
cat /app/server/appsettings.json | sed -e 's/\/\/ .*$//g' | jq ".ModuleOptions.ModulesPath=\"$MODULES_PATH\"" > /app/server/appsettings.json.new
mv /app/server/appsettings.json.new /app/server/appsettings.json

# Run the AI server with the correct application data directory
cd /app/server && dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
