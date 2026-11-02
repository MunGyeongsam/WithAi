-- counter_model.lua
-- Model: 상태(value)와 규칙(범위 제한)만 가진다.
-- print 도, io.read 도 모른다. 그래서 어디서든(콘솔/LÖVE/테스트) 재사용된다.

local CounterModel = {}
CounterModel.__index = CounterModel

function CounterModel.new(min, max)
  min = min or 0
  max = max or 10
  assert(min <= max, "min 은 max 보다 클 수 없습니다")
  return setmetatable({ value = min, min = min, max = max }, CounterModel)
end

-- 규칙 위반이면 false 를 돌려줄 뿐, 메시지를 직접 출력하지 않는다.
function CounterModel:increment()
  if self.value >= self.max then
    return false
  end
  self.value = self.value + 1
  return true
end

function CounterModel:decrement()
  if self.value <= self.min then
    return false
  end
  self.value = self.value - 1
  return true
end

function CounterModel:reset()
  self.value = self.min
end

return CounterModel
