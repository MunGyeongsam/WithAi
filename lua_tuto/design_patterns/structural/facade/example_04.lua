local connected = false
local function connect() return connected end
local function send(data) return data end
local network = {}
function network:request(data)
	if not connect() then
		return nil, "connection failed"
	end
	return send(data)
end

local result, err = network:request("score")
assert(result == nil and err == "connection failed")
connected = true
result, err = network:request("score")
assert(result == "score" and err == nil)
print(result)
