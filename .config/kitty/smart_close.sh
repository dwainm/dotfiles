#!/bin/bash
# Smart close: kill tmux pane if in tmux, else close kitty

if [ -n "$TMUX" ]; then
    # We're in tmux, kill the current pane
    # If it's the last pane, the window closes
    # If it's the last window, tmux exits and kitty will close
    tmux kill-pane
else
    # Not in tmux, close kitty window
    kitty @ --to unix:/tmp/mykitty-fixed close-window --self
fi
