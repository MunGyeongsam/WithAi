local legacy_input = { getKey = function(_, key) return key == "space" end }

-- Before: gameplay code is coupled to the legacy method name.
assert(legacy_input:getKey("space") == true)

-- After: gameplay code depends on the Target contract.
local input = {
	is_pressed = function(key)
		return legacy_input:getKey(key)
	end
}

assert(input.is_pressed("space") == true)
assert(input.is_pressed("enter") == false)
print(input.is_pressed("space"))
