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
    MODULES_PATH="/data/modules"
    DATA_DIR="/data/downloads"
fi

# Override and export the environment variables
export MODULES_PATH="/data/modules"
export DATA_DIR="/data/downloads"

# Force setting environment variables globally for the container
echo "MODULES_PATH=/data/modules" >> /etc/environment
echo "DATA_DIR=/data/downloads" >> /etc/environment
source /etc/environment  # Reload environment variables

# Debugging output
echo "FORCING MODULE STORAGE PATHS!"
echo "MODULES_PATH is now set to: $MODULES_PATH"
echo "DATA_DIR is now set to: $DATA_DIR"

# Create directories if they don't exist
mkdir -p "$MODULES_PATH"
mkdir -p "$DATA_DIR"

# ✅ Fix `appsettings.json` by removing invalid control characters & comments
APP_SETTINGS="/app/server/appsettings.json"
TEMP_SETTINGS="${APP_SETTINGS}.new"

if [ -f "$APP_SETTINGS" ]; then
    echo "✅ Cleaning up appsettings.json..."
    
    # 🔥 Remove control characters and strip comments
    cat "$APP_SETTINGS" | tr -d '\000-\031' | sed -e 's/\/\/.*//g' > "${APP_SETTINGS}.cleaned"

    # ✅ Validate JSON before modifying
    if jq empty "${APP_SETTINGS}.cleaned"; then
        echo "✅ appsettings.json is valid! Updating paths..."

        # ✅ Modify JSON using Python to avoid jq issues
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

# ✅ Create a symbolic link from `/app/modules` to `/data/modules` (Fix hardcoded paths)
# ln -sfn /data/modules /app/modules
# ln -sfn /data/downloads /app/downloads

# ✅ Start the AI Server with Correct Paths
cd /app/server || { echo "❌ ERROR: Failed to change to /app/server"; exit 1; }
exec dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
