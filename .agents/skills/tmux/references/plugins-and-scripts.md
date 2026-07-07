# TPM Plugins & Custom Scripts

## TPM Plugins

Managed via `~/.config/tmux/plugins/tpm/`:

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager |
| `tmux-plugins/tmux-sensible` | Sensible defaults |
| `tmux-plugins/tmux-resurrect` | Save/restore sessions |
| `tmux-plugins/tmux-continuum` | Auto-save every 15 min, auto-restore |
| `olimorris/tmux-pomodoro-plus` | Pomodoro timer in status |
| `samoshkin/tmux-fzf` | FZF-based session/window switching |
| `tmux-sessionx` | Session management |

**TPM Commands:**
```bash
prefix + I   # Install plugins
prefix + U   # Update plugins
prefix + M-u # Clean unused plugins
```

## Custom Scripts

| Script | Purpose |
|--------|---------|
| `scripts/window-select-hint.sh` | Colemak home-row hints for window selection |
| `scripts/worktree-select.sh` | FZF-pick git worktree, open/switch to window |
| `scripts/opencode-window-animator.sh` | Spinner animation on opencode agent windows |
| `scripts/opencode-pane-cleanup.sh` | Clean stale agent rename when opencode exits |
| `scripts/opencode-status-icon.sh` | Show ⚡/❓/💤 status in pane for opencode agent |

## Status Bar (Catppuccin Mocha)

- **Top position**, center-aligned
- **Left**: Session name + continuum status + pomodoro status
- **Right**: Active application + uptime
- **Windows**: Slanted style, number-right, shows `#W` with zoom indicator
- **Frequent modules**: session, application, uptime (others available: battery, cpu, load, gitmux, kube, weather, date_time, directory, host, user)
