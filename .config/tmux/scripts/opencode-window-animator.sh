#!/usr/bin/env bash
# Window name animator for opencode running state.
# Cycles a braille spinner while any pane in the window is in "running" state.
# Restores the original window name when no running panes remain or window is closed.
#
# Usage: opencode-window-animator.sh <window_id> <session_name>

set -euo pipefail

WINDOW_ID="${1:-}"
SESSION="${2:-}"

if [ -z "$WINDOW_ID" ] || [ -z "$SESSION" ]; then
    echo "Usage: $0 <window_id> <session_name>" >&2
    exit 1
fi

ANIM_KEY="TMUX_AGENT_ANIM_${WINDOW_ID}_PID"
ORIG_KEY="TMUX_AGENT_ORIG_NAME_${WINDOW_ID}"

# Cleanup on exit: kill tracking env vars, restore original name if still running
cleanup() {
    tmux set-environment -gu "$ANIM_KEY" 2>/dev/null || true
    tmux set-environment -gu "$ORIG_KEY" 2>/dev/null || true
}
trap cleanup EXIT

# Self-terminate if tmux server is gone
if ! command -v tmux >/dev/null 2>&1; then
    exit 0
fi
if ! tmux list-sessions >/dev/null 2>&1; then
    exit 0
fi

# Store our PID
tmux set-environment -g "$ANIM_KEY" "$$"

# Braille spinner frames (10 frames, smooth loop)
FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
FRAME_COUNT=${#FRAMES[@]}
IDX=0

# Sleep interval in seconds (120ms)
SLEEP="0.120"

# Check if any pane in this window has opencode running state
any_pane_running() {
    local pane_id state
    while IFS= read -r pane_id; do
        [ -z "$pane_id" ] && continue
        state=$(tmux show-environment -g "TMUX_AGENT_PANE_${pane_id}_STATE" 2>/dev/null | sed 's/^[^=]*=//' || true)
        if [ "$state" = "running" ]; then
            return 0
        fi
    done < <(tmux list-panes -t "$WINDOW_ID" -F '#{pane_id}' 2>/dev/null || true)
    return 1
}

# Check if window still exists
window_exists() {
    tmux list-windows -t "$SESSION" -F '#{window_id}' 2>/dev/null | grep -qx "$WINDOW_ID"
}

# Get current window name
current_window_name() {
    tmux display-message -p -t "$WINDOW_ID" '#{window_name}' 2>/dev/null || true
}

# Get original saved name
get_original_name() {
    tmux show-environment -g "$ORIG_KEY" 2>/dev/null | sed 's/^[^=]*=//' || true
}

while true; do
    # Self-terminate if tmux server gone
    if ! tmux list-sessions >/dev/null 2>&1; then
        break
    fi

    # Self-terminate if window closed
    if ! window_exists; then
        break
    fi

    # Self-terminate if no running panes in this window
    if ! any_pane_running; then
        # Restore original name before exiting
        orig=$(get_original_name)
        if [ -n "$orig" ]; then
            tmux rename-window -t "$WINDOW_ID" "$orig" 2>/dev/null || true
        fi
        break
    fi

    # Get original name if not yet saved
    saved_name=$(get_original_name)
    if [ -z "$saved_name" ]; then
        cur_name=$(current_window_name)
        # If current name already has spinner prefix, strip it to avoid nesting
        if [[ "$cur_name" =~ ^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]\  ]]; then
            cur_name="${cur_name:2}"
        elif [[ "$cur_name" =~ ^(💻|❓|💤)\  ]]; then
            cur_name="${cur_name:2}"
        fi
        tmux set-environment -g "$ORIG_KEY" "$cur_name"
        saved_name="$cur_name"
    fi

    # Rename window with current spinner frame
    frame="${FRAMES[$IDX]}"
    tmux rename-window -t "$WINDOW_ID" "${frame} ${saved_name}" 2>/dev/null || true

    IDX=$(( (IDX + 1) % FRAME_COUNT ))
    sleep "$SLEEP" 2>/dev/null || sleep 1
done
