local score = { submit = function(_, value) return value >= 0 end }
local proxy = {}
function proxy:submit(value)
	if type(value) ~= "number" then return false, "number required" end
	return score:submit(value)
end

local accepted = proxy:submit(100)
local rejected, reason = proxy:submit("bad")
assert(accepted == true and rejected == false and reason == "number required")
print(accepted, rejected, reason)
