-- enemy_model.lua
-- 적 한 마리의 상태. 전투가 시작될 때 데이터(def)로부터 새로 만들어진다.

local EnemyModel = {}
EnemyModel.__index = EnemyModel

-- def: { name, hp, attack, gold }
function EnemyModel.new(def)
  return setmetatable({
    name = def.name,
    hp = def.hp,
    maxHp = def.hp,
    attack = def.attack,
    gold = def.gold or 0,
  }, EnemyModel)
end

function EnemyModel:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
end

function EnemyModel:isDead()
  return self.hp <= 0
end

return EnemyModel
