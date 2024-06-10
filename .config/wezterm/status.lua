local wezterm = require("wezterm")
local krbon = require("palette")

local M = {}

wezterm.on("update-status", function(window, pane)
	-- Domain/Workspace name
	local stat = pane:get_domain_name() or window:active_workspace()
	local stat_color = krbon.lavender
	-- It's a little silly to have workspace name all the time
	-- Utilize this to display LDR or current key table name
	if window:active_key_table() then
		stat = window:active_key_table():gsub("_mode", ""):gsub("_", " ")
		stat_color = krbon.blue
	end
	if window:leader_is_active() then
		stat = "leader"
		stat_color = krbon.green
	end
	stat = stat:upper()

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

	local date = wezterm.strftime("%d/%m")
	-- Time
	local time = wezterm.strftime("%H:%M")

	local use_icons = false

	-- Left status (left of the tab line)
	window:set_left_status(wezterm.format({
		{ Background = { Color = stat_color } },
		{ Foreground = { Color = krbon.bg0 } },
		{ Text = " " },
		{ Text = (use_icons and wezterm.nerdfonts.oct_terminal .. "  " or "") .. stat },
		{ Foreground = { Color = stat_color } },
		{ Text = "_" },
		"ResetAttributes",
		{ Foreground = { Color = stat_color } },
		{ Text = wezterm.nerdfonts.pl_left_hard_divider },
	}))

	local right = {}

	local divider = false

	-- if cmd ~= "" then
	-- 	right[#right + 1] = { Foreground = { Color = krbon.pink } }
	-- 	right[#right + 1] = { Text = cmd .. " " .. wezterm.nerdfonts.fa_code .. " " }
	-- 	right[#right + 1] = { Text = " " }
	-- 	right[#right + 1] = "ResetAttributes"
	-- 	divider = true
	-- end

	if cwd ~= "" then
		if divider then
			right[#right + 1] = { Foreground = { Color = krbon.fg0 } }
			right[#right + 1] = { Text = wezterm.nerdfonts.pl_right_soft_divider }
			right[#right + 1] = { Text = " " }
		end
		right[#right + 1] = { Foreground = { Color = krbon.sky } }
		right[#right + 1] = { Text = cwd .. " " .. wezterm.nerdfonts.md_folder .. " " }
		right[#right + 1] = { Background = { Color = krbon.bg2 } }
		right[#right + 1] = "ResetAttributes"
	end

	right[#right + 1] = { Text = " " }
	right[#right + 1] = { Foreground = { Color = krbon.bg2 } }
	right[#right + 1] = { Text = wezterm.nerdfonts.pl_right_hard_divider }
	right[#right + 1] = { Background = { Color = krbon.bg2 } }
	right[#right + 1] = { Text = " " }
	right[#right + 1] = { Foreground = { Color = stat_color } }
	right[#right + 1] = { Text = date .. (use_icons and " " .. wezterm.nerdfonts.md_calendar .. " " or "") }
	right[#right + 1] = "ResetAttributes"

	right[#right + 1] = { Background = { Color = krbon.bg2 } }
	right[#right + 1] = { Foreground = { Color = krbon.bg2 } }
	right[#right + 1] = { Text = " " }
	right[#right + 1] = { Foreground = { Color = stat_color } }
	right[#right + 1] = { Text = wezterm.nerdfonts.pl_right_hard_divider }
	right[#right + 1] = { Background = { Color = stat_color } }
	right[#right + 1] = { Text = " " }
	right[#right + 1] = { Foreground = { Color = krbon.bg2 } }
	right[#right + 1] = { Text = time .. (use_icons and " " .. wezterm.nerdfonts.md_clock .. " " or "") }
	right[#right + 1] = { Text = " " }

	-- Right status
	-- window:set_right_status(wezterm.format(right))
end)

return M
