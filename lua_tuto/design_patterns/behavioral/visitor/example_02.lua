local shapes = {
	{ radius = 2, accept = function(self, visitor) return visitor:visit_circle(self) end },
	{ side = 3, accept = function(self, visitor) return visitor:visit_square(self) end }
}

local area = {}
function area:visit_circle(shape) return math.pi * shape.radius ^ 2 end
function area:visit_square(shape) return shape.side ^ 2 end

local results = {}
for _, shape in ipairs(shapes) do results[#results + 1] = area and shape:accept(area) end
assert(results[2] == 9)
print(results[1], results[2])
