local assets = { load = function(_, name) return "asset:" .. name end }
local scene = {}
function scene:start()
	local stage = assets:load("stage")
	return "scene:" .. stage
end

local result = scene:start()
assert(result == "scene:asset:stage")
print(result)
