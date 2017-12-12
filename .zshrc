# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/dwain/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="af-magic"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

#######################
#Vim Bind keys
#######################
bindkey -v
export KEYTIMEOUT=1

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE=true

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh
source $HOME/.private
#################################
# Aliases
#################################

#################################
# PROXY
#################################

function a8cproxysettingon(){
	sudo networksetup -setautoproxystate  "Wi-Fi" on
	sudo networksetup -setautoproxyurl "Wi-Fi" "https://pac.a8c.com"
}

function a8cproxysettingoff(){
	sudo networksetup -setautoproxystate  "Wi-Fi" off	
}

function a8cproxy(){
	
	if [[ 'on' == $1 ]]; then
		echo 'Turning Setting On';
		a8cproxysettingon
	fi

	if [[ 'off' == $1 ]]; then
		 echo 'Turning Setting Off';
		 a8cproxysettingoff
	fi
}

#################################
# WP Docker
#################################
alias wp='docker-compose exec --user www-data phpfpm wp'
alias dcbash='docker-compose exec --user root phpfpm bash'
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dockerstop='docker stop $(docker ps -a -q)'

#################################
# VIM
#################################
alias vi=vim
function vimrc(){
vi ~/.vim/vimrc
}

function download() {
	if [ `which curl` ]; then
		curl -s "$1" > "$2";
	elif [ `which wget` ]; then
		wget -nv -O "$2" "$1"
	fi
}

###
# Git
##
alias gap="git add -p"
	# Dotfiles gitifie
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
#delete branche
function gbdel(){
  git branch | grep $1 | xargs git branch -D
}

  function gcol(){
      #git checkout like %branch%
       git branch | grep $1 | xargs git checkout
  }

function gcob(){
    git checkout -b $1
}

function gpoc(){
  git rev-parse --abbrev-ref HEAD | xargs git push --set-upstream origin
}
function gpof(){
  git rev-parse --abbrev-ref HEAD | xargs git push -fu origin
}

function gcd() {
	REPONAME=$(node -e "console.log(process.argv[1].match(/.*?\/([a-zA-Z0-9\-]+).git/)[1]);" $1)
	git clone $1 && cd "${REPONAME}"
}

#CLI
cpdir() {
  echo "${PWD##*/}" | pbcopy
  echo "${PWD##*/} copied"
}

cpwd() {
  echo "${PWD}" | pbcopy
  echo "path copied"
}

cdlike(){
  ls -a | grep $1 | xargs cd
}

dater(){
	 TZ=GMT date -r $1
}

#####
# POTFILES
#######
export WP_I18N_LIB="~/lib/wpi18n"

##########
# Node
#########
# this is the root folder where all globally installed node packages will  go
export NPM_PACKAGES="/usr/local/npm_packages"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
# add to PATH
export PATH="$NPM_PACKAGES/bin:$PATH"
#Node Version Manager
export NVM_DIR="/Users/dwain/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

#############
#navigation
############
function cdplugin(){
	cd /Users/dwain/projects/$1/wordpress/wp-content/plugins/$2
}

function cdgosrc(){
  cd /Users/dwain/Go/workspace/src/github.com
}

alias cdbook="cd /Users/dwain/vagrant/wcvagrant/www/wordpress-trunk/wp-content/plugins/woocommerce-bookings/"

###########
# WooDeploy
###########
export GOPATH="$HOME/Go/workspace"
export PATH=$PATH:$HOME/Go/workspace/bin
export WOODEPLOY_ALL_PLUGINS_DIR="$HOME/wc-all-plugins"
export WOODEPLOY_BEANSTALK_DIR="$HOME/woocommerce-products"
alias wd="WOODEPLOY_ALL_PLUGINS_DIR=$WOODEPLOY_ALL_PLUGINS_DIR WOODEPLOY_BEANSTALK_DIR=$WOODEPLOY_BEANSTALK_DIR WOODEPLOY_SLACK_WEBHOOK_URL=$WOODEPLOY_SLACK_WEBHOOK_URL WOODEPLOY_P2_TOKEN='$WOODEPLOY_P2_TOKEN' woodeploy -v"


# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

###########
# Ruby
###########
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting


# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshrc="vim ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
