local renderers = {
    text = function(value) return "[TEXT] " .. value end,
    upper = function(value) return string.upper(value) end
}

local renderer_context = { renderer = renderers.text }
function renderer_context:set_renderer(strategy)
    self.renderer = strategy
end
function renderer_context:render(value)
    return self.renderer(value)
end

renderer_context:set_renderer(renderers.upper)
assert(renderer_context:render("hello") == "HELLO")
print(renderer_context:render("hello"))
