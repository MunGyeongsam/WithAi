local function leaf(value)
    return { score = function(self) return self.value end, value = value }
end

local function group(children)
    return {
        children = children,
        score = function(self)
            local total = 0
            for _, child in ipairs(self.children) do total = total + child:score() end
            return total
        end
    }
end

local root = group({ leaf(3), group({ leaf(4), leaf(5) }) })
assert(root:score() == 12)
print(root:score())
