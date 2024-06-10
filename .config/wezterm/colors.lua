local krbon = require("palette")

local M = {}

-- config.color_scheme = "Tokyo Night"
M.window_background_opacity = 0.9

M.force_reverse_video_cursor = true
M.inactive_pane_hsb = {
	saturation = 0.25,
	brightness = 0.5,
}

M.colors = {
	tab_bar = {
		background = krbon.none,
		active_tab = {
			bg_color = krbon.none,
			fg_color = krbon.fg0,
		},
		inactive_tab = {
			bg_color = krbon.none,
			fg_color = krbon.fg2,
		},
		inactive_tab_hover = {
			bg_color = krbon.none,
			fg_color = krbon.fg1,
			italic = true,
		},
		new_tab = {
			bg_color = krbon.none,
			fg_color = krbon.fg2,
		},
		new_tab_hover = {
			bg_color = krbon.none,
			fg_color = krbon.fg1,
			italic = true,
		},
	},
}

return M
