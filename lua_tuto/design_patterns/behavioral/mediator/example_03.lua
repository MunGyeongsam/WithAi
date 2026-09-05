local battle = { log = {} }
function battle:attack(attacker, target, damage)
	self.log[#self.log + 1] = attacker.name .. " hits " .. target.name
	target:take_damage(damage)
end

local function create_unit(name, health, mediator)
	local unit = { name = name, health = health }
	function unit:attack(target, damage) mediator:attack(self, target, damage) end
	function unit:take_damage(damage) self.health = self.health - damage end
	return unit
end

local hero = create_unit("hero", 100, battle)
local slime = create_unit("slime", 20, battle)
hero:attack(slime, 5)
assert(slime.health == 15)
print(battle.log[1], slime.health)
