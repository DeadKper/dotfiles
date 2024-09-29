local palette = require("palette")

local config = {
	color_scheme = "Oxocarbon Dark (Gogh)",
	window_background_opacity = 1,
	force_reverse_video_cursor = true,
	inactive_pane_hsb = {
		saturation = 0.6,
		brightness = 0.6,
	},
	colors = {
		tab_bar = {
			background = palette.none,
			new_tab = {
				bg_color = palette.none,
				fg_color = palette.fg1,
			},
			new_tab_hover = {
				bg_color = palette.fg1,
				fg_color = palette.none,
			},
		},
	},
}

return config
