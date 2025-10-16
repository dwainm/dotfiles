#!/bin/bash

# Map window indices to Colemak home row keys
keys=("x" "a" "r" "s" "t" "d" "h" "n" "e" "i" "o")

# Get list of window indices and names
windows=$(tmux list-windows -F "#{window_index}:#{window_name}")

# Build hint message
hint=""
for entry in $windows; do
  win="${entry%%:*}"
  name="${entry#*:}"

  if [ "$win" -eq 0 ]; then
    hint+="[o]0:$name  "
  elif [ "$win" -le 9 ]; then
    hint+="[${keys[$win]}]$win:$name  "
  fi
done

tmux display-message "$hint"
