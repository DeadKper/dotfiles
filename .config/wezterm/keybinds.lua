local wezterm = require("wezterm")
local action = wezterm.action
local act = action
local deep_copy = require("utils").deep_copy

local config
local repeat_time = 500
local repeat_number = 0

---Add generated key combinations
---@param combinations string|table<string|table> key, array of keys or table with contents to combine with data
---@param data table<string, any> data table to be added to all combinations, it should at least contain `action` field
---@param can_repeat nil|boolean|string wheter or not to create key_table or name o the key_table to make key repeatable
local function gen_keys(combinations, data, can_repeat)
	local repeat_tbl = nil
	if can_repeat then
		if type(can_repeat) == "string" and #can_repeat > 0 then
			repeat_tbl = "repeat_table_" .. can_repeat
		else
			repeat_tbl = string.format("repeat_table_%04d", repeat_number)
			repeat_number = repeat_number + 1
		end

		if config.key_tables == nil then
			config.key_tables = {}
		end
		if config.key_tables[repeat_tbl] == nil then
			config.key_tables[repeat_tbl] = {}
		end

		data.action = action.Multiple({
			data.action,
			action.ActivateKeyTable({
				name = repeat_tbl,
				timeout_milliseconds = repeat_time,
			}),
		})
	end

	if type(combinations) == "string" then
		combinations = { combinations }
	end

	for _, value in pairs(combinations) do
		local tbl = deep_copy(data)
		if type(value) == "table" then
			for key, val in pairs(value) do
				tbl[key] = val
			end
		else
			tbl.key = value
		end

		table.insert(config.keys, tbl)
		if can_repeat then
			local tbl_copy = deep_copy(tbl)
			tbl_copy.mods = tbl_copy.mods:gsub("LEADER", ""):gsub("%|%|", "|"):gsub("^%|", ""):gsub("%|$", "")
			if tbl_copy.mods:len() == 0 then
				tbl_copy.mods = nil
			end
			table.insert(config.key_tables[repeat_tbl], tbl_copy)
		end
	end
end

config = {
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 },
	keys = {
		{ key = "a", mods = "LEADER|CTRL", action = action.SendKey({ key = "a", mods = "CTRL" }) },
		{ key = "c", mods = "LEADER", action = action.SpawnTab("CurrentPaneDomain") },
		{ key = "|", mods = "LEADER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", mods = "LEADER", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "o", mods = "LEADER", action = action.RotatePanes("Clockwise") },
		{ key = "o", mods = "LEADER|CTRL", action = action.ActivateLastTab },
		{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
		{ key = "x", mods = "LEADER", action = action.CloseCurrentPane({ confirm = true }) },
		{ key = "x", mods = "LEADER|CTRL", action = action.CloseCurrentPane({ confirm = false }) },
		{
			key = ",",
			mods = "LEADER",
			action = action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Tab title:" },
				}),
				action = wezterm.action_callback(function(window, pane, line) ---@diagnostic disable-line:unused-local
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{
			key = ";",
			mods = "LEADER|SHIFT",
			action = action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Workspace name:" },
				}),
				action = wezterm.action_callback(function(window, pane, line) ---@diagnostic disable-line:unused-local
					if line then
						wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
					end
				end),
			}),
		},
		{
			key = "s",
			mods = "LEADER",
			action = act.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
		{
			key = "w",
			mods = "LEADER",
			action = act.ShowLauncherArgs({
				flags = "FUZZY|TABS",
			}),
		},
		{
			key = "S",
			mods = "LEADER|SHIFT",
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

		-- need shift because latin american keyboard distribution
		{ key = "[", mods = "LEADER|SHIFT", action = action.ActivateCopyMode },
		{ key = ":", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
	},
}

gen_keys({ "UpArrow", "k" }, { mods = "LEADER", action = action.ActivatePaneDirection("Up") }, "activate_pane")
gen_keys({ "DownArrow", "j" }, { mods = "LEADER", action = action.ActivatePaneDirection("Down") }, "activate_pane")
gen_keys({ "LeftArrow", "h" }, { mods = "LEADER", action = action.ActivatePaneDirection("Left") }, "activate_pane")
gen_keys({ "RightArrow", "l" }, { mods = "LEADER", action = action.ActivatePaneDirection("Right") }, "activate_pane")
gen_keys({ "UpArrow", "k" }, { mods = "LEADER|CTRL", action = action.AdjustPaneSize({ "Up", 2 }) }, "resize_pane")
gen_keys({ "DownArrow", "j" }, { mods = "LEADER|CTRL", action = action.AdjustPaneSize({ "Down", 2 }) }, "resize_pane")
gen_keys({ "LeftArrow", "h" }, { mods = "LEADER|CTRL", action = action.AdjustPaneSize({ "Left", 5 }) }, "resize_pane")
gen_keys({ "RightArrow", "l" }, { mods = "LEADER|CTRL", action = action.AdjustPaneSize({ "Right", 5 }) }, "resize_pane")
gen_keys("p", { mods = "LEADER", action = action.ActivateTabRelative(-1) }, "activate_tab")
gen_keys("n", { mods = "LEADER", action = action.ActivateTabRelative(1) }, "activate_tab")
gen_keys("p", { mods = "LEADER|SHIFT", action = action.MoveTabRelative(-1) }, "move_tab")
gen_keys("n", { mods = "LEADER|SHIFT", action = action.MoveTabRelative(1) }, "move_tab")

for i = 1, 10 do
	config.keys[#config.keys + 1] = {
		key = tostring(i % 10),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	}
end

return config
