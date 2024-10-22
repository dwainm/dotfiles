#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting
sketchybar --set "$NAME" label="$(gcalcli agenda --nocolor --nostarted --details title | head -2  | tail -1 | gsed -e 's/^\w*\s\w*\s\w*.*[0-9]\s*//')"
