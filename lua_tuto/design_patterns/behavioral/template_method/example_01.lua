local function run(loader, parser)
	local raw = loader()
	local parsed = parser(raw)
	return parsed
end

local events = {}
local value = run(
	function()
		events[#events + 1] = "load"
		return "42"
	end,
	function(raw)
		events[#events + 1] = "parse"
		return tonumber(raw)
	end
)

assert(value == 42)
assert(events[1] == "load" and events[2] == "parse")
print(value, table.concat(events, "->"))
