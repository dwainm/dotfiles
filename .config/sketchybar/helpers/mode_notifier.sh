#!/bin/bash

# Helper script to notify sketchybar of mode changes
# Usage: mode_notifier.sh MODE_NAME

MODE=${1:-"NORMAL"}
sketchybar --trigger mode_change MODE="$MODE" &