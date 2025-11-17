#!/bin/bash

# Helper script to notify sketchybar of mode changes
# Usage: mode_notifier.sh MODE_NAME

MODE=${1:-"NORMAL"}

# Note: F14 auto-trigger removed - manually press F14 to enter Kanata insert mode if needed
# Escape/Caps will exit both skhd writing mode and Kanata insert mode

sketchybar --trigger mode_change MODE="$MODE" &