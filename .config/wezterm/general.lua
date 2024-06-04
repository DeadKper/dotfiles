local wezterm = require("wezterm")
local krbon = require("palette")

wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local M = {}

if wezterm.config_builder then
	M = wezterm.config_builder()
end

M.audible_bell = "Disabled"
M.adjust_window_size_when_changing_font_size = false

-- M.font = wezterm.font({ family = "SauceCodePro Nerd Font" })
M.font_size = 11

M.default_workspace = "main"
M.scrollback_lines = 3000
M.window_close_confirmation = "NeverPrompt"

M.window_decorations = "RESIZE"
M.use_fancy_tab_bar = false
M.tab_bar_at_bottom = true
M.show_new_tab_button_in_tab_bar = false

M.status_update_interval = 1000

local wsl_domains = wezterm.default_wsl_domains()

for _, domain in ipairs(wsl_domains) do
	domain.default_cwd = "~"
end

M.wsl_domains = wsl_domains

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

---@diagnostic disable-next-line:unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
	local title = tostring(tab.tab_index + 1) .. ":" .. tab_title(tab)
	title = string.sub(title, 1, string.len(title) >= 13 and 13 or string.len(title))

	local format = {}

	if tab.tab_index > 0 then
		format[#format + 1] = { Foreground = { Color = krbon.fg0 } }
		format[#format + 1] = { Text = "" }
		format[#format + 1] = "ResetAttributes"
	end

	format[#format + 1] = { Text = " " }
	format[#format + 1] = { Text = title }
	format[#format + 1] = { Text = " " }
	format[#format + 1] = "ResetAttributes"

	return wezterm.format(format)
end)

M.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return M
