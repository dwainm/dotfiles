---
name: tmux
description: Tmux terminal multiplexer - Catppuccin theme, TPM plugins, custom scripts, session/worktree management, and key bindings
metadata:
  tags: tmux, terminal, multiplexer, catppuccin, tpm, plugins, session-management
---

## When to use

Use this skill for:
- Tmux configuration, key bindings, and plugin management
- Session, window, pane operations (create, navigate, resize, kill)
- Tmux-resurrect/continuum save/restore workflow
- Custom scripts (worktree-select, window-select-hint, opencode integration)
- Catppuccin theme and status bar customization

## How to use

This skill is organized into reference files by topic:

- [references/keybindings.md](references/keybindings.md) - Full prefix and Alt-based key binding tables
- [references/plugins-and-scripts.md](references/plugins-and-scripts.md) - TPM plugin list, custom scripts, status bar config

Read only the reference file relevant to your current task.

---

## Quick Reference

### Configuration Files

| File | Purpose |
|------|---------|
| `~/.config/tmux/tmux.conf` | Main config (symlinked by yadm) |
| `~/.config/tmux/tmux.conf##os.Darwin` | macOS-specific overrides |
| `~/.config/tmux/tmux.conf##os.Linux` | Linux-specific overrides |
| `~/.config/tmux/scripts/*.sh` | Custom scripts |

**Prefix**: `Ctrl-Space` — see [references/keybindings.md](references/keybindings.md) for the full table.

### Common Operations

```bash
# Reload config
tmux source-file ~/.config/tmux/tmux.conf

# Split panes
prefix + -      # horizontal split (current dir)
prefix + \      # vertical split (current dir)
Alt--           # horizontal split (root key)
Alt-\           # vertical split (root key)

# Session management
tmux new-session -s name
tmux switch-client -t name
tmux kill-session -t name

# Window management
tmux new-window -c "#{pane_current_path}"
tmux rename-window -t <id> "new-name"
tmux kill-window -t <id>

# Save/Restore (resurrect)
prefix + C-s   # Save
prefix + C-r   # Restore

# Pomodoro
prefix + p     # Toggle
prefix + P     # Cancel
prefix + _     # Skip
prefix + C-p   # Menu
prefix + e     # Restart
```

### Best Practices

1. **Save often** — continuum auto-saves every 15 min; manual `prefix + C-s` before risky ops
2. **OS-specific configs** — yadm symlinks the correct `tmux.conf##os.<OS>` per machine
3. **TPM after clone** — run `prefix + I` on new machine to install plugins
4. **Worktree workflow** — use `Alt-w` or `prefix + w` for `worktree-select.sh` to jump between git worktrees
5. **Prefix conflict** — `prefix + C-Space` sends literal `Ctrl-Space` to the pane
