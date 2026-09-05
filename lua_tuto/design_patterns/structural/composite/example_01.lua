local function leaf(name)
	return { name = name, draw = function(self) return self.name end }
end

local function group(name, children)
	return {
		name = name,
		children = children,
		draw = function(self)
			local names = {}
			for _, child in ipairs(self.children) do
				names[#names + 1] = child:draw()
			end
			return table.concat(names, "+")
		end
	}
end

local root = group("root", { leaf("player"), group("enemies", { leaf("slime") }) })
assert(root:draw() == "player+slime")
print(root.name, root:draw())
