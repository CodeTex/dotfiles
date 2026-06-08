#!/usr/bin/env fish

set -gx FISH_CONFIG_HOME $HOME/.config/fish
set fish_greeting

# Envars
set -gx CHEZMOI_HOME $HOME/.local/share/chezmoi
if not set -q HOSTNAME
	set -gx HOSTNAME (cat /etc/hostname)
end

# Abbreviations
abbr sf source $FISH_CONFIG_HOME/config.fish
abbr vf $EDITOR $FISH_CONFIG_HOME/config.fish

abbr fl "fc-list : family | awk -F ',' '{print \$1}' | sort | uniq"

abbr ff "fzf --preview 'bat --style=numbers --color=always {}'"

abbr cm chezmoi
abbr cmp chezmoi_push

abbr svenv "source ./.venv/bin/activate.fish"

# Aliases
alias ls "eza --long --header --group-directories-first --icons=auto"
alias la "ls --all"
alias lt "eza --tree --level=2 --long --icons --git"
alias lta "lt --all"
alias lo "eza --header --group-directories-first --oneline"
alias decompress "tar -xzf"
alias occ opencode_registry
alias cd z

function zd --description "Change directory using zoxide"
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


# Virtualenv activation helper
# Usage: `va` to source ./.venv/bin/activate or `va path/to/activate` for a custom path
function va --description "Activate project's virtualenv from ./.venv/bin/activate"
    set -l activate_path
    if test (count $argv) -gt 0
        set activate_path $argv[1]
    else
        set activate_path ./.venv/bin/activate
    end

    if test -f $activate_path
        source $activate_path
    else
        echo "No virtualenv activation script found at '$activate_path'"
    end
end

# Initializations
mise activate fish | source

starship init fish | source

zoxide init fish | source

if type -q fzf_key_bindings
    fzf_key_bindings
end

# Functions
function compress --description "Compress a directory into a .tar.gz file"
    tar -czf (string replace -r '/' '' "$argv[1]").tar.gz (string replace -r '/' '' "$argv[1]")
end
