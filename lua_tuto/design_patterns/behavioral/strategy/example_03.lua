local walk = function(x, distance) return x + distance end
local dash = function(x, distance) return x + distance * 2 end

local player = { x = 10, movement = walk }
function player:set_movement(strategy)
    self.movement = strategy
end

function player:move(distance)
    self.x = self.movement(self.x, distance)
end

player:set_movement(dash)
player:move(5)
assert(player.x == 20)
player:set_movement(walk)
player:move(5)
assert(player.x == 25)
print(player.x)
