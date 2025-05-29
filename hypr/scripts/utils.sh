#!/usr/bin/env bash

function get_random_file () {
	local dir_path="$1"
	local file_type="$2"

	# Check if directory exists
	if [[ ! -d "$dir_path" ]]; then
		echo "Error: Directory '$dir_path' does not exist" >&2
		return 1
	fi

	# Build find command based on input
	local find_cmd="find '$dir_path' -maxdepth 1 -type f"
	if [[ "$file_type" == "img" ]]; then
		find_cmd="$find_cmd \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \)"
	else
		find_cmd="$find_cmd -name '*.$file_type'"
	fi

	# Get array of matching files (excluding subdirectories)
	local files=()
	while IFS= read -r file; do
		[[ -n "$file" ]] && files+=("$file")
	done < <(eval "$find_cmd")

	# Check if any files were found
	if [[ ${#files[@]} -eq 0 ]]; then
		echo "Error: No ${file_type} files found in '$dir_path'" >&2
		return 1
	fi

	# Select random file and return its path
	local random_index=$((RANDOM % ${#files[@]}))
	echo "${files[$random_index]}"
}

# random_image=$(get_random_file "$HOME/wallpapers/gruvbox/" "img")
# echo "$random_image"

function get_subdirs () {
	local dir_path="$1"
	shift
	local exclude_dirs=("$@")

	# Check if directory exists
	if [[ ! -d "$dir_path" ]]; then
		echo "Error: Directory '$dir_path' does not exist" >&2
	   	return 1
	fi

	# Get all subdirs
	local subdirs=()
	while IFS= read -r -d '' subdir; do
		local basename=$(basename "$subdir")
		local exclude=false
		for excluded in "${exclude_dirs[@]}"; do
			if [[ "$basename" == "$excluded" ]]; then
				exclude=true
				break
			fi
		done

		if [[ "$exclude" == false ]]; then
			subdirs+=("$subdir")
		fi
	done < <(find "$dir_path" -mindepth 1 -maxdepth 1 -type d -print0)

	printf '%s\n' "${subdirs[@]}"
}

# readarray -t subdirs_array < <(get_subdirs "$HOME/wallpapers" "archive")
# for dir in "${subdirs_array[@]}"; do
# 	echo " $dir"
# done

function get_dir_names () {
	local paths=("$@")
	local dir_names=()

	for path in "${paths[@]}"; do
		local dir_name=$(basename "$path")
		dir_names+=("$dir_name")
	done

	printf '%s\n' "${dir_names[@]}"
}

# readarray -t names_array < <(get_dir_names "${subdirs_array[@]}")
# for name in "${names_array[@]}"; do
#	echo "> $name"
# done

