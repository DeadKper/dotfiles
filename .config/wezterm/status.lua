local wezterm = require("wezterm")
local palette = require("palette")

local config = {
	tab_max_width = 24,
}

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

local active_color = palette.sky
local hover_color = palette.fg1
local inactive_color = palette.fg3
local background_color = palette.none

local tab_tracker = {
	current = nil,
	previous = nil,
}

---@diagnostic disable-next-line:unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
	local has_unseen_output = false
	for _, pane in ipairs(tab.panes) do
		if pane.has_unseen_output then
			has_unseen_output = true
			break
		end
	end

	local padding = {
		powerline = {
			state = true,
			space = 2,
		},
		spacer = {
			state = true,
			space = 2,
		},
	}

	local function get_padding()
		local pads = 0
		for _, value in pairs(padding) do
			if value.state then
				pads = pads + value.space
			end
		end
		return pads
	end

	local index = tostring(tab.tab_index + 1)
	local title = tab_title(tab):gsub([[^[a-zA-Z]+@[a-zA-Z0-9_.]+: *]], "")
	title = title:gsub([[Copy mode: ]], "")
	title = (has_unseen_output and wezterm.nerdfonts.fa_bell .. " " or "") .. index .. ":" .. title
	title = title:gsub("^%s+", ""):gsub("%s+$", "")

	local pads = get_padding()

	if max_width - pads >= math.min(#title, 7) then
		if #title > max_width - pads then
			title = wezterm.truncate_right(title, max_width - pads - 1) .. "…"
		else
			title = wezterm.truncate_right(title, max_width - pads)
		end
	else
		title = string.format("%0" .. #tostring(#tabs) .. "d", index)
		if #title + pads >= max_width then
			padding.powerline.state = false
		end
		if #title + get_padding() >= max_width then
			padding.spacer.state = false
		end
	end

	if tab_tracker.current == nil then
		tab_tracker.current = tab.tab_index
	end

	local format = {}

	local color
	if tab.is_active then
		color = active_color
		if tab_tracker.current ~= tab.tab_index then
			tab_tracker.previous = tab_tracker.current
			tab_tracker.current = tab.tab_index
		end
	elseif hover then
		color = hover_color
	else
		color = inactive_color
	end

	format[#format + 1] = "ResetAttributes"
	format[#format + 1] = { Foreground = { Color = background_color } }
	format[#format + 1] = { Background = { Color = color } }
	format[#format + 1] = { Attribute = { Intensity = "Bold" } }
	if padding.powerline.state then
		format[#format + 1] = { Text = wezterm.nerdfonts.pl_left_hard_divider }
	end
	if padding.spacer.state then
		format[#format + 1] = { Text = " " }
	end
	if tab_tracker.previous == tab.tab_index then
		format[#format + 1] = { Foreground = { Color = active_color } }
	end
	format[#format + 1] = { Text = title }
	format[#format + 1] = "ResetAttributes"
	format[#format + 1] = { Foreground = { Color = background_color } }
	format[#format + 1] = { Background = { Color = color } }
	if padding.spacer.state then
		format[#format + 1] = { Text = " " }
	end
	format[#format + 1] = { Foreground = { Color = color } }
	format[#format + 1] = { Background = { Color = background_color } }
	if padding.powerline.state then
		format[#format + 1] = { Text = wezterm.nerdfonts.pl_left_hard_divider }
	end

	return wezterm.format(format)
end)

wezterm.on("update-status", function(window, pane)
	local domain = pane:get_domain_name()
	local left_status = window:active_workspace()

	local left_status_color = palette.lavender
	if domain == "local" then
		left_status_color = palette.fg0
	end
	if domain ~= "local" and domain ~= "unix" then
		left_status = domain .. ":" .. left_status
	end
	local leader_color = palette.green
	local keytable_color = palette.blue
	local repeat_color = palette.pink

	if window:active_key_table() then
		local name = window:active_key_table()
		if name:find("^repeat_table_") then
			left_status_color = repeat_color
			left_status = "repeat"
		else
			left_status = window:active_key_table():gsub("_mode", ""):gsub("_", " ")
			left_status_color = keytable_color
		end
	end

	if window:leader_is_active() then
		left_status_color = leader_color
	end
	-- left_status = left_status:upper()

	local basename = function(s)
		-- Nothing a little regex can't fix
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	-- Current working directory
	local cwd = pane:get_current_working_dir()
	if cwd then
		if type(cwd) == "userdata" then
			-- Wezterm introduced the URL object in 20240127-113634-bbcac864
			cwd = basename(cwd.file_path) ---@diagnostic disable-line:undefined-field
		else
			-- 20230712-072601-f4abf8fd or earlier version
			cwd = basename(cwd)
		end
	else
		cwd = ""
	end

	-- Current command
	local cmd = pane:get_foreground_process_name()
	-- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
	cmd = cmd and basename(cmd) or ""

	local date = wezterm.strftime("%d %h")
	-- Time
	local time = wezterm.strftime("%H:%M")

	local use_icons = true

	-- Left status (left of the tab line)
	local left = {}

	left[#left + 1] = { Background = { Color = left_status_color } }
	left[#left + 1] = { Foreground = { Color = palette.bg0 } }
	left[#left + 1] = { Attribute = { Intensity = "Bold" } }
	left[#left + 1] = { Text = " " }
	left[#left + 1] = { Text = (use_icons and wezterm.nerdfonts.cod_terminal_tmux .. " " or "") .. left_status }
	left[#left + 1] = { Foreground = { Color = left_status_color } }
	left[#left + 1] = { Text = " " }
	left[#left + 1] = "ResetAttributes"
	left[#left + 1] = { Foreground = { Color = left_status_color } }
	left[#left + 1] = { Background = { Color = palette.bg2 } }
	left[#left + 1] = { Text = wezterm.nerdfonts.pl_left_hard_divider }

	local handle, _ = io.popen(
		[[
seconds="$(cat /proc/uptime | cut -d ' ' -f 1 | sed 's/\..*//')"
hours="$((seconds/3600))"
minutes="$((seconds-hours*3600))"
minutes="$((minutes/60))"
echo "${hours}h ${minutes}m"
	]],
		"r"
	)
	if handle ~= nil then
		left[#left + 1] = { Attribute = { Intensity = "Bold" } }
		left[#left + 1] = { Foreground = { Color = palette.bg2 } }
		left[#left + 1] = { Text = wezterm.nerdfonts.pl_right_hard_divider }
		left[#left + 1] = { Background = { Color = palette.bg2 } }
		left[#left + 1] = { Foreground = { Color = left_status_color } }
		left[#left + 1] = { Text = (use_icons and wezterm.nerdfonts.fa_power_off .. " " or "") .. handle:read("*l") }
		left[#left + 1] = { Text = " " }
		left[#left + 1] = "ResetAttributes"
		left[#left + 1] = { Foreground = { Color = palette.bg2 } }
		left[#left + 1] = { Background = { Color = palette.none } }
		left[#left + 1] = { Text = wezterm.nerdfonts.pl_left_hard_divider }
		handle:close()
	end

	window:set_left_status(wezterm.format(left))

	local right = {}

	right[#right + 1] = { Foreground = { Color = palette.fg0 } }
	right[#right + 1] = { Background = { Color = palette.none } }
	right[#right + 1] = { Text = (use_icons and wezterm.nerdfonts.md_clock .. " " or "") .. time }
	right[#right + 1] = "ResetAttributes"

	right[#right + 1] = { Foreground = { Color = palette.fg0 } }
	right[#right + 1] = { Background = { Color = palette.none } }
	right[#right + 1] = { Text = " " .. wezterm.nerdfonts.pl_right_soft_divider .. " " }
	right[#right + 1] = { Text = (use_icons and wezterm.nerdfonts.md_calendar .. " " or "") .. date }
	right[#right + 1] = "ResetAttributes"

	handle, _ = io.popen("echo $USER", "r")
	local hostname = wezterm.hostname()
	if handle ~= nil then
		right[#right + 1] = { Background = { Color = palette.none } }
		right[#right + 1] = { Attribute = { Intensity = "Bold" } }
		right[#right + 1] = { Text = " " }
		right[#right + 1] = { Foreground = { Color = palette.bg2 } }
		right[#right + 1] = { Text = wezterm.nerdfonts.pl_right_hard_divider }
		right[#right + 1] = { Background = { Color = palette.bg2 } }
		right[#right + 1] = { Text = " " }
		right[#right + 1] = { Foreground = { Color = left_status_color } }
		local user = handle:read("*l")
		local pane_title = pane:get_title()
		if pane_title:find([[^[^@]+@]]) then
			user = pane_title:match([[^[^@]+]])
			hostname = pane_title:gsub("^[^@]+@", ""):match("^[a-zA-Z0-9_.]+")
		end
		right[#right + 1] = { Text = (use_icons and wezterm.nerdfonts.fa_user .. " " or "") .. user }
		right[#right + 1] = "ResetAttributes"
		handle:close()
	end

	right[#right + 1] = { Background = { Color = palette.none } }
	right[#right + 1] = { Attribute = { Intensity = "Bold" } }
	right[#right + 1] = { Background = { Color = palette.bg2 } }
	right[#right + 1] = { Foreground = { Color = palette.bg2 } }
	right[#right + 1] = { Text = " " }
	right[#right + 1] = { Foreground = { Color = left_status_color } }
	right[#right + 1] = { Text = wezterm.nerdfonts.pl_right_hard_divider }
	right[#right + 1] = { Background = { Color = left_status_color } }
	right[#right + 1] = { Text = " " }
	right[#right + 1] = { Foreground = { Color = palette.bg2 } }
	right[#right + 1] = { Text = (use_icons and wezterm.nerdfonts.fa_server .. " " or "") .. hostname }
	right[#right + 1] = { Text = " " }

	-- Right status
	window:set_right_status(wezterm.format(right))
end)

return config
