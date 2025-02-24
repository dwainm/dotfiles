#!/bin/bash

# Get the focused window's properties
WINDOW_INFO=$(yabai -m query --windows --window)
SPACE_INFO=$(yabai -m query --spaces --space)

# Get the layout type
LAYOUT=$(echo "$SPACE_INFO" | jq -r '.type')

# First determine the layout icon
case $LAYOUT in
    "bsp")
        ICON="󰕰"  # Grid/tiling layout icon
        ;;
    "float")
        ICON="󰖾"  # Floating windows icon
        ;;
    "stack")
        ICON=""  # Stacked windows icon
        ;;
    *)
        ICON="󰄽"  # Generic screen/window icon
        ;;
esac

# Check if window exists and get zoom state
if [[ ! -z "$WINDOW_INFO" ]]; then
    HAS_FULLSCREEN_ZOOM=$(echo "$WINDOW_INFO" | jq '.["has-fullscreen-zoom"]')
    IS_NATIVE_FULLSCREEN=$(echo "$WINDOW_INFO" | jq '.["is-native-fullscreen"]')

    # If zoomed or in native fullscreen, override the icon and add text
    if [[ "$HAS_FULLSCREEN_ZOOM" == "true" ]] || [[ "$IS_NATIVE_FULLSCREEN" == "true" ]]; then
        ICON="󰍉"  # Magnifying glass icon
        sketchybar --set yabai_layout label="zoomed" icon="$ICON"
        exit 0
    fi
fi

# If not zoomed, show regular layout
sketchybar --set yabai_layout label="$LAYOUT" icon="$ICON"
