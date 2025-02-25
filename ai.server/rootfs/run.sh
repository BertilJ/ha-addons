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

# ✅ Fix JSON Parsing Issue: Strip comments & control characters before modifying JSON
APP_SETTINGS="/app/server/appsettings.json"
TEMP_SETTINGS="${APP_SETTINGS}.new"

if [ -f "$APP_SETTINGS" ]; then
    echo "✅ Cleaning up appsettings.json..."
    
    # 🔥 Remove control characters, invalid JSON forma
