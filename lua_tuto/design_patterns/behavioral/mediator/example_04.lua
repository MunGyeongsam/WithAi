local lobby = { players = {}, messages = {} }
function lobby:join(player)
	self.players[#self.players + 1] = player
	player.lobby = self
end

function lobby:ready(player)
	player.is_ready = true
	self.messages[#self.messages + 1] = player.name .. " ready"
end

local function create_player(name)
	local player = { name = name, is_ready = false }
	function player:join(lobby) lobby:join(self) end
	function player:signal_ready() self.lobby:ready(self) end
	return player
end

local first = create_player("A")
local second = create_player("B")
first:join(lobby)
second:join(lobby)
first:signal_ready()
second:signal_ready()
assert(#lobby.messages == 2)
print(lobby.messages[1], lobby.messages[2])
