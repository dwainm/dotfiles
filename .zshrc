# Authors: Sorin Ionescu <sorin.ionescu@gmail.com>

#######################
#Vim Bind keys
#######################
bindkey -v
export KEYTIMEOUT=1

# Allow backspace to delete across newlines in multiline paste
bindkey "^?" backward-delete-char
bindkey "^H" backward-delete-char

### Completion
# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Up and Down arrow keys now shows related history based on what is entered on the current prompt

if [[ -s "/opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
	source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

if [[ -s "/usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
	source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# History sharing between sessions.
setopt share_history

# Cd directory without typing CD
setopt autocd

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE=true

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Keep Secrets
if [[ -s "$HOME/.private" ]]; then
	source $HOME/.private
fi

#######
# TMUX
#######
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux new-session
fi

#################################
# Aliases
#################################

#################################
# SKHD
#################################

function skhd_ddterm () {
	WINDOW_TITLE="ddterm"
	WINDOW_ID=$(yabai -m query --windows | jq -e ".[] | select(.title==\"$WINDOW_TITLE\") | .id")

	case $WINDOW_ID in
		''|*[!0-9]*) unset $WINDO_ID ;;
	esac

	if ! [[ $WINDOW_ID ]]; then 
		open -na /Applications/Kitty.app --args --title "$WINDOW_TITLE"  
	else 
		WINDOW_QUERY=$(yabai -m query --windows --window "$WINDOW_ID") 
		IS_HIDDEN=$(echo "$WINDOW_QUERY" | jq '."is-hidden"') 
		HAS_FOCUS=$(echo "$WINDOW_QUERY" | jq '."has-focus"') 
		if [[ "${HAS_FOCUS}" != "true" ]]; then 
			yabai -m window "$WINDOW_ID" --space mouse --move abs:0:0 --grid "10:1:0:0:1:4" --layer above --focus 
		fi 
		if [[ "${IS_HIDDEN}" != "true" ]]; then 
			skhd -k "cmd - h" 
		fi 
	fi
}

#################################
# Automattic 
#################################

function wppull () {
  rsync -az --delete --delete-after --exclude '.svn' --exclude '.git' --exclude '.settings' --exclude 'wp-content/themes' wpcom:/home/wpcom/public_html/ ~/Projects/wpcom/ --info=progress2
}

function wppush () {
  rsync -az --delete --delete-after --exclude '.svn' --exclude '.git' --exclude '.settings' --exclude 'wp-content/themes' ~/Projects/wpcom/ wpcom:/home/wpcom/public_html/ --info=progress2
}

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

function sandbox(){
	if [[ 'on' == $1 ]]; then
		echo 'Setting config and starting ssh session..';
		sudo sed -i '' 's/^#192.0.92.115/192.0.92.115/g' /etc/hosts
		ssh wpcomsandbox
	fi

	if [[ 'off' == $1 ]]; then
		echo 'Disabling sandbox hosts config...';
		sudo sed -i '' 's/^192.0.92.115/#192.0.92.115/g' /etc/hosts
	fi
}

function rotationCalendarWeeks(){
	for ((j = 1 ; j < 52 ; j++)); do
		mondayMonth=$(date  -v-Sun -v+${j}w -v+Mon  "+%b")
		mon=$(date  -v-Sun -v+${j}w -v+Mon  "+%d")

		fridayMonth=$(date  -v-Sun -v+${j}w -v+Fri  "+%b")
		fri=$(date  -v-Sun -v+${j}w -v+Fri  "+%d")
		echo "$mondayMonth $mon - $fridayMonth $fri"
	done
}

function wpurl(){
	if [ -z "$1" ]; then
		npm run wp option update home http://localhost:8082/
		npm run wp option update siteurl http://localhost:8082/
		return
	fi
}

function plannerweekslonglist(){
    months=''
    dayranges=''
    startweek=20
    endweek=52
	for ((j = startweek;  j < endweek ; j++)); do
        # Get the current weeks start and end date.
		mon=$(date  -v-Sun -v+${j}w -v+Mon  "+%d")
		fri=$(date  -v-Sun -v+${j}w -v+Fri  "+%d")
		dayranges+="$mon - $fri\t"
        # Get the current month and append it.
		curmonth=$(date  -v-Sun -v+${j}w -v+Mon  "+%b")
        months+="$curmonth\t";
	done

    echo -e $months
    echo -e $dayranges
}

function weeklyupdateweeks(){
	prevmonth='MON'
	for ((j = 1 ; j < 52 ; j++)); do
		curmonth=$(date  -v-Sun -v+${j}w -v+Mon  "+%B")
		mon=$(date  -v-Sun -v+${j}w -v+Mon  "+%d")
		fri=$(date  -v-Sun -v+${j}w -v+Fri  "+%d")
		if [[ $curmonth != $prevmonth ]]; then
			prevmonth=$curmonth;
			echo ''
			# echo $curmonth
			echo ''
		fi
		echo "Weekly Update $curmonth $mon - $fri"
	done
}
function plannerweeks(){
	prevmonth='MON'
	for ((j = 1 ; j < 52 ; j++)); do
		curmonth=$(date  -v-Sun -v+${j}w -v+Mon  "+%b")
		mon=$(date  -v-Sun -v+${j}w -v+Mon  "+%d")
		fri=$(date  -v-Sun -v+${j}w -v+Fri  "+%d")
		if [[ $curmonth != $prevmonth ]]; then
			prevmonth=$curmonth;
			echo ''
			echo $curmonth
			echo ''
		fi
		echo "$mon - $fri"
	done
}

function calThisWeek(){
	icalBuddy -nrd -nc -eep notes -ic dwain.maralack@a8c.com eventsToday+5 | grep • |  grep -v Disengage | grep -v Family | grep -v Initialise | grep -v Lunch | grep -v 'weekly updates' | grep -v 'Week Planning' | grep -v 'Team and Group Updates' | grep -v Comms | tr • - | pbcopy
	echo "Events coppied to clipboard"
}

function calendarlastweek(){
	icalBuddy -nrd -nc -ic dwain.maralack@a8c.com eventsFrom:$(date -v-Sun -v-Mon  "+%Y/%m/%d") to:$(date -v-Sun -v-Sat  "+%Y/%m/%d")  | grep • |  grep -v Disengage | grep -v Family | grep -v Initialise | grep -v Lunch | grep -v Fika | grep -iv "\d slots" | grep -v Busy | tr • - | pbcopy
}

function wcpayurl(){
	cd ~/projects/woocommerce-payments/
	if [ -z "$1" ]; then
		echo 'No url supplied';
	else
		wp option update home $1
		wp option update siteurl $1
	fi
}

#################################
# WP Docker
#################################
alias dc='docker-compose'
alias dcup='docker compose up -d'
alias dockerstop='docker stop $(docker ps -a -q)'

#################################
# Unix Text Handling
#################################
alias vim=nvim
alias vi=nvim
alias v=nvim
alias jobs='jobs -l'
function vimrc(){
	vi ~/.vim/vimrc
}

function nvrc(){
	v ~/.config/nvim/
}
alias nvimrc=nvrc

alias wiki='vim -c "VimwikiIndex"'
alias a8cwiki=' vim ~/Documents/Automattic/index.md'

function download() {
	if [ `which curl` ]; then
		curl -s "$1" > "$2";
	elif [ `which wget` ]; then
		wget -nv -O "$2" "$1"
	fi
}

function agreplace(){
	ag $s1 --files-with-matches | xargs -I {} sed -i '.back' -e "s/$s1/$2/g" {};
}

####
# ACK is better than grep.
###
alias a='ack --ignore-dir tests --ignore-dir tmp '
alias aphp='ack --php --ignore-dir tests --ignore-dir tmp '
alias ajs='ack --js --ignore-dir tests --ignore-dir tmp '

###
# Git
##
alias g="git"
alias gap="git add -p"
alias gs='git status -s'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gsave='git add -A && git commit -m "chore: save point"'
alias gundo='git reset HEAD~1 --mixed'
alias gdone='git push origin HEAD'
alias glg='git log --pretty=format:"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]" --abbrev-commit -30'
alias gres='git reset --hard'

# Enable git completion for g alias
compdef g=git

# Custom completion for gwt (git worktree helper)
_gwt() {
  local -a branches worktrees repo_name

  # Get list of local and remote branches
  branches=(${(f)"$(git branch -a 2>/dev/null | sed 's/^[* ]*//' | sed 's/remotes\///')"})

  # Get repo name and extract branch names from worktrees
  if git rev-parse --git-dir > /dev/null 2>&1; then
    repo_name=$(basename "$(git rev-parse --show-toplevel)")
    # Get worktree paths, extract basenames, strip repo prefix
    worktrees=(${(f)"$(git worktree list 2>/dev/null | awk 'NR>1 {print $1}' | xargs -I {} basename {} | sed "s/^${repo_name}-//")"})
  fi

  # Check if -d flag is in the command line
  if [[ ${words[(I)-d]} -gt 0 ]]; then
    # For delete mode, show existing worktrees (branch names only)
    _arguments '-d[Delete worktree]' "*:branch name:($worktrees)"
  else
    # For create mode, show all branches
    _arguments \
      '-d[Delete worktree and tmux session]' \
      '-b[Branch off specified branch]:base branch:($branches)' \
      '-c[Branch off current branch]' \
      '-h[Show help]' \
      '--help[Show help]' \
      '*:branch name:($branches)'
  fi
}

compdef _gwt gwt

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

function gco(){
	git fetch && git checkout $1
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

# Update local main to exactly where you are right now (no merge commit, no push)
gum() {
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  local pretty_commit=$(git log --oneline -1 HEAD)

  echo "🔥 gum: making local main identical to $current_branch"
  echo "   $pretty_commit"

  git update-ref refs/heads/main HEAD

  echo "✅ Done — local main is now everywhere at this commit"
  echo "   When ready: git push origin main"
}

###
# Config repo management
##
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias cgap='config add -p'
alias cgc='config commit -m'
alias cgca='config commit --amend'
alias cgp='config push'
alias cgs='config status'

######
# Custom Scripts
######
export PATH="$HOME/bin:$PATH"

#################################
# CLI
#################################
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

addspace(){
	for i in $(seq $1)
	do
		echo
	done
}

alias space='addspace'

alias lsg='ls | grep'
alias hosts='sudo vim /etc/hosts'
#turn on word wrap in less ( see -S, which removes wrap, is not in the list )
export LESS="-F -g -i -M -R -w -X -z-4"

## Legacy function to check if we're in a VIM shell
isvim() {
	env | grep vim
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
alias nvm='fnm'
eval "$(fnm env --use-on-cd)"

#Zoxide for better CD memory's
eval "$(zoxide init zsh)" 

#Starship Prompt
eval "$(starship init zsh)"

# Silince deprecated notices when using WP-CLI
alias wp="PHP_INI_SCAN_DIR='' php -d error_reporting='E_ALL & ~E_DEPRECATED & ~E_STRICT' /usr/local/bin/wp"

#############
#navigation
############
function cdplugin(){
	cd /Users/dwain/projects/$1/wordpress/wp-content/plugins/$2
}

function cdgosrc(){
  cd /Users/dwain/projects/go/src
}

function cdwpcont(){
	cd /Users/dwain/projects/$1/wordpress/wp-content
}

alias cdpayfast="cd /Users/dwain/projects/payfast/app/public/wp-content/plugins/woocommerce-gateway-payfast"
alias cdwcpayplugins="cd /Users/dwain/projects/woocommerce-payments/docker/wordpress/wp-content/plugins"
alias cdgo="cd /Users/dwain/projects/go"
alias cdstripe="cd /Users/dwain/projects/wcpay/app/public/wp-content/plugins/woocommerce-gateway-stripe"

function wplog(){
	less +F /Users/dwain/projects/$1/wordpress/wp-content/debug.log
}

###########
# WooDeploy
###########
export GOPATH="/Users/dwain/projects"
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOPATH/bin

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Rails uses RAILS_EDITOR over EDITOR
export RAILS_EDITOR='nvim'
export VISUAL='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

###########
# Ruby
###########

for cmd in rspec ruby rubocop rails jekyll; do
  alias $cmd="bundle exec $cmd"
done
# export GEM_HOME="$HOME/.gem"

###########
# Rails Development
###########

dev() {
  # Find the Rails root no matter where you are
  local dir="$(pwd)"
  while [[ "$dir" != "" && ! -f "$dir/bin/rails" ]]; do
    dir=${dir%/*}
  done

  [[ -f "$dir/bin/rails" ]] || { echo "❌ Not a Rails root"; return 1; }
  cd "$dir"

  # Generate random ports to avoid conflicts when running multiple Rails projects
  local http_port=$((3000 + RANDOM % 999))           # 3000–3998
  local debug_port=$((40000 + RANDOM % 25535))       # 40000–65535
  local asset_port=$((3035 + RANDOM % 200))          # 3035–3234 for Vite/Tailwind/etc.
  local pid_file="tmp/pids/server.${http_port}.pid"

  echo "🚀 Starting Rails in $(basename "$PWD")"
  echo "   → http://localhost:$http_port  (debug: $debug_port)"

  # Set ports via env vars. Your config/environments/development.rb must respect these!
  # RUBY_DEBUG_PORT is read by: DEBUGGER__.open_tcp(port: ENV["RUBY_DEBUG_PORT"].to_i)
  # See: config/environments/development.rb for debug port configuration
  RUBY_DEBUG_PORT="$debug_port" \
  RB_DEBUGGER_PORT="$debug_port" \
  DEBUGGER_PORT="$debug_port" \
  PORT="$http_port" \
  PIDFILE="$pid_file" \
  VITE_RUBY_PORT="$asset_port" \
  JS_DEV_SERVER_PORT="$asset_port" \
    bin/dev "$@"
}

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshrc="vim ~/.zshrc"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/usr/local/opt/php@7.3/bin:$PATH"
export PATH="/usr/local/opt/php@7.3/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"
[ -f ~/.local/bin/mise ] && eval "$(~/.local/bin/mise activate)"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
eval "$(~/.local/bin/mise activate)"

