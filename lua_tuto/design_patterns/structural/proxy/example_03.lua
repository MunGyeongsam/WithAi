local service = { send = function(_, message) return "sent:" .. message end }
local proxy = { online = false, queue = {} }
function proxy:send(message)
	if not self.online then
		self.queue[#self.queue + 1] = message
		return "queued:" .. message
	end
	return service:send(message)
end
function proxy:flush()
	local results = {}
	for _, message in ipairs(self.queue) do results[#results + 1] = service:send(message) end
	self.queue = {}
	return results
end

assert(proxy:send("hello") == "queued:hello")
proxy.online = true
local sent = proxy:flush()
assert(sent[1] == "sent:hello" and #proxy.queue == 0)
print(sent[1])
