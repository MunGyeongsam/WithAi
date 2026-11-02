-- inventory_controller.lua
-- 가방 모드 입력 담당. "숫자인가?"는 여기서, "그 번호의 아이템이 있는가?"는 Model 에서 판단한다.

local InventoryController = {}
InventoryController.__index = InventoryController

function InventoryController.new()
  return setmetatable({}, InventoryController)
end

function InventoryController:handle(game, input)
  if input == "b" then
    return game:closeInventory()
  end
  local index = tonumber(input)
  if not index then
    return false, "아이템 번호 또는 b 를 입력하세요"
  end
  return game:useItem(index)
end

return InventoryController
