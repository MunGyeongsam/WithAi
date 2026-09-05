local sprites = {}
local function sprite(name)
	sprites[name] = sprites[name] or { name = name, texture = "coin.png" }
	return sprites[name]
end

local function create_coin(x, y)
	return { x = x, y = y, sprite = sprite("coin") }
end

local first = create_coin(10, 20)
local second = create_coin(30, 40)
assert(first.sprite == second.sprite)
assert(first.x ~= second.x and first.sprite.name == "coin")
print(first.x, second.x, first.sprite.name)
