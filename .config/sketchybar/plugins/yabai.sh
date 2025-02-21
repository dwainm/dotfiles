#!/bin/bash
LAYOUT=$(yabai -m query --spaces --space | jq -r '.type')

case $LAYOUT in
    "bsp")
        ICON="󰕰"  # Grid/tiling layout icon
        ;;
    "float")
        ICON="󰖾"  # Floating windows icon
        ;;
    "stack")
        ICON=""  # Stacked windows icon
        ;;
    *)
        ICON="󰄽"  # Generic screen/window icon
        ;;
esac

sketchybar --set yabai_layout label="$LAYOUT" icon="$ICON"
