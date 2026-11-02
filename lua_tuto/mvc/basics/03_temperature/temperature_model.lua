-- temperature_model.lua
-- Model: 섭씨 온도 하나를 저장하고, 값이 바뀌면 구독자(listener)에게 알린다 (Observer 패턴).
-- Model 은 "누가" 구독하는지 모른다. 함수 목록만 가지고 있다.

local ABSOLUTE_ZERO = -273.15

local TemperatureModel = {}
TemperatureModel.__index = TemperatureModel

function TemperatureModel.new(celsius)
  return setmetatable({ celsius = celsius or 0, listeners = {} }, TemperatureModel)
end

-- 구독 해제 함수를 돌려준다.
function TemperatureModel:subscribe(listener)
  local listeners = self.listeners
  listeners[#listeners + 1] = listener
  return function()
    for i = #listeners, 1, -1 do
      if listeners[i] == listener then
        table.remove(listeners, i)
      end
    end
  end
end

function TemperatureModel:notify()
  for _, listener in ipairs(self.listeners) do
    listener(self)
  end
end

function TemperatureModel:setCelsius(celsius)
  if type(celsius) ~= "number" then
    return false, "숫자가 아닙니다"
  end
  if celsius < ABSOLUTE_ZERO then
    return false, "절대영도(-273.15°C)보다 낮을 수 없습니다"
  end
  if celsius ~= self.celsius then
    self.celsius = celsius
    self:notify()
  end
  return true
end

function TemperatureModel:setFahrenheit(fahrenheit)
  if type(fahrenheit) ~= "number" then
    return false, "숫자가 아닙니다"
  end
  return self:setCelsius((fahrenheit - 32) * 5 / 9)
end

function TemperatureModel:getFahrenheit()
  return self.celsius * 9 / 5 + 32
end

return TemperatureModel
