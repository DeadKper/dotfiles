local M = {}

M.unix_domains = {
	{
		name = "unix",
	},
}

M.default_gui_startup_args = { "connect", "unix" }

return M
