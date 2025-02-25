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
LOGS_PATH=$(jq --raw-output '.LOGS_PATH // empty' "$CONFIG_PATH")
SCRIPTS_PATH=$(jq --raw-output '.SCRIPTS_PATH // empty' "$CONFIG_PATH")

# Validate settings and fall back to defaults if needed
if [ -z "$MODULES_PATH" ] || [ -z "$DATA_DIR" ] || [ -z "$LOGS_PATH" ] || [ -z "$SCRIPTS_PATH" ]; then
    echo "Warning: One or more paths are empty! Using default values."
    MODULES_PATH="/config/ai-server/modules"
    DATA_DIR="/config/ai-server/downloads"
    LOGS_PATH="/config/ai-server/logs"
    SCRIPTS_PATH="/config/ai-server/scripts"
fi

# Override and export the environment variables
export MODULES_PATH="$MODULES_PATH"
export DATA_DIR="$DATA_DIR"
export LOGS_PATH="$LOGS_PATH"
export SCRIPTS_PATH="$SCRIPTS_PATH"

# Persist environment variables globally
echo "MODULES_PATH=$MODULES_PATH" >> /etc/environment
echo "DATA_DIR=$DATA_DIR" >> /etc/environment
echo "LOGS_PATH=$LOGS_PATH" >> /etc/environment
echo "SCRIPTS_PATH=$SCRIPTS_PATH" >> /etc/environment
source /etc/environment  # Reload environment variables

# Debugging output
echo "MODULES_PATH is now set to: $MODULES_PATH"
echo "DATA_DIR is now set to: $DATA_DIR"
echo "LOGS_PATH is now set to: $LOGS_PATH"
echo "SCRIPTS_PATH is now set to: $SCRIPTS_PATH"

# Ensure directories exist and have correct permissions
mkdir -p "$MODULES_PATH" "$DATA_DIR" "$LOGS_PATH" "$SCRIPTS_PATH"
chmod -R 777 "$MODULES_PATH" "$DATA_DIR" "$LOGS_PATH" "$SCRIPTS_PATH"

# Fix `appsettings.json` by removing invalid control characters & comments
APP_SETTINGS="/app/server/appsettings.json"
TEMP_SETTINGS="${APP_SETTINGS}.new"

if [ -f "$APP_SETTINGS" ]; then
    echo "✅ Cleaning up appsettings.json..."
    
    # Remove control characters and strip comments
    tr -d '\000-\031' < "$APP_SETTINGS" | sed -e 's/\/\/.*//g' > "${APP_SETTINGS}.cleaned"

    # Validate JSON before modifying
    if jq empty "${APP_SETTINGS}.cleaned"; then
        echo "✅ appsettings.json is valid! Updating paths..."

        # Modify JSON using Python to avoid jq limitations
        python3 -c "
import json

with open('${APP_SETTINGS}.cleaned', 'r') as f:
    config = json.load(f)

config['ModulesDirPath'] = '${MODULES_PATH}'
config['DownloadedModulePackagesDirPath'] = '${DATA_DIR}'

with open('${TEMP_SETTINGS}', 'w') as f:
    json.dump(config, f, indent=4)

print('✅ Successfully updated appsettings.json')
" || echo "❌ Failed to update appsettings.json!"

        mv "$TEMP_SETTINGS" "$APP_SETTINGS"
        chmod 777 "$APP_SETTINGS"  # Ensure write permissions
    else
        echo "❌ appsettings.json is still invalid! Keeping the original file."
    fi
else
    echo "⚠️ Warning: appsettings.json not found, skipping modification."
fi

# Start the AI Server with Correct Paths
cd /app/server || { echo "❌ ERROR: Failed to change to /app/server"; exit 1; }
exec dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
