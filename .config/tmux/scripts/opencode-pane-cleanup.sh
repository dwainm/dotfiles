#!/bin/bash
# Restore original window name if opencode is no longer running in the pane.
# Called on after-select-pane.
PANE_ID="${1:-}"
[ -z "$PANE_ID" ] && exit 0

# Check if opencode is still running on this pane's TTY
PANE_TTY=$(tmux display-message -t "$PANE_ID" -p '#{pane_tty}' 2>/dev/null)
if [ -n "$PANE_TTY" ]; then
    if ps -t "$(basename "$PANE_TTY")" -o command= 2>/dev/null | grep -qw opencode; then
        exit 0
    fi
fi

# Opencode is gone. Clean up pane option and window name.
WINDOW_ID=$(tmux display-message -t "$PANE_ID" -p '#{window_id}' 2>/dev/null)
[ -z "$WINDOW_ID" ] && exit 0

# Clear old @opencode_status if still present (migration cleanup)
tmux set-option -pu -t "$PANE_ID" @opencode_status 2>/dev/null || true

# Restore original window name if we modified it
ORIG_KEY="TMUX_AGENT_ORIG_NAME_${WINDOW_ID}"
ANIM_KEY="TMUX_AGENT_ANIM_${WINDOW_ID}_PID"

orig=$(tmux show-environment -g "$ORIG_KEY" 2>/dev/null | sed 's/^[^=]*=//' || true)
if [ -n "$orig" ]; then
    tmux rename-window -t "$WINDOW_ID" "$orig" 2>/dev/null || true
    tmux set-environment -gu "$ORIG_KEY" 2>/dev/null || true
fi

# Kill any lingering animator
anim_pid=$(tmux show-environment -g "$ANIM_KEY" 2>/dev/null | sed 's/^[^=]*=//' || true)
if [ -n "$anim_pid" ] && kill -0 "$anim_pid" 2>/dev/null; then
    kill "$anim_pid" 2>/dev/null || true
fi
tmux set-environment -gu "$ANIM_KEY" 2>/dev/null || true
