# Brew

install brew first

brew install git 
sudo mv /usr/bin/git /usr/bin/git-apple

brew install zsh vim tmux reattach-to-user-namespace fzf ctags

# dotfiles
How to use

Clone into $HOME/dotfiles
Mv all from dotfiles to $HOME
Rename .git to .myconf

Add aliases
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias gcf='git config --list'

now you can manage your dotfiles with config(git alias) command.

# Terminal
chsh -s $(which zsh)
Setup afterGlow: https://github.com/lysyi3m/osx-terminal-themes/blob/master/schemes/Afterglow.terminal ( downlaod the file and right click open )
Set it as defaut.
Also set path to $(which zsh) as terminal start.

# Vim 
Open vim and run :PlugInstall
create symlink to vim wiki icloud storage: ln -s /Users/dwain/Documents/vimwiki /Users/dwain/vimwiki

