# Dwain's Dotfile Context

## Environment
- macOS (Apple Silicon)
- Colemak keyboard layout
- Keyboard-driven workflow (minimal mouse)

## Core Stack
- **Editor**: Neovim (LazyVim) - vi bindings everywhere
- **Terminal**: Kitty + tmux (auto-starts)
- **Shell**: Zsh with Starship prompt
- **Theme**: Catppuccin Mocha (consistent across tools)

## Window Management & Bar
- Aerospace (tiling WM)
- SketchyBar (status bar)
- skhd (hotkeys)
- Kanata (keyboard remapping for Colemak)

## Development
- Ruby on Rails
- Node (fnm), Go, PHP, Lua
- mise for runtime management

## Key Paths
- Dotfiles: `~/.myconf/` (bare git repo)
- Projects: `~/projects/`

## Dotfile Management
- Use the `config` alias instead of `git` for dotfile operations
- Example: `config add`, `config commit`, `config push`
- Do NOT add Claude co-author attribution to commits

## Config Locations
- nvim: `~/.config/nvim/`
- kitty: `~/.config/kitty/kitty.conf`
- aerospace: `~/.config/aerospace/aerospace.toml`
- sketchybar: `~/.config/sketchybar/`
- skhd: `~/.config/skhd/skhdrc`
- kanata: `~/.config/kanata/kanata.kbd`
- starship: `~/.config/starship.toml`

## Preferences
- Nerd Fonts (JetBrains Mono, Hack)
- Git worktrees over branches
- zoxide for navigation, fzf for fuzzy finding
