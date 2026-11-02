-- todo_model.lua
-- Model: 할 일 목록 데이터와 규칙(빈 내용 금지, 번호 범위 확인)을 가진다.
-- 실패하면 (false, 이유) 를 돌려준다. 이유를 "어떻게 보여줄지"는 View 의 몫이다.

local TodoModel = {}
TodoModel.__index = TodoModel

function TodoModel.new()
  return setmetatable({ items = {} }, TodoModel)
end

function TodoModel:add(text)
  text = text and text:match("^%s*(.-)%s*$") or ""
  if text == "" then
    return false, "내용이 비어 있습니다"
  end
  self.items[#self.items + 1] = { text = text, done = false }
  return true
end

function TodoModel:isValidIndex(index)
  return type(index) == "number" and index >= 1 and index <= #self.items
end

function TodoModel:toggle(index)
  if not self:isValidIndex(index) then
    return false, "없는 번호입니다: " .. tostring(index)
  end
  local item = self.items[index]
  item.done = not item.done
  return true
end

function TodoModel:remove(index)
  if not self:isValidIndex(index) then
    return false, "없는 번호입니다: " .. tostring(index)
  end
  table.remove(self.items, index)
  return true
end

function TodoModel:countDone()
  local count = 0
  for _, item in ipairs(self.items) do
    if item.done then
      count = count + 1
    end
  end
  return count
end

return TodoModel
