local old_renderer = { drawRect = function(_, x, y, w, h) return x + y + w + h end }
local renderer = {
	rectangle = function(x, y, width, height)
		return old_renderer:drawRect(x, y, width, height)
	end
}
assert(renderer.rectangle(1, 2, 3, 4) == 10)
print(renderer.rectangle(1, 2, 3, 4))
