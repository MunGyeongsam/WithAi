local function save(data) return "save:" .. data end
local function encrypted(action)
	return function(data) return action("encrypted(" .. data .. ")") end
end
local function compressed(action)
	return function(data) return action("compressed(" .. data .. ")") end
end

local decorated = compressed(encrypted(save))
assert(decorated("map") == "save:encrypted(compressed(map))")
print(decorated("map"))
