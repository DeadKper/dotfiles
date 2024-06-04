local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

M.disable_default_key_bindings = true

M.leader = {
	key = "a",
	mods = "CTRL",
	timeout_milliseconds = 900, -- Close enough to update interval
}

M.keys = {
	-- Send C-a when pressing C-a twice
	{ key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "m", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "phys:Space", mods = "LEADER", action = act.ActivateCommandPalette },

	-- Pane keybindings
	{ key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Renaming Tab Title...:" },
			}),
			action = wezterm.action_callback(function(window, pane, line) ---@diagnostic disable-line:unused-local
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Tab keybindings
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "t", mods = "LEADER", action = act.ShowTabNavigator },
	{ key = "P", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "N", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

	{ action = act.CopyTo("Clipboard"), mods = "CTRL|SHIFT", key = "C" },
	{ action = act.PasteFrom("Clipboard"), mods = "CTRL|SHIFT", key = "V" },

	{ action = act.IncreaseFontSize, mods = "CTRL", key = "+" },
	{ action = act.DecreaseFontSize, mods = "CTRL", key = "-" },
	{ action = act.ResetFontSize, mods = "CTRL", key = "0" },

	{ action = act.Nop, mods = "ALT", key = "Enter" },
	{ action = act.ToggleFullScreen, key = "F11" },
}

for i = 1, 10 do
	M.keys[#M.keys + 1] = {
		key = tostring(i % 10),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	}
end

return M
