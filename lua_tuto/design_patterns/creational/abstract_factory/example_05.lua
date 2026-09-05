local test_factory = {
	player = function() return { hp = 1 } end,
	enemy = function() return { hp = 1 } end
}
local game_factory = {
	player = function() return { hp = 100 } end,
	enemy = function() return { hp = 50 } end
}

local function create_game(factory)
	return { player = factory.player(), enemy = factory.enemy() }
end

local game = create_game(test_factory)
assert(game.player.hp == 1 and game.enemy.hp == 1)
print(game.player.hp, game.enemy.hp)
