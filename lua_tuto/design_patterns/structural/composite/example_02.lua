local function leaf(hp)
    return {
        hp = hp,
        damage = function(self, amount) self.hp = self.hp - amount end
    }
end

local function group(children)
    return {
        children = children,
        damage = function(self, amount)
            for _, child in ipairs(self.children) do child:damage(amount) end
        end
    }
end

local party = group({ leaf(10), leaf(20) })
party:damage(5)
assert(party.children[1].hp == 5 and party.children[2].hp == 15)
print(party.children[1].hp, party.children[2].hp)
