#!/bin/bash

# Notify sketchybar of mode changes and sync kanata layer
# Usage: mode_notifier.sh MODE_NAME

MODE=${1:-"NORMAL"}

# Sync kanata layer with mode (INSERT uses insert layer, all others use base)
if [ "$MODE" = "INSERT" ]; then
  printf '{"ChangeLayer":{"new":"insert"}}\n' | nc -w1 localhost 6677 2>/dev/null &
else
  printf '{"ChangeLayer":{"new":"base"}}\n' | nc -w1 localhost 6677 2>/dev/null &
fi

sketchybar --trigger mode_change MODE="$MODE" &
