local function connect() return true end
local function send(data) return data end
local network = {}
function network:request(data)
	assert(connect(), "connection failed")
	return send(data)
end

assert(network:request("score") == "score")
print(network:request("score"))
