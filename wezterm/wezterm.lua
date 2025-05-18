local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.enable_wayland = false

config.color_scheme = 'Catppuccin Macchiato'

config.font = wezterm.font('FiraCode Nerd Font')

return config
