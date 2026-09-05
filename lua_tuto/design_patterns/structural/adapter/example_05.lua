local degrees = { value = function() return 180 end }
local radians = {
	value = function()
		return math.rad(degrees.value())
	end
}
local value = radians.value()
assert(math.abs(value - math.pi) < 0.0001)
print(value)
