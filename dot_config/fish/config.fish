#!/usr/bin/env fish

# Abbreviations
abbr sf source $FISH_CONFIG_HOME/config.fish
abbr vf $EDITOR $FISH_CONFIG_HOME/config.fish

abbr fl "fc-list : family | awk -F ',' '{print \$1}' | sort | uniq"

abbr dps docker ps -a
abbr dls docker image ls -a
abbr dcup docker compose up -d
abbr dcdn docker compose down
abbr dclogs docker compose logs -f
abbr dcls docker compose ps

abbr ff "fzf --preview 'bat --style=numbers --color=always {}'"

# Aliases
if command -v eza >/dev/null
	alias ls="eza --long --header --group-directories-first --icons=auto"
	alias la="ls --all"
	alias lt="eza --tree --level=2 --long --icons --git"
	alias lta="lt --all"
	alias lo="eza --header --group-directories-first --oneline"
end

if command -v zoxide >/dev/null
	alias cd="zd"

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
end

alias ..="cd .."
alias ...="cd ../.."

alias decompress="tar -xzf"

# Initializations
# Check and activate mise
if command -v mise >/dev/null
    mise activate fish | source
end

# Check and initialize starship
if command -v starship >/dev/null
    starship init fish | source
end

# Check and initialize zoxide
if command -v zoxide >/dev/null
    zoxide init fish | source
end

# Check and initialize try
if command -v try >/dev/null
    try init ~/Work/tries | source
end

# Check and source fzf completions and key-bindings
if command -v fzf >/dev/null
    if test -f /usr/share/fzf/completion.fish
        source /usr/share/fzf/completion.fish
    end
    if test -f /usr/share/fzf/key-bindings.fish
        source /usr/share/fzf/key-bindings.fish
    end
end

# Functions
function compress --description "Compress a directory into a .tar.gz file"
    tar -czf (string replace -r '/' '' "$argv[1]").tar.gz (string replace -r '/' '' "$argv[1]")
end

