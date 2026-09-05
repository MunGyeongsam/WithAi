local chat = { participants = {}, messages = {} }

function chat:register(participant)
	self.participants[#self.participants + 1] = participant
end

local function create_player(name, mediator)
	local player = { name = name, received = {} }
	function player:say(message) mediator:send(self, message) end
	function player:receive(sender, message)
		self.received[#self.received + 1] = sender.name .. ":" .. message
	end
	mediator:register(player)
	return player
end

function chat:send(sender, message)
	self.messages[#self.messages + 1] = sender.name .. ":" .. message
	for _, participant in ipairs(self.participants) do
		if participant ~= sender then participant:receive(sender, message) end
	end
end

local player = create_player("player", chat)
local friend = create_player("friend", chat)
player:say("hello")
assert(friend.received[1] == "player:hello")
print(friend.received[1])
