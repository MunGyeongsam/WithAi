-- counter_view.lua
-- View: Model 을 "읽어서" 보여주기만 한다. Model 값을 바꾸지 않는다.
-- 출력 함수(write)를 주입받으므로 테스트에서는 출력을 가로챌 수 있다.

local CounterView = {}
CounterView.__index = CounterView

function CounterView.new(write)
  return setmetatable({ write = write or print }, CounterView)
end

function CounterView:render(model)
  self.write(string.format("[카운터] %d   (범위 %d ~ %d)", model.value, model.min, model.max))
end

function CounterView:showMessage(message)
  self.write("  ! " .. message)
end

return CounterView
