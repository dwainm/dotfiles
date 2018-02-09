# dotfiles
How to use

Clone into $HOME/dotfiles
Mv all from dotfiles to $HOME
Rename .git to .myconf

Add aliases
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias gcf='git config --list'

now you can manage your dotfiles with config(git alias) command.
