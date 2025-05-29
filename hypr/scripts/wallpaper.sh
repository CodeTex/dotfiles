#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/utils.sh"

function create_cache_images() {
    local x_wall="$1"
    local output_filename="$2"
    local thmbDir="$HOME/.cache/custom/$3"

    # Create thumbnail image
    magick "${x_wall}" -strip -resize 1000 -gravity center -extent 1000 -quality 90 "${thmbDir}/${output_filename}.thmb"

    # Create square image
    magick "${x_wall}" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "${thmbDir}/${output_filename}.sqre.png" && mv "${thmbDir}/${output_filename}.sqre.png" "${thmbDir}/${output_filename}.sqre"

    # Create blur image
    magick "${x_wall}" -strip -scale 10% -blur 0x3 -resize 100% "${thmbDir}/${output_filename}.blur"

    # Create quadratic image
    magick "${thmbDir}/${output_filename}.sqre" \( -size 500x500 xc:white -fill "rgba(0,0,0,0.7)" -draw "polygon 400,500 500,500 500,0 450,0" -fill black -draw "polygon 500,500 500,0 450,500" \) -alpha Off -compose CopyOpacity -composite "${thmbDir}/${output_filename}.quad.png" && mv "${thmbDir}/${output_filename}.quad.png" "${thmbDir}/${output_filename}.quad"
}

function format_string() {
    local input_string="$1"
    local formatted_string

    # Replace underscores with spaces
    formatted_string="${input_string//_/ }"

    # Capitalize each word
    formatted_string=$(echo "$formatted_string" | awk '{
        for (i=1; i<=NF; i++) {
            $i = toupper(substr($i, 1, 1)) substr($i, 2)
        }
        print
    }')

    echo "$formatted_string"
}

function reverse_format_string() {
    local input_string="$1"
    local reversed_string

    # Replace spaces with underscores
    reversed_string="${input_string// /_}"

    # Make all letters lowercase
    reversed_string=$(echo "$reversed_string" | tr '[:upper:]' '[:lower:]')

    echo "$reversed_string"
}

function rofi_select () {
	local theme_paths=("$@")
	
	local theme_names=()
	local theme_walls=()
	for path in "${theme_paths[@]}"; do
		name=$(basename $path)
		theme_names+=("$(format_string $name)")
		random_thumbnail=$(get_random_file $path "img")
		create_cache_images $random_thumbnail $name "thumbnails"
		theme_walls+=("${HOME}/.cache/custom/thumbnails/${name}.quad")
	done

	local hypr_border=10
	rofi_selection=$(
		i=0
		while [ $i -lt ${#theme_names[@]} ]; do
			echo -en "${theme_names[$i]}\x00icon\x1f${theme_walls[$i]}\n"
			i=$((i + 1))
		done | rofi -dmenu \
			-theme-str "window{width:100%;} listview{columns:5;} element{border-radius:$((hypr_border * 5))px;padding:0.5em;} element-icon{size:23em;border-radius:$((hypr_border * 5 - 5))px;}" \
			-theme "${HOME}/.config/rofi/hyde_selector" \
			-select "${theme_names[0]}"	
	)

	echo $(reverse_format_string "$rofi_selection")
}

# Set wallpaper using swww
function set_wallpaper () {
    local wallpaper_path="$1"
    
	if [[ ! -f "$wallpaper_path" ]]; then
		echo "Error: Wallpaper '$wallpaper_path' not found"
		return 1
	fi

	swww img "$wallpaper_path" --transition-bezier .43,1.19,1,.4 --transition-type outer --transition-duration 0.8 --transition-fps 70 --invert-y
}

# Set hyprpanel theme from selected theme folder name
function set_hyprpanel_theme () {
    local selected_dir="$1"
    local theme_name=$(basename "$selected_dir")
 	local theme_path="/usr/share/hyprpanel/themes/${theme_name}.json"
	
	if [[ ! -f "$theme_path" ]]; then
		echo "Error: Hyprpanel theme '$theme_path' not found"
		return 1
	fi

	hyprpanel useTheme "$theme_path"
}

function main () {
	readarray -t wallpaper_theme_list < <(get_subdirs "$HOME/wallpapers" "archive")
	[[ "${#wallpaper_theme_list[@]}" -eq 0 ]] && exit 1

	selected_theme=$(rofi_select "${wallpaper_theme_list[@]}")

	random_wallpaper=$(get_random_file "${HOME}/wallpapers/${selected_theme}" "img")
	[[ ! -n "$random_wallpaper" ]] && exit 1

	create_cache_images "$random_wallpaper" "wall" ""
	[[ $? -eq 1 ]] && exit 1

	set_wallpaper "$random_wallpaper"
	[[ $? -eq 1 ]] && exit 1

	set_hyprpanel_theme "$selected_theme"
	[[ $? -eq 1 ]] && exit 1
}

main "$@"

