local function leaf()
    return { count = function() return 1 end }
end

local function group(children)
    return {
        children = children,
        count = function(self)
            local total = 1
            for _, child in ipairs(self.children) do total = total + child:count() end
            return total
        end
    }
end

local root = group({ leaf(), group({ leaf(), leaf() }) })
assert(root:count() == 5)
print(root:count())
