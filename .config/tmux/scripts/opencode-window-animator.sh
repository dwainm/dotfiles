#!/usr/bin/env bash
# Window name animator for opencode running state.
# Usage: opencode-window-animator.sh <window_id> <session_name>
set -euo pipefail

WINDOW_ID="${1:-}"
SESSION="${2:-}"
[ -z "$WINDOW_ID" ] || [ -z "$SESSION" ] && exit 1

INDEX=$(tmux display-message -p -t "$WINDOW_ID" '#I' 2>/dev/null || echo "0")
NAMEFILE="${TMPDIR:-/tmp}/opencode-orig-WIN${INDEX}.txt"

cleanup() { rm -f "$NAMEFILE" 2>/dev/null || true; }
trap cleanup EXIT

command -v tmux >/dev/null 2>&1 || exit 0
tmux list-sessions >/dev/null 2>&1 || exit 0

FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
IDX=0

any_running() {
    while IFS= read -r pid; do
        [ -z "$pid" ] && continue
        s=$(tmux show-option -pqv -t "$pid" @opencode_status 2>/dev/null || true)
        [ "$s" = "running" ] && return 0
    done < <(tmux list-panes -t "$WINDOW_ID" -F '#{pane_id}' 2>/dev/null || true)
    return 1
}

window_exists() {
    tmux list-windows -t "$SESSION" -F '#{window_id}' 2>/dev/null | grep -qx "$WINDOW_ID"
}

while true; do
    tmux list-sessions >/dev/null 2>&1 || break
    window_exists || break

    if ! any_running; then
        [ -f "$NAMEFILE" ] && tmux rename-window -t "$WINDOW_ID" "$(cat "$NAMEFILE")" 2>/dev/null || true
        break
    fi

    if [ ! -f "$NAMEFILE" ]; then
        name=$(tmux display-message -p -t "$WINDOW_ID" '#W' 2>/dev/null || true)
        [[ "$name" =~ ^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]\  ]] && name="${name:2}"
        [[ "$name" =~ ^(💻|❓|💤)\  ]] && name="${name:2}"
        echo "$name" > "$NAMEFILE"
    fi

    saved=$(cat "$NAMEFILE")
    tmux rename-window -t "$WINDOW_ID" "${FRAMES[$IDX]} ${saved}" 2>/dev/null || true
    IDX=$(( (IDX + 1) % ${#FRAMES[@]} ))
    sleep 0.120 2>/dev/null || sleep 1
done
