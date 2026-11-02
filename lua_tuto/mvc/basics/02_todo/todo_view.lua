-- todo_view.lua
-- View: 목록을 콘솔 문자열로 그린다. Model 을 읽기만 한다.

local TodoView = {}
TodoView.__index = TodoView

function TodoView.new(write)
  return setmetatable({ write = write or print }, TodoView)
end

function TodoView:render(model)
  self.write("---- 할 일 목록 ----")
  if #model.items == 0 then
    self.write("  (할 일이 없습니다)")
  end
  for i, item in ipairs(model.items) do
    local mark = item.done and "x" or " "
    self.write(string.format("  %d. [%s] %s", i, mark, item.text))
  end
  self.write(string.format("  완료 %d / 전체 %d", model:countDone(), #model.items))
end

function TodoView:showError(message)
  self.write("  ! " .. message)
end

function TodoView:showHelp()
  self.write("  명령: add <내용> | done <번호> | del <번호> | list | help | quit")
end

return TodoView
