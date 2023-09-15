
# Macos 
### Set capslock to be control.
- In systems preference go to keyboard.
- Click on the bottom right "modifier keys"
- Change capslock to be control.

### Install Rectangle App .
Install the app
Import config in the app: .RectangleConfig

### Mouse changes
Turn on tap to click on trackpad settings

### Cloud 
Change iCloud settings to use Desktop and Documents folder. So cloud documents and desktop is not seperate from device documents and desktop.

### Spaces and Desktop setting's
Go to keyboard shortcuts and make sure CTR - [1-9] shortcuts are enabled for moving between spaces.
Go to mission controll (settings > Desktop and dock ) and turn off automatticial re-arrange spaces by recent use.

### Menu bar and dock
Set the menu bar and the dock to auto hide so the show up when your mouse goes over them.
Go to System Prefs > Keyboard > Shortcuts > Keyboard and change the shortcut to SHIFT+CMD B for "Move focus to menu bar option".

# Brew

### Install brew first

`[brew](brew) install git` 
`sudo mv /usr/bin/git /usr/bin/git-apple`

Now, reload the terminal for the profile to load the correct git location and confirm by running `which git`.

### Install and setup diffmerge
`brew install diffmerge`   
`git config --global merge.tool diffmerge` 

### Install a few helfpul tools
`brew install zsh vim fzf ctags svn fnm ripgrep tree-sitter`
`brew install tree lf`
`brew install orbstack`
`brew install lnav figlet`
`brew install tmuxinator`

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

# Terminal

Set brew ZSH as you shell:
`sudo sh -c "echo $(which zsh) >> /etc/shells"`
`chsh -s $(which zsh)`

#### Install Font
brew install --cask font-jetbrains-mono-nerd-font

Setup afterGlow Dark Theme:
- Go to https://github.com/lysyi3m/macos-terminal-themes/blob/master/themes/Afterglow.terminal
- Click on raw and save as afterglow.termianl.
- Right click on open and Set it as defaut.

Setup Zshell Presto:

Remember Prezto overrides ~/zshrc and symlink it into the prezto one.

- `rm -rf ~/.zprezto && git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}"/.zprezto`
- Add back alias as we removed it: `alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'`
- Make suer we do not overwrite the save zshrc file with all important functions and aliases: `config checkout -- .zprezto/runcoms/zshrc`

### Install Brew tools
brew install --cask kitty
brew install hammerspoon --cask

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
Check: ` echo $PATH`
Make sure your paths are configured so that home brew ( `/usr/local/bin` ) 
is before `/bin` and `/usr/bin/`

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

#tmux
```
brew install tmux
```

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

```
brew install tmuxinator
```

<prefix> I to install plugins.

# Touchbar
Makes it more tollerable: https://medium.com/@svinkle/how-to-make-the-touch-bar-slightly-more-tolerable-857d29041f6a

# Todois
Setup todoist by building it from your fork: https://github.com/dwainm/todoist

```
git clone git@github.com:dwainm/todoist.git
cd todoist
Go install
Go build
Go release
mv ./todoist_darwin_amd64 /usr/local/bin/todoist 
```
