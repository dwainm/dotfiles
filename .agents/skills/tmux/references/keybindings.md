# Key Bindings

**Prefix**: `Ctrl-Space`

## Navigation (Alt-based, no prefix needed)

| Key | Action |
|-----|--------|
| `Alt-[` / `Alt-]` | Previous / Next window |
| `Alt--` / `Alt-\` | Split horizontal / vertical |
| `Alt-z` | Zoom pane |
| `Alt-c` | New window (current dir) |
| `Alt-x` | Kill window |
| `Alt-v` | Enter copy mode |
| `Alt-,` | Rename window |
| `Alt-s` | Session manager (fzf) |
| `Alt-t` | Quick session switch (fzf) |
| `M-<` / `M->` | Swap pane left / right |
| `M-?` | Show help popup |

## Prefix-based

| Key | Action |
|-----|--------|
| `prefix + r` | Reload config |
| `prefix + g` | Open lazygit popup |
| `prefix + t` | Quick session switch |
| `prefix + T` | Session manager menu |
| `prefix + w` | Window select (home row hints) |
| `prefix + s` | Session list (choose-tree) |
| `prefix + ?` | Show help popup |
| `prefix + v` | Enter copy mode |
| `prefix + z` / `Space` | Zoom pane |
| `prefix + c` | New window |
| `prefix + ,` / `$` | Rename window / session |
| `prefix + -` / `\` | Split horizontal / vertical |
| `prefix + [` / `]` | Previous / next window |
| `prefix + C-s` | Save session (resurrect) |
| `prefix + C-r` | Restore session (resurrect) |
| `prefix + p` | Toggle pomodoro |
| `prefix + M-1..7` | Layout presets |

## Pane navigation — integrated with Aerospace

- `prefix + h/j/k/l` → normal pane switching
- `prefix + C-h/j/k/l` → Aerospace window manager focus if at edge (copy-mode)
- `prefix + arrows` → directional pane select

## Prefix conflict

`prefix + C-Space` sends literal `Ctrl-Space` to the pane.
