
# Macos 
### Set capslock to be control.
- In systems preference go to keyboard.
- Click on the bottom right "modifier keys"
- Change capslock to be control.

### Turn off shortcuts to change input sources
Keyboard > Shortctus > Input Sources

### Mac Apps

- Install Rectangle App: Import config in the app: .RectangleConfig
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

### Install brew first

`[brew](brew) install git` 
`sudo mv /usr/bin/git /usr/bin/git-apple`

Now, reload the terminal for the profile to load the correct git location and confirm by running `which git`.

### Install and setup diffmerge
`brew install diffmerge`   
`git config --global merge.tool diffmerge` 

### Install a few helfpul tools
* `brew install zsh vim neovim starship zoxide fzf ctags svn fnm ripgrep tree-sitter ack php`
* `brew install tree bat lf lsd`
* `brew install orbstack`
* `brew install --cask db-browser-for-sqlite`
* `brew install lnav figlet xh`
* `brew install zsh-history-substring-search`
* `brew install --cask michaelvillar-timer`
#### Meeting Bar
On your work device, setup meeting bar to help you move through the day knowing what's current and what's next.

#### Ruby related
brew install gnupg
Follow instruction for installing RVM: https://github.com/rvm/rvm/issues/5261#issuecomment-1704547846
If above doesn't work go to RVM

## Apps
1. Install the app Import config in the app: .RectangleConfig
1. Setup apple calender accounts
1. Instal or raycast : `brew install --cask raycast`

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

#### Install Font
`brew tap homebrew/cask-fonts`

`brew install --cask font-jetbrains-mono-nerd-font`

Setup Zshell Presto:

Remember Prezto overrides ~/zshrc and symlink it into the prezto one.

- `rm -rf ~/.zprezto && git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}"/.zprezto`
- Add back alias as we removed it: `alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'`
- Make sure we do not overwrite the save zshrc file with all important functions and aliases: `config checkout -- .zprezto/runcoms/zshrc`

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
We already have FNM so if needed we can just use that.
https://www.npmjs.com/get-npm

# Setup Composer

`brew install composer`

--- old way below
`curl -sS https://getcomposer.org/installer | php`

`sudo mv composer.phar /usr/local/bin/`

`sudo chmod 755 /usr/local/bin/composer.phar`

# Vim 
Neovim:
- Install packer: https://github.com/wbthomason/packer.nvim
- Run packer install inside vim: :PackerInstall

OldVim
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

Open tmux and then:
<prefix> I to install plugins.

# Todoist
Setup todoist by building it from your fork: https://github.com/dwainm/todoist

```
git clone git@github.com:dwainm/todoist.git
cd todoist
Go install
Go build
Go release
mv ./todoist_darwin_amd64 /usr/local/bin/todoist 
```
