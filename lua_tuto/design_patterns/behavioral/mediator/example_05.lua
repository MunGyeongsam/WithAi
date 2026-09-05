local match = { players = {}, started = false }
function match:register(player)
	self.players[#self.players + 1] = player
	player.match = self
end

function match:set_ready(player)
	player.ready = true
	for _, current in ipairs(self.players) do
		if not current.ready then return false end
	end
	self.started = true
	for _, current in ipairs(self.players) do current:start() end
	return true
end

local function create_player(name)
	local player = { name = name, ready = false, started = false }
	function player:ready_up() return self.match:set_ready(self) end
	function player:start() self.started = true end
	return player
end

local first = create_player("a")
local second = create_player("b")
match:register(first)
match:register(second)
assert(first:ready_up() == false)
assert(second:ready_up() == true)
assert(match.started and first.started and second.started)
print(match.started, first.started, second.started)
