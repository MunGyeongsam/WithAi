local function update_entity(read_input, move, draw)
	local input = read_input()
	move(input)
	return draw()
end

local x = 0
local result = update_entity(
	function() return 2 end,
	function(value) x = x + value end,
	function() return x end
)

assert(result == 2)
print(result)
