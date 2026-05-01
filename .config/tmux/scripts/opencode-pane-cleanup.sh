#!/bin/bash
# Clear @opencode_status if opencode is no longer running in the pane.
# Called on pane-focus-in / after-select-window.
PANE_ID="$1"
[ -z "$PANE_ID" ] && exit 0

STATUS=$(tmux show-option -pqv -t "$PANE_ID" @opencode_status 2>/dev/null)
[ -z "$STATUS" ] && exit 0

PANE_TTY=$(tmux display-message -t "$PANE_ID" -p '#{pane_tty}' 2>/dev/null)
[ -z "$PANE_TTY" ] && exit 0

if ! ps -t "$(basename "$PANE_TTY")" -o command= 2>/dev/null | grep -qw opencode; then
  tmux set-option -pu -t "$PANE_ID" @opencode_status 2>/dev/null
fi
