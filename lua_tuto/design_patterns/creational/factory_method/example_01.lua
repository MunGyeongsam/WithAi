local Creator = {}

function Creator:spawn()
    local enemy = self:create_enemy()
    enemy.spawned = true
    return enemy
end

local SlimeCreator = setmetatable({}, { __index = Creator })
function SlimeCreator:create_enemy()
    return { kind = "slime", health = 60 }
end

local BossCreator = setmetatable({}, { __index = Creator })
function BossCreator:create_enemy()
    return { kind = "boss", health = 500 }
end

local enemy = BossCreator:spawn()
assert(enemy.spawned and enemy.kind == "boss")
print(enemy.kind, enemy.health)
