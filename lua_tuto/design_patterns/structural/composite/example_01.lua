local function leaf(name)
	return { name = name, draw = function(self) return self.name end }
end

local function group(name, children)
	local result = {
		name = name,
		children = children or {},
		draw = function(self)
			local names = {}
			for _, child in ipairs(self.children) do
				names[#names + 1] = child:draw()
			end
			return table.concat(names, "+")
		end,
		add = function(self, child)
			self.children[#self.children + 1] = child
		end,
		remove = function(self, child)
			for index, current in ipairs(self.children) do
				if current == child then
					table.remove(self.children, index)
					return true
				end
			end
			return false
		end
	}
	return result
end

local enemies = group("enemies", { leaf("slime") })
local root = group("root", { leaf("player"), enemies })
assert(root:draw() == "player+slime")
local boss = leaf("boss")
enemies:add(boss)
assert(root:draw() == "player+slime+boss")
assert(enemies:remove(boss) and root:draw() == "player+slime")
print(root.name, root:draw())
