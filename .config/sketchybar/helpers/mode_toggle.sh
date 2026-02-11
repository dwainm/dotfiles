#!/bin/bash

# Toggle between SERVICE and NORMAL modes
# Usage: mode_toggle.sh

STATE_FILE="/tmp/sketchybar_mode_state"

if [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "SERVICE" ]]; then
  echo "NORMAL" > "$STATE_FILE"
  sketchybar --trigger mode_change MODE="NORMAL" &
else
  echo "SERVICE" > "$STATE_FILE"
  sketchybar --trigger mode_change MODE="SERVICE" &
fi
