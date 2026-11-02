-- text_view.lua
-- View 1: 섭씨/화씨 숫자로 보여준다. Model 을 구독해서 값이 바뀌면 스스로 다시 그린다.

local TextView = {}
TextView.__index = TextView

function TextView.new(write)
  return setmetatable({ write = write or print }, TextView)
end

function TextView:attach(model)
  return model:subscribe(function(m)
    self:render(m)
  end)
end

function TextView:render(model)
  self.write(string.format("  [숫자] %.1f°C = %.1f°F", model.celsius, model:getFahrenheit()))
end

return TextView
