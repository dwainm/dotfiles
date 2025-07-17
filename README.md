
# Macos 
### Set capslock to be control.
- In systems preference go to keyboard.
- Click on the bottom right "modifier keys"
- Change capslock to be control.

### Turn off shortcuts to change input sources
Keyboard > Shortctus > Input Sources

### Mac Apps
- Install PasteNow

### Mouse changes
Turn on tap to click on trackpad settings

### Cloud 
Change iCloud settings to use Desktop and Documents folder. So cloud documents and desktop is not seperate from device documents and desktop.

### Spaces and Desktop setting's
1. Go to keyboard shortcuts and make sure CTR - [1-9] shortcuts are enabled for moving between spaces.
2. Go to mission controll (settings > Desktop and dock ) and turn off automatticial re-arrange spaces by recent use.
3. Go to accesability > display and turn off reduce motion (this will remove the slideshow effect when switching spaces).

# Brew

`[brew](brew) install git` 
`sudo mv /usr/bin/git /usr/bin/git-apple`

Install all brew packages with `brew bundle`

### Setup Diffmerge
`git config --global merge.tool diffmerge` 

#### Mise
https://mise.jdx.dev


### Ruby and Rails
https://guides.rubyonrails.org/install_ruby_on_rails.html

## Apps
1. Setup apple calender accounts

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

Makes sur zpresto is loaded below. The plugins should all work.



### Setup Zshell Presto:

Remember Prezto overrides ~/zshrc and symlink it into the prezto one.

- `rm -rf ~/.zprezto && git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}"/.zprezto`
- Add back alias as we removed it: `alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'`
- Make sure we do not overwrite the save zshrc file with all important functions and aliases: `config checkout -- .zprezto/runcoms/zshrc`

Generate your configuration files (copy/paste this as one command):

```
$ setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
 ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s $(which zsh)
```

### Set up path
Check: ` echo $PATH`
Make sure your paths are configured so that home brew ( `/usr/local/bin` ) 
is before `/bin` and `/usr/bin/`

#tmux
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Open tmux and then:
<prefix> I to install plugins.

