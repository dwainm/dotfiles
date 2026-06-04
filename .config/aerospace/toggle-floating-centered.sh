#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(dirname "$0")"
BLUR_OVERLAY="$SCRIPT_DIR/blur-overlay"
BLUR_SOURCE="$SCRIPT_DIR/blur-overlay.swift"
STATE_FILE="/tmp/floating-window-state"

# Compile blur-overlay if missing or outdated
if [[ ! -x "$BLUR_OVERLAY" ]] || [[ "$BLUR_SOURCE" -nt "$BLUR_OVERLAY" ]]; then
  echo "Compiling blur-overlay..." >&2
  swiftc "$BLUR_SOURCE" -o "$BLUR_OVERLAY" 2>/dev/null || true
fi

BOUNDS=$(osascript -e 'tell application "Finder" to return bounds of window of desktop')
MONITOR_W=$(echo "$BOUNDS" | awk -F', ' '{print $3}')
MONITOR_H=$(echo "$BOUNDS" | awk -F', ' '{print $4}')

if [ "$MONITOR_W" -gt 2560 ]; then
  PCT=50
elif [ "$MONITOR_W" -gt 1920 ]; then
  PCT=60
else
  PCT=92
fi

W=$((MONITOR_W * PCT / 100))
H=$((MONITOR_H))
X=$(( (MONITOR_W - W) / 2 ))
Y=0

if aerospace layout floating; then
  # Save current app before any focus changes
  CURRENT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
  
  # Save current window position/size before centering
  osascript -e "
    tell application \"System Events\"
      tell process \"$CURRENT_APP\"
        set _window to front window
        set {x, y} to position of _window
        set {w, h} to size of _window
        return (x as text) & \"|\" & (y as text) & \"|\" & (w as text) & \"|\" & (h as text)
      end tell
    end tell" > "$STATE_FILE"
  echo "|$CURRENT_APP" >> "$STATE_FILE"
  
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
  
  # Restore original window position/size if state exists
  if [[ -f "$STATE_FILE" ]]; then
    STATE=$(cat "$STATE_FILE" | tr '\n' ' ')
    SAVED_X=$(echo "$STATE" | cut -d'|' -f1)
    SAVED_Y=$(echo "$STATE" | cut -d'|' -f2)
    SAVED_W=$(echo "$STATE" | cut -d'|' -f3)
    SAVED_H=$(echo "$STATE" | cut -d'|' -f4)
    SAVED_APP=$(echo "$STATE" | cut -d'|' -f5 | xargs)
    
    if [[ -n "$SAVED_APP" ]]; then
      osascript -e "
        tell application \"System Events\"
          tell process \"$SAVED_APP\"
            set _window to front window
            set position of _window to {$SAVED_X, $SAVED_Y}
            set size of _window to {$SAVED_W, $SAVED_H}
          end tell
        end tell" 2>/dev/null || true
    fi
    rm -f "$STATE_FILE"
  fi
fi
