#!/usr/bin/env bash

# Rofi config
config="$HOME/.config/rofi/pavucontrol-menu.rasi"

# Function to get device from description
get_device_from_desc() {
    local description="$1"
    pactl list sinks | grep -C2 "Description: $description" | grep 'Name:' | cut -d: -f2 | xargs
}

# Function to get the description of the default sink
get_default_sink_desc() {
    local default_sink=$(pactl info | grep "Default Sink:" | cut -d: -f2 | xargs)
    pactl list sinks | sed -n "/Name: $default_sink/,/Description: /p" | grep "Description:" | cut -d: -f2 | xargs
}

# Function to list sinks and prepare output for rofi
list_sinks() {
    pactl list sinks | awk '/Description: / {print $2, $3, $4, $5}' | while read -r desc; do
        echo -en "${desc}\0info\x1f${desc}\n"
    done
}

# Get the description of the default sink
default_sink_desc=$(get_default_sink_desc)

# Use rofi to display the list of sinks and capture the selected sink
# Use awk to find the index of the default sink and set it as the selected row
selected_row=$(pactl list sinks | awk '/Description: / {print $0}' | grep -n "$default_sink_desc" | cut -d: -f1)
selected=$(list_sinks | rofi -dmenu -i -selected-row "$selected_row" -config "${config}")

# Extract the description from the selected line
desc=$(echo "$selected" | sed 's/.*\x00info\x1f//')

# Change the default sink if a selection was made
if [ -n "$desc" ]; then
    device=$(get_device_from_desc "$desc")
    if [ -n "$device" ]; then
        pactl set-default-sink "$device"
        notify-send "Audio Output Changed" "Changed to $desc"
    else
        notify-send "Error" "Failed to change audio output to $desc"
    fi
fi
