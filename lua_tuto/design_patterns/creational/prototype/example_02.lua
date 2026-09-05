local bullet_prototype = { x = 0, y = 0, speed = 5, damage = 2 }

local function clone(source)
	local copy = {}
	for key, value in pairs(source) do copy[key] = value end
	return copy
end

local bullet = clone(bullet_prototype)
bullet.x, bullet.y = 100, 40
assert(bullet ~= bullet_prototype and bullet.speed == 5)
print(bullet.x, bullet.y, bullet.speed)
