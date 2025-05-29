#!/usr/bin/zsh

WALLPAPERS_DIR=$HOME/wallpapers/active
WALLPAPER=$(find "$WALLPAPERS_DIR" -type f | shuf -n 1)

swww img "$WALLPAPER"

