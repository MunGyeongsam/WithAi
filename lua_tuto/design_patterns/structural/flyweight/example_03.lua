local fonts = {}
local function font_definition(size)
	fonts[size] = fonts[size] or { size = size, family = "pixel" }
	return fonts[size]
end

local title = { text = "Title", font = font_definition(16) }
local score = { text = "Score", font = font_definition(16) }
assert(title.font == score.font and title.text ~= score.text)
print(title.font.size, title.font == score.font)
