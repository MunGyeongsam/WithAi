local function make_handler(name, action, next_handler)
	return {
		name = name,
		handle = function(self, value)
			local result = action(value)
			if result ~= nil then return result end
			if self.next then return self.next:handle(value) end
			return "unhandled"
		end,
		next = next_handler
	}
end

local fallback = make_handler("fallback", function() return "unhandled" end)
local quit = make_handler("quit", function(value)
	if value == "quit" then return "quit" end
end, fallback)
local pause = make_handler("pause", function(value)
	if value == "pause" then return "paused" end
end, quit)

assert(pause:handle("pause") == "paused")
assert(pause:handle("quit") == "quit")
print(pause:handle("unknown"))
