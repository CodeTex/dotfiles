# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/codetex/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"

# Init starship prompt
eval "$(starship init zsh)"

# Init zoxide
eval "$(zoxide init zsh)"

# Clean go cache
go clean -cache

# Set default editor
export EDITOR='vim'

# Aliases
alias cd='z'
alias zz='z ..'

alias sz='source ~/.zshrc && echo "~/.zshrc reloaded"'
alias vz='vim ~/.zshrc'

alias ls='eza'
alias ll='eza -lbF'
alias la='eza -lbaF'
alias lt="eza --tree --level=3 -R --group-directories-first --ignore-glob='.cache|.git'"
alias lta='lt -a'

alias fl="fc-list : family | awk -F ',' '{print \$1}' | sort | uniq"

alias ff='fastfetch'

alias lgit='lazygit'
alias gc='git clone'
alias gd='git diff'
alias gl="git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an %ar%C(auto) %D%n%s%n'"
alias gs='git status --short'

