#!/bin/bash

threshold_green=0
threshold_yellow=25
threshold_red=100

check_lock_files() {
	local pacman_lock="/var/lib/pacman/db.lck"
	local checkup_lock="${TMPDIR:-/tmp}/checkup-db-${UID}/db.lck"

	while [ -f "$pacman_lock" ] || [ -f "$checkup_lock" ]; do
		sleep 1
	done
}

check_lock_files

updates=$(yay -Qau | wc -l)

css_class="green"

if [ "$updates" -gt $threshold_red ]; then
	css_class="red"
elif [ "$updates" -gt $threshold_yellow ]; then
	css_class="yellow"
else
	css_class="green"
fi

if [ "$updates" -gt $threshold_green ]; then
	printf '{"text": "%s", "alt": "%s", "tooltip": "Click to update your system", "class": "%s"}' "$updates" "$updates" "$css_class"
else
	printf '{"text": "0", "alt": "0", "tooltip": "No updates available", "class": "green"}'
fi
