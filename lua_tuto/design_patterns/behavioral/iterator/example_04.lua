local function pairs_iterator(map)
	local keys = { "hp", "mp" }
	local index = 0
	return function()
		index = index + 1
		local key = keys[index]
		if key then return key, map[key] end
	end
end

local values = {}
for key, value in pairs_iterator({ hp = 10, mp = 5 }) do
	values[#values + 1] = key .. "=" .. value
end

assert(table.concat(values, ",") == "hp=10,mp=5")
print(table.concat(values, ","))
