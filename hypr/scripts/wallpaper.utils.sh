#!/usr/bin/env bash

# Constants
CACHE_DIR="${HOME}/.cache/custom"
WALLPAPERS_CACHE_DIR="${CACHE_DIR}/wallpapers"
WALLPAPERS_THEMES_DIR="${HOME}/wallpapers"
LINK_FILE_NAME="wall"
SUPPORTED_EXTENSIONS=("jpg" "jpeg" "png")

EXCLUDED_THEMES=("archive" "new")

# Load utils
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

# Create cache derivatives
create_thumbnail() {
	magick "$1" -strip \
		-resize 1000 -gravity center -extent 1000 \
		-quality 90 \
		"$2/$3.thmb"
}

create_blurred() {
	magick "$1" -strip \
		-scale 10% -blur 0x3 -resize 100% \
		"$2/$3.blur"
}

create_squared() {
	magick "$1" -strip \
		-thumbnail 500x500^ -gravity center -extent 500x500 \
		"$2/$3.sqre.png" && \
		mv "$2/$3.sqre.png" "$2/$3.sqre"
}

create_quadratic() {
	local out_fn="${1%.*}" # Remove the file extension

	[[ ! "$1" == *.sqre ]] && echo "Error: Input file is not *.sqre" && exit 1
	
	magick "$1" \( -size 500x500 xc:white -fill "rgba(0,0,0,0.7)" -draw "polygon 400,500 500,500 500,0 450,0" -fill black -draw "polygon 500,500 500,0 450,500" \) -alpha Off -compose CopyOpacity -composite "${out_fn}.quad.png" && mv "${out_fn}.quad.png" "${out_fn}.quad"
}

create_cached_images() {
    local src_fpath="$1"
	local hash_name=$(generate_hash "$src_fpath")
	
	create_blurred "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}"
	create_squared  "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}"
	create_quadratic "$WALLPAPERS_CACHE_DIR/${hash_name}.sqre"

	#local OPTIND opt
	#while getopts "atbsq" opt; do
	#	case $opt in
	#		a) 
	#			create_thumbnail "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}"
	#			create_blurred "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}"
	#			create_squared  "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}"
	#			create_quadratic "$WALLPAPERS_CACHE_DIR/${hash_name}.sqre" ;;
	#		t) create_thumbnail "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}" ;;
	#		b) create_blurred "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}" ;;
	#		s) create_squared "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}" ;;
	#		q)
	#			create_squared "$src_fpath" "$WALLPAPERS_CACHE_DIR" "${hash_name}"
	#			create_quadratic "$WALLPAPERS_CACHE_DIR/${hash_name}.sqre" ;;
	#	esac	
	#done
}

generate_hash() {
	echo "$1" | md5sum | awk '{ print $1 }'
}

verify_cached_images() {
	local src_fpath="$1"
	local hash_name=$(generate_hash "$src_fpath")

	[[ -f "$WALLPAPERS_CACHE_DIR/${hash_name}.blur" && -f "$WALLPAPERS_CACHE_DIR/${hash_name}.quad" ]] 
}

remove_cached_images() {
	local hash_name="$1"
	rm -f "$WALLPAPERS_CACHE_DIR/${hash_name}.blur" "$WALLPAPERS_CACHE_DIR/${hash_name}.quad" 
}

check_removed_wallpapers() {
    declare -A wallpaper_map

    # Iterate over each theme directory
	while IFS= read -r theme_dir; do    
		local theme_name=$(basename "$theme_dir")

        # Skip excluded themes
        if printf '%s\n' "${EXCLUDED_THEMES[@]}" | grep -q "^${theme_name}$"; then
            continue
        fi

        # Iterate over each supported file extension
		for wallpaper in "$theme_dir"/*; do
			[[ -f "$wallpaper" ]] || continue  # Skip if not a file
			local hash_name=$(generate_hash "$wallpaper")
			wallpaper_map["$hash_name"]=$wallpaper
		done
	done < <(find "$WALLPAPERS_THEMES_DIR" -mindepth 1 -maxdepth 1 -type d)

    # Check cached files
    for cached_file in "$WALLPAPERS_CACHE_DIR"/*.{blur,quad}; do
        [[ -f "$cached_file" ]] || continue  # Skip if not a file

        local cached_hash=$(basename "${cached_file%.*}")
        if [[ -z "${wallpaper_map[$cached_hash]}" ]]; then
            # Remove cached files if the original wallpaper no longer exists
			remove_cached_images "$cached_hash"
        fi
    done
}

check_wallpaper_changes() {
    for theme_dir in "$WALLPAPERS_THEMES_DIR"/*; do
        if [[ -d "$theme_dir" ]]; then
            local theme_name=$(basename "$theme_dir")

            # Skip excluded themes
            if printf '%s\n' "${EXCLUDED_THEMES[@]}" | grep -q "^${theme_name}$"; then
                continue
            fi

            for ext in "${SUPPORTED_EXTENSIONS[@]}"; do
                for wallpaper in "$theme_dir"/*."$ext"; do
                    if [[ -f "$wallpaper" ]]; then
                        if ! verify_cached_images "$wallpaper"; then
							create_cached_images "$wallpaper"
						fi
                    fi
                done
            done
        fi
    done
}

create_symlinks() {
	local wallpaper_path="$1"
	local theme_name=$(basename "$(dirname "$wallpaper_path}")")
	local hash_name=$(generate_hash "$wallpaper_path")

	ln -sf "$WALLPAPERS_CACHE_DIR/${hash_name}.blur" "$CACHE_DIR/${LINK_FILE_NAME}.blur"
	ln -sf "$WALLPAPERS_CACHE_DIR/${hash_name}.quad" "$CACHE_DIR/${LINK_FILE_NAME}.quad"
}

format_theme_name() {
	local name="$1"
 
	# Replace _,- with whitespace
	name="${name//_/ }"
	name="${name//-/ }"

	# Capitalize
	name=$(echo "$name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1 ')

	echo "$name"
}

select_theme() {
	local rofi_input=""

	# Create map to get original name from formatted one
	declare -A name_map
	
	# Get all themes and a random wallpaper from their dir
	while IFS= read -r theme_dir; do
		theme_name=$(basename "$theme_dir")

		# Skip excluded themes
		if printf '%s\n' "${EXCLUDED_THEMES[@]}" | grep -q "^${theme_name}$"; then
			continue
		fi

		# Get a random wallpaper file
		random_wallpaper=$(get_random_file "$theme_dir" "img")
		[[ ! -n "$random_wallpaper" ]] && continue

		hash_name=$(generate_hash "$random_wallpaper")
		cache_img="$WALLPAPERS_CACHE_DIR/${hash_name}.quad"

		formatted_name=$(format_theme_name "$theme_name")
		name_map["$formatted_name"]="$theme_name"

		rofi_input+="${formatted_name}\x00icon\x1f$cache_img\n"

	done < <(find "$WALLPAPERS_THEMES_DIR" -mindepth 1 -maxdepth 1 -type d)

	hypr_border=10
	theme_override="window{width:100%;}
	listview{columns:5;}
	element{border-radius:$((hypr_border * 5))px;padding:0.5em;}
	element-icon{size:23em;border-radius:$((hypr_border * 5 - 5))px;}" 

	selected=$(
		echo -en "$rofi_input" | sort -n | rofi -dmenu \
			-theme-str "${theme_override}" \
			-theme "$HOME/.config/rofi/hyde_selector"
	)

	[[ ! -n "$selected" ]] && return 1

	# Return theme directory name
	echo "${name_map[$selected]}"
}

select_wallpaper() {
	local theme_dir="$1"
	local rofi_input=""

	# Create map to translate from cache hash name to real wallpaper path
	declare -A path_map

	for suffix in "${SUPPORTED_EXTENSIONS[@]}"; do
		for file in "$WALLPAPERS_THEMES_DIR/$theme_dir"/*."$suffix"; do
			[[ ! -f "$file" ]] && continue
		
			hash_name=$(generate_hash "$file")
			cache_img="$WALLPAPERS_CACHE_DIR/${hash_name}.sqre"
			
			file_name=$(basename "$file")
			path_map["$file_name"]="$file"

			rofi_input+="${file_name}\x00icon\x1f$cache_img\n"
		done
	done

	hypr_border=10
	col_count=8
	theme_override="window{width:100%;}
    listview{columns:${col_count};spacing:5em;}
	element{border-radius:$((hypr_border * 3))px;orientation:vertical;} 
    element-icon{size:28em;border-radius:0em;}
    element-text{padding:1em;}"

	selected=$(
		echo -en "$rofi_input" | sort -n | rofi -dmenu \
			-theme-str "${theme_override}" \
			-theme "$HOME/.config/rofi/hyde_selector"
	)

	[[ ! -n "$selected" ]] && return 1

	# Return original wallpaper path
	echo "${path_map[$selected]}"
}

# Set wallpaper using swww
set_wallpaper () {
    local wallpaper_path="$1"
    
	if [[ ! -f "$wallpaper_path" ]]; then
		echo "Error: Wallpaper '$wallpaper_path' not found"
		return 1
	fi

	swww img "$wallpaper_path" --transition-bezier .43,1.19,1,.4 --transition-type outer --transition-duration 0.8 --transition-fps 70 --invert-y
}

# Set hyprpanel theme from selected theme folder name
set_hyprpanel_theme () {
    local selected_dir="$1"
    local theme_name=$(basename "$selected_dir")
 	local theme_path="/usr/share/hyprpanel/themes/${theme_name}.json"
	
	if [[ ! -f "$theme_path" ]]; then
		echo "Error: Hyprpanel theme '$theme_path' not found"
		return 1
	fi

	hyprpanel useTheme "$theme_path"
}

