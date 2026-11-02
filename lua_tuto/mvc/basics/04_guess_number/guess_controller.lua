-- guess_controller.lua
-- Controller: 입력 문자열이 "숫자인지"만 확인(입력 검증)하고 Model 에 넘긴다.
-- "범위 안의 숫자인지"는 게임 규칙이므로 Model 이 판단한다.

local GuessController = {}
GuessController.__index = GuessController

function GuessController.new(model, view)
  return setmetatable({ model = model, view = view }, GuessController)
end

function GuessController:handle(line)
  local model, view = self.model, self.view
  line = (line or ""):match("^%s*(.-)%s*$")

  if line == "quit" then
    return false
  elseif line == "restart" then
    model:restart()
    view:showIntro(model)
    return true
  end

  local number = tonumber(line)
  if not number or number % 1 ~= 0 then
    view:showError("정수를 입력하세요 (또는 restart / quit)")
    return true
  end

  local result, err = model:guess(number)
  if result then
    view:showResult(model, result)
  else
    view:showError(err)
  end
  return true
end

return GuessController
