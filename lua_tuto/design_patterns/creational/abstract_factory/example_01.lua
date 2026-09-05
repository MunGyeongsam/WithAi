local dark = {
	button = function() return "dark button" end,
	panel = function() return "dark panel" end
}
local light = {
	button = function() return "light button" end,
	panel = function() return "light panel" end
}

local function build_screen(factory)
	return {
		button = factory.button(),
		panel = factory.panel()
	}
end

local screen = build_screen(dark)
assert(screen.button == "dark button")
assert(screen.panel == "dark panel")
print(screen.button, screen.panel)
