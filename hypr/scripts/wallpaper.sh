#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"
source "${SCRIPT_DIR}/wallpaper.utils.sh"

function main() {
	check_wallpaper_changes
	check_removed_wallpapers

    # Select a theme
	selected_theme=$(select_theme)
    [[ $? -eq 1 ]] && exit 1
	echo "Selected theme: $selected_theme"

	# Set bar theme
	set_hyprpanel_theme "$selected_theme"

	# Select wallpaper
	selected_wallpaper=$(select_wallpaper "$selected_theme")
    [[ $? -eq 1 ]] && exit 1
	echo "Selected wallpaper: $selected_wallpaper"

	# Set wallpaper
	set_wallpaper "$selected_wallpaper"

	# Set link to rofi background
	create_symlinks "$selected_wallpaper"
}

main "$@"
