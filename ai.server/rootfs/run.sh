#!/bin/bash
set -e  # Exit on error

CONFIG_PATH="/data/options.json"

# Ensure options.json exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: Configuration file $CONFIG_PATH not found!"
    exit 1
fi

# Load settings from Home Assistant add-on options
MODULES_PATH=$(jq --raw-output '.MODULES_PATH // empty' "$CONFIG_PATH")
DATA_DIR=$(jq --raw-output '.DATA_DIR // empty' "$CONFIG_PATH")

# Validate settings
if [ -z "$MODULES_PATH" ] || [ -z "$DATA_DIR" ]; then
    echo "Error: MODULES_PATH or DATA_DIR is empty! Using default values."
    MODULES_PATH="/config/ai-server/modules"
    DATA_DIR="/config/ai-server/downloads"
fi

#Override and export the environment variables
export MODULES_PATH="/config/ai-server/modules"
export DATA_DIR="/config/ai-server/downloads"

#Force setting environment variables globally for the container
echo "MODULES_PATH=/config/ai-server/modules" >> /etc/environment
echo "DATA_DIR=/config/ai-server/downloads" >> /etc/environment
source /etc/environment  # Reload environment variables

# Debugging output
echo "FORCING MODULE STORAGE PATHS!"
echo "MODULES_PATH is now set to: $MODULES_PATH"
echo "DATA_DIR is now set to: $DATA_DIR"

# Create directories if they don't exist
mkdir -p "$MODULES_PATH"
mkdir -p "$DATA_DIR"

#Force update `appsettings.json` to ensure persistence
APP_SETTINGS="/app/server/appsettings.json"
if [ -f "$APP_SETTINGS" ]; then
    TEMP_SETTINGS="${APP_SETTINGS}.new"
    jq --arg modules "$MODULES_PATH" \
       --arg downloads "$DATA_DIR" \
       '.ModulesDirPath = $modules | .DownloadedModulePackagesDirPath = $downloads' \
       "$APP_SETTINGS" > "$TEMP_SETTINGS" && mv "$TEMP_SETTINGS" "$APP_SETTINGS"
else
    echo "Warning: appsettings.json not found, skipping modification."
fi

#Verify if modules are now stored correctly
echo "Checking if modules are stored in the correct location..."
ls -la "$MODULES_PATH"

#Start the AI Server with Correct Paths
cd /app/server || { echo "ERROR: Failed to change to /app/server"; exit 1; }
exec dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
