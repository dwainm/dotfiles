#!/bin/bash

# Toggle between SERVICE and NORMAL modes
# Usage: mode_toggle.sh

# Check current mode (we'll use a simple file to track state)
STATE_FILE="/tmp/sketchybar_mode_state"

if [[ -f "$STATE_FILE" && "$(cat "$STATE_FILE")" == "SERVICE" ]]; then
    # Currently in SERVICE mode, switch to NORMAL
    echo "NORMAL" > "$STATE_FILE"
    sketchybar --trigger mode_change MODE="NORMAL" &
else
    # Currently in NORMAL mode, switch to SERVICE
    echo "SERVICE" > "$STATE_FILE"
    sketchybar --trigger mode_change MODE="SERVICE" &
fi