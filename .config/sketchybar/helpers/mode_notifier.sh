#!/bin/bash

# Helper script to notify sketchybar of mode changes
# Usage: mode_notifier.sh MODE_NAME

MODE=${1:-"NORMAL"}

# Auto-sync kanata insert layer with skhd writing mode using TCP
if [ "$MODE" = "INSERT" ]; then
  echo "[$(date)] mode_notifier: Entering INSERT mode, sending layer-switch via TCP" >> /tmp/mode_notifier.log
  (printf '{"ChangeLayer":{"new":"insert"}}\n' | nc localhost 6677 >/dev/null 2>&1 &)
  echo "[$(date)] mode_notifier: Layer switch command sent" >> /tmp/mode_notifier.log
else
  # Explicitly switch back to base layer when exiting writing mode
  echo "[$(date)] mode_notifier: Exiting INSERT mode (mode=$MODE), switching to base layer" >> /tmp/mode_notifier.log
  (printf '{"ChangeLayer":{"new":"base"}}\n' | nc localhost 6677 >/dev/null 2>&1 &)
  echo "[$(date)] mode_notifier: Base layer command sent" >> /tmp/mode_notifier.log
fi

sketchybar --trigger mode_change MODE="$MODE" &