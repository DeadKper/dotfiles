local utils = {}

---Return deep copy of a table
---@param tbl table
---@return table copy
function utils.deep_copy(tbl)
	local copy = {}
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			copy[key] = utils.deep_copy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function deep_extends(tbl, extend)
	for key, value in pairs(extend) do
		if tbl[key] ~= nil and type(tbl[key]) == "table" then
			deep_extends(tbl[key], value)
		else
			tbl[key] = value
		end
	end
end

---Extends content from a list of tables into the first table
---@param tbl table
---@param ... table
function utils.extends(tbl, ...)
	for _, value in ipairs({ ... }) do
		if value and type(value) == "table" then
			deep_extends(tbl, value)
		end
	end
end

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function utils.basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

return utils
