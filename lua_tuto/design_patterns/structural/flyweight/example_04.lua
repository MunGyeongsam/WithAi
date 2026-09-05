local colors = {}
local function color_definition(code)
	colors[code] = colors[code] or { code = code }
	return colors[code]
end

local first = { x = 2, color = color_definition("red") }
local second = { x = 8, color = color_definition("red") }
assert(first.color == second.color and first.x ~= second.x)
print(first.color.code, first.color == second.color)
