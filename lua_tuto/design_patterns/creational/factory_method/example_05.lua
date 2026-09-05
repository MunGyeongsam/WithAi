local Creator = {}
function Creator:equip()
    local weapon = self:create_weapon()
    weapon.equipped = true
    return weapon
end

local BowCreator = setmetatable({}, { __index = Creator })
function BowCreator:create_weapon()
    return { kind = "bow", damage = 8, range = 6 }
end

local weapon = BowCreator:equip()
assert(weapon.equipped and weapon.kind == "bow")
print(weapon.kind, weapon.range)
