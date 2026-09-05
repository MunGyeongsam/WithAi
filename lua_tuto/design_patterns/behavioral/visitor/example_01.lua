local nodes = {
	{
		hp = 10,
		accept = function(self, visitor) return visitor:visit_enemy(self) end
	},
	{
		value = 5,
		accept = function(self, visitor) return visitor:visit_coin(self) end
	}
}

local visitor = {}
function visitor:visit_enemy(node) return node.hp end
function visitor:visit_coin(node) return node.value end

local results = {}
for _, node in ipairs(nodes) do
	results[#results + 1] = node:accept(visitor)
end

assert(results[1] == 10 and results[2] == 5)
print(table.concat(results, ","))
