-- temperature_controller.lua
-- Controller: 명령을 해석해 Model 만 호출한다. View 를 전혀 모른다!
-- 화면 갱신은 Model 의 알림(notify)을 받은 View 들이 알아서 한다.
-- 단, 오류 메시지 출력용 함수(onError)는 주입받는다.

local STEP = 5

local TemperatureController = {}
TemperatureController.__index = TemperatureController

function TemperatureController.new(model, onError)
  return setmetatable({ model = model, onError = onError or print }, TemperatureController)
end

function TemperatureController:handle(line)
  local model = self.model
  local command, value = (line or ""):match("^%s*(%S*)%s*(.-)%s*$")
  local ok, err = true, nil

  if command == "c" then
    ok, err = model:setCelsius(tonumber(value))
  elseif command == "f" then
    ok, err = model:setFahrenheit(tonumber(value))
  elseif command == "up" then
    ok, err = model:setCelsius(model.celsius + STEP)
  elseif command == "down" then
    ok, err = model:setCelsius(model.celsius - STEP)
  elseif command == "quit" then
    return false
  else
    ok, err = false, "명령: c <섭씨> | f <화씨> | up | down | quit"
  end

  if not ok then
    self.onError("  ! " .. err)
  end
  return true
end

return TemperatureController
