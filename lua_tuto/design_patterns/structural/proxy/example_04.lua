local load_count = 0
local image = { draw = function(_, name) return "draw:" .. name end }
local proxy = { loaded = false, image = nil }
function proxy:draw(name)
	if not self.loaded then
		load_count = load_count + 1
		self.image = image
		self.loaded = true
	end
	return self.image:draw(name)
end

assert(not proxy.loaded)
assert(proxy:draw("boss") == "draw:boss")
assert(proxy.loaded and load_count == 1)
print(proxy:draw("boss"), load_count)
