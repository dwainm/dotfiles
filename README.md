# dotfiles

Managed with [yadm](https://yadm.io/). No symlinks, no Stow — yadm tracks dotfiles directly in `$HOME` using a bare git repo.

## Installation

```bash
# Install yadm
sudo pacman -S yadm   # Arch
brew install yadm     # macOS

# Clone dotfiles
yadm clone git@github.com:dwainm/dotfiles.git

# If local files differ from the repo, overwrite them:
yadm checkout --force
```

## Managing dotfiles

Edit files directly in `~` — they are the real tracked files, not symlinks.

```bash
yadm status         # See changes
yadm add <file>     # Stage files
yadm commit -m ".." # Commit
yadm push           # Push to remote
yadm pull           # Pull latest
```

## OS-specific files

Yadm uses **alternates** — files with `##os.Darwin##` or `##os.Linux##` suffixes. On checkout, yadm detects your OS and deploys the matching version.

| macOS-only | Linux-only | Cross-platform |
|---|---|---|
| `aerospace` | `hypr` | `git`, `gh`, `nvim` |
| `sketchybar` | `waybar` | `tmux`, `kitty` |
| `skhd` | `walker` | `zshrc`, `vimrc` |
| `karabiner` | `mako` | `mise`, `bin` |
| `kanata` | `omarchy` | |

## Git data location

`~/.local/share/yadm/repo.git` (XDG_DATA_HOME compliant).

## Setup notes

### macOS
- Set capslock to control in System Preferences > Keyboard > Modifier Keys
- Turn off input source shortcuts: Keyboard > Shortcuts > Input Sources
- Enable tap-to-click in Trackpad settings
- Spaces: enable Ctrl-[1-9] for switching, disable auto-rearrange, turn off reduce motion

### Terminal
- Set ZSH as your shell: `chsh -s $(which zsh)`
- Prezto: `git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}"/.zprezto`
- Generate prezto runcoms, then restore your zshrc: `yadm checkout -- .zprezto/runcoms/zshrc`

### tmux plugins
```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```
Then in tmux: `<prefix> + I` to install plugins.

### Mise
https://mise.jdx.dev
