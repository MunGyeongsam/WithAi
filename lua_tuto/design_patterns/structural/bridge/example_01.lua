local draw_text = { draw = function(_, text) return "screen:" .. text end }
local draw_console = { draw = function(_, text) return "console:" .. text end }
local label = { renderer = draw_text, text = "HP" }
function label:set_renderer(renderer)
    self.renderer = renderer
end
function label:draw()
	return self.renderer:draw(self.text)
end

local result = label:draw()
assert(result == "screen:HP")
print(result)
label:set_renderer(draw_console)
assert(label:draw() == "console:HP")
print(label:draw())
