# Initialize Zinit
####################################################################################################

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load Plugins and Snippets
####################################################################################################

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# General Settings
####################################################################################################

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
####################################################################################################

alias ls='ls --color'
alias vim='nvim'
alias c='clear'

alias gcm='git commit -m'
alias gco='git checkout'
alias ga='git add'
alias gp='git push -u origin'

alias jjj='vim $(fzf --preview="bat --color=always {}")'

# ENV Variables
####################################################################################################

# Add ~/bin to PATH
export PATH=$HOME/bin:$PATH

# Oh-my-posh
####################################################################################################

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/zen.toml)"
fi

# Syntax highlighting colors
################################################################################

## Declare the variable
typeset -A ZSH_HIGHLIGHT_STYLES

# To differentiate aliases from other command types
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=magenta,bold'

ZSH_HIGHLIGHT_STYLES[assign]='fg=#c6d0f5'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#c6d0f5'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#c6d0f5'

ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#ef9f76'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ef9f76'

# To have paths colored instead of underlined
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

# To disable highlighting of globbing expressions
ZSH_HIGHLIGHT_STYLES[globbing]='none'

# Vim Keyboard Bindings
####################################################################################################

export EDITOR="nvim"
export VISUAL="$EDITOR"

bindkey -v
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^E' edit-command-line

bindkey -M viins '^K' up-history
bindkey -M viins '^J' down-history

fzf-vim-widget() {
  local file
  file=$(find . -type f -o -type d 2>/dev/null | fzf \
    --preview 'if [ -d {} ]; then ls --color=always {}; else bat --color=always {}; fi' \
    --height 100%) || return
  [[ -n $file ]] && vim "$file"
}

zle -N fzf-vim-widget
bindkey -M viins '^P' fzf-vim-widget

bindkey -M viins '^L' vi-forward-char

# FZF
####################################################################################################

CHEATSHEET=$(cat <<'EOF'

Alex's Cheatsheet
-----------------

find . -name '*.txt'  Search files
tar -xvf file.tar.gz  Extract archive
tar -cvf file.tar.gz dir  Create archive

uname -a       Show OS info
ps aux | grep cmd Show processes by keyword
vmstat 1          Show system stats every 1 sec
iostat -x 1       Show disk IO stats
lsof -i :80       List processes using port 80
EOF
)

# Redefine CTRL+R to skip the preview
fzf-history-widget() {
  local selected
  selected=$(fc -rl 1 | sed 's/^[ ]*[0-9]\+  *//' | fzf --height 50% --ansi --preview="echo \"$CHEATSHEET\"") || return
  LBUFFER=$selected
  zle redisplay
}

zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# Zoxide
####################################################################################################

unalias zi 2>/dev/null
eval "$(zoxide init zsh)"
