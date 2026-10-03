local function update_entity(read_input, move, draw)
	local events = {}
	local input = read_input()
	events[#events + 1] = "input"
	move(input)
	events[#events + 1] = "move"
	local out = draw()
	events[#events + 1] = "draw"
	return out, events
end

local x = 0
local result, events = update_entity(
	function() return 2 end,
	function(value) x = x + value end,
	function() return x end
)

assert(result == 2)
assert(table.concat(events, "->") == "input->move->draw")
print(result, table.concat(events, "->"))
