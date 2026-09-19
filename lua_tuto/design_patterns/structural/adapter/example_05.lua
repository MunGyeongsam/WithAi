local degrees = { value = function() return 180 end }
local radians = {
	value = function()
		local value = degrees.value()
		if type(value) ~= "number" then
			return nil, "angle must be a number"
		end
		return math.rad(value)
	end
}
local value, err = radians.value()
assert(not err)
assert(math.abs(value - math.pi) < 0.0001)
print(value)
