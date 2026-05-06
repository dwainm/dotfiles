#!/usr/bin/env bash
direction="${1:?usage: < -1 | +1 >}"

cur=$(tmux display -p '#{window_index}')
target=$((cur + direction))

# boundary — can't go past first or last window index
indices=$(tmux list-windows -F '#{window_index}')
first=$(echo "$indices" | sort -n | head -1)
last=$(echo "$indices" | sort -n | tail -1)

if [ "$target" -lt "$first" ] || [ "$target" -gt "$last" ]; then
    exit 0
fi

if echo "$indices" | grep -qx "^${target}\$"; then
    tmux move-window -d -s ":$target" -t :999
    tmux move-window -t ":$target"
    tmux move-window -d -s :999 -t ":$cur"
else
    tmux move-window -t ":$target"
fi
