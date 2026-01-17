#!/usr/bin/env fish

set fish_greeting

# Envars
set -gx CHEZMOI_HOME $HOME/.local/share/chezmoi
set -gx FISH_CONFIG_HOME $HOME/.config/fish
set -gx HOSTNAME $(hostname)

set -gx XDG_MUSIC_DIR $HOME/music

# Abbreviations
abbr bf bat $FISH_CONFIG_HOME/config.fish
abbr sf source $FISH_CONFIG_HOME/config.fish
abbr vf $EDITOR $FISH_CONFIG_HOME/config.fish

abbr fl "fc-list : family | awk -F ',' '{print \$1}' | sort | uniq"

abbr dps docker ps -a
abbr dls docker image ls -a
abbr dcup docker compose up -d
abbr dcdn docker compose down
abbr dclogs docker compose logs -f
abbr dcls docker compose ps

abbr g git
abbr gs "git status"
abbr gcm "git commit -m"
abbr gcam "git commit -a -m"
abbr gcad "gitt commit -a --amend"

abbr ff "fzf --preview 'bat --style=numbers --color=always {}'"

abbr cgf "cd $CHEZMOI_HOME && git fetch && git status && cd $HOME"
abbr cgs "cd $CHEZMOI_HOME && git status && cd $HOME"
abbr cra "chezmoi re-add"
abbr cpa "cd $CHEZMOI_HOME && git pull && chezmoi apply && cd $HOME"
abbr cpd "cd $CHEZMOI_HOME && git pull && chezmoi diff && cd $HOME"
abbr cpush "chezmoi re-add && cd $CHEZMOI_HOME && git add . && git commit -m 'feat: update dotfiles' && git push && cd $HOME"
abbr cvim "chezmoi edit --apply"

# Aliases
alias ls="eza --long --header --group-directories-first --icons=auto"
alias la="ls --all"
alias lt="eza --tree --level=2 --long --icons --git"
alias lta="lt --all"
alias lo="eza --header --group-directories-first --oneline"

# alias d="docker"
# alias r="rails"

alias cd="z"

function cd --description "Change directory using zoxide"
    if test (count $argv) -eq 0
        # No arguments: go to home
        builtin cd ~ && return
    else if test -d "$argv[1]"
        # Argument is valid directory: cd to it
        builtin cd "argv[1]"
    else
        # Use zoxide to navigate, print success or error
        zoxide $argv && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    end
end

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias decompress="tar -xzf"

# alias tracknew="comm -13 <(sort $HOME/.config/yay/pkglist_baseline.txt) <(pacman -Qe | awk '{print \$1}' | sort) >>$HOME/.config/yay/pkglist.txt"

# Initializations
mise activate fish | source

starship init fish | source

zoxide init fish | source

try init ~/Work/tries | source

fzf_key_bindings

# Functions
function compress --description "Compress a directory into a .tar.gz file"
    tar -czf (string replace -r '/' '' "$argv[1]").tar.gz (string replace -r '/' '' "$argv[1]")
end
