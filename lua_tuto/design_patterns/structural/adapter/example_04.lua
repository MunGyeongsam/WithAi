local old_renderer = {
	drawBox = function(_, left, top, right, bottom)
		return left + top + right + bottom
	end
}
local renderer = {
	rectangle = function(x, y, width, height)
		return old_renderer:drawBox(x, y, x + width, y + height)
	end
}
assert(renderer.rectangle(1, 2, 3, 4) == 13)
print(renderer.rectangle(1, 2, 3, 4))
