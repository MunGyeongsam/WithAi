local queue = { first = 1, last = 2, [1] = "a", [2] = "b" }
local function values(source)
	local index = source.first - 1
	return function()
		index = index + 1
		if index <= source.last then return source[index] end
	end
end

local next_value = values(queue)
local first, second, done = next_value(), next_value(), next_value()
assert(first == "a" and second == "b" and done == nil)
print(first, second, done)
