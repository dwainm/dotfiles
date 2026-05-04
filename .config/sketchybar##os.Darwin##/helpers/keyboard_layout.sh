#!/bin/bash

# Path to the input source switcher binary
SWITCHER="$HOME/.local/bin/switch-input-source"

# Get current keyboard layout
get_current_layout() {
  defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | \
    grep "KeyboardLayout Name" | \
    head -1 | \
    tr -d '[:space:]' | \
    sed 's/"KeyboardLayoutName"=\(.*\);/\1/'
}

# Switch to next keyboard layout using native binary
switch_layout() {
  if [ -x "$SWITCHER" ]; then
    "$SWITCHER"
    # Trigger sketchybar update immediately after switching
    sketchybar --trigger routine
  else
    echo "Error: switch-input-source binary not found at $SWITCHER" >&2
    exit 1
  fi
}

# Main
case "${1:-}" in
  get)
    get_current_layout
    ;;
  switch)
    switch_layout
    ;;
  *)
    echo "Usage: $0 {get|switch}"
    exit 1
    ;;
esac
