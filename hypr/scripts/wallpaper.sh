#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/pictures/wallpapers/active"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

# Get random wallpaper that is not the current one
WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)

# Apply the selected wallpaper
hyprctl hyprpaper reload ,"$WALLPAPER"
