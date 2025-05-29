#!/usr/bin/env zsh

# Init starship prompt
eval "$(starship init zsh)"

# Init zoxide
eval "$(zoxide init zsh)"

# Clean go cache
go clean -cache

# Load aliases
source $ZDOTDIR/aliases

# Load plugins
fpath=(/usr/share/zsh-completions $fpath)

# source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

zmodload zsh/complist
autoload -U compinit; compinit
_comp_options+=(globdots)

