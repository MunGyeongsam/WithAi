local function export(data, encode, write)
	local encoded = encode(data)
	return write(encoded)
end

local events = {}
local result = export(
	"score",
	function(value)
		events[#events + 1] = "encode"
		return "json:" .. value
	end,
	function(value)
		events[#events + 1] = "write"
		return "file:" .. value
	end
)

assert(result == "file:json:score")
assert(table.concat(events, "->") == "encode->write")
print(result, table.concat(events, "->"))
