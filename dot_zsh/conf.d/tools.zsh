# fzf, prompt, and directory-jump integrations
source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Docker Desktop CLI completions
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
(( ${+_comps[docker]} )) || compinit
