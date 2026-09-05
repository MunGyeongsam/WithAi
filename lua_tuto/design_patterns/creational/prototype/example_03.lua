local sword_prototype = { name = "sword", damage = 12, rarity = "rare" }

local function clone(source)
    local copy = {}
    for key, value in pairs(source) do copy[key] = value end
    return copy
end

local rare_sword = clone(sword_prototype)
rare_sword.name = "flame sword"
assert(sword_prototype.name == "sword" and rare_sword.damage == 12)
print(rare_sword.name, rare_sword.rarity)
