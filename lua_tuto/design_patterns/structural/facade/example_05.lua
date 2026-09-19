local physics = { step = function(_, dt) return dt end }
local collisions = { update = function(_, dt) return dt * 2 end }
local game_state = { update = function(_, physics_time, collision_time) return physics_time + collision_time end }
local world = {}
function world:update(dt)
	local physics_time = physics:step(dt)
	local collision_time = collisions:update(dt)
	return game_state:update(physics_time, collision_time)
end

assert(world:update(0.5) == 1.5)
print(world:update(0.5))
