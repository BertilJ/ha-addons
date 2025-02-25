#!/bin/bash
set -e

echo "Starting Code Project AI add-on..."

# Ensure necessary directories exist
mkdir -p /data/models
mkdir -p /data/config
mkdir -p /data/logs

# Link persistent storage locations
ln -sfn /data/models /app/modules
ln -sfn /data/config /app/config
ln -sfn /data/logs /app/logs

# Start the AI Server
cd /app
exec dotnet ./CodeProject.AI-Server.dll
