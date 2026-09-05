local legacy_input = { getKey = function(_, key) return key == "space" end }
local input = {
	is_pressed = function(key)
		return legacy_input:getKey(key)
	end
}

assert(input.is_pressed("space") == true)
assert(input.is_pressed("enter") == false)
print(input.is_pressed("space"))
