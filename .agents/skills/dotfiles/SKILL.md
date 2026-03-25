---
name: dotfiles
description: Dotfile and config management using yadm - track, sync, and deploy configuration across machines
metadata:
  tags: dotfiles, config, yadm, dotfiles, configuration, symlink, backup
triggers:
  - "dotfiles"
  - "config"
  - ".zshrc"
  - ".tmux.conf"
  - "my config"
  - "track this file"
---

## When to use

Use this skill whenever dealing with:
- Dotfiles management (`.zshrc`, `.tmux.conf`, `.vimrc`, etc.)
- Config file changes or tracking
- Syncing configuration across machines
- Setting up new machine from dotfiles
- Any mention of "dotfiles" or "my config"

## How yadm works

yadm is a git-based dotfile manager that:
- Stores dotfiles in `~/.local/share/yadm/repo.git/`
- Creates symlinks from home directory to tracked files
- Works like git but for dotfiles

## Commands

### Check status
```bash
yadm status
# or use alias:
ystat
```

### Add files to tracking
```bash
yadm add ~/.zshrc ~/.tmux.conf
yadd ~/.zshrc
```

### Commit changes
```bash
yadm commit -m "description of changes"
ycom "updated tmux keybindings"
```

### Push to remote
```bash
yadm push
ypush
```

### Pull from remote
```bash
yadm pull
ypull
```

### Clone on new machine
```bash
yadm clone <repo-url>
```

## Tracked files

Dwain's current dotfiles:
- `~/.zshrc` - Shell configuration
- `~/.tmux.conf` - Tmux configuration
- `~/bin/gwt` - Git worktree helper
- `~/.pi/agent/settings.json` - Pi settings
- `~/.pi/agent/extensions/harness-review.ts` - Pi extension

## Best practices

1. **Always commit** after making config changes
2. **Push** after commits to sync to remote
3. **Pull** before making changes on a new machine
4. **Use aliases**: ystat, yadd, ycom, ypush, ypull

## Example workflow

```
# Made changes to .zshrc?
yadd ~/.zshrc
ycom "add new alias for git"
ypush

# New machine setup?
yadm clone git@github.com:user/dotfiles.git
```

## Troubleshooting

- Files show as `120000` mode = symlink (correct!)
- `yadm status` shows "No commits yet" = needs first commit
- Symlinks broken = re-run `yadm checkout <file>`