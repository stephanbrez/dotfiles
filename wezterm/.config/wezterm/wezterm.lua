--  __       __                     __
-- |  \  _  |  \                   |  \
-- | ▓▓ / \ | ▓▓ ______  ________ _| ▓▓_    ______   ______  ______ ____
-- | ▓▓/  ▓\| ▓▓/      \|        \   ▓▓ \  /      \ /      \|      \    \
-- | ▓▓  ▓▓▓\ ▓▓  ▓▓▓▓▓▓\\▓▓▓▓▓▓▓▓\▓▓▓▓▓▓ |  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\ ▓▓▓▓▓▓\▓▓▓▓
-- | ▓▓ ▓▓\▓▓\▓▓ ▓▓    ▓▓ /    ▓▓  | ▓▓ __| ▓▓    ▓▓ ▓▓   \▓▓ ▓▓ | ▓▓ | ▓
-- | ▓▓▓▓  \▓▓▓▓ ▓▓▓▓▓▓▓▓/  ▓▓▓▓_  | ▓▓|  \ ▓▓▓▓▓▓▓▓ ▓▓     | ▓▓ | ▓▓ | ▓
-- | ▓▓▓    \▓▓▓\▓▓     \  ▓▓    \  \▓▓  ▓▓\▓▓     \ ▓▓     | ▓▓ | ▓▓ | ▓
--  \▓▓      \▓▓ \▓▓▓▓▓▓▓\▓▓▓▓▓▓▓▓   \▓▓▓▓  \▓▓▓▓▓▓▓\▓▓      \▓▓  \▓▓  \▓

-- TODO:
-- update theme switcher for auto light/dark mode
--
-- ╔════════════════════════════════════════════════╗
-- ║  ░█▄█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀█░█░░░█▀█░█▀▀░█░█  ║
-- ║  ░█░█░█▀▀░░█░░█▀█░█░█░█░█░█░█░█░░░█░█░█░█░░█░  ║
-- ║  ░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░  ║
-- ╚════════════════════════════════════════════════╝

-- When using i3 or any other wm, Keybindings with the META key will supercede
-- wezterm's default bindings. Any custom keybindings will use CTRL+SHIFT to
-- match the (very sane) WeZTerm defaults.
--
-- *Shift* is the base for all keybindings
-- *Ctrl+Shift* for all tab, pane and window actions
-- *Ctrl+Shift+Alt* for **editing* things
-- *Alt+Shift* for workspace actions

-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local cycle_theme = require("cycle_theme")
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").dawn
local act = wezterm.action

-- Automatically match schemes based on OS settings
function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function Scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Rosé Pine Moon (base16)"
	else
		return "Rosé Pine Dawn (base16)"
	end
end

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- config.front_end = "WebGpu"
-- Appearance
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_and_split_indices_are_zero_based = true
config.font = wezterm.font("DejaVuSansM Nerd Font")
config.font_size = 12

-- Pane dimming
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.9,
}
-- -- Show active workspaces
-- wezterm.on("update-right-status", function(window, pane)
-- 	window:set_right_status(window:active_workspace())
-- end)
-- Tab bar
wezterm.on("update-right-status", function(window, pane)
	-- The elements to be shown in the tab bar
	local elements = {}

	-- Figure out the cwd and host of the current pane.
	-- This will pick up the hostname for the remote host if your
	-- shell is using OSC 7 on the remote host.
	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri then
		local cwd = ""
		local hostname = ""

		if type(cwd_uri) == "userdata" then
			-- Running on a newer version of wezterm and we have
			-- a URL object here, making this simple!

			cwd = cwd_uri.file_path
			hostname = cwd_uri.host or wezterm.hostname()
		else
			-- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
			-- which doesn't have the Url object
			cwd_uri = cwd_uri:sub(8)
			local slash = cwd_uri:find("/")
			if slash then
				hostname = cwd_uri:sub(1, slash - 1)
				-- and extract the cwd from the uri, decoding %-encoding
				cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
					return string.char(tonumber(hex, 16))
				end)
			end
		end

		-- Remove the domain name portion of the hostname
		local dot = hostname:find("[.]")
		if dot then
			hostname = hostname:sub(1, dot - 1)
		end
		if hostname == "" then
			hostname = wezterm.hostname()
		end

		-- Current command
		local cmd = pane:get_foreground_process_name()
		if cmd then
			cmd = string.gsub(cmd, "(.*[/\\])(.*)", "%2")
			table.insert(elements, { Text = wezterm.nerdfonts.oct_terminal .. " " .. cmd })
			table.insert(elements, { Text = " | " })
		end

		table.insert(elements, { Text = wezterm.nerdfonts.md_folder .. " " .. cwd })
		table.insert(elements, { Text = " | " })
		table.insert(elements, { Text = wezterm.nerdfonts.md_at .. " " .. hostname })
	end

	window:set_right_status(wezterm.format(elements))
end) --
--
--
-- Auto light/dark mode:
config.colors = theme.colors()
-- config.color_scheme = Scheme_for_appearance(get_appearance())

-- Keybindings
config.enable_kitty_keyboard = true
config.keys = {
	-- Tabs
	{
		key = "t",
		mods = "SUPER|META",
		action = wezterm.action_callback(function(window, pane)
			cycle_theme.theme_switcher(window, pane)
		end),
	},
	-- Rename tab
	{
		key = "e",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- Open launcher
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncher },
	-- Panes
	-- Remap pane splitting hotkeys
	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "=",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	-- Workspaces
	-- Show the launcher in fuzzy selection mode and have it list all workspaces
	-- and allow activating one.
	{
		key = "w",
		mods = "ALT|SHIFT",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	},
	-- Prompt for a name to use for a new workspace and switch to it.
	{
		key = "n",
		mods = "ALT|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
	-- Switch to the default workspace
	{
		key = "d",
		mods = "ALT|SHIFT",
		action = act.SwitchToWorkspace({
			name = "default",
		}),
	},
	-- Switch to a neovim workspace, which will have `nvim` launched into it
	{
		key = "c",
		mods = "ALT|SHIFT",
		action = act.SwitchToWorkspace({
			name = "neovim",
			spawn = {
				args = { "nvim" },
			},
		}),
	},
}
--
-- end config

-- Maximize the window on startup
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
