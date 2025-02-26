#!/bin/bash
CONFIG_PATH=/data/options.json

# Load paths from options.json
export MODULES_PATH=$(jq --raw-output '.MODULES_PATH // "/app/modules"' $CONFIG_PATH)
export DATA_DIR=$(jq --raw-output '.DATA_DIR // "/etc/codeproject/ai"' $CONFIG_PATH)

# Ensure directories exist
mkdir -p "$MODULES_PATH"
mkdir -p "$DATA_DIR"

# Fix appsettings.json to use the correct modules path
cat /app/server/appsettings.json | sed -e 's/\/\/ .*$//g' | jq ".ModuleOptions.ModulesPath=\"$MODULES_PATH\"" > /app/server/appsettings.json.new
mv /app/server/appsettings.json.new /app/server/appsettings.json

# Run the AI server with the correct application data directory
cd /app/server && dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
