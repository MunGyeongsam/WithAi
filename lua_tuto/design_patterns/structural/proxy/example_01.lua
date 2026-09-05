local real = { read = function(_, key) return "value:" .. key end }
local proxy = {}
function proxy:read(key)
	assert(key ~= "secret", "access denied")
	return real:read(key)
end

local result = proxy:read("name")
assert(result == "value:name")
print(result)
