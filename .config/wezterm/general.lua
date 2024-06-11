local wezterm = require("wezterm")
local krbon = require("palette")

wezterm.on("gui-attached", function(domain) ---@diagnostic disable-line:unused-local
	-- maximize all displayed windows on startup
	local workspace = wezterm.mux.get_active_workspace()
	for _, window in ipairs(wezterm.mux.all_windows()) do
		if window:get_workspace() == workspace then
			window:gui_window():maximize()
		end
	end
end)

local M = {}

M.audible_bell = "Disabled"
M.adjust_window_size_when_changing_font_size = false
M.font = wezterm.font_with_fallback({
	{
		family = "FiraCode Nerd Font",
	},
	{
		family = "FiraCode Nerd Font",
		assume_emoji_presentation = true,
	},
	{
		family = "Noto Emoji",
		assume_emoji_presentation = true,
	},
})
M.font_size = 12
M.tab_max_width = 32
M.hide_tab_bar_if_only_one_tab = true

M.default_workspace = "main"
M.scrollback_lines = 3000
M.window_close_confirmation = "NeverPrompt"

M.window_decorations = "RESIZE"
M.use_fancy_tab_bar = false
M.tab_bar_at_bottom = true
M.show_new_tab_button_in_tab_bar = false
M.status_update_interval = 1000

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

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
	if gpu.backend == "Vulkan" and gpu.device_type == "IntegratedGpu" then
		M.webgpu_preferred_adapter = gpu
		M.front_end = "WebGpu"
		break
	end
end

---@diagnostic disable-next-line:unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
	local title = tostring(tab.tab_index + 1) .. ":" .. tab_title(tab)
	title = string.sub(title, 1, string.len(title) >= M.tab_max_width - 3 and M.tab_max_width - 3 or string.len(title))

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
