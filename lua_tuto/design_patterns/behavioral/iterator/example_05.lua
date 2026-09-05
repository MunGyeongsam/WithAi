local function filter(list, predicate)
	local index = 0
	return function()
		while index < #list do
			index = index + 1
			if predicate(list[index]) then return list[index] end
		end
	end
end

local even = {}
for value in filter({ 1, 2, 3, 4 }, function(item) return item % 2 == 0 end) do
	even[#even + 1] = value
end

assert(table.concat(even, ",") == "2,4")
print(table.concat(even, ","))
