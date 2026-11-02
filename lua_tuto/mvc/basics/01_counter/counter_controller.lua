-- counter_controller.lua
-- Controller: 사용자 입력(문자열 명령)을 해석해 Model 을 호출하고, View 에 갱신을 요청한다.
-- 입력을 "어디서" 받는지(io.read, 스크립트, 키보드)는 모른다. 명령 문자열만 받는다.

local CounterController = {}
CounterController.__index = CounterController

function CounterController.new(model, view)
  return setmetatable({ model = model, view = view }, CounterController)
end

-- 계속 실행하면 true, 종료 명령이면 false 를 돌려준다.
function CounterController:handle(command)
  local model, view = self.model, self.view

  if command == "+" then
    if not model:increment() then
      view:showMessage("이미 최댓값입니다")
    end
  elseif command == "-" then
    if not model:decrement() then
      view:showMessage("이미 최솟값입니다")
    end
  elseif command == "r" then
    model:reset()
  elseif command == "q" then
    return false
  else
    view:showMessage("알 수 없는 명령: " .. tostring(command) .. "  (+, -, r, q)")
  end

  view:render(model)
  return true
end

return CounterController
