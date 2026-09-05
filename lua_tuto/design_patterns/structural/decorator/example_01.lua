local function base(value) return value end
local function with_prefix(action, prefix)
	return function(value)
		return prefix .. action(value)
	end
end

local decorated = with_prefix(base, "HP: ")
assert(base(100) == 100)
local with_suffix = function(action, suffix)
	return function(value)
		return action(value) .. suffix
	end
end

local composed = with_suffix(decorated, "!")
assert(composed(100) == "HP: 100!")
print(composed(100))
