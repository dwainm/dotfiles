# Brew

install brew first

brew install git 
sudo mv /usr/bin/git /usr/bin/git-apple

brew install zsh vim fzf ctags

# dotfiles
How to use

Clone into $HOME/dotfiles and CD into it
`git clone git@github.com:dwainm/dotfiles.git && cd dotfiles`

Rename .git to .myconf
`mv .git .myconf`

Mv all from dotfiles to $HOME
`cd ~ && mv dotfiles/.* .`

Add aliases
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias gcf='git config --list'

now you can manage your dotfiles with config(git alias) command.

# Terminal

Set brew ZSH as you shell:
`sudo sh -c "echo $(which zsh) >> /etc/shells"`
`chsh -s $(which zsh)`


Setup afterGlow Dark Theme:
- Go to https://github.com/lysyi3m/osx-terminal-themes/blob/master/schemes/Afterglow.terminal 
- Click on raw and save as afterglow.termianl.
- Right click on open and Set it as defaut.

Setup Zshell Presto:

Remember Prezto overrides ~/zshrc and symlink it into the prezto one.

`rm -rf ~/.zprezto`
`git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto`
`config checkout -- .zprezto/runcoms/zshrc`

Generate your configuration files (copy/paste this as one command):
```
$ setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
 ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s $(which zsh)
```

# Vim 
Open vim and run `:PlugInstall`

Create symlink to vim wiki icloud storage: 
`ln -s /Users/dwain/Documents/vimwiki /Users/dwain/vimwiki`

