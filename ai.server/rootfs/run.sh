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

# 🔥 Override and export the environment variables
export MODULES_PATH="/data/modules"
export DATA_DIR="/data/downloads"

# 🔥 Force setting environment variables globally for the container
echo "MODULES_PATH=/data/modules" >> /etc/environment
echo "DATA_DIR=/data/downloads" >> /etc/environment
source /etc/environment  # Reload environment variables

# ✅ Debugging output
echo "FORCING MODULE STORAGE PATHS!"
echo "MODULES_PATH is now set to: $MODULES_PATH"
echo "DATA_DIR is now set to: $DATA_DIR"

# ✅ Create directories if they don't exist
mkdir -p "$MODULES_PATH"
mkdir -p "$DATA_DIR"

# ✅ Fix `appsettings.json` by **replacing it with a clean version**
APP_SETTINGS="/app/server/appsettings.json"
if [ -f "$APP_SETTINGS" ]; then
    echo "❌ appsettings.json is corrupted. Replacing it with a clean version."
    mv "$APP_SETTINGS" "$APP_SETTINGS.bak"
fi

# ✅ Create a new valid `appsettings.json`
cat <<EOF > "$APP_SETTINGS"
{
    "ModulesDirPath": "/data/modules",
    "DownloadedModulePackagesDirPath": "/data/downloads"
}
EOF
chmod 777 "$APP_SETTINGS"

echo "✅ Successfully replaced appsettings.json!"

# ✅ Create a symbolic link from `/app/modules` to `/data/modules` (Fix hardcoded paths)
ln -sfn /data/modules /app/modules
ln -sfn /data/downloads /app/downloads

# ✅ Start the AI Server with Correct Paths
cd /app/server || { echo "❌ ERROR: Failed to change to /app/server"; exit 1; }
exec dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
