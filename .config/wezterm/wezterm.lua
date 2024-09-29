local wezterm = require("wezterm")
local utils = require("utils")

LAST_TAB = 0

local config = wezterm.config_builder()

config = {
	-- disable_default_key_bindings = true,
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	font = wezterm.font_with_fallback({
		{
			family = "FiraCode Nerd Font", -- Font with ligatures
			assume_emoji_presentation = false, -- Use unicode form instead of emoji
		},
		{
			family = "FiraCode Nerd Font", -- Same font, this is to prevent ligatures from not displaying in full size
			assume_emoji_presentation = true, -- Use unicode form instead of emoji
		},
	}),
	font_size = 10.5,
	window_padding = {
		left = 5,
		right = 5,
		top = 5,
		bottom = 5,
	},
	enable_tab_bar = true,
	adjust_window_size_when_changing_font_size = false,
	hide_tab_bar_if_only_one_tab = false,
	tab_bar_at_bottom = true,
	scrollback_lines = 10000,
	default_workspace = "home",
	use_fancy_tab_bar = false,
	tab_and_split_indices_are_zero_based = true,
	status_update_interval = 1000,
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "powershell.exe", "-NoLogo" }
	config.launch_menu = { {
		label = "PowerShell",
		args = { "powershell.exe", "-NoLogo" },
	} }
end

for _, file in ipairs({ "keybinds", "status", "colors", "multiplex", "plugins" }) do
	utils.extends(config, require(file))
end

return config
