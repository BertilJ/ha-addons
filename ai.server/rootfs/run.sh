#!/bin/bash
CONFIG_PATH=/data/options.json

# Load paths from options.json (or use default locations)
# export MODULES_PATH=$(jq --raw-output '.MODULES_PATH // "/app/modules"' $CONFIG_PATH)
# export DATA_DIR=$(jq --raw-output '.DATA_DIR // "/etc/codeproject/ai"' $CONFIG_PATH)

# Ensure Home Assistant storage exists
mkdir -p /share/ai-server/data
mkdir -p /share/ai-server/modules
mkdir -p /share/ai-server/downloads/modules/packages
mkdir -p /share/ai-server/opt


# Bind /etc/codeproject/ai to /share/ai-server/data (Already working)
if [ ! -L "/etc/codeproject/ai" ]; then
    rm -rf /etc/codeproject/ai
    ln -s /share/ai-server/data /etc/codeproject/ai
fi

# Bind /app/modules to /share/ai-server/modules (Primary Module Location)
if [ ! -L "/app/modules" ]; then
    rm -rf /app/modules
    ln -s /share/ai-server/modules /app/modules
fi

# Bind /app/modules to /share/ai-server/modules (Primary Module Location according to documentation)
if [ ! -L "/opt/codeproject/ai" ]; then
    rm -rf /opt/codeproject/ai
    ln -s /share/ai-server/opt /opt/codeproject/ai
fi

# Bind /app/downloads/modules/packages to /share/ai-server/downloads/modules/packages (Temporary Module Downloads)
if [ ! -L "/app/downloads/modules/packages" ]; then
    rm -rf /app/downloads/modules/packages
    ln -s /share/ai-server/downloads/modules/packages /app/downloads/modules/packages
fi


# Debug output to check if mapping works
# echo "DATA_DIR is mapped to: $DATA_DIR"
# echo "MODULES_PATH is mapped to: $MODULES_PATH"
# ls -la /etc/codeproject/ai
# ls -la /app/modules
# ls -la /app/downloads/modules/packages
# ls -la /share/ai-server
# ls -la /opt/codeproject/ai

# mkdir -p "$MODULES_PATH"
# mkdir -p "$DATA_DIR"

# Run the AI server with the correct application data directory
cd /app/server && dotnet ./CodeProject.AI.Server.dll --ApplicationDataDir="$DATA_DIR"
