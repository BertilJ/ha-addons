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
    echo "Error: MODULES_PATH or DATA_DIR is empty!"
    exit 1
fi

# ✅ Force Environment Variables to Persist
export MODULES_PATH="$MODULES_PATH"
export DATA_DIR="$DATA_DIR"

# ✅ Debugging output to verify paths are set correctly
echo "Forcing correct storage paths..."
echo "MODULES_PATH is now: $MODULES_PATH"
echo "DATA_DIR is now: $DATA_DIR"

# Create directories if they don't exist
mkdir -p "$MODULES_PATH"
mkdir -p "$DATA_DIR"

# ✅ Force Update `appsettings.json` to Ensure Modules Are Stored in `/config/ai-server/modules`
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

# ✅ Verify If Modules Directory is Now Correctly Mounted
echo "Checking module storage path..."
ls -la "$MODULES_PATH"

# ✅ Start the AI Server with Correct Paths
cd /app/server || { echo "Error: Failed to change to /app/server"; exit 1; }
exec dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
