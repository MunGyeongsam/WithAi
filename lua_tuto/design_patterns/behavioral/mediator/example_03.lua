local battle = { log = {}, units = {} }
function battle:register(unit)
	self.units[unit.name] = unit
end
function battle:attack(attacker, target_name, damage)
	local target = self.units[target_name]
	if not target then
		return false
	end
	self.log[#self.log + 1] = attacker.name .. " hits " .. target.name
	target:take_damage(damage)
	return true
end

local function create_unit(name, health, mediator)
	local unit = { name = name, health = health }
	function unit:attack(target_name, damage) return mediator:attack(self, target_name, damage) end
	function unit:take_damage(damage) self.health = self.health - damage end
	return unit
end

local hero = create_unit("hero", 100, battle)
local slime = create_unit("slime", 20, battle)
battle:register(hero)
battle:register(slime)
assert(hero:attack("slime", 5))
assert(not hero:attack("missing", 5))
assert(slime.health == 15)
print(battle.log[1], slime.health)
