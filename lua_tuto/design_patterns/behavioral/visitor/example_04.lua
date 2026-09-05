local entities = {
	{ name = "A", accept = function(self, visitor) return visitor:visit_player(self) end },
	{ name = "B", accept = function(self, visitor) return visitor:visit_npc(self) end }
}

local names = {}
function names:visit_player(entity) return "P:" .. entity.name end
function names:visit_npc(entity) return "N:" .. entity.name end

local results = {}
for _, entity in ipairs(entities) do results[#results + 1] = entity:accept(names) end
assert(results[1] == "P:A" and results[2] == "N:B")
print(table.concat(results, ","))
