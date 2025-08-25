local wezterm = require("wezterm")
local mux = wezterm.mux

local config = {
	unix_domains = {
		{
			name = "unix",
		},
	},
	wsl_domains = {
		name = "WSL:Fedora",
		distribution = "Fedora",
	},
	default_domain = "WSL:Fedora",
}

-- Decide whether cmd represents a default startup invocation
local function is_default_startup(cmd)
	if not cmd then
		-- we were started with `wezterm` or `wezterm start` with
		-- no other arguments
		return true
	end
	if (cmd.domain == "DefaultDomain" or cmd.domain == config.default_domain) and not cmd.args then
		-- Launched via `wezterm start --cwd something`
		return true
	end
	-- we were launched some other way
	return false
end

wezterm.on("gui-startup", function(cmd)
	if is_default_startup(cmd) then
		-- for the default startup case, we want to switch to the unix domain instead
		local domain = mux.get_domain(config.default_domain)
		mux.set_default_domain(domain)
		-- ensure that it is attached
		domain:attach() -- this seems to break wezterm
	end
end)

return config
