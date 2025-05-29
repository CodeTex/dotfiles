#!/usr/bin/env zsh

if uwsm check may-start; then
	exec uwsm start hyprland.desktop
fi

