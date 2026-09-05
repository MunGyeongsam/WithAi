local items = { "sword", "potion" }
local function each(list)
	local index = 0
	return function()
		index = index + 1
		return list[index]
	end
end

local next_item = each(items)
local first, second, done = next_item(), next_item(), next_item()
assert(first == "sword" and second == "potion" and done == nil)
print(first, second, done)
