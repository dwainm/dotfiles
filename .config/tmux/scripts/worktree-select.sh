#!/usr/bin/env bash
# List git worktrees with tmux window status, select to open/switch/create.

# Use pane's cwd from tmux, fall back to script cwd
cd "${1:-.}" || exit 1

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  tmux display-popup -E -h 6 -w 60 "echo 'Not in a git repo'; echo; echo '  $(pwd)'; echo; echo 'Press Enter to close...'; read"
  exit 0
}

EXISTING_WINDOWS=$(tmux list-windows -F "#{window_index}:#{window_name}:#{pane_current_path}" 2>/dev/null)

FZF_ACTIVE=""
FZF_PENDING=""

while IFS= read -r line; do
  if [[ "$line" =~ ^worktree\ (.*) ]]; then
    wt_path="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^branch\ (.*) ]]; then
    branch="${BASH_REMATCH[1]##refs/heads/}"
    win_info=$(echo "$EXISTING_WINDOWS" | grep -F ":${wt_path}" | head -1)
    if [[ -n "$win_info" ]]; then
      win_idx=$(echo "$win_info" | cut -d: -f1)
      win_name=$(echo "$win_info" | cut -d: -f2)
      FZF_ACTIVE+="$win_idx:$win_name"$'\t'"$branch"$'\t'"$wt_path"$'\n'
    else
      FZF_PENDING+="[attach]"$'\t'"$branch"$'\t'"$wt_path"$'\n'
    fi
  fi
done < <(git worktree list --porcelain 2>/dev/null)

FZF_INPUT="${FZF_ACTIVE}${FZF_PENDING}"
[[ -z "$FZF_INPUT" ]] && { tmux display-popup -E -h 6 -w 60 "echo 'No worktrees in this repo'; echo; echo 'Press Enter to close...'; read"; exit 0; }

SELECTION=$(echo "$FZF_INPUT" | fzf-tmux -p -w 70% -h 60% --layout=reverse \
  --prompt="Worktree > " \
  --delimiter=$'\t' \
  --with-nth=1,2 \
  --bind='q:abort,esc:abort') || true

[[ -z "$SELECTION" ]] && exit 0

WT_PATH=$(echo "$SELECTION" | cut -f3 | xargs)
WT_BRANCH=$(echo "$SELECTION" | cut -f2)

# Re-query windows to pick up any just-created ones
EXISTING=$(tmux list-windows -F "#{window_index}:#{pane_current_path}" 2>/dev/null | grep -F ":${WT_PATH}" | head -1 | cut -d: -f1)

if [[ -n "$EXISTING" ]]; then
  tmux select-window -t "$EXISTING"
else
  tmux new-window -c "$WT_PATH" -n "$WT_BRANCH"
fi
