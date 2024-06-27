--  __       __                     __
-- |  \  _  |  \                   |  \
-- | ▓▓ / \ | ▓▓ ______  ________ _| ▓▓_    ______   ______  ______ ____
-- | ▓▓/  ▓\| ▓▓/      \|        \   ▓▓ \  /      \ /      \|      \    \
-- | ▓▓  ▓▓▓\ ▓▓  ▓▓▓▓▓▓\\▓▓▓▓▓▓▓▓\▓▓▓▓▓▓ |  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\ ▓▓▓▓▓▓\▓▓▓▓
-- | ▓▓ ▓▓\▓▓\▓▓ ▓▓    ▓▓ /    ▓▓  | ▓▓ __| ▓▓    ▓▓ ▓▓   \▓▓ ▓▓ | ▓▓ | ▓
-- | ▓▓▓▓  \▓▓▓▓ ▓▓▓▓▓▓▓▓/  ▓▓▓▓_  | ▓▓|  \ ▓▓▓▓▓▓▓▓ ▓▓     | ▓▓ | ▓▓ | ▓
-- | ▓▓▓    \▓▓▓\▓▓     \  ▓▓    \  \▓▓  ▓▓\▓▓     \ ▓▓     | ▓▓ | ▓▓ | ▓
--  \▓▓      \▓▓ \▓▓▓▓▓▓▓\▓▓▓▓▓▓▓▓   \▓▓▓▓  \▓▓▓▓▓▓▓\▓▓      \▓▓  \▓▓  \▓

-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local cycle_theme = require("cycle_theme")

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function Scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Gruvbox dark, hard (base16)"
	else
		return "Gruvbox light, hard (base16)"
	end
end

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font("DejaVuSansM Nerd Font")
config.font_size = 12
-- Auto light/dark mode:
-- config.color_scheme = "Gruvbox light, medium (base16)"
config.color_scheme = Scheme_for_appearance(get_appearance())
-- Keybindings
config.keys = {
	{
		key = "t",
		mods = "SUPER|META",
		action = wezterm.action_callback(function(window, pane)
			cycle_theme.theme_switcher(window, pane)
		end),
	},
}
--
-- end config
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

return config
