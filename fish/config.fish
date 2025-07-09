#!/usr/bin/env fish
if status is-login
    # echo Hello, back!
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting
end

# Environment variables
set -g XDG_CACHE_HOME $HOME/.cache
set -g XDG_CONFIG_HOME $HOME/.config
set -g FISH_CONFIG_HOME $XDG_CONFIG_HOME/fish

set -g ROCM_PATH /opt/rocm
set -g HSA_OVERRIDE_GFX_VERSION 11.0.0

set -g EDITOR vim
set -g TERM wezterm
set -g VISUAL vim

# Abbreviations
abbr sf source $FISH_CONFIG_HOME/config.fish
abbr vf $EDITOR $FISH_CONFIG_HOME/config.fish
abbr vw $EDITOR $XDG_CONFIG_HOME/wezterm/wezterm.lua

abbr cd z
abbr zz z ..

abbr l eza
abbr ll eza --header --group-directories-first --long --all
abbr la eza --header --group-directories-first --long --all
abbr lt eza --header --group-directories-first --tree --level 2
abbr lo eza --header --group-directories-first --oneline

abbr fl "fc-list : family | awk -F ',' '{print \$1}' | sort | uniq"

abbr dps docker ps -a
abbr dls docker image ls -a
abbr dcup docker compose up -d
abbr dcdn docker compose down
abbr dclogs docker compose logs -f
abbr dcls docker compose ps
#alias dcbash 'docker compose "$@" /bin/bash'

abbr ff fastfetch
abbr km $HOME/keymapp/keymapp

# Other initializations
starship init fish | source
zoxide init fish | source
fzf --fish | source
