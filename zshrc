# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="phil"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

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
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

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
plugins=(git brew python)

# User configuration
#
function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo " $ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

os=`uname`

if [ $os = "Darwin" ];
then
    export XC_PATH=`xcode-select -p`
    export IOS_SDK=`xcrun --sdk iphoneos --show-sdk-path`
    export OSX_SDK=`xcrun --sdk macosx --show-sdk-path`
    export XC_DATA="$HOME/Library/Developer/Xcode/DerivedData"
fi

if [ $os = "Darwin" ];
then
    alias ls='ls -G'
else
    alias ls='ls --color'
fi

export LOCAL_ROOT="$HOME/.local_root/"
export LOCAL_BIN="$LOCAL_ROOT/bin"
export PATH="$LOCAL_BIN:$HOME/go/bin:/usr/local/bin:$PATH:"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8

export TERM=xterm-256color

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias g='grep'
alias gi='grep -i'
alias gr='grep -R'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'
alias s='source ~/.zshrc'
alias hexdump='hexdump -C'

pushd ()
{
    if [ $# -eq 0 ] ;
    then
        DIR="${HOME}"
    else
        DIR="$1"
    fi

    builtin pushd "${DIR}" > /dev/null
}

pushd_builtin ()
{
    builtin pushd > /dev/null
}

popd () 
{
    builtin popd > /dev/null
}

if [ $UID -ne 0 ] ; 
then
    alias sudo='sudo'
    alias scat='sudo cat'
    alias svim='sudo vim'
    alias root='sudo su'
    alias reboot='sudo reboot'
    alias halt='sudo halt'
fi

alias b='popd > /dev/null'
alias flip='pushd_builtin'
alias 2='python2'
alias 3='python3'
alias py='ipython3'
alias clone='git clone --recursive'

export LSCOLORS="Exfxcxdxbxegedabagacad"
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
