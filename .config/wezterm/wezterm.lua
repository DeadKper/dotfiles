local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

for _, file in ipairs({ "keys", "general", "colors", "status", "multiplex" }) do
	for key, value in pairs(require(file)) do
		config[key] = value
	end
end

return config
