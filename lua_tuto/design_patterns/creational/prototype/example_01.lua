local slime_prototype = { kind = "slime", stats = { hp = 20 } }
function slime_prototype:clone()
    return {
        kind = self.kind,
        stats = { hp = self.stats.hp }
    }
end

local enemy = slime_prototype:clone()
enemy.stats.hp = 10

assert(enemy ~= slime_prototype)
assert(enemy.stats ~= slime_prototype.stats)
assert(slime_prototype.stats.hp == 20)
print(enemy.kind, enemy.stats.hp, slime_prototype.stats.hp)
