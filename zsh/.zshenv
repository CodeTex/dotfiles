#!/usr/bin/env zsh

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDF_CACHE_HOME="$HOME/.cache"

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

# huggingface
export HF_HOME="$HOME/.cache/huggingface"
export HF_HUB_CACHE="$HF_HOME/hub"
export HF_TOKEN_PATH="$HF_HOME/token"
export HF_HUB_ENABLE_HF_TRANSFER=true
export HF_XET_HIGH_PERFORMANCE=true

# uv
export PATH="$HOME/.local/share/../bin:$PATH"
