local function save_file(data) return data end
local function encode(data) return "encoded:" .. data end
local save_system = {}
function save_system:save(data)
	local encoded = encode(data)
	return save_file(encoded)
end

assert(save_system:save("progress") == "encoded:progress")
print(save_system:save("progress"))
