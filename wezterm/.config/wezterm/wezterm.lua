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
-- local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").dawn
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
		return "One Light (base16)"
		-- return "Rosé Pine Moon (base16)"
	else
		return "OneDark (base16)"
		-- return "Rosé Pine Dawn (base16)"
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
-- Tab bar
wezterm.on("update-right-status", function(window, pane)
	if not pane then
		return
	end
	
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
-- config.color_scheme = "Everforest Light (Gogh)"
-- config.color_scheme = "Seoulbones_light"
-- config.color_scheme = "Monokai (light) (terminal.sexy)"
-- config.colors = theme.colors()
-- config.color_scheme = Scheme_for_appearance(get_appearance())

-- Default scheme
local default_scheme = "Seoulbones_light"

-- Load SSH themes from separate file (contains sensitive host information)
local host_to_scheme = {}
local ssh_themes_path = wezterm.config_dir .. "/ssh-themes.lua"

-- Try to load SSH themes config
local success, ssh_config = pcall(dofile, ssh_themes_path)
if success and ssh_config and ssh_config.host_to_scheme then
	host_to_scheme = ssh_config.host_to_scheme
	wezterm.log_info("Loaded SSH themes from: " .. ssh_themes_path)
else
	wezterm.log_info("No SSH themes config found at: " .. ssh_themes_path)
	-- This is normal if no sensitive hosts are configured
end

-- Use default SSH domains (creates SSH:hostname and SSHMUX:hostname domains)
config.ssh_domains = wezterm.default_ssh_domains()
for _, dom in ipairs(config.ssh_domains) do
	dom.assume_shell = "Posix"
end
wezterm.log_info("Loaded " .. #config.ssh_domains .. " SSH domains from ~/.ssh/config")

-- Set the global default
config.color_scheme = default_scheme

-- Simplified SSH theme detection
wezterm.on("update-status", function(window, pane)
	local overrides = {}

	-- First check pane's domain name (for SSHMUX: and SSH: domains)
	local domain_name = pane:get_domain_name()
	if domain_name then
		local hostname = domain_name:gsub("^SSH:", ""):gsub("^SSHMUX:", "")
		if hostname ~= domain_name then
			for pattern, scheme in pairs(host_to_scheme) do
				if string.find(hostname, pattern) then
					overrides.color_scheme = scheme
					break
				end
			end
		end
	end

	-- Also check foreground process for direct ssh commands
	if not overrides.color_scheme then
		local fg = pane:get_foreground_process_info() or {}
		if fg.name == "ssh" and fg.argv then
			for _, arg in ipairs(fg.argv) do
				for pattern, scheme in pairs(host_to_scheme) do
					if string.find(arg, pattern) then
						overrides.color_scheme = scheme
						break
					end
				end
				if overrides.color_scheme then
					break
				end
			end
		end
	end

	if not overrides.color_scheme then
		overrides.color_scheme = default_scheme
	end

	window:set_config_overrides(overrides)
end)



-- Keybindings
config.enable_kitty_keyboard = true
config.keys = {
	-- Tabs
	-- {
	-- 	key = "t",
	-- 	mods = "SUPER|META",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		cycle_theme.theme_switcher(window, pane)
	-- 	end),
	-- },
	-- Manual theme switcher (safe binding with ALT)
	{
		key = "T",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action_callback(function(window, pane)
			local current = window:get_config().color_scheme
			local new_scheme = current == "Zenbones_dark" and "Seoulbones_light" or "Zenbones_dark"
			window:set_config_overrides({ color_scheme = new_scheme })
			debug_log("Manual theme switch: " .. current .. " -> " .. new_scheme)
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
		key = "0",
		mods = "ALT|SHIFT",
		action = act.SwitchToWorkspace({
			name = "default",
		}),
	},
	-- Switch to a neovim workspace, which will have `nvim` launched into it
	{
		key = "1",
		mods = "ALT|SHIFT",
		action = act.SwitchToWorkspace({
			name = "neovim",
			spawn = {
				args = { "nvim" },
			},
		}),
	},
	-- SSH Sessions
	-- Connect to SSH domain
	{
		key = "c",
		mods = "ALT|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "SSH Hostname",
			action = wezterm.action_callback(function(window, pane, host)
				if host then
					window:perform_action(wezterm.action.AttachDomain { DomainName = host }, pane)
					if window:active_tab() then
						window:active_tab():set_title(host)
					end
				end
			end),
		}),
	},
	-- Detach from SSH session
	{
		key = "d",
		mods = "ALT|SHIFT",
		action = wezterm.action.DetachDomain "CurrentPaneDomain",
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
