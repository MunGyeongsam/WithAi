local function item_builder()
	local item = {}
	local builder = {}
	function builder:name(value) item.name = value; return self end
	function builder:damage(value) item.damage = value; return self end
	function builder:build()
		assert(item.name and item.damage, "name and damage are required")
		return { name = item.name, damage = item.damage }
	end
	return builder
end

local sword = item_builder():name("sword"):damage(12):build()
assert(sword.name == "sword" and sword.damage == 12)
print(sword.name, sword.damage)
