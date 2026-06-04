#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

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

aerospace layout floating && osascript -e "
  tell application \"System Events\"
    set _app to name of first application process whose frontmost is true
    tell process _app
      set _window to front window
      set position of _window to {$X, $Y}
      set size of _window to {$W, $H}
      activate
    end tell
  end tell" || aerospace layout tiling
