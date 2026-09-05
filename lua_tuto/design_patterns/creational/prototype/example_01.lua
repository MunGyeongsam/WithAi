local function clone(source)
    local copy = {}
    for key, value in pairs(source) do copy[key] = value end
    return copy
end

local slime_prototype = { kind = "slime", stats = { hp = 20 } }
local enemy = clone(slime_prototype)
enemy.stats = clone(slime_prototype.stats)
enemy.stats.hp = 10

assert(enemy ~= slime_prototype)
assert(enemy.stats ~= slime_prototype.stats)
assert(slime_prototype.stats.hp == 20)
print(enemy.kind, enemy.stats.hp, slime_prototype.stats.hp)
