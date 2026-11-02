-- inventory_model.lua
-- 아이템 목록과 규칙(최대 개수). 아이템을 "사용하면 무슨 일이 생기는지"는 모른다.
-- 효과 적용은 여러 모델(플레이어 등)을 함께 다뤄야 하므로 GameModel 이 맡는다.

local InventoryModel = {}
InventoryModel.__index = InventoryModel

function InventoryModel.new(capacity)
  return setmetatable({ items = {}, capacity = capacity or 5 }, InventoryModel)
end

function InventoryModel:isFull()
  return #self.items >= self.capacity
end

-- item: { name, kind = "potion" | "weapon", power }
function InventoryModel:add(item)
  if self:isFull() then
    return false, "가방이 가득 찼습니다"
  end
  self.items[#self.items + 1] = { name = item.name, kind = item.kind, power = item.power }
  return true
end

-- 꺼낸 아이템을 돌려준다. 없는 번호면 nil, 이유.
function InventoryModel:take(index)
  if type(index) ~= "number" or not self.items[index] then
    return nil, "없는 아이템 번호입니다: " .. tostring(index)
  end
  return table.remove(self.items, index)
end

return InventoryModel
