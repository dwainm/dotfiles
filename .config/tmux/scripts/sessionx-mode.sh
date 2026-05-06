#!/usr/bin/env bash
MODE="${1:-session}"
SESSIONX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tmux-sessionx"

if [ "$MODE" = "window" ]; then
  tmux set-option -g @sessionx-window-mode on
fi

"$SESSIONX_DIR/scripts/sessionx.sh"

if [ "$MODE" = "window" ]; then
  tmux set-option -g @sessionx-window-mode off
fi
