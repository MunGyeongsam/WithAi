local items = {
	{ damage = 10, accept = function(self, visitor) return visitor:visit_weapon(self) end },
	{ defense = 4, accept = function(self, visitor) return visitor:visit_armor(self) end }
}

local describe = {}
function describe:visit_weapon(item) return "damage:" .. item.damage end
function describe:visit_armor(item) return "defense:" .. item.defense end

local results = {}
for _, item in ipairs(items) do results[#results + 1] = item:accept(describe) end
assert(results[1] == "damage:10" and results[2] == "defense:4")
print(table.concat(results, ","))
