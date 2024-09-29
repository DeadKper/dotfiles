local wezterm = require("wezterm")
-- local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- local config = {
-- 	keys = {
-- 		{
-- 			key = "w",
-- 			mods = "LEADER|ALT",
-- 			action = wezterm.action_callback(function(win, pane)
-- 				resurrect.save_state(resurrect.workspace_state.get_workspace_state())
-- 			end),
-- 		},
-- 		{
-- 			key = "W",
-- 			mods = "LEADER|SHIFT|ALT",
-- 			action = resurrect.window_state.save_window_action(),
-- 		},
-- 		{
-- 			key = "s",
-- 			mods = "LEADER|ALT",
-- 			action = wezterm.action_callback(function(win, pane)
-- 				resurrect.save_state(resurrect.workspace_state.get_workspace_state())
-- 				resurrect.window_state.save_window_action()
-- 			end),
-- 		},
-- 	},
-- }

return {}
