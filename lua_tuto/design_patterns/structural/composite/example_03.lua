local function leaf(name)
    return { draw = function(self) return self.name end, name = name }
end

local function panel(children)
    return {
        children = children,
        draw = function(self)
            local names = {}
            for _, child in ipairs(self.children) do names[#names + 1] = child:draw() end
            return table.concat(names, "+")
        end
    }
end

local ui = panel({ leaf("button"), panel({ leaf("icon") }) })
assert(ui:draw() == "button+icon")
print(ui:draw())
