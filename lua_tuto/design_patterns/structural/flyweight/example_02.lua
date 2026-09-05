local tiles = {}
local function tile_definition(kind)
	tiles[kind] = tiles[kind] or { kind = kind, solid = kind == "wall" }
	return tiles[kind]
end

local first = { x = 1, y = 2, definition = tile_definition("wall") }
local second = { x = 4, y = 2, definition = tile_definition("wall") }
assert(first.definition == second.definition and first.x ~= second.x)
print(first.definition.solid, first.definition == second.definition)
