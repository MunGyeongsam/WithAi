local function range(last)
	local value = 0
	return function()
		value = value + 1
		if value <= last then return value end
	end
end

local values = {}
for value in range(3) do
	values[#values + 1] = value
end

assert(table.concat(values, ",") == "1,2,3")
print(table.concat(values, ","))
