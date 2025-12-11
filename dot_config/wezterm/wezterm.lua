--@diagnostic disable:undefined-global

local wezterm = require("wezterm")

local config = wezterm.config_builder()
local font_size = 9
local opacity = 0.98

local os_name = 'Windows' -- Windows, Linux or MacOS

local separator = package.config:sub(1, 1)
if separator == '/' then
    local uname = io.popen("uname -s"):read("*l")
    if uname == "Linux" then
        os_name = 'Linux'
    elseif uname == "Darwin" then
        os_name = 'MacOS'
    end
elseif separator == '\\' then
    os_name = 'Windows'
end

local function get_home()
    return os.getenv("HOME") or os.getenv("USERPROFILE")
end

-- Hyprland Compatibility

config.enable_wayland = false

-- Shell

if os_name == "Windows" then
    -- config.default_prog = { "C:\\Windows\\System32\\wsl.exe", "--distribution", "archlinux" }
    config.default_prog = { 
	"C:\\Program Files\\PowerShell\\7\\pwsh.exe",
	"-NoLogo",
	"-WorkingDirectory",
	get_home()
    }
    -- config.default_cwd = get_home() 
elseif os_name == "Linux" then
    -- config.default_cwd = get_home()
end

-- Appearance
config.initial_rows = 50
config.initial_cols = 160
config.window_padding = {
	left = 8,
	right = 2,
	top = 8,
	bottom = 8,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.win32_system_backdrop = "Acrylic"
config.window_background_opacity = opacity

config.hide_mouse_cursor_when_typing = true
config.max_fps = 144
config.animation_fps = 60
config.cursor_blink_rate = 250

config.color_scheme = "Catppuccin Mocha"
local color_mauve = "#cba6f7"
local color_lavender = "#b4befe"
local color_surface_2 = "#585b70"
local color_surface_1 = "#45475a"
local color_surface_0 = "#313244"
local color_base = "#1e1e2e"
local color_mantle = "#181825"
local color_crust = "#11111b"

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false
config.tab_and_split_indices_are_zero_based = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false

config.tab_max_width = 30

config.window_frame = {
    font_size = font_size + 2
}

local leader_is_active = false

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
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
		tab_left = leader_is_active and wezterm.nerdfonts.ple_upper_right_triangle or ""
	end

	-- Calculate space needed for the left and right triangles and padding
	local left_space = tab.tab_index == 0 and (leader_is_active and 1 or 0) or 1
	local right_space = 1
	local padding_space = 2

	-- Ensure that the titles fit in the available space
	local title = tab.active_pane.title
	local available_width = max_width - (left_space + right_space + padding_space)
	-- title = wezterm.truncate_right(title, available_width)
	title = process_title(title, available_width)

	local cells = {}

	-- Add left triangle if needed
    if tab_left ~= "" then
        table.insert(cells, { Background = { Color = edge_background } })
        table.insert(cells, { Foreground = { Color = edge_foreground } })
        table.insert(cells, { Text = tab_left })
    end
    
    -- Add title with background and foreground
    table.insert(cells, { Background = { Color = background } })
    table.insert(cells, { Foreground = { Color = foreground } })
    table.insert(cells, { Text = " " .. title .. " " })
    
    -- Add right triangle
    table.insert(cells, { Background = { Color = edge_background } })
    table.insert(cells, { Foreground = { Color = edge_foreground } })
    table.insert(cells, { Text = tab_right })
    
    return cells
end)

-- Function to process the title to make it more useful
function process_title(title, max_width)
    -- Determine the path separator (\ for Windows, / for Unix)
    local path_separator = "\\"
    if string.find(title, "/", 1, true) then
        path_separator = "/"
    end
    
    -- Pattern to match the last part of the path
    local last_part_pattern = "([^" .. path_separator .. "]+)$"
    -- Pattern to match the parent directory
    local parent_dir_pattern = "([^" .. path_separator .. "]+)" .. path_separator .. "[^" .. path_separator .. "]+$"
    
    -- Check if the title contains a path separator
    if string.find(title, path_separator, 1, true) then
        -- Extract the last part of the path (filename or directory)
        local last_part = string.match(title, last_part_pattern) or title
        
        -- If we couldn't extract a last part, use the whole title
        if not last_part or last_part == "" then
            last_part = title
        end
        
        -- Extract the parent directory name
        local parent_dir = string.match(title, parent_dir_pattern) or ""
        
        -- If the last part fits within the max width
        if #last_part <= max_width then
            -- If there's room for parent_dir + separator + last_part
            if #parent_dir > 0 and #parent_dir + 1 + #last_part <= max_width then
                return parent_dir .. path_separator .. last_part
            end
            
            -- If there's not enough room for the parent dir, just show the last part
            return last_part
        else
            -- If even the last part doesn't fit, truncate it from the left
            return "..." .. string.sub(last_part, -(max_width-3))
        end
    end
    
    -- For non-path titles, just truncate from the right if needed
    return wezterm.truncate_right(title, max_width)
end

-- Font
config.font = wezterm.font_with_fallback({
	-- { family = 'FiraMono Nerd Font' },
	{
		family = "FiraCode Nerd Font",
		weight = "Regular",
		harfbuzz_features = {
			-- https://github.com/tonsky/FiraCode/wiki/How-to-enable-stylistic-sets
			"cv04", -- styles: i
			"cv08", -- styles: l
			"cv14", -- styles: r
			"ss04", -- styles: $
		},
	},
	{ family = "NotoSans Nerd Font" },
	{ family = "JetBrains Nerd Font" },
})
config.font_size = font_size

config.warn_about_missing_glyphs = true

config.harfbuzz_features = {
	"kern", -- default kerning
	"liga", -- default ligatures
	"clig", -- default contextual ligatures
}

-- Keybindings
config.leader = { key = "f", mods = "ALT", timeout_milliseconds = 2500 }
config.keys = {
	{ mods = "LEADER", key = "c", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ mods = "LEADER", key = "w", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{ mods = "LEADER", key = "b", action = wezterm.action.ActivateTabRelative(-1) },
	{ mods = "LEADER", key = "n", action = wezterm.action.ActivateTabRelative(1) },
	{ mods = "LEADER", key = ",", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = "LEADER", key = ".", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ mods = "LEADER", key = "h", action = wezterm.action.ActivatePaneDirection("Left") },
	{ mods = "LEADER", key = "j", action = wezterm.action.ActivatePaneDirection("Down") },
	{ mods = "LEADER", key = "k", action = wezterm.action.ActivatePaneDirection("Up") },
	{ mods = "LEADER", key = "l", action = wezterm.action.ActivatePaneDirection("Right") },
	{ mods = "LEADER", key = "LeftArrow", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ mods = "LEADER", key = "DownArrow", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
	{ mods = "LEADER", key = "UpArrow", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ mods = "LEADER", key = "RightArrow", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
}

-- leader + 0-9 to switch tabs
for i = 1, 9 do
	table.insert(config.keys, {
		mods = "LEADER",
		key = tostring(i),
		action = wezterm.action.ActivateTab(i - 1), -- indexed tabs start from 0
	})
end

-- tmux status
wezterm.on("update-right-status", function(window, _)
	local DIVIDER = ""
	local prefix = ""
	local ARROW_FOREGROUND = { Foreground = { Color = color_mantle } }

	leader_is_active = window:leader_is_active()
	if leader_is_active then
		prefix = " " .. wezterm.nerdfonts.md_space_invaders .. " " -- activation icon
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