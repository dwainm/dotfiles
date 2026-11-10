#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(dirname "$0")"
BLUR_OVERLAY="$SCRIPT_DIR/blur-overlay"
BLUR_SOURCE="$SCRIPT_DIR/blur-overlay.swift"

# Compile blur-overlay if missing or outdated
if [[ ! -x "$BLUR_OVERLAY" ]] || [[ "$BLUR_SOURCE" -nt "$BLUR_OVERLAY" ]]; then
  echo "Compiling blur-overlay..." >&2
  swiftc "$BLUR_SOURCE" -o "$BLUR_OVERLAY" 2>/dev/null || true
fi

# Frame of the screen holding the focused window (not the union of all screens)
read -r MONITOR_X MONITOR_Y MONITOR_W MONITOR_H < <("$BLUR_OVERLAY" screen)

if [ "$MONITOR_W" -gt 2560 ]; then
  PCT=50
elif [ "$MONITOR_W" -gt 1920 ]; then
  PCT=60
else
  PCT=92
fi

W=$((MONITOR_W * PCT / 100))
H=$((MONITOR_H))
X=$(( MONITOR_X + (MONITOR_W - W) / 2 ))
Y=$MONITOR_Y

if aerospace layout floating; then
  # Save current app before any focus changes
  CURRENT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
  
  # Center window
  osascript -e "
    tell application \"System Events\"
      tell process \"$CURRENT_APP\"
        set _window to front window
        set position of _window to {$X, $Y}
        set size of _window to {$W, $H}
      end tell
    end tell"
  
  # Start blur in background
  "$BLUR_OVERLAY" on --material 2 --dim 50 &
  
  # Small delay then restore focus
  sleep 0.1
  osascript -e "tell application \"$CURRENT_APP\" to activate"
else
  # Already floating - tile and disable blur
  aerospace layout tiling
  "$BLUR_OVERLAY" off
fi
