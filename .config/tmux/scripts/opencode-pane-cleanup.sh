#!/bin/bash
# Clean up stale window rename when opencode is gone.
# Called on after-select-pane.
PANE_ID="${1:-}"
[ -z "$PANE_ID" ] && exit 0

# If opencode is still running, nothing to do
PANE_TTY=$(tmux display-message -t "$PANE_ID" -p '#{pane_tty}' 2>/dev/null)
if [ -n "$PANE_TTY" ]; then
    if ps -t "$(basename "$PANE_TTY")" -o command= 2>/dev/null | grep -qw opencode; then
        exit 0
    fi
fi

WINDOW_ID=$(tmux display-message -t "$PANE_ID" -p '#{window_id}' 2>/dev/null)
[ -z "$WINDOW_ID" ] && exit 0

# Clear pane option
tmux set-option -pu -t "$PANE_ID" @opencode_status 2>/dev/null || true

# Strip any stale spinner/state prefix from window name
NAME=$(tmux display-message -p -t "$WINDOW_ID" '#W' 2>/dev/null)
if [[ "$NAME" =~ ^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏❓💤]\  ]]; then
    tmux rename-window -t "$WINDOW_ID" "${NAME:2}" 2>/dev/null || true
fi
