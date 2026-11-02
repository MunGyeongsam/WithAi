-- inventory_view.lua
-- 가방 내용. 같은 모델이라도 모드에 따라 다르게 보여준다(요약 / 번호 선택). 읽는 모델: inventory

local KIND_TEXT = { potion = "회복", weapon = "공격" }

local InventoryView = { title = "가방" }
InventoryView.__index = InventoryView

function InventoryView.new()
  return setmetatable({}, InventoryView)
end

function InventoryView:lines(game)
  local inv = game.inventory
  if #inv.items == 0 then
    return { string.format("(비어 있음)  0/%d", inv.capacity) }
  end

  if game.mode ~= "inventory" then
    local names = {}
    for i, item in ipairs(inv.items) do
      names[i] = item.name
    end
    return { string.format("%s  %d/%d", table.concat(names, ", "), #inv.items, inv.capacity) }
  end

  local lines = {}
  for i, item in ipairs(inv.items) do
    lines[i] = string.format("%d) %s  (%s +%d)", i, item.name, KIND_TEXT[item.kind] or item.kind, item.power)
  end
  return lines
end

return InventoryView
