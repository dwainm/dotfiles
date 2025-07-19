#!/bin/bash

# Kanata service management script
# Usage: ./kanata.sh [start|stop|status]

PLIST_PATH="/Library/LaunchDaemons/com.kanata.plist"
SERVICE_NAME="system/com.kanata"
CONFIG_PLIST="/Users/dwain/.config/kanata/com.kanata.plist"

case "$1" in
    start)
        echo "Enabling Kanata service..."
        sudo cp "$CONFIG_PLIST" "$PLIST_PATH"
        sudo chown root:wheel "$PLIST_PATH" 
        sudo chmod 644 "$PLIST_PATH"
        sudo launchctl enable "$SERVICE_NAME"
        sudo launchctl bootstrap system "$PLIST_PATH"
        echo "Kanata started"
        ;;
    
    stop)
        echo "Stopping Kanata service..."
        sudo launchctl bootout "$SERVICE_NAME" 2>/dev/null || true
        sudo launchctl disable "$SERVICE_NAME" 2>/dev/null || true
        sudo rm -f "$PLIST_PATH"
        echo "Kanata stopped"
        ;;
    
    status)
        echo "Checking Kanata status..."
        if sudo launchctl list | grep -q "com.kanata"; then
            echo "✓ Kanata service is running"
            ps aux | grep kanata | grep -v grep | grep -v kanata.sh || echo "No kanata processes found"
        else
            echo "✗ Kanata service is not running"
        fi
        ;;
    
    *)
        echo "Usage: $0 {start|stop|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Install and start Kanata service"
        echo "  stop    - Stop and remove Kanata service"  
        echo "  status  - Check if Kanata is running"
        exit 1
        ;;
esac