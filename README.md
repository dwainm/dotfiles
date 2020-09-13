# Brew

install brew first

brew install git 
sudo mv /usr/bin/git /usr/bin/git-apple

Install and setup diffmerge
brew cask install diffmerge   
git config --global merge.tool diffmerge 

brew install zsh vim fzf ctags

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

Set up GNU sed:
with `brew install gnu-sed`

Set up path
Make sure your paths are configured so that home brew ( `/usr/local/bin` ) 
is before `/bin` and `/usr/bin/`

# dotfiles
How to use

Clone into $HOME/dotfiles and CD into it
`git clone git@github.com:dwainm/dotfiles.git && cd dotfiles`

Rename .git to .myconf
`mv .git .myconf`

Mv all from dotfiles to $HOME
`cd ~ && mv dotfiles/.* .`

Add aliases:

`alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'`

now you can manage your dotfiles with config(git alias) command.

# Setup NPM 
https://www.npmjs.com/get-npm

# Setup Composer

`curl -sS https://getcomposer.org/installer | php`

`sudo mv composer.phar /usr/local/bin/`

`sudo chmod 755 /usr/local/bin/composer.phar`

# Vim 
Open vim and run `:PlugInstall`

Create symlink to vim wiki icloud storage: 
`ln -s /Users/dwain/Documents/vimwiki /Users/dwain/vimwiki`

# Touchbar
Makes it more tollerable: https://medium.com/@svinkle/how-to-make-the-touch-bar-slightly-more-tolerable-857d29041f6a
