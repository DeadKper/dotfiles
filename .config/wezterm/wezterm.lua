local config = {}

for _, file in ipairs({ "keys", "general", "colors", "status" }) do
	for key, value in pairs(require(file)) do
		config[key] = value
	end
end

return config
