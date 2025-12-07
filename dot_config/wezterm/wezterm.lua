--@diagnostic disable:undefined-global

local wezterm = require 'wezterm'

local config = wezterm.config_builder()
local opacity = 0.98

-- Hyprland Compatibility
config.enable_wayland = false

-- config.default_prog = { "/usr/bin/fish", "-i" }

-- Appearance
config.hide_mouse_cursor_when_typing = true
config.window_background_opacity = opacity
config.max_fps = 144
config.animation_fps = 60
config.cursor_blink_rate = 250

config.color_scheme = 'Catppuccin Mocha'
local color_mauve = '#cba6f7'
local color_lavender = '#b4befe'
local color_surface_2 = '#585b70'
local color_surface_1 = '#45475a'
local color_surface_0 = '#313244'
local color_base = '#1e1e2e'
local color_mantle = '#181825'
local color_crust = '#11111b'

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false
config.tab_and_split_indices_are_zero_based = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false

config.tab_max_width = 25

local leader_is_active = false

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
	local edge_background = color_crust
	local background = color_surface_0
	local foreground = color_lavender

	if tab.is_active then
		background = color_lavender
		foreground = color_surface_0
	elseif hover then
		background = color_surface_1
		foreground = color_lavender
	end

	local edge_foreground = background

	local tab_left = wezterm.nerdfonts.ple_upper_right_triangle 
	local tab_right = wezterm.nerdfonts.ple_lower_left_triangle 

	if tab.tab_index == 0 then
		tab_left = leader_is_active and wezterm.nerdfonts.ple_upper_right_triangle or ''
	end

	-- ensure that the titles fit in the available space, and that we have room for the edges
	local title = tab.active_pane.title
	title = wezterm.truncate_right(title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = tab_left },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = ' ' .. title .. ' ' },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = tab_right },
	}
end)

-- Font
config.font = wezterm.font_with_fallback({
	-- { family = 'FiraMono Nerd Font' },
	{
		family = 'FiraCode Nerd Font',
		weight = 'Regular',
		harfbuzz_features = {
			-- https://github.com/tonsky/FiraCode/wiki/How-to-enable-stylistic-sets
			'cv04', -- styles: i
			'cv08', -- styles: l
			'cv14', -- styles: r
			'ss04', -- styles: $
		},
	},
	{ family = 'NotoSans Nerd Font' },
	{ family = 'Symbola' }
}) 
config.font_size = 9

config.warn_about_missing_glyphs = true

config.harfbuzz_features = {
	'kern', -- default kerning
	'liga', -- default ligatures
	'clig', -- default contextual ligatures
}

-- Keybindings
config.leader = { key = 'f', mods = 'ALT', timeout_milliseconds = 1000 }
config.keys = {
	{ mods = 'LEADER', key = 'c', action = wezterm.action.SpawnTab('CurrentPaneDomain'), },
	{ mods = 'LEADER', key = 'x', action = wezterm.action.CloseCurrentPane({ confirm = true }), },
	{ mods = 'LEADER', key = 'b', action = wezterm.action.ActivateTabRelative(-1), },
	{ mods = 'LEADER', key = 'n', action = wezterm.action.ActivateTabRelative(1), },
	{ mods = 'LEADER', key = '.', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
	{ mods = 'LEADER', key = '/', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }, },
	{ mods = 'LEADER', key = 'h', action = wezterm.action.ActivatePaneDirection('Left'), },
	{ mods = 'LEADER', key = 'j', action = wezterm.action.ActivatePaneDirection('Down'), },
	{ mods = 'LEADER', key = 'k', action = wezterm.action.ActivatePaneDirection('Up'), },
	{ mods = 'LEADER', key = 'l', action = wezterm.action.ActivatePaneDirection('Right'), },
	{ mods = 'LEADER', key = 'LeftArrow', action = wezterm.action.AdjustPaneSize { 'Left', 5 }, },
	{ mods = 'LEADER', key = 'DownArrow', action = wezterm.action.AdjustPaneSize { 'Down', 5 }, },
	{ mods = 'LEADER', key = 'UpArrow', action = wezterm.action.AdjustPaneSize { 'Up', 5 }, },
	{ mods = 'LEADER', key = 'RightArrow', action = wezterm.action.AdjustPaneSize { 'Right', 5 }, },
}

-- leader + 0-9 to switch tabs
for i = 1, 9 do
	table.insert(config.keys, {
		mods = 'LEADER',
		key = tostring(i),
		action = wezterm.action.ActivateTab(i - 1), -- indexed tabs start from 0
	})
end

-- tmux status
wezterm.on('update-right-status', function(window, _)
	local DIVIDER = ''
	local prefix = ''
	local ARROW_FOREGROUND = { Foreground = { Color = color_mantle } }


	leader_is_active = window:leader_is_active()
	if leader_is_active then
		prefix = ' ' .. wezterm.nerdfonts.md_space_invaders .. ' ' -- activation icon
		DIVIDER = wezterm.nerdfonts.ple_lower_left_triangle	
	end

	window:set_left_status(wezterm.format({
		{ Background = { Color = color_mauve } },
		{ Foreground = { Color = color_crust } },
		{ Text = prefix },
		ARROW_FOREGROUND,
		{ Background = { Color = color_mantle } },
		{ Foreground = { Color = color_mauve } },
		{ Text = DIVIDER },
	}))
end)

return config

