-- guess_model.lua
-- Model: 숫자 맞히기 게임의 상태(정답, 시도 횟수, 진행 상태)와 규칙.
-- 난수 함수(random)를 주입받는다 → 테스트에서 정답을 고정할 수 있어 결과가 항상 같다.

local GuessModel = {}
GuessModel.__index = GuessModel

-- options: { min, max, maxAttempts, random = function(min, max) return 정수 end }
function GuessModel.new(options)
  options = options or {}
  local self = setmetatable({}, GuessModel)
  self.min = options.min or 1
  self.max = options.max or 100
  self.maxAttempts = options.maxAttempts or 7
  self.random = options.random or function(a, b)
    return math.random(a, b)
  end
  self:restart()
  return self
end

function GuessModel:restart()
  self.secret = self.random(self.min, self.max)
  self.attempts = 0
  self.state = "playing" -- "playing" | "won" | "lost"
  self.history = {}
end

function GuessModel:remaining()
  return self.maxAttempts - self.attempts
end

-- 결과: "low" | "high" | "correct". 규칙 위반이면 nil, 이유.
function GuessModel:guess(number)
  if self.state ~= "playing" then
    return nil, "게임이 끝났습니다. 다시 시작하세요"
  end
  if type(number) ~= "number" then
    return nil, "숫자가 아닙니다"
  end
  if number < self.min or number > self.max then
    return nil, string.format("%d ~ %d 사이 숫자만 가능합니다", self.min, self.max)
  end

  self.attempts = self.attempts + 1
  self.history[#self.history + 1] = number

  local result
  if number < self.secret then
    result = "low"
  elseif number > self.secret then
    result = "high"
  else
    result = "correct"
  end

  if result == "correct" then
    self.state = "won"
  elseif self.attempts >= self.maxAttempts then
    self.state = "lost"
  end
  return result
end

return GuessModel
