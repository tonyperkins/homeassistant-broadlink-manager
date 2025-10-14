#!/bin/bash
set -e

# ==============================================================================
# Home Assistant Add-on: Broadlink Manager
# Runs the Broadlink Manager application
# ==============================================================================

CONFIG_PATH=/data/options.json

echo "[INFO] Starting Broadlink Manager..."

# Set SUPERVISOR_TOKEN if not already set (Home Assistant provides this)
if [ -z "$SUPERVISOR_TOKEN" ]; then
    # Try to read from the standard location
    if [ -f /run/secrets/supervisor_token ]; then
        export SUPERVISOR_TOKEN=$(cat /run/secrets/supervisor_token)
        echo "[INFO] Loaded SUPERVISOR_TOKEN from /run/secrets/supervisor_token"
    elif [ -f /var/run/secrets/supervisor_token ]; then
        export SUPERVISOR_TOKEN=$(cat /var/run/secrets/supervisor_token)
        echo "[INFO] Loaded SUPERVISOR_TOKEN from /var/run/secrets/supervisor_token"
    else
        echo "[WARNING] SUPERVISOR_TOKEN not found - will run in standalone mode"
    fi
else
    echo "[INFO] Running in Supervisor mode (SUPERVISOR_TOKEN found)"
fi

# Get configuration options from Home Assistant
LOG_LEVEL=$(jq --raw-output '.log_level // "info"' $CONFIG_PATH)
WEB_PORT=$(jq --raw-output '.web_port // "8099"' $CONFIG_PATH)
AUTO_DISCOVER=$(jq --raw-output '.auto_discover // "true"' $CONFIG_PATH)

# Set log level
echo "[INFO] Setting log level to: ${LOG_LEVEL}"
export LOG_LEVEL

# Set configuration environment variables
export WEB_PORT
export AUTO_DISCOVER

# Print configuration
echo "[INFO] Configuration:"
echo "[INFO] - Log Level: ${LOG_LEVEL}"
echo "[INFO] - Web Port: ${WEB_PORT}"
echo "[INFO] - Auto Discover: ${AUTO_DISCOVER}"

# Start the application
echo "[INFO] Starting Broadlink Manager application..."
cd /app || { echo "[ERROR] Cannot change to application directory"; exit 1; }

# Run the main application
exec python3 main.py
