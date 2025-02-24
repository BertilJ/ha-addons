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

# Create directories if they don't exist
mkdir -p "$MODULES_PATH"
mkdir -p "$DATA_DIR"

# Debugging output
echo "Starting AI Server with:"
echo "  MODULES_PATH: $MODULES_PATH"
echo "  DATA_DIR: $DATA_DIR"

# Update appsettings.json safely
APP_SETTINGS="/app/server/appsettings.json"
if [ -f "$APP_SETTINGS" ]; then
    TEMP_SETTINGS="${APP_SETTINGS}.new"
    jq ".ModuleOptions.ModulesPath=\"$MODULES_PATH\"" "$APP_SETTINGS" > "$TEMP_SETTINGS" && mv "$TEMP_SETTINGS" "$APP_SETTINGS"
else
    echo "Warning: appsettings.json not found, skipping modification."
fi

# Navigate to application directory
cd /app/server || { echo "Error: Failed to change to /app/server"; exit 1; }

# Start the AI server application
exec dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
