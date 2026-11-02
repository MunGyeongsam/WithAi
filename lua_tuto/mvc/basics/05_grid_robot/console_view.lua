-- console_view.lua
-- View: RobotModel 을 ASCII 문자로 그린다.
-- LÖVE2D 로 옮길 때는 이 파일만 love.graphics.rectangle 을 쓰는 View 로 바꾸면 된다.

local ConsoleView = {}
ConsoleView.__index = ConsoleView

function ConsoleView.new(write)
  return setmetatable({ write = write or print }, ConsoleView)
end

function ConsoleView:render(model)
  for y = 1, model.height do
    local cells = {}
    for x = 1, model.width do
      local char
      if x == model.x and y == model.y then
        char = "R"
      elseif x == model.goalX and y == model.goalY then
        char = "G"
      elseif model:isWall(x, y) then
        char = "#"
      else
        char = "."
      end
      cells[#cells + 1] = char
    end
    self.write("  " .. table.concat(cells))
  end
  self.write(string.format("  이동 %d회", model.moves))
end

function ConsoleView:showMessage(message)
  self.write("  ! " .. message)
end

return ConsoleView
