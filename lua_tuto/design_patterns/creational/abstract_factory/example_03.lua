local small = {
	width = function() return 320 end,
	height = function() return 180 end
}
local large = {
	width = function() return 1280 end,
	height = function() return 720 end
}

local function create_screen(factory)
	return { width = factory.width(), height = factory.height() }
end

local screen = create_screen(large)
assert(screen.width == 1280 and screen.height == 720)
print(screen.width, screen.height)
