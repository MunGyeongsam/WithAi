-- player_model.lua
-- 플레이어 한 명의 상태(체력, 공격력, 장비, 골드)와 규칙(체력 상한, 사망 판정).

local PlayerModel = {}
PlayerModel.__index = PlayerModel

-- def: { name, maxHp, attack }
function PlayerModel.new(def)
  return setmetatable({
    name = def.name or "용사",
    hp = def.maxHp,
    maxHp = def.maxHp,
    baseAttack = def.attack,
    weapon = nil, -- { name, power }
    gold = 0,
  }, PlayerModel)
end

function PlayerModel:getAttack()
  return self.baseAttack + (self.weapon and self.weapon.power or 0)
end

function PlayerModel:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
end

-- 실제로 회복된 양을 돌려준다.
function PlayerModel:heal(amount)
  local before = self.hp
  self.hp = math.min(self.maxHp, self.hp + amount)
  return self.hp - before
end

function PlayerModel:equip(weapon)
  self.weapon = { name = weapon.name, power = weapon.power }
end

function PlayerModel:addGold(amount)
  self.gold = self.gold + amount
end

function PlayerModel:isDead()
  return self.hp <= 0
end

return PlayerModel
