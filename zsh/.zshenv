#!/usr/bin/env zsh

# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# editor
export EDITOR="vim"
export VISUAL="vim"

# terminal emulator
export TERM="wezterm"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

. "$HOME/.cargo/env"
