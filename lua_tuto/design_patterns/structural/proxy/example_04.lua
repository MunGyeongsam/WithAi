local load_count = 0
local function load_image(name)
	if name == "missing" then return nil, "image not found" end
	return { draw = function(_, image_name) return "draw:" .. image_name end }
end
local proxy = { loaded = false, image = nil }
function proxy:draw(name)
	if not self.loaded then
		load_count = load_count + 1
		local loaded, err = load_image(name)
		if not loaded then return nil, err end
		self.image = loaded
		self.loaded = true
	end
	return self.image:draw(name)
end

assert(not proxy.loaded)
local missing, err = proxy:draw("missing")
assert(missing == nil and err == "image not found" and not proxy.loaded)
assert(proxy:draw("boss") == "draw:boss")
assert(proxy.loaded and load_count == 2)
print(proxy:draw("boss"), load_count)
