local fantasy = {
	hero = function() return "knight" end,
	enemy = function() return "dragon" end
}
local sci_fi = {
	hero = function() return "pilot" end,
	enemy = function() return "robot" end
}

local function create_world(factory)
	return { hero = factory.hero(), enemy = factory.enemy() }
end

local world = create_world(sci_fi)
assert(world.hero == "pilot" and world.enemy == "robot")
print(world.hero, world.enemy)
